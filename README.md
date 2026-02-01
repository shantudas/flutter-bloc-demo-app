# Flutter Social App - Production-Ready Clean Architecture
A production-ready Flutter application demonstrating clean architecture principles with offline-first capabilities, environment-based configuration, comprehensive logging, and Firebase Crashlytics integration.
## 📋 Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Running the App](#running-the-app)
- [Building for Production](#building-for-production)
- [Documentation](#documentation)
---
## 🎯 Overview
This application showcases **production-grade** Flutter development practices including:
### Core Principles
- **Clean Architecture** with clear separation of concerns (Domain, Data, Presentation)
- **BLoC Pattern** for predictable state management
- **Offline-First** approach with local caching
- **Environment-Based Configuration** (Development & Production)
- **Comprehensive Logging System** with multiple log levels
- **Firebase Crashlytics Integration** for error tracking
### Production Features
- ✅ Multiple environment support (dev/prod)
- ✅ Environment variables via `.env` files
- ✅ Multi-level logging (DEBUG, INFO, WARNING, ERROR, FATAL)
- ✅ Firebase Crashlytics with custom keys and breadcrumbs
- ✅ Automatic error reporting and crash tracking
- ✅ Android product flavors (dev/prod)
- ✅ Build scripts and Makefile commands
---
## ✨ Features
### Implemented
- **Environment Configuration**: Separate dev/prod environments with `.env` file support
- **Logging System**: Multi-level logging with Crashlytics integration
- **Firebase Crashlytics**: Automatic crash reporting with custom context
- **Splash Screen**: App initialization and navigation
- **Onboarding**: Three-page introduction flow
- **Authentication**: JWT token-based login with secure storage
- **Posts Feed**: Infinite scroll with offline-first caching
---
## 🛠️ Tech Stack
| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.19+ |
| **Language** | Dart 3.3+ |
| **State Management** | flutter_bloc 8.1+ |
| **Networking** | Dio 5.4+ |
| **Local Storage** | Hive 2.2+ |
| **Secure Storage** | flutter_secure_storage 9.2+ |
| **Dependency Injection** | get_it 7.7+ |
| **Firebase** | firebase_core, firebase_crashlytics |
---
## 📁 Project Structure
```
lib/
├── main.dart, main_dev.dart, main_prod.dart
├── config/                    # Environment configuration
│   ├── environment.dart
│   ├── app_config.dart
│   └── env_loader.dart
├── core/                      # Core functionality
│   ├── api/                   # API client & interceptors
│   ├── di/                    # Dependency injection
│   ├── services/              # Firebase services
│   └── utils/                 # Logger, helpers
└── features/                  # Feature modules
    ├── auth/
    │   ├── data/             # Data layer
    │   ├── domain/           # Business logic
    │   └── presentation/     # UI & BLoC
    ├── posts/
    ├── onboarding/
    └── splash/
```
---
## 🚀 Getting Started
### Prerequisites
- Flutter SDK >= 3.19.0
- Dart SDK >= 3.3.0
- Android Studio / VS Code
- Firebase Account (for Crashlytics)
### Installation
1. **Clone the repository**
```bash
git clone <repository-url>
cd flutter_bloc
```
2. **Install dependencies**
```bash
flutter pub get
```
3. **Set up environment variables**
Create `.env.dev` file:
```bash
cp .env.example .env.dev
```
Edit `.env.dev` with your values:
```dotenv
ENV=dev
API_BASE_URL=https://dummyjson.com
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_APP_ID=your_firebase_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_PROJECT_ID=your-project-id
ENCRYPTION_KEY=your_32_character_encryption_key
APP_NAME=Social App Dev
APPLICATION_ID=com.example.flutter_bloc.dev
```
4. **Generate code**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
5. **Run the app**
From IDE (Android Studio/VS Code):
- Simply click Run (automatically loads `.env.dev`)
From Terminal:
```bash
make dev-run
# or
flutter run -t lib/main.dart --flavor dev
```
---
## 🏃 Running the App
### Using Makefile (Recommended)
```bash
# Development
make dev-run              # Run in dev mode
make dev-build-apk        # Build dev APK
# Production
make prod-run             # Run in prod mode
make prod-build-apk       # Build prod APK
make prod-build-appbundle # Build App Bundle
# Utilities
make clean               # Clean build artifacts
make generate            # Run code generation
```
### Manual Commands
**Development:**
```bash
flutter run -t lib/main_dev.dart --flavor dev
flutter build apk -t lib/main_dev.dart --flavor dev --debug
```
**Production:**
```bash
flutter run -t lib/main_prod.dart --flavor prod --release
flutter build appbundle -t lib/main_prod.dart --flavor prod --release \
  --obfuscate --split-debug-info=build/symbols
```
---
## 📦 Building for Production
### Android
1. **Configure signing** (create `android/key.properties`)
2. **Build APK**:
```bash
make prod-build-apk
```
3. **Build App Bundle** (Play Store):
```bash
make prod-build-appbundle
```
Output: `build/app/outputs/bundle/prodRelease/app-prod-release.aab`
### iOS
1. Configure Xcode signing
2. Build:
```bash
make prod-build-ios
```
---
## 📚 Documentation
For detailed documentation, see:
- **[IMPLEMENTATION.md](IMPLEMENTATION.md)** - Complete implementation guide:
  - Environment Configuration
  - Logging System
  - Firebase Crashlytics Integration
  - Project Structure
  - Secrets Management
- **[TEST_IMPLEMENTATION.md](TEST_IMPLEMENTATION.md)** - Testing guide:
  - Unit testing
  - BLoC testing
  - Repository testing
  - Coverage reports
---
## 🧪 Testing
```bash
# Run all tests
flutter test
# Run with coverage
flutter test --coverage
# Specific test
flutter test test/features/auth/domain/usecases/login_usecase_test.dart
```
---
## 🔐 Demo Credentials
Test login with DummyJSON API:
| Username | Password |
|----------|----------|
| `emilys` | `emilyspass` |
| `michaelw` | `michaelwpass` |
---
## 🏗️ Architecture
Clean Architecture with three layers:
```
┌─────────────────────────────┐
│    PRESENTATION LAYER       │
│  (UI + BLoC)                │
├─────────────────────────────┤
│      DOMAIN LAYER           │
│  (Business Logic)           │
├─────────────────────────────┤
│       DATA LAYER            │
│  (API + Database)           │
└─────────────────────────────┘
```
**Data Flow**: UI → BLoC → Use Case → Repository → Data Source
---
## 🤝 Contributing
Contributions welcome! Please:
1. Follow Flutter best practices
2. Maintain clean architecture principles
3. Write tests for new features
4. Update documentation
---
## 📄 License
This project is licensed under the MIT License.
---
**Built with ❤️ using Flutter**
