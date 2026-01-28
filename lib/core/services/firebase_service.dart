import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../../config/app_config.dart';
import '../utils/app_logger.dart';

/// Firebase Service that manages Firebase initialization and Crashlytics
class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  bool _isInitialized = false;
  AppConfig? _config;

  /// Initialize Firebase and Crashlytics
  Future<void> initialize(AppConfig config) async {
    if (_isInitialized) {
      AppLogger.warning('Firebase already initialized');
      return;
    }

    _config = config;

    try {
      // Initialize Firebase with manual configuration
      // This allows us to use different Firebase projects for dev/prod
      // without needing separate google-services.json files during development
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: config.firebaseApiKey,
          appId: config.firebaseAppId,
          messagingSenderId: config.firebaseMessagingSenderId,
          projectId: config.firebaseProjectId,
        ),
      );

      AppLogger.info('✅ Firebase initialized successfully');

      // Initialize Crashlytics
      await _initializeCrashlytics(config);

      _isInitialized = true;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize Firebase',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Initialize Crashlytics with environment-specific settings
  Future<void> _initializeCrashlytics(AppConfig config) async {
    try {
      final crashlytics = FirebaseCrashlytics.instance;

      // Enable Crashlytics collection based on feature flag
      final isCrashlyticsEnabled = config.isFeatureEnabled('enable_crashlytics');

      if (!isCrashlyticsEnabled) {
        AppLogger.info('🔕 Crashlytics disabled via feature flag');
        await crashlytics.setCrashlyticsCollectionEnabled(false);
        return;
      }

      // Enable Crashlytics
      await crashlytics.setCrashlyticsCollectionEnabled(true);

      // Set custom keys for environment context
      await crashlytics.setCustomKey('environment', config.environment.name);
      await crashlytics.setCustomKey('app_name', config.appName);
      await crashlytics.setCustomKey('debug_mode', config.debugMode);
      await crashlytics.setCustomKey('log_level', config.logLevelName);

      // Pass all uncaught Flutter errors to Crashlytics
      FlutterError.onError = (errorDetails) {
        AppLogger.error(
          'Flutter Error',
          error: errorDetails.exception,
          stackTrace: errorDetails.stack,
          context: {
            'library': errorDetails.library ?? 'unknown',
            'context': errorDetails.context?.toString() ?? 'unknown',
          },
        );
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        AppLogger.error(
          'Async Error',
          error: error,
          stackTrace: stack,
        );
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      AppLogger.info('✅ Crashlytics initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize Crashlytics',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Set user identifier for Crashlytics
  /// Call this after user authentication
  Future<void> setUserIdentifier(String userId) async {
    if (!_isInitialized) return;

    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
      AppLogger.info('User identifier set for Crashlytics', context: {'userId': userId});
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to set user identifier',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Clear user identifier (e.g., on logout)
  Future<void> clearUserIdentifier() async {
    if (!_isInitialized) return;

    try {
      await FirebaseCrashlytics.instance.setUserIdentifier('');
      AppLogger.info('User identifier cleared');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to clear user identifier',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Set custom key-value pair for crash context
  Future<void> setCustomKey(String key, dynamic value) async {
    if (!_isInitialized) return;

    try {
      if (value is String) {
        await FirebaseCrashlytics.instance.setCustomKey(key, value);
      } else if (value is int) {
        await FirebaseCrashlytics.instance.setCustomKey(key, value);
      } else if (value is double) {
        await FirebaseCrashlytics.instance.setCustomKey(key, value);
      } else if (value is bool) {
        await FirebaseCrashlytics.instance.setCustomKey(key, value);
      } else {
        await FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to set custom key',
        error: e,
        stackTrace: stackTrace,
        context: {'key': key, 'value': value.toString()},
      );
    }
  }

  /// Log a message to Crashlytics (breadcrumb)
  Future<void> log(String message) async {
    if (!_isInitialized) return;

    try {
      await FirebaseCrashlytics.instance.log(message);
    } catch (e) {
      // Silently fail to avoid recursion with logger
    }
  }

  /// Record a non-fatal exception
  Future<void> recordException(
    dynamic exception,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    if (!_isInitialized) return;

    try {
      await FirebaseCrashlytics.instance.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } catch (e, stack) {
      AppLogger.error(
        'Failed to record exception to Crashlytics',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Force a test crash (for testing purposes)
  /// Only call this in development!
  void forceCrash() {
    if (_config?.debugMode ?? false) {
      AppLogger.warning('⚠️ Forcing test crash');
      FirebaseCrashlytics.instance.crash();
    } else {
      AppLogger.warning('Force crash ignored - not in debug mode');
    }
  }

  /// Send test non-fatal exception
  Future<void> sendTestException() async {
    AppLogger.info('Sending test exception to Crashlytics');
    try {
      throw Exception('Test exception from FirebaseService');
    } catch (e, stackTrace) {
      await recordException(e, stackTrace, reason: 'Test exception');
    }
  }
}

