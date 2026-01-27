import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:social_app/core/errors/exceptions.dart';
import 'package:social_app/core/errors/failures.dart';
import 'package:social_app/core/network/network_info.dart';
import 'package:social_app/core/storage/secure_storage_service.dart';
import 'package:social_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:social_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:social_app/features/auth/data/models/auth_response_dto.dart';
import 'package:social_app/features/auth/data/models/user_dto.dart';
import 'package:social_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:social_app/features/auth/domain/entities/user.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([
  AuthRemoteDataSource,
  AuthLocalDataSource,
  SecureStorageService,
  NetworkInfo,
])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockSecureStorageService mockSecureStorage;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockSecureStorage = MockSecureStorageService();
    mockNetworkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      secureStorage: mockSecureStorage,
      networkInfo: mockNetworkInfo,
    );
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
    final tUserDto = UserDto(
      id: 1,
      username: tUsername,
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
    );

    test('should check if device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.login(
        username: anyNamed('username'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => tAuthResponseDto);
      when(mockRemoteDataSource.getCurrentUser()).thenAnswer((_) async => tUserDto);
      when(mockSecureStorage.saveTokens(
        accessToken: anyNamed('accessToken'),
        refreshToken: anyNamed('refreshToken'),
      )).thenAnswer((_) async => Future.value());
      when(mockLocalDataSource.cacheUser(any)).thenAnswer((_) async => Future.value());

      // act
      await repository.login(username: tUsername, password: tPassword);

      // assert
      verify(mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return auth response when login is successful', () async {
        // arrange
        when(mockRemoteDataSource.login(
          username: anyNamed('username'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => tAuthResponseDto);
        when(mockRemoteDataSource.getCurrentUser()).thenAnswer((_) async => tUserDto);
        when(mockSecureStorage.saveTokens(
          accessToken: anyNamed('accessToken'),
          refreshToken: anyNamed('refreshToken'),
        )).thenAnswer((_) async => Future.value());
        when(mockLocalDataSource.cacheUser(any)).thenAnswer((_) async => Future.value());

        // act
        final result = await repository.login(username: tUsername, password: tPassword);

        // assert
        verify(mockRemoteDataSource.login(username: tUsername, password: tPassword));
        expect(result, Right(tAuthResponseDto.toEntity()));
      });

      test('should save tokens after successful login', () async {
        // arrange
        when(mockRemoteDataSource.login(
          username: anyNamed('username'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => tAuthResponseDto);
        when(mockRemoteDataSource.getCurrentUser()).thenAnswer((_) async => tUserDto);
        when(mockSecureStorage.saveTokens(
          accessToken: anyNamed('accessToken'),
          refreshToken: anyNamed('refreshToken'),
        )).thenAnswer((_) async => Future.value());
        when(mockLocalDataSource.cacheUser(any)).thenAnswer((_) async => Future.value());

        // act
        await repository.login(username: tUsername, password: tPassword);

        // assert
        verify(mockSecureStorage.saveTokens(
          accessToken: 'test_access_token',
          refreshToken: 'test_refresh_token',
        ));
      });

      test('should cache user data after successful login', () async {
        // arrange
        when(mockRemoteDataSource.login(
          username: anyNamed('username'),
          password: anyNamed('password'),
        )).thenAnswer((_) async => tAuthResponseDto);
        when(mockRemoteDataSource.getCurrentUser()).thenAnswer((_) async => tUserDto);
        when(mockSecureStorage.saveTokens(
          accessToken: anyNamed('accessToken'),
          refreshToken: anyNamed('refreshToken'),
        )).thenAnswer((_) async => Future.value());
        when(mockLocalDataSource.cacheUser(any)).thenAnswer((_) async => Future.value());

        // act
        await repository.login(username: tUsername, password: tPassword);

        // assert
        verify(mockLocalDataSource.cacheUser(tUserDto));
      });

      test('should return ServerFailure when ServerException is thrown', () async {
        // arrange
        when(mockRemoteDataSource.login(
          username: anyNamed('username'),
          password: anyNamed('password'),
        )).thenThrow(ServerException('Login failed'));

        // act
        final result = await repository.login(username: tUsername, password: tPassword);

        // assert
        expect(result, const Left(ServerFailure('Login failed')));
      });

      test('should return NetworkFailure when SocketException is thrown', () async {
        // arrange
        when(mockRemoteDataSource.login(
          username: anyNamed('username'),
          password: anyNamed('password'),
        )).thenThrow(const SocketException(''));

        // act
        final result = await repository.login(username: tUsername, password: tPassword);

        // assert
        expect(result, const Left(NetworkFailure('No internet connection')));
      });
    });

    group('device is offline', () {
      test('should return NetworkFailure when device is offline', () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // act
        final result = await repository.login(username: tUsername, password: tPassword);

        // assert
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, const Left(NetworkFailure('No internet connection')));
      });
    });
  });

  group('logout', () {
    test('should clear tokens and cache', () async {
      // arrange
      when(mockSecureStorage.clearTokens()).thenAnswer((_) async => Future.value());
      when(mockLocalDataSource.clearCache()).thenAnswer((_) async => Future.value());

      // act
      await repository.logout();

      // assert
      verify(mockSecureStorage.clearTokens());
      verify(mockLocalDataSource.clearCache());
    });

    test('should return Right(null) when logout is successful', () async {
      // arrange
      when(mockSecureStorage.clearTokens()).thenAnswer((_) async => Future.value());
      when(mockLocalDataSource.clearCache()).thenAnswer((_) async => Future.value());

      // act
      final result = await repository.logout();

      // assert
      expect(result, const Right(null));
    });

    test('should return CacheFailure when logout fails', () async {
      // arrange
      when(mockSecureStorage.clearTokens()).thenThrow(Exception('Failed to clear'));

      // act
      final result = await repository.logout();

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('Should be left'),
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
    const tUser = User(
      id: 1,
      username: 'testuser',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
    );

    test('should return cached user when available', () async {
      // arrange
      when(mockLocalDataSource.getCachedUser()).thenAnswer((_) async => tUserDto);

      // act
      final result = await repository.getCurrentUser();

      // assert
      verify(mockLocalDataSource.getCachedUser());
      verifyZeroInteractions(mockRemoteDataSource);
      expect(result, const Right(tUser));
    });

    test('should fetch from remote when cache is empty and device is online', () async {
      // arrange
      when(mockLocalDataSource.getCachedUser()).thenAnswer((_) async => null);
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getCurrentUser()).thenAnswer((_) async => tUserDto);
      when(mockLocalDataSource.cacheUser(any)).thenAnswer((_) async => Future.value());

      // act
      final result = await repository.getCurrentUser();

      // assert
      verify(mockRemoteDataSource.getCurrentUser());
      verify(mockLocalDataSource.cacheUser(tUserDto));
      expect(result, const Right(tUser));
    });

    test('should return CacheFailure when no cache and device is offline', () async {
      // arrange
      when(mockLocalDataSource.getCachedUser()).thenAnswer((_) async => null);
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, const Left(CacheFailure('No user data available')));
    });

    test('should return ServerFailure when ServerException is thrown', () async {
      // arrange
      when(mockLocalDataSource.getCachedUser()).thenThrow(ServerException('Error'));

      // act
      final result = await repository.getCurrentUser();

      // assert
      expect(result, const Left(ServerFailure('Error')));
    });
  });

  group('isAuthenticated', () {
    test('should return true when access token exists', () async {
      // arrange
      when(mockSecureStorage.getAccessToken()).thenAnswer((_) async => 'test_token');

      // act
      final result = await repository.isAuthenticated();

      // assert
      expect(result, true);
    });

    test('should return false when access token does not exist', () async {
      // arrange
      when(mockSecureStorage.getAccessToken()).thenAnswer((_) async => null);

      // act
      final result = await repository.isAuthenticated();

      // assert
      expect(result, false);
    });
  });
}

