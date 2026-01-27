import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:social_app/core/api/api_client.dart';
import 'package:social_app/core/constants/api_endpoints.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:social_app/features/auth/data/models/auth_response_dto.dart';
import 'package:social_app/features/auth/data/models/user_dto.dart';

import 'auth_remote_data_source_test.mocks.dart';

@GenerateMocks([ApiClient, Dio])
void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;
  late MockDio mockDio;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    dataSource = AuthRemoteDataSourceImpl(mockApiClient);
    when(mockApiClient.dio).thenReturn(mockDio);
  });

  group('login', () {
    const tUsername = 'testuser';
    const tPassword = 'password123';
    final tAuthResponseDto = AuthResponseDto(
      id: 1,
      username: tUsername,
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      accessToken: 'test_access_token',
      refreshToken: 'test_refresh_token',
    );

    final tResponseData = {
      'id': 1,
      'username': tUsername,
      'email': 'test@example.com',
      'firstName': 'Test',
      'lastName': 'User',
      'accessToken': 'test_access_token',
      'refreshToken': 'test_refresh_token',
    };

    test('should perform a POST request with correct endpoint and data', () async {
      // arrange
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: tResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.login),
          ));

      // act
      await dataSource.login(username: tUsername, password: tPassword);

      // assert
      verify(mockDio.post(
        ApiEndpoints.login,
        data: {
          'username': tUsername,
          'password': tPassword,
          'expiresInMins': 60,
        },
      ));
    });

    test('should return AuthResponseDto when the response code is 200', () async {
      // arrange
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
            data: tResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.login),
          ));

      // act
      final result = await dataSource.login(username: tUsername, password: tPassword);

      // assert
      expect(result, tAuthResponseDto);
    });

    test('should throw ServerException when DioException occurs', () async {
      // arrange
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.login),
        response: Response(
          data: {'message': 'Invalid credentials'},
          statusCode: 401,
          requestOptions: RequestOptions(path: ApiEndpoints.login),
        ),
      ));

      // act
      final call = dataSource.login;

      // assert
      expect(
        () => call(username: tUsername, password: tPassword),
        throwsA(isA<ServerException>()),
      );
    });

    test('should throw ServerException with correct message when DioException occurs', () async {
      // arrange
      const errorMessage = 'Invalid credentials';
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.login),
        response: Response(
          data: {'message': errorMessage},
          statusCode: 401,
          requestOptions: RequestOptions(path: ApiEndpoints.login),
        ),
      ));

      // act & assert
      try {
        await dataSource.login(username: tUsername, password: tPassword);
        fail('Should have thrown ServerException');
      } catch (e) {
        expect(e, isA<ServerException>());
        expect((e as ServerException).message, errorMessage);
      }
    });

    test('should throw ServerException when unexpected error occurs', () async {
      // arrange
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenThrow(Exception('Unexpected error'));

      // act
      final call = dataSource.login;

      // assert
      expect(
        () => call(username: tUsername, password: tPassword),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getCurrentUser', () {
    final tUserDto = UserDto(
      id: 1,
      username: 'testuser',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
    );

    final tResponseData = {
      'id': 1,
      'username': 'testuser',
      'email': 'test@example.com',
      'firstName': 'Test',
      'lastName': 'User',
    };

    test('should perform a GET request with correct endpoint', () async {
      // arrange
      when(mockDio.get(any)).thenAnswer((_) async => Response(
            data: tResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.currentUser),
          ));

      // act
      await dataSource.getCurrentUser();

      // assert
      verify(mockDio.get(ApiEndpoints.currentUser));
    });

    test('should return UserDto when the response code is 200', () async {
      // arrange
      when(mockDio.get(any)).thenAnswer((_) async => Response(
            data: tResponseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.currentUser),
          ));

      // act
      final result = await dataSource.getCurrentUser();

      // assert
      expect(result.id, tUserDto.id);
      expect(result.username, tUserDto.username);
      expect(result.email, tUserDto.email);
    });

    test('should throw ServerException when DioException occurs', () async {
      // arrange
      when(mockDio.get(any)).thenThrow(DioException(
        requestOptions: RequestOptions(path: ApiEndpoints.currentUser),
        response: Response(
          data: {'message': 'Unauthorized'},
          statusCode: 401,
          requestOptions: RequestOptions(path: ApiEndpoints.currentUser),
        ),
      ));

      // act
      final call = dataSource.getCurrentUser;

      // assert
      expect(() => call(), throwsA(isA<ServerException>()));
    });
  });
}

