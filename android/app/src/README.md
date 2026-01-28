# Firebase Configuration Files

This directory contains environment-specific Firebase configuration files.

## Structure

```
android/app/src/
├── dev/
│   └── google-services.json    # Development Firebase project
└── prod/
    └── google-services.json    # Production Firebase project
```

## Setup Instructions

### 1. Create Firebase Projects

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create two projects:
   - **Development Project**: `your-app-dev`
   - **Production Project**: `your-app-prod`

### 2. Add Android Apps

For each Firebase project:

1. Click "Add app" → Select Android
2. Enter the package name:
   - Dev: `com.example.flutter_bloc.dev`
   - Prod: `com.example.flutter_bloc`
3. Download the `google-services.json` file
4. Place the file in the appropriate directory:
   - Dev: `android/app/src/dev/google-services.json`
   - Prod: `android/app/src/prod/google-services.json`

### 3. Enable Crashlytics

For each Firebase project:

1. In Firebase Console, go to **Crashlytics**
2. Click "Enable Crashlytics"
3. Follow the setup instructions

### 4. Update Configuration Files

Replace the placeholder values in:
- `lib/config/env/dev_config.dart`
- `lib/config/env/prod_config.dart`

With your actual Firebase credentials:
- `firebaseApiKey`
- `firebaseAppId`
- `firebaseMessagingSenderId`
- `firebaseProjectId`

## Testing

### Development Environment

```bash
# Run with dev flavor
flutter run -t lib/main_dev.dart --flavor dev

# Build with dev flavor
flutter build apk -t lib/main_dev.dart --flavor dev
```

### Production Environment

```bash
# Run with prod flavor
flutter run -t lib/main_prod.dart --flavor prod

# Build with prod flavor
flutter build apk -t lib/main_prod.dart --flavor prod --release
flutter build appbundle -t lib/main_prod.dart --flavor prod --release
```

## Verify Crashlytics

### Send Test Crash

Add a test button in your app that calls:

```dart
FirebaseService.instance.sendTestException();
```

Or force a crash (dev only):

```dart
FirebaseService.instance.forceCrash();
```

Check the Firebase Console → Crashlytics to see the reported crashes.

## Security Notes

- ⚠️ **DO NOT commit real `google-services.json` files to Git**
- Add them to `.gitignore` if they contain sensitive data
- Use environment variables or secure storage in CI/CD
- The placeholder files are safe to commit

## iOS Setup

For iOS, you'll need to create:

```
ios/Runner/Firebase/
├── Dev/
│   └── GoogleService-Info.plist
└── Prod/
    └── GoogleService-Info.plist
```

And update the Xcode project to copy the correct file based on the scheme.

