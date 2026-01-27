import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';
import '../network/network_info.dart';
import 'api_interceptors.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient({
    required SecureStorageService secureStorage,
    required NetworkInfo networkInfo,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
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
      AuthInterceptor(secureStorage, _dio),
      LoggingInterceptor(),
      RetryInterceptor(dio: _dio, networkInfo: networkInfo),
    ]);
  }

  Dio get dio => _dio;
}

