# Flutter Social App - Clean Architecture with BLoC

A production-ready Flutter application demonstrating clean architecture principles with offline-first capabilities, using BLoC for state management and DummyJSON API for backend services.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Setup](#project-setup)
- [Demo Credentials](#demo-credentials)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Documentation](#documentation)
- [License](#license)

---

## 🎯 Overview

This application showcases modern Flutter development practices including:
- **Clean Architecture** with clear separation of concerns
- **Offline-First** approach with local caching
- **BLoC Pattern** for predictable state management
- **Dependency Injection** with GetIt
- **Secure Storage** for authentication tokens
- **Comprehensive Testing** with unit, widget, and BLoC tests

---

## ✨ Features

### 🎬 Implemented Features

#### 1. **Splash Screen**
- App initialization and setup
- Authentication status verification
- Onboarding completion check
- Automatic navigation to appropriate screen

#### 2. **Onboarding**
- Three-page swipeable introduction
- Skip and next navigation
- First-time user experience
- Persistent completion status

#### 3. **Authentication**
- Login with username/password validation
- JWT token-based authentication
- Secure token storage with flutter_secure_storage
- Automatic token refresh via interceptors
- Session management and logout

#### 4. **Posts Feed**
- Infinite scroll pagination
- Pull-to-refresh functionality
- Offline-first data loading
- Modern post card UI
- Error handling with retry mechanism
- Loading and empty states

### 🚀 Future Enhancements

- [ ] Post detail view with comments
- [ ] Create, edit, and delete posts
- [ ] User profile management
- [ ] Search functionality
- [ ] Dark mode support
- [ ] Push notifications
- [ ] Social sharing
- [ ] Analytics integration

---

## 🛠️ Tech Stack

| Category | Technology | Purpose |
|----------|-----------|---------|
| **Framework** | Flutter 3.19+ | Cross-platform UI framework |
| **Language** | Dart 3.3+ | Programming language |
| **State Management** | flutter_bloc 8.1+ | Predictable state container |
| **Networking** | Dio 5.4+ | HTTP client with interceptors |
| **Local Storage** | Hive 2.2+ | NoSQL database for offline data |
| **Secure Storage** | flutter_secure_storage 9.2+ | Encrypted storage for tokens |
| **Settings Storage** | shared_preferences 2.2+ | Key-value storage |
| **Dependency Injection** | get_it 7.7+ | Service locator pattern |
| **Navigation** | go_router 14.2+ | Declarative routing |
| **Functional Programming** | dartz 0.10+ | Either, Option types |
| **Network Status** | connectivity_plus 6.0+ | Network connectivity detection |
| **Code Generation** | build_runner, json_serializable, freezed | Code generation tools |
| **Testing** | mockito, bloc_test, flutter_test | Testing utilities |

---

## 🚀 Project Setup

### Prerequisites

- Flutter SDK >= 3.19.0
- Dart SDK >= 3.3.0
- Android Studio / VS Code with Flutter extensions
- iOS: Xcode 15+ (for iOS development)

### Installation Steps

1. **Clone the repository**
```bash
git clone <repository-url>
cd flutter_bloc
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate code**
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. **Run the app**
```bash
flutter run
```

### Platform-Specific Setup

#### Android
```bash
# Debug build
flutter run --debug

# Release build
flutter build apk --release
flutter build appbundle --release
```

#### iOS
```bash
# Debug build
flutter run --debug

# Release build
flutter build ios --release
```

#### Web
```bash
flutter run -d chrome
flutter build web
```

---

## 🔐 Demo Credentials

Use these credentials to test the login functionality:

**User 1:**
- Username: `emilys`
- Password: `emilyspass`

**User 2:**
- Username: `michaelw`
- Password: `michaelwpass`

> **Note:** These credentials are from the DummyJSON API (https://dummyjson.com/users)

---

## 🏗️ Architecture

This app follows **Clean Architecture** principles with three distinct layers:

```
┌─────────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                     │
│              (UI + BLoC State Management)                │
│   - Screens/Pages       - BLoC (Events/States)          │
│   - Widgets             - Dependency Injection           │
├─────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                        │
│          (Business Logic - Framework Independent)        │
│   - Entities            - Repository Interfaces          │
│   - Use Cases           - Failures                       │
├─────────────────────────────────────────────────────────┤
│                       DATA LAYER                         │
│    (Data Sources, API, Database, Implementations)        │
│   - Repository Impl     - Models/DTOs                    │
│   - Remote Data Source  - Local Data Source             │
│   - API Client          - Mappers                        │
└─────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

**Presentation Layer:**
- UI Components (Screens, Widgets)
- BLoC for state management
- Events and States
- User interactions
- Navigation

**Domain Layer:**
- Business entities
- Use cases (business logic)
- Repository interfaces
- Error handling (Failures)

**Data Layer:**
- Repository implementations
- API communication
- Local database operations
- DTO ↔ Entity mapping
- Caching strategy

---

## 📁 Project Structure

```
lib/
├── core/                           # Core application utilities
│   ├── api/
│   │   ├── api_client.dart        # Dio configuration
│   │   ├── api_interceptors.dart  # Auth, logging, cache interceptors
│   │   └── api_endpoints.dart     # API endpoint constants
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── storage_keys.dart
│   ├── di/
│   │   └── injection_container.dart  # GetIt DI setup
│   ├── errors/
│   │   ├── exceptions.dart        # Custom exceptions
│   │   └── failures.dart          # Failure classes
│   ├── network/
│   │   └── network_info.dart      # Connectivity check
│   ├── router/
│   │   └── app_router.dart        # GoRouter configuration
│   ├── storage/
│   │   ├── secure_storage_service.dart    # Token storage
│   │   ├── local_storage_service.dart     # Hive operations
│   │   └── settings_storage_service.dart  # SharedPreferences
│   └── utils/
│       ├── logger.dart
│       └── validators.dart
│
├── features/                       # Feature modules
│   ├── splash/
│   │   └── presentation/
│   │       ├── bloc/
│   │       └── pages/
│   │
│   ├── onboarding/
│   │   └── presentation/
│   │       └── pages/
│   │
│   ├── auth/                      # Authentication feature
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_data_source.dart
│   │   │   │   └── auth_remote_data_source.dart
│   │   │   ├── models/
│   │   │   │   ├── auth_response_dto.dart
│   │   │   │   └── user_dto.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── auth_response.dart
│   │   │   │   └── user.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── get_current_user_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart
│   │       │   ├── auth_event.dart
│   │       │   └── auth_state.dart
│   │       └── pages/
│   │           └── login_screen.dart
│   │
│   └── posts/                     # Posts feed feature
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       └── presentation/
│           ├── bloc/
│           ├── pages/
│           └── widgets/
│
└── main.dart                      # App entry point
```

---

## 📚 Documentation

For detailed implementation and testing guides, refer to:

- **[IMPLEMENTATION.md](IMPLEMENTATION.md)** - Complete architecture details, data flow, and implementation patterns
- **[TEST_IMPLEMENTATION.md](TEST_IMPLEMENTATION.md)** - Comprehensive testing guide with examples

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/domain/entities/user_test.dart

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 🔄 App Flow

```
App Launch
    ↓
Splash Screen (Initialize)
    ↓
Check Onboarding Status
    ↓
    ├─→ First Time? → Onboarding → Login
    │
    └─→ Returning? → Check Auth Token
                          ↓
                    ├─→ Valid Token → Home (Posts)
                    │
                    └─→ No Token → Login → Home (Posts)
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Follow Flutter best practices
2. Write tests for new features
3. Update documentation
4. Follow the existing code style
5. Use meaningful commit messages

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 📞 Support

For issues and questions:
- Create an issue on GitHub
- Check existing documentation
- Review the implementation guide

---

**Version:** 1.0.0  
**Last Updated:** January 27, 2026  
**Status:** ✅ Production Ready

---

**Built with ❤️ using Flutter and Clean Architecture**

