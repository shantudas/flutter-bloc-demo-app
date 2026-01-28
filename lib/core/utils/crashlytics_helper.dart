import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import 'app_logger.dart';

/// Helper class for common Crashlytics operations
class CrashlyticsHelper {
  /// Set user identifier after login
  static Future<void> setUser(String userId, {String? email, String? username}) async {
    await FirebaseService.instance.setUserIdentifier(userId);

    if (email != null) {
      await FirebaseService.instance.setCustomKey('user_email', email);
    }
    if (username != null) {
      await FirebaseService.instance.setCustomKey('username', username);
    }

    AppLogger.info('User context set for Crashlytics', context: {
      'userId': userId,
      'hasEmail': email != null,
      'hasUsername': username != null,
    });
  }

  /// Clear user identifier on logout
  static Future<void> clearUser() async {
    await FirebaseService.instance.clearUserIdentifier();
    await FirebaseService.instance.setCustomKey('user_email', '');
    await FirebaseService.instance.setCustomKey('username', '');

    AppLogger.info('User context cleared from Crashlytics');
  }

  /// Set current screen name
  static Future<void> setCurrentScreen(String screenName) async {
    await FirebaseService.instance.setCustomKey('current_screen', screenName);
    await FirebaseService.instance.log('Screen: $screenName');
  }

  /// Set app state (foreground/background)
  static Future<void> setAppState(AppLifecycleState state) async {
    final stateStr = state.name;
    await FirebaseService.instance.setCustomKey('app_state', stateStr);
    await FirebaseService.instance.log('App state: $stateStr');
  }

  /// Set network status
  static Future<void> setNetworkStatus(bool isOnline) async {
    await FirebaseService.instance.setCustomKey('network_status', isOnline ? 'online' : 'offline');
  }

  /// Set feature flags state
  static Future<void> setFeatureFlags(Map<String, bool> flags) async {
    final activeFlags = flags.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .join(', ');

    await FirebaseService.instance.setCustomKey('active_features', activeFlags);
  }

  /// Record a handled exception
  static Future<void> recordHandledException(
    dynamic exception,
    StackTrace? stackTrace, {
    String? context,
  }) async {
    AppLogger.error(
      'Handled exception${context != null ? ": $context" : ""}',
      error: exception,
      stackTrace: stackTrace,
    );

    await FirebaseService.instance.recordException(
      exception,
      stackTrace,
      reason: context,
      fatal: false,
    );
  }

  /// Record a business logic error (non-crash)
  static Future<void> recordBusinessError(
    String errorType,
    String message, {
    Map<String, dynamic>? additionalData,
  }) async {
    final error = Exception('BusinessError: $errorType - $message');

    AppLogger.warning(
      'Business error: $errorType',
      context: {
        'message': message,
        ...?additionalData,
      },
    );

    await FirebaseService.instance.recordException(
      error,
      StackTrace.current,
      reason: 'Business Error: $errorType',
      fatal: false,
    );
  }

  /// Record network error
  static Future<void> recordNetworkError(
    String url,
    int? statusCode,
    String errorMessage, {
    String? method,
  }) async {
    await FirebaseService.instance.setCustomKey('last_network_error_url', url);
    await FirebaseService.instance.setCustomKey('last_network_error_code', statusCode ?? -1);

    final error = Exception('NetworkError: $method $url - $statusCode - $errorMessage');

    AppLogger.error(
      'Network error',
      error: error,
      context: {
        'url': url,
        'statusCode': statusCode,
        'method': method,
      },
    );

    await FirebaseService.instance.recordException(
      error,
      StackTrace.current,
      reason: 'Network Error',
      fatal: false,
    );
  }

  /// Set session duration
  static Future<void> updateSessionDuration(Duration duration) async {
    await FirebaseService.instance.setCustomKey(
      'session_duration_seconds',
      duration.inSeconds,
    );
  }

  /// Log important user journey milestone
  static Future<void> logMilestone(String milestone, {Map<String, dynamic>? data}) async {
    AppLogger.info('Milestone: $milestone', context: data);
    await FirebaseService.instance.log('MILESTONE: $milestone');

    if (data != null) {
      for (var entry in data.entries) {
        await FirebaseService.instance.setCustomKey(
          'milestone_${entry.key}',
          entry.value,
        );
      }
    }
  }
}

