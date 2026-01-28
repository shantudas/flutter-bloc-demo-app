import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../../../core/utils/app_logger.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final SecureStorageService secureStorage;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.secureStorage,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AuthResponse>> login({
    required String username,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final authResponse = await remoteDataSource.login(
        username: username,
        password: password,
      );

      AppLogger.debug('AuthResponse: $authResponse');


      // Save tokens
      await secureStorage.saveTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken ?? authResponse.accessToken,
      );

      // Cache user
      final userDto = await remoteDataSource.getCurrentUser();
      await localDataSource.cacheUser(userDto);

      return Right(authResponse.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on SocketException {
      return const Left(NetworkFailure('No internet connection'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await secureStorage.clearTokens();
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to logout: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> refreshToken() async {
    try {
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken == null) {
        return const Left(AuthenticationFailure('No refresh token found'));
      }

      // For DummyJSON, we'll just return the current user with existing token
      final user = await getCurrentUser();
      return user.fold(
        (failure) => Left(failure),
        (userData) async {
          final accessToken = await secureStorage.getAccessToken();
          return Right(AuthResponse(
            user: userData,
            accessToken: accessToken ?? '',
            refreshToken: refreshToken,
          ));
        },
      );
    } catch (e) {
      return Left(AuthenticationFailure('Failed to refresh token: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Try to get from cache first
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }

      // If not in cache, fetch from remote
      if (await networkInfo.isConnected) {
        final user = await remoteDataSource.getCurrentUser();
        await localDataSource.cacheUser(user);
        return Right(user.toEntity());
      }

      return const Left(CacheFailure('No user data available'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await secureStorage.getAccessToken();
    return token != null;
  }
}

