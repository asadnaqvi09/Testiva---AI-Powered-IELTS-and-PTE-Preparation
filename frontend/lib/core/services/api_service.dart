import 'dart:convert';
import 'package:frontend/core/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  /// From [AppConfig] — set with `--dart-define=API_BASE_URL=...` for devices.
  static String get baseUrl => AppConfig.apiBaseUrl;

  static String get socketBaseUrl {
    final uri = Uri.parse(baseUrl);
    if (uri.hasPort && uri.port != 0) {
      return '${uri.scheme}://${uri.host}:${uri.port}';
    }
    return '${uri.scheme}://${uri.host}';
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> setRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', token);
  }

  static Future<void> persistAuthResponse(Map<String, dynamic> resData) async {
    final access = resData['accessToken']?.toString();
    final refresh = resData['refreshToken']?.toString();
    if (access != null && access.isNotEmpty) {
      await setToken(access);
    }
    if (refresh != null && refresh.isNotEmpty) {
      await setRefreshToken(refresh);
    }
  }

  static Future<void> clearAuthSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('token');
    await prefs.remove('user_data');
    await prefs.remove('saved_password');
  }

  static Future<void> clearToken() async {
    await clearAuthSession();
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<bool> _tryRefreshToken() async {
    final refresh = await getRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;
    try {
      final url = Uri.parse('$baseUrl/auth/refresh-token');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refresh}),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return false;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['success'] != true) return false;
      await persistAuthResponse(data);
      return data['accessToken'] != null;
    } catch (_) {
      return false;
    }
  }

  /// Public wrapper for AuthGate cold-start.
  static Future<bool> tryRefreshPublic() => _tryRefreshToken();

  static Future<void> clearRememberedPassword() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_password');
  }

  static bool _shouldRetryAuth(String endpoint) {
    return !endpoint.startsWith('/auth/refresh-token') &&
        !endpoint.startsWith('/auth/login') &&
        !endpoint.startsWith('/auth/register') &&
        !endpoint.startsWith('/auth/google') &&
        !endpoint.startsWith('/auth/verify-otp');
  }

  static Duration _timeoutFor(String endpoint) {
    if (endpoint.startsWith('/auth/') || endpoint.startsWith('/ai/')) {
      return const Duration(seconds: 20);
    }
    return const Duration(seconds: 10);
  }

  static Future<http.Response> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool retried = false,
    bool skipAuthRetry = false,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();
    final timeout = _timeoutFor(endpoint);
    late http.Response response;
    switch (method) {
      case 'POST':
        response = await http
            .post(url, headers: headers, body: body != null ? jsonEncode(body) : null)
            .timeout(timeout);
        break;
      case 'PUT':
        response = await http
            .put(url, headers: headers, body: body != null ? jsonEncode(body) : null)
            .timeout(timeout);
        break;
      case 'PATCH':
        response = await http.patch(url, headers: headers).timeout(timeout);
        break;
      case 'DELETE':
        response = await http.delete(url, headers: headers).timeout(timeout);
        break;
      default:
        response = await http.get(url, headers: headers).timeout(timeout);
    }
    if (!skipAuthRetry &&
        !retried &&
        response.statusCode == 401 &&
        _shouldRetryAuth(endpoint)) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        return _request(
          method,
          endpoint,
          body: body,
          retried: true,
          skipAuthRetry: skipAuthRetry,
        );
      }
      await clearAuthSession();
    }
    return response;
  }

  static Future<void> logout() async {
    final refresh = await getRefreshToken();
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await _request(
          'POST',
          '/auth/logout',
          body: {'refreshToken': refresh},
          skipAuthRetry: true,
        );
      } catch (_) {}
    }
    await clearAuthSession();
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    try {
      return await _request('POST', endpoint, body: body);
    } catch (e) {
      print('API Error [POST $endpoint]: $e');
      rethrow;
    }
  }

  static Future<http.Response> get(String endpoint) async {
    try {
      return await _request('GET', endpoint);
    } catch (e) {
      print('API Error [GET $endpoint]: $e');
      rethrow;
    }
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    try {
      return await _request('PUT', endpoint, body: body);
    } catch (e) {
      print('API Error [PUT $endpoint]: $e');
      rethrow;
    }
  }

  static Future<http.Response> patch(String endpoint) async {
    try {
      return await _request('PATCH', endpoint);
    } catch (e) {
      print('API Error [PATCH $endpoint]: $e');
      rethrow;
    }
  }

  static Future<http.Response> delete(String endpoint) async {
    try {
      return await _request('DELETE', endpoint);
    } catch (e) {
      print('API Error [DELETE $endpoint]: $e');
      rethrow;
    }
  }
}
