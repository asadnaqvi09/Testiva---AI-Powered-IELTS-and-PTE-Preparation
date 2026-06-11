import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class ApiClient {
  late final Dio _dio;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: false,
    ),
  );

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          _logger.i('=> ${options.method} ${options.uri}\nHeaders: ${options.headers}\nData: ${options.data}');
          
          // Inject Authorization token if available
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('<= [${response.statusCode}] ${response.requestOptions.uri}\nResponse: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          _logger.e('<= [${e.response?.statusCode}] ${e.requestOptions.uri}\nError: ${e.message}\nData: ${e.response?.data}');
          
          if (e.response?.statusCode == 401) {
            // Handle Unauthorized globally here (e.g., clear token, trigger logout)
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('auth_token');
            _logger.w('Token expired or invalid. Unauthorized.');
          }

          return handler.next(e);
        },
      ),
    );
  }

  Dio get instance => _dio;

  // Convenience methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) {
    return _dio.delete(path, data: data, queryParameters: queryParameters);
  }
}
