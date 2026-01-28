import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';
import '../network/network_info.dart';
import 'api_interceptors.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({
    required AppConfig config,
    required SecureStorageService secureStorage,
    required NetworkInfo networkInfo,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(secureStorage, _dio, config.apiBaseUrl),
      LoggingInterceptor(),
      RetryInterceptor(dio: _dio, networkInfo: networkInfo),
    ]);
  }

  Dio get dio => _dio;
}

