import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.18.149:5000/api/v1';


  static String? _token;


  static void setToken(String token) {
    _token = token;
  }


  static Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: _getHeaders(),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(
      url,
      headers: _getHeaders(),
    ).timeout(const Duration(seconds: 10));
  }
}