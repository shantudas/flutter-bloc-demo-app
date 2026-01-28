import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../config/app_config.dart';
import '../network/network_info.dart';
import '../storage/secure_storage_service.dart';
import '../storage/settings_storage_service.dart';
import '../storage/local_storage_service.dart';
import '../api/api_client.dart';

// Auth
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Posts
import '../../features/posts/data/datasources/posts_local_data_source.dart';
import '../../features/posts/data/datasources/posts_remote_data_source.dart';
import '../../features/posts/data/repositories/posts_repository_impl.dart';
import '../../features/posts/domain/repositories/posts_repository.dart';
import '../../features/posts/domain/usecases/get_posts_usecase.dart';
import '../../features/posts/presentation/bloc/posts_bloc.dart';

// Splash
import '../../features/splash/presentation/bloc/splash_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies(AppConfig config) async {
  // Register the app configuration
  sl.registerLazySingleton(() => config);
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  sl.registerLazySingleton(() => secureStorage);

  sl.registerLazySingleton(() => Connectivity());

  // Network
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  // Storage Services
  sl.registerLazySingleton(
    () => SecureStorageService(sl()),
  );

  sl.registerLazySingleton(
    () => SettingsStorageService(sl()),
  );

  sl.registerLazySingleton(
    () => LocalStorageService(),
  );

  // Initialize local storage
  await sl<LocalStorageService>().init();

  // API Client
  sl.registerLazySingleton(
    () => ApiClient(
      config: sl(),
      secureStorage: sl(),
      networkInfo: sl(),
    ),
  );

  // ============ Features ============

  // Splash
  sl.registerFactory(
    () => SplashBloc(
      secureStorage: sl(),
      settingsStorage: sl(),
    ),
  );

  // Auth - BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  // Auth - Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Auth - Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      secureStorage: sl(),
      networkInfo: sl(),
    ),
  );

  // Auth - Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  // Posts - BLoC
  sl.registerFactory(
    () => PostsBloc(
      getPostsUseCase: sl(),
    ),
  );

  // Posts - Use Cases
  sl.registerLazySingleton(() => GetPostsUseCase(sl()));

  // Posts - Repository
  sl.registerLazySingleton<PostsRepository>(
    () => PostsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Posts - Data Sources
  sl.registerLazySingleton<PostsRemoteDataSource>(
    () => PostsRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<PostsLocalDataSource>(
    () => PostsLocalDataSourceImpl(sl()),
  );
}

