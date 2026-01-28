# Firebase Crashlytics Quick Reference

## 🚀 Quick Start

### Initialize (Already Done)
Firebase and Crashlytics are automatically initialized in `main.dart`, `main_dev.dart`, and `main_prod.dart`.

## 🔧 Common Operations

### Set User Identifier (After Login)

```dart
import 'package:social_app/core/utils/crashlytics_helper.dart';

// After successful authentication
await CrashlyticsHelper.setUser(
  user.id,
  email: user.email,
  username: user.username,
);
```

### Clear User (On Logout)

```dart
await CrashlyticsHelper.clearUser();
```

### Track Screen Navigation

```dart
@override
void initState() {
  super.initState();
  CrashlyticsHelper.setCurrentScreen('ProfileScreen');
}
```

### Log User Actions

```dart
import 'package:social_app/core/utils/app_logger.dart';

// Simple action
AppLogger.logUserAction('button_clicked');

// With metadata
AppLogger.logUserAction('purchase_completed', metadata: {
  'amount': 99.99,
  'currency': 'USD',
  'product_id': 'premium_monthly',
});
```

### Record Handled Exceptions

```dart
try {
  await riskyOperation();
} catch (e, stackTrace) {
  await CrashlyticsHelper.recordHandledException(
    e,
    stackTrace,
    context: 'Failed to load user profile',
  );
  // Show error to user
}
```

### Record Network Errors

```dart
await CrashlyticsHelper.recordNetworkError(
  'https://api.example.com/users',
  500,
  'Internal Server Error',
  method: 'GET',
);
```

### Record Business Logic Errors

```dart
await CrashlyticsHelper.recordBusinessError(
  'payment_failed',
  'Insufficient funds in account',
  additionalData: {
    'account_balance': 10.50,
    'required_amount': 99.99,
  },
);
```

### Set Custom Context

```dart
import 'package:social_app/core/services/firebase_service.dart';

// Set custom keys
await FirebaseService.instance.setCustomKey('subscription_tier', 'premium');
await FirebaseService.instance.setCustomKey('posts_count', 42);
await FirebaseService.instance.setCustomKey('is_verified', true);
```

### Log Milestones

```dart
// User completed onboarding
await CrashlyticsHelper.logMilestone('onboarding_completed', data: {
  'steps_completed': 5,
  'time_taken_seconds': 180,
});

// User reached level
await CrashlyticsHelper.logMilestone('level_reached', data: {
  'level': 10,
});
```

### Track App Lifecycle

```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    CrashlyticsHelper.setAppState(state);
  }
  
  // ...rest of widget
}
```

### Monitor Network Status

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

Connectivity().onConnectivityChanged.listen((result) {
  final isOnline = result != ConnectivityResult.none;
  CrashlyticsHelper.setNetworkStatus(isOnline);
});
```

## 🧪 Testing

### Test Screen (Development Only)

```dart
import 'package:social_app/features/debug/crashlytics_test_screen.dart';

// Navigate to test screen
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const CrashlyticsTestScreen()),
);
```

### Quick Tests

```dart
import 'package:social_app/core/services/firebase_service.dart';

// Send test exception (non-fatal)
await FirebaseService.instance.sendTestException();

// Force crash (dev only - app will crash!)
FirebaseService.instance.forceCrash();
```

## 📝 Logging Levels

All logging automatically integrates with Crashlytics:

```dart
import 'package:social_app/core/utils/app_logger.dart';

// DEBUG (dev only) - Not sent to Crashlytics
AppLogger.debug('Detailed debug info');

// INFO - Sent as breadcrumb
AppLogger.info('User logged in');

// WARNING - Sent as breadcrumb
AppLogger.warning('API rate limit approaching');

// ERROR - Sent as non-fatal exception
AppLogger.error('Failed to load data', error: e, stackTrace: stackTrace);

// FATAL - Sent as fatal exception
AppLogger.fatal('Critical system failure', error: e, stackTrace: stackTrace);
```

## 🏗️ Build Commands

### Development

```bash
# Run with dev flavor
flutter run -t lib/main_dev.dart --flavor dev

# Build APK
flutter build apk -t lib/main_dev.dart --flavor dev
```

### Production

```bash
# Build release APK
flutter build apk -t lib/main_prod.dart --flavor prod --release

# Build app bundle for Play Store
flutter build appbundle -t lib/main_prod.dart --flavor prod --release
```

## 🔍 Viewing Crashes

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project (dev or prod)
3. Navigate to **Crashlytics** in the left menu
4. View crashes, set up alerts, and analyze trends

## 💡 Best Practices

### ✅ Do

- Set user identifier after login
- Clear user identifier on logout
- Log important user actions
- Track screen navigation
- Record handled exceptions for visibility
- Use meaningful custom keys
- Test with the test screen in development
- Check Firebase Console regularly

### ❌ Don't

- Log sensitive data (passwords, tokens, PII)
- Use Crashlytics for analytics (use Firebase Analytics instead)
- Force crashes in production
- Set too many custom keys (keep it focused)
- Ignore non-fatal exceptions
- Forget to test before releasing

## 🆘 Common Issues

### Crashes Not Appearing

1. Wait 2-5 minutes (initial delay is normal)
2. Ensure internet connectivity
3. Check feature flag: `enable_crashlytics` should be `true`
4. Verify Firebase project matches your build flavor
5. Check `google-services.json` is in correct directory

### Symbolication Not Working

1. Ensure Firebase Crashlytics Gradle plugin is applied
2. Clean and rebuild: `flutter clean && flutter pub get`
3. Check ProGuard/R8 rules (for release builds)
4. Verify mapping files uploaded (automatic with Gradle plugin)

### Different Firebase Projects

Dev and prod use different Firebase projects:
- Dev: `android/app/src/dev/google-services.json`
- Prod: `android/app/src/prod/google-services.json`

Ensure both are configured correctly!

## 📚 Further Reading

- [Firebase Crashlytics Documentation](https://firebase.google.com/docs/crashlytics)
- [Flutter Crashlytics Plugin](https://firebase.flutter.dev/docs/crashlytics/overview)
- [Environment Setup Guide](ENVIRONMENT_SETUP.md)
- [Implementation Guide](ENVIRONMENT_IMPLEMENTATION.md)

## 📞 Support

If you encounter issues, check:
1. Implementation guide in `ENVIRONMENT_IMPLEMENTATION.md`
2. Firebase setup instructions in `android/app/src/README.md`
3. Firebase Console for project status
4. Flutter doctor: `flutter doctor -v`

