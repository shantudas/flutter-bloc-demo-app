import 'dart:math';
import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import '../network/network_info.dart';
import '../utils/app_logger.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final Dio _dio;
  final String _baseUrl;

  AuthInterceptor(this._secureStorage, this._dio, this._baseUrl);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for login endpoint
    if (options.path.contains('/auth/login')) {
      return handler.next(options);
    }

    // Add access token to headers
    final accessToken = await _secureStorage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    AppLogger.debug('AuthInterceptor Error: ${err.message}, status code: ${err.response?.statusCode}');

    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry original request
        try {
          final options = err.requestOptions;
          final accessToken = await _secureStorage.getAccessToken();
          options.headers['Authorization'] = 'Bearer $accessToken';

          final response = await _dio.fetch(options);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '$_baseUrl${ApiEndpoints.refresh}',
        data: {'refreshToken': refreshToken},
      );

      await _secureStorage.saveTokens(
        accessToken: response.data['token'] ?? response.data['accessToken'],
        refreshToken: response.data['refreshToken'] ?? refreshToken,
      );

      return true;
    } catch (e) {
      AppLogger.error('Failed to refresh token', error: e);
      return false;
    }
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug('REQUEST[${options.method}] => PATH: ${options.path}');
    AppLogger.debug('Headers: ${options.headers}');
    if (options.data != null) {
      AppLogger.debug('Data: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      error: err.message,
    );
    handler.next(err);
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final NetworkInfo networkInfo;

  RetryInterceptor({
    required this.dio,
    required this.networkInfo,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only retry on network errors
    if (err.type != DioExceptionType.connectionTimeout &&
        err.type != DioExceptionType.receiveTimeout &&
        err.type != DioExceptionType.unknown) {
      return handler.next(err);
    }

    // Check if we should retry
    final retryCount = err.requestOptions.extra['retry_count'] ?? 0;
    if (retryCount >= AppConstants.maxRetries) {
      return handler.next(err);
    }

    // Check network connectivity
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return handler.next(err);
    }

    // Exponential backoff
    await Future.delayed(Duration(seconds: pow(2, retryCount).toInt()));

    // Retry request
    err.requestOptions.extra['retry_count'] = retryCount + 1;

    try {
      final response = await dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } catch (e) {
      return handler.next(err);
    }
  }
}

