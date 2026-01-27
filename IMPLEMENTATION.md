# Implementation Guide - Flutter Clean Architecture

Complete guide on how this Flutter application is implemented using Clean Architecture, BLoC pattern, and offline-first approach.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Clean Architecture Layers](#clean-architecture-layers)
- [Project Structure](#project-structure)
- [BLoC Pattern](#bloc-pattern)
- [Dependency Injection](#dependency-injection)
- [Storage Strategy](#storage-strategy)
- [API Integration](#api-integration)
- [Data Flow](#data-flow)
- [Auth Feature Deep Dive](#auth-feature-deep-dive)
- [Error Handling](#error-handling)
- [Best Practices](#best-practices)

---

## 🏗️ Architecture Overview

This application implements **Clean Architecture** principles with three distinct layers, ensuring:
- **Separation of Concerns**
- **Testability**
- **Maintainability**
- **Scalability**
- **Framework Independence**

### The Three Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │   Screens   │→ │    BLoC     │→ │  Dependency Injection   │ │
│  │   Widgets   │  │Events/States│  │      (GetIt)            │ │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                       DOMAIN LAYER                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │  Entities   │  │  Use Cases  │  │ Repository Interfaces   │ │
│  │  (Models)   │  │  (Business) │  │     (Contracts)         │ │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘ │
├─────────────────────────────────────────────────────────────────┤
│                        DATA LAYER                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │Repository   │  │Data Sources │  │      Models/DTOs        │ │
│  │Implement    │  │Remote/Local │  │       (JSON)            │ │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Clean Architecture Layers

### 1. Presentation Layer

**Responsibility:** Handle UI and user interactions

**Components:**
- **Pages/Screens:** UI layouts
- **Widgets:** Reusable UI components
- **BLoC:** Business logic components
  - Events: User actions
  - States: UI states
- **Dependency Injection:** Service registration

**Rules:**
- Can depend on Domain layer
- Cannot depend on Data layer
- Communicates with domain via BLoC

**Example Structure:**
```dart
features/auth/presentation/
├── bloc/
│   ├── auth_bloc.dart      # Business logic
│   ├── auth_event.dart     # User actions
│   └── auth_state.dart     # UI states
└── pages/
    └── login_screen.dart   # UI
```

---

### 2. Domain Layer

**Responsibility:** Define business logic and rules (Framework independent)

**Components:**
- **Entities:** Core business models
- **Use Cases:** Business operations
- **Repository Interfaces:** Data contracts
- **Failures:** Error definitions

**Rules:**
- No dependencies on other layers
- Pure Dart code (no Flutter imports)
- Defines contracts (interfaces)

**Example Structure:**
```dart
features/auth/domain/
├── entities/
│   ├── user.dart               # Business entity
│   └── auth_response.dart      # Response entity
├── repositories/
│   └── auth_repository.dart    # Repository contract
└── usecases/
    ├── login_usecase.dart      # Login business logic
    ├── logout_usecase.dart     # Logout business logic
    └── get_current_user_usecase.dart
```

**Entity Example:**
```dart
class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? image;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.image,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [id, username, email, firstName, lastName, image];
}
```

---

### 3. Data Layer

**Responsibility:** Handle data operations (API, Database, Cache)

**Components:**
- **Repository Implementations:** Implement domain contracts
- **Data Sources:**
  - Remote: API calls
  - Local: Database operations
- **Models/DTOs:** JSON serialization
- **Mappers:** Convert DTO ↔ Entity

**Rules:**
- Implements domain repository interfaces
- Handles data from multiple sources
- Maps DTOs to domain entities

**Example Structure:**
```dart
features/auth/data/
├── datasources/
│   ├── auth_remote_data_source.dart  # API calls
│   └── auth_local_data_source.dart   # Cache operations
├── models/
│   ├── user_dto.dart                 # JSON model
│   └── auth_response_dto.dart        # JSON model
└── repositories/
    └── auth_repository_impl.dart     # Repository implementation
```

**DTO Example:**
```dart
@JsonSerializable()
class UserDto {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? image;

  UserDto({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.image,
  });

  // JSON serialization
  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  // Convert to domain entity
  User toEntity() {
    return User(
      id: id,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      image: image,
    );
  }
}
```

---

## 📂 Project Structure

### Core Module

```
lib/core/
├── api/
│   ├── api_client.dart              # Dio setup
│   ├── api_interceptors.dart        # Request/Response interceptors
│   └── api_endpoints.dart           # API URLs
│
├── constants/
│   ├── app_constants.dart           # App-wide constants
│   └── storage_keys.dart            # Storage key constants
│
├── di/
│   └── injection_container.dart     # GetIt DI configuration
│
├── errors/
│   ├── exceptions.dart              # Custom exceptions
│   └── failures.dart                # Failure classes (Left side of Either)
│
├── network/
│   └── network_info.dart            # Connectivity checker
│
├── router/
│   └── app_router.dart              # GoRouter configuration
│
├── storage/
│   ├── secure_storage_service.dart  # flutter_secure_storage wrapper
│   ├── local_storage_service.dart   # Hive wrapper
│   └── settings_storage_service.dart # SharedPreferences wrapper
│
└── utils/
    ├── logger.dart                  # Logging utility
    └── validators.dart              # Input validators
```

### Feature Module Structure

Each feature follows the same clean architecture pattern:

```
features/<feature_name>/
├── data/
│   ├── datasources/
│   │   ├── <feature>_remote_data_source.dart
│   │   └── <feature>_local_data_source.dart
│   ├── models/
│   │   └── <model>_dto.dart
│   └── repositories/
│       └── <feature>_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   └── <entity>.dart
│   ├── repositories/
│   │   └── <feature>_repository.dart
│   └── usecases/
│       ├── <operation>_usecase.dart
│       └── ...
│
└── presentation/
    ├── bloc/
    │   ├── <feature>_bloc.dart
    │   ├── <feature>_event.dart
    │   └── <feature>_state.dart
    ├── pages/
    │   └── <screen>.dart
    └── widgets/
        └── <widget>.dart
```

---

## 🔄 BLoC Pattern

### What is BLoC?

**Business Logic Component** - A design pattern for managing state in Flutter applications.

### Key Concepts

1. **Events:** User actions/triggers
2. **States:** UI states
3. **BLoC:** Processes events and emits states

### BLoC Flow

```
User Interaction (UI)
        ↓
    Add Event
        ↓
    ┌─────────┐
    │  BLoC   │ ← Use Cases (Domain Layer)
    └─────────┘
        ↓
   Emit State
        ↓
   Update UI
```

### BLoC Implementation Example

**1. Define Events:**
```dart
// auth_event.dart
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  const AuthLoginRequested({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}
```

**2. Define States:**
```dart
// auth_state.dart
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}
```

**3. Implement BLoC:**
```dart
// auth_bloc.dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginUseCase(
      LoginParams(
        username: event.username,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (authResponse) => emit(AuthAuthenticated(authResponse.user)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await logoutUseCase();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await getCurrentUserUseCase();

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
```

**4. Use in UI:**
```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Navigate to home
          context.go('/home');
        } else if (state is AuthError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return LoginForm(
          onSubmit: (username, password) {
            context.read<AuthBloc>().add(
              AuthLoginRequested(
                username: username,
                password: password,
              ),
            );
          },
        );
      },
    );
  }
}
```

---

## 💉 Dependency Injection

### Why GetIt?

- Service locator pattern
- Easy to test
- No code generation needed
- Lazy and factory registration

### Setup (injection_container.dart)

```dart
final sl = GetIt.instance;

Future<void> init() async {
  // ===== Features =====
  
  // Auth BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  // Auth Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      secureStorage: sl(),
      networkInfo: sl(),
    ),
  );

  // Auth Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  // ===== Core =====
  
  // API Client
  sl.registerLazySingleton(() => ApiClient(sl()));
  
  // Storage Services
  sl.registerLazySingleton(() => SecureStorageService());
  sl.registerLazySingleton(() => LocalStorageService());
  sl.registerLazySingleton(() => SettingsStorageService());
  
  // Network Info
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(Connectivity()),
  );

  // External
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => Connectivity());
}
```

### Usage in main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize DI
  await init();
  
  // Initialize storage
  await sl<LocalStorageService>().init();
  await sl<SettingsStorageService>().init();
  
  runApp(MyApp());
}
```

### Usage in Widgets

```dart
// Provide BLoC
BlocProvider(
  create: (context) => sl<AuthBloc>(),
  child: LoginScreen(),
)

// Access from context
context.read<AuthBloc>().add(AuthLoginRequested(...));
```

---

## 💾 Storage Strategy

### Three Types of Storage

#### 1. Secure Storage (flutter_secure_storage)

**Purpose:** Store sensitive data (tokens, credentials)

**Implementation:**
```dart
class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
```

**Use Cases:**
- JWT tokens
- API keys
- User credentials

---

#### 2. Local Storage (Hive)

**Purpose:** Offline data caching (posts, users, comments)

**Implementation:**
```dart
class LocalStorageService {
  late Box usersBox;
  late Box postsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    usersBox = await Hive.openBox('users');
    postsBox = await Hive.openBox('posts');
  }

  // Cache operations
  Future<void> cacheUser(Map<String, dynamic> userData) async {
    await usersBox.put('current_user', userData);
  }

  Map<String, dynamic>? getCachedUser() {
    return usersBox.get('current_user');
  }

  Future<void> cachePosts(List<Map<String, dynamic>> posts) async {
    await postsBox.put('posts_list', posts);
  }

  List<Map<String, dynamic>>? getCachedPosts() {
    final data = postsBox.get('posts_list');
    if (data != null) {
      return List<Map<String, dynamic>>.from(data);
    }
    return null;
  }

  Future<void> clearCache() async {
    await usersBox.clear();
    await postsBox.clear();
  }
}
```

**Use Cases:**
- Offline data
- Cache API responses
- Large datasets

---

#### 3. Settings Storage (SharedPreferences)

**Purpose:** App settings and simple flags

**Implementation:**
```dart
class SettingsStorageService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Onboarding
  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool('onboarding_completed', value);
  }

  bool isOnboardingCompleted() {
    return _prefs.getBool('onboarding_completed') ?? false;
  }

  // Theme
  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('dark_mode', value);
  }

  bool isDarkMode() {
    return _prefs.getBool('dark_mode') ?? false;
  }

  // Clear settings
  Future<void> clearSettings() async {
    await _prefs.clear();
  }
}
```

**Use Cases:**
- Onboarding status
- Theme preference
- Language selection
- Simple flags

---

## 🌐 API Integration

### API Client Setup

**Dio Configuration:**
```dart
class ApiClient {
  late final Dio dio;

  ApiClient(SecureStorageService secureStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      AuthInterceptor(secureStorage),
      LoggingInterceptor(),
      CacheInterceptor(),
    ]);
  }
}
```

### Interceptors

**1. Auth Interceptor:**
```dart
class AuthInterceptor extends Interceptor {
  final SecureStorageService secureStorage;

  AuthInterceptor(this.secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry original request
        final response = await _retry(err.requestOptions);
        handler.resolve(response);
        return;
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await secureStorage.getRefreshToken();
      // Call refresh token API
      // Save new tokens
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return Dio().request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
```

**2. Logging Interceptor:**
```dart
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    Logger.d('REQUEST[${options.method}] => PATH: ${options.path}');
    Logger.d('Headers: ${options.headers}');
    Logger.d('Data: ${options.data}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Logger.d('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    Logger.d('Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Logger.e('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    Logger.e('Error: ${err.message}');
    handler.next(err);
  }
}
```

### API Endpoints

```dart
class ApiEndpoints {
  static const String baseUrl = 'https://dummyjson.com';

  // Auth
  static const String login = '/auth/login';
  static const String currentUser = '/auth/me';
  static const String refreshToken = '/auth/refresh';

  // Posts
  static const String posts = '/posts';
  static String postDetail(int id) => '/posts/$id';
  static String postsByUser(int userId) => '/posts/user/$userId';

  // Comments
  static String commentsByPost(int postId) => '/posts/$postId/comments';
}
```

---

## 🔄 Data Flow in Clean Architecture

### Complete Data Flow Diagram

```
┌───────────────────────────────────────────────────────────────┐
│                         USER INTERFACE                         │
│                     (Presentation Layer)                       │
└────────────────────────┬──────────────────────────────────────┘
                         │
                         ↓ User Action (e.g., Login Button)
                         │
┌────────────────────────▼──────────────────────────────────────┐
│                      BLoC (Bloc/Cubit)                         │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │ 1. Receive Event (AuthLoginRequested)                    │ │
│  │ 2. Emit Loading State                                    │ │
│  │ 3. Call Use Case                                         │ │
│  └──────────────────────────────────────────────────────────┘ │
└────────────────────────┬──────────────────────────────────────┘
                         │
                         ↓
┌────────────────────────▼──────────────────────────────────────┐
│                      USE CASE                                  │
│                   (Domain Layer)                               │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │ 1. Validate business rules                               │ │
│  │ 2. Call Repository Interface                             │ │
│  │ 3. Return Either<Failure, Success>                       │ │
│  └──────────────────────────────────────────────────────────┘ │
└────────────────────────┬──────────────────────────────────────┘
                         │
                         ↓
┌────────────────────────▼──────────────────────────────────────┐
│                  REPOSITORY IMPL                               │
│                    (Data Layer)                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │ 1. Check network connectivity                            │ │
│  │ 2. Try remote data source (API)                          │ │
│  │ 3. Cache response locally                                │ │
│  │ 4. On error, fallback to local cache                     │ │
│  │ 5. Map DTO to Entity                                     │ │
│  │ 6. Return Either<Failure, Entity>                        │ │
│  └──────────────────────────────────────────────────────────┘ │
└──────────┬────────────────────────────────────┬───────────────┘
           │                                    │
           ↓                                    ↓
┌──────────▼────────────┐          ┌───────────▼──────────────┐
│  REMOTE DATA SOURCE   │          │  LOCAL DATA SOURCE       │
│    (API Client)       │          │      (Cache)             │
│  ┌─────────────────┐  │          │  ┌────────────────────┐ │
│  │ Dio HTTP Call   │  │          │  │ Hive Operations    │ │
│  │ JSON Parsing    │  │          │  │ Get/Set/Delete     │ │
│  │ Error Handling  │  │          │  │ Return DTO         │ │
│  └─────────────────┘  │          │  └────────────────────┘ │
└───────────────────────┘          └────────────────────────┘
```

### Step-by-Step Flow Example: Login

```
1. USER ACTION
   ↓
   User taps "Login" button

2. PRESENTATION LAYER
   ↓
   LoginScreen captures username/password
   ↓
   Adds event to BLoC:
   context.read<AuthBloc>().add(
     AuthLoginRequested(username: 'emilys', password: 'emilyspass')
   );

3. BLoC PROCESSING
   ↓
   AuthBloc receives AuthLoginRequested event
   ↓
   Emits AuthLoading state (UI shows loading)
   ↓
   Calls LoginUseCase with LoginParams

4. DOMAIN LAYER (Use Case)
   ↓
   LoginUseCase receives parameters
   ↓
   Calls authRepository.login(username, password)
   ↓
   Returns Either<Failure, AuthResponse>

5. DATA LAYER (Repository)
   ↓
   AuthRepositoryImpl.login() is called
   ↓
   Checks network connectivity
   ↓
   If online:
     ├─> Calls AuthRemoteDataSource.login()
     ├─> Gets AuthResponseDto from API
     ├─> Saves tokens to SecureStorage
     ├─> Caches user to LocalStorage
     ├─> Converts DTO to Entity
     └─> Returns Right(AuthResponse)
   ↓
   If offline:
     └─> Returns Left(NetworkFailure)

6. REMOTE DATA SOURCE
   ↓
   Makes POST request to /auth/login
   ↓
   Dio sends request with interceptors:
     - Adds headers
     - Logs request
   ↓
   Receives JSON response
   ↓
   Parses to AuthResponseDto
   ↓
   Returns DTO

7. BACK TO BLoC
   ↓
   BLoC receives Either<Failure, AuthResponse>
   ↓
   If Right (success):
     └─> Emits AuthAuthenticated(user)
   ↓
   If Left (failure):
     └─> Emits AuthError(message)

8. UI UPDATE
   ↓
   BlocBuilder rebuilds UI based on state:
   ↓
   If AuthAuthenticated:
     └─> Navigate to Home screen
   ↓
   If AuthError:
     └─> Show error message
   ↓
   If AuthLoading:
     └─> Show loading indicator
```

---

## 🎯 Auth Feature Deep Dive

Complete architecture diagram and implementation for the Authentication feature.

### Auth Feature Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            PRESENTATION LAYER                                │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │                          LOGIN SCREEN (UI)                             │  │
│  │  ┌─────────────┐  ┌──────────────┐  ┌──────────────────────────────┐ │  │
│  │  │ TextField   │  │   Button     │  │   BlocConsumer<AuthState>    │ │  │
│  │  │ (username)  │  │   (Login)    │  │   - Loading → Spinner        │ │  │
│  │  │ TextField   │  │              │  │   - Error → SnackBar         │ │  │
│  │  │ (password)  │  │              │  │   - Authenticated → Navigate │ │  │
│  │  └─────────────┘  └──────────────┘  └──────────────────────────────┘ │  │
│  └────────────────────────────┬──────────────────────────────────────────┘  │
│                                │                                             │
│                                ↓ add(AuthLoginRequested)                     │
│  ┌────────────────────────────▼──────────────────────────────────────────┐  │
│  │                           AUTH BLOC                                    │  │
│  │                                                                        │  │
│  │  Events:                    States:                                   │  │
│  │  • AuthLoginRequested       • AuthInitial                             │  │
│  │  • AuthLogoutRequested      • AuthLoading                             │  │
│  │  • AuthCheckRequested       • AuthAuthenticated(User)                 │  │
│  │  • AuthUserUpdated          • AuthUnauthenticated                     │  │
│  │                             • AuthError(String)                       │  │
│  │                                                                        │  │
│  │  Dependencies:                                                         │  │
│  │  • LoginUseCase                                                        │  │
│  │  • LogoutUseCase                                                       │  │
│  │  • GetCurrentUserUseCase                                               │  │
│  └────────────────────────────┬──────────────────────────────────────────┘  │
└─────────────────────────────────┼──────────────────────────────────────────┘
                                  │
                                  ↓ call use case
┌─────────────────────────────────▼──────────────────────────────────────────┐
│                              DOMAIN LAYER                                   │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │                          USE CASES                                     │ │
│  │                                                                        │ │
│  │  ┌───────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │ │
│  │  │  LoginUseCase     │  │  LogoutUseCase   │  │GetCurrentUser    │  │ │
│  │  │                   │  │                  │  │   UseCase        │  │ │
│  │  │  call(params)     │  │  call()          │  │  call()          │  │ │
│  │  │  ↓                │  │  ↓               │  │  ↓               │  │ │
│  │  │  repository       │  │  repository      │  │  repository      │  │ │
│  │  │   .login()        │  │   .logout()      │  │   .getCurrentUser│  │ │
│  │  └───────────────────┘  └──────────────────┘  └──────────────────┘  │ │
│  │                                                                        │ │
│  │  Returns: Either<Failure, AuthResponse>                               │ │
│  └────────────────────────────┬──────────────────────────────────────────┘ │
│                                │                                            │
│  ┌────────────────────────────▼──────────────────────────────────────────┐ │
│  │                    REPOSITORY INTERFACE                                │ │
│  │                                                                        │ │
│  │  abstract class AuthRepository {                                      │ │
│  │    Future<Either<Failure, AuthResponse>> login({...});                │ │
│  │    Future<Either<Failure, void>> logout();                            │ │
│  │    Future<Either<Failure, User>> getCurrentUser();                    │ │
│  │    Future<bool> isAuthenticated();                                    │ │
│  │  }                                                                     │ │
│  └────────────────────────────┬──────────────────────────────────────────┘ │
│                                │                                            │
│  ┌────────────────────────────▼──────────────────────────────────────────┐ │
│  │                          ENTITIES                                      │ │
│  │                                                                        │ │
│  │  ┌─────────────────────┐        ┌──────────────────────────────────┐ │ │
│  │  │   User              │        │   AuthResponse                   │ │ │
│  │  │  - id               │        │  - user: User                    │ │ │
│  │  │  - username         │        │  - accessToken: String           │ │ │
│  │  │  - email            │        │  - refreshToken: String          │ │ │
│  │  │  - firstName        │        │                                  │ │ │
│  │  │  - lastName         │        └──────────────────────────────────┘ │ │
│  │  │  - image            │                                              │ │
│  │  └─────────────────────┘                                              │ │
│  └────────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────┬──────────────────────────────────────────┘
                                  │
                                  ↓ implements interface
┌─────────────────────────────────▼──────────────────────────────────────────┐
│                               DATA LAYER                                    │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │                   AUTH REPOSITORY IMPLEMENTATION                       │ │
│  │                                                                        │ │
│  │  login(username, password) {                                          │ │
│  │    1. Check network → networkInfo.isConnected                         │ │
│  │    2. Call remoteDataSource.login()                                   │ │
│  │    3. Save tokens → secureStorage.saveTokens()                        │ │
│  │    4. Get user → remoteDataSource.getCurrentUser()                    │ │
│  │    5. Cache user → localDataSource.cacheUser()                        │ │
│  │    6. Map DTO → Entity                                                │ │
│  │    7. Return Either<Failure, AuthResponse>                            │ │
│  │  }                                                                     │ │
│  │                                                                        │ │
│  │  Dependencies:                                                         │ │
│  │  • AuthRemoteDataSource                                                │ │
│  │  • AuthLocalDataSource                                                 │ │
│  │  • SecureStorageService                                                │ │
│  │  • NetworkInfo                                                         │ │
│  └────────────┬───────────────────────────────────┬─────────────────────┘ │
│               │                                   │                        │
│               ↓                                   ↓                        │
│  ┌────────────▼──────────────────┐  ┌────────────▼───────────────────┐   │
│  │  AUTH REMOTE DATA SOURCE      │  │  AUTH LOCAL DATA SOURCE        │   │
│  │                               │  │                                │   │
│  │  login(username, password) {  │  │  cacheUser(UserDto) {          │   │
│  │    dio.post(                  │  │    localStorageService         │   │
│  │      '/auth/login',           │  │      .usersBox                 │   │
│  │      data: {...}              │  │      .put('user', dto)         │   │
│  │    )                          │  │  }                             │   │
│  │    return AuthResponseDto     │  │                                │   │
│  │  }                            │  │  getCachedUser() {             │   │
│  │                               │  │    return localStorageService  │   │
│  │  getCurrentUser() {           │  │      .usersBox.get('user')     │   │
│  │    dio.get('/auth/me')        │  │  }                             │   │
│  │    return UserDto             │  │                                │   │
│  │  }                            │  │  clearCache() {                │   │
│  │                               │  │    localStorageService         │   │
│  │  Uses: ApiClient (Dio)        │  │      .usersBox.clear()         │   │
│  └───────────────────────────────┘  └────────────────────────────────┘   │
│                                                                            │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │                            MODELS (DTOs)                               │ │
│  │                                                                        │ │
│  │  ┌─────────────────────────────┐    ┌──────────────────────────────┐ │ │
│  │  │  UserDto                     │    │  AuthResponseDto             │ │ │
│  │  │  @JsonSerializable()         │    │  @JsonSerializable()         │ │ │
│  │  │                              │    │                              │ │ │
│  │  │  • fromJson()                │    │  • fromJson()                │ │ │
│  │  │  • toJson()                  │    │  • toJson()                  │ │ │
│  │  │  • toEntity() → User         │    │  • toEntity() → AuthResponse │ │ │
│  │  │  • fromEntity()              │    │                              │ │ │
│  │  └─────────────────────────────┘    └──────────────────────────────┘ │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────┬──────────────────────────────────────────┘
                                  │
                                  ↓
┌─────────────────────────────────▼──────────────────────────────────────────┐
│                          STORAGE & NETWORK                                  │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │                                                                        │ │
│  │  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐   │ │
│  │  │ SecureStorage    │  │ LocalStorage     │  │  NetworkInfo     │   │ │
│  │  │ (Tokens)         │  │ (Hive Cache)     │  │  (Connectivity)  │   │ │
│  │  │                  │  │                  │  │                  │   │ │
│  │  │ • saveTokens()   │  │ • usersBox       │  │ • isConnected    │   │ │
│  │  │ • getToken()     │  │ • postsBox       │  │ • onStatusChange │   │ │
│  │  │ • clearTokens()  │  │ • cacheData()    │  │                  │   │ │
│  │  └──────────────────┘  └──────────────────┘  └──────────────────┘   │ │
│  │                                                                        │ │
│  │  ┌──────────────────────────────────────────────────────────────────┐ │ │
│  │  │                       API CLIENT (Dio)                            │ │ │
│  │  │                                                                   │ │ │
│  │  │  Interceptors:                                                    │ │ │
│  │  │  1. AuthInterceptor → Add Bearer token                           │ │ │
│  │  │  2. LoggingInterceptor → Log requests/responses                  │ │ │
│  │  │  3. CacheInterceptor → Handle offline caching                    │ │ │
│  │  │                                                                   │ │ │
│  │  │  Base URL: https://dummyjson.com                                 │ │ │
│  │  │  Timeout: 30 seconds                                             │ │ │
│  │  └──────────────────────────────────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Auth Flow Sequence

```
┌──────┐         ┌──────┐        ┌──────────┐       ┌────────────┐      ┌─────────┐
│ User │         │  UI  │        │   BLoC   │       │  Use Case  │      │   Repo  │
└───┬──┘         └───┬──┘        └────┬─────┘       └─────┬──────┘      └────┬────┘
    │                │                │                   │                   │
    │  Enter creds   │                │                   │                   │
    ├───────────────>│                │                   │                   │
    │                │                │                   │                   │
    │  Tap Login     │                │                   │                   │
    ├───────────────>│                │                   │                   │
    │                │  Add Event     │                   │                   │
    │                ├───────────────>│                   │                   │
    │                │                │  Call UseCase     │                   │
    │                │                ├──────────────────>│                   │
    │                │                │                   │  Call login()     │
    │                │                │                   ├──────────────────>│
    │                │                │                   │                   │
    │                │                │                   │    Check Network  │
    │                │                │                   │<──────────────────┤
    │                │                │                   │                   │
    │                │                │                   │    API Call       │
    │                │                │                   │<──────────────────┤
    │                │                │                   │                   │
    │                │                │                   │  Save Tokens      │
    │                │                │                   │<──────────────────┤
    │                │                │                   │                   │
    │                │                │                   │  Cache User       │
    │                │                │                   │<──────────────────┤
    │                │                │                   │                   │
    │                │                │  Return Success   │                   │
    │                │                │<──────────────────┤                   │
    │                │                │                   │                   │
    │                │  Emit State    │                   │                   │
    │                │<───────────────┤                   │                   │
    │                │                │                   │                   │
    │  Navigate Home │                │                   │                   │
    │<───────────────┤                │                   │                   │
    │                │                │                   │                   │
```

---

## ⚠️ Error Handling

### Exception Hierarchy

```dart
// exceptions.dart
class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}
```

### Failure Classes

```dart
// failures.dart
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
```

### Error Handling in Repository

```dart
@override
Future<Either<Failure, AuthResponse>> login({
  required String username,
  required String password,
}) async {
  // Check network
  if (!await networkInfo.isConnected) {
    return const Left(NetworkFailure('No internet connection'));
  }

  try {
    // Try API call
    final authResponse = await remoteDataSource.login(
      username: username,
      password: password,
    );

    // Save tokens
    await secureStorage.saveTokens(
      accessToken: authResponse.accessToken,
      refreshToken: authResponse.refreshToken,
    );

    // Cache user
    final userDto = await remoteDataSource.getCurrentUser();
    await localDataSource.cacheUser(userDto);

    // Return success
    return Right(authResponse.toEntity());
    
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
    
  } on SocketException {
    return const Left(NetworkFailure('No internet connection'));
    
  } catch (e) {
    return Left(ServerFailure('Unexpected error: ${e.toString()}'));
  }
}
```

---

## 🎨 Best Practices

### 1. **Separation of Concerns**
- Each layer has a single responsibility
- Domain layer is framework-independent
- Data layer handles all external dependencies

### 2. **Dependency Inversion**
- High-level modules don't depend on low-level modules
- Both depend on abstractions (interfaces)
- Use dependency injection

### 3. **Immutability**
- Use `const` constructors
- Use `@immutable` annotation
- Use Equatable for value comparison

### 4. **Error Handling**
- Use `Either<Failure, Success>` pattern
- Convert exceptions to failures at data layer
- Handle errors gracefully in UI

### 5. **Testing**
- Write tests for each layer
- Mock dependencies
- Test business logic independently

### 6. **Code Organization**
- Group by feature, not by type
- Keep related files together
- Use clear naming conventions

### 7. **State Management**
- Use BLoC for complex features
- Keep BLoCs focused and single-purpose
- Emit immutable states

### 8. **API Integration**
- Use interceptors for common operations
- Handle token refresh automatically
- Implement retry logic

### 9. **Offline Support**
- Cache data locally
- Check network before API calls
- Fallback to cache when offline

### 10. **Security**
- Store tokens securely
- Never log sensitive data
- Validate user input

---

## 📊 Summary

This implementation guide covers:
- ✅ Clean Architecture principles
- ✅ BLoC pattern for state management
- ✅ Dependency injection with GetIt
- ✅ Three-layer storage strategy
- ✅ API integration with Dio
- ✅ Complete data flow
- ✅ Auth feature deep dive with diagrams
- ✅ Error handling patterns
- ✅ Best practices

For testing implementation, see **[TEST_IMPLEMENTATION.md](TEST_IMPLEMENTATION.md)**

---

**Last Updated:** January 27, 2026  
**Version:** 1.0.0

