import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_response_dto.dart';
import '../models/user_dto.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseDto> login({
    required String username,
    required String password,
  });

  Future<UserDto> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthResponseDto> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        ApiEndpoints.login,
        data: {
          'username': username,
          'password': password,
          'expiresInMins': 60,
        },
      );

      return AuthResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to login',
      );
    } catch (e) {
      throw ServerException('Unexpected error occurred');
    }
  }

  @override
  Future<UserDto> getCurrentUser() async {
    try {
      final response = await apiClient.dio.get(ApiEndpoints.currentUser);

      return UserDto.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to get current user',
      );
    } catch (e) {
      throw ServerException('Unexpected error occurred');
    }
  }
}

