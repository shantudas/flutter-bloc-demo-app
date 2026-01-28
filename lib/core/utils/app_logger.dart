import 'dart:developer' as developer;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../config/environment.dart';

/// Application-wide logger with environment-aware filtering
///
/// Log Levels:
/// - 0: DEBUG (Development only)
/// - 1: INFO
/// - 2: WARNING
/// - 3: ERROR
/// - 4: FATAL
class AppLogger {
  static const String _tag = 'SocialApp';
  static int _logLevel = 0;
  static bool _enableConsoleOutput = true;
  static Environment _environment = Environment.development;

  /// Initialize the logger with configuration
  static void init({
    required int logLevel,
    required bool enableConsoleOutput,
    required Environment environment,
  }) {
    _logLevel = logLevel;
    _enableConsoleOutput = enableConsoleOutput;
    _environment = environment;
  }

  /// Log a debug message (only in development)
  static void debug(String message, {String? tag, Map<String, dynamic>? context}) {
    if (_logLevel <= 0) {
      _log('DEBUG', message, tag: tag, level: 500, context: context);
    }
  }

  /// Log an info message
  static void info(String message, {String? tag, Map<String, dynamic>? context}) {
    if (_logLevel <= 1) {
      _log('INFO', message, tag: tag, level: 800, context: context);
      // Send as breadcrumb to Crashlytics
      _sendBreadcrumbToCrashlytics('INFO: $message');
    }
  }

  /// Log a warning message
  static void warning(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (_logLevel <= 2) {
      _log(
        'WARNING',
        message,
        tag: tag,
        level: 900,
        context: context,
        error: error,
        stackTrace: stackTrace,
      );
      // Send as breadcrumb to Crashlytics
      _sendBreadcrumbToCrashlytics('WARNING: $message');
    }
  }

  /// Log an error message
  static void error(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (_logLevel <= 3) {
      _log(
        'ERROR',
        message,
        tag: tag,
        level: 1000,
        context: context,
        error: error,
        stackTrace: stackTrace,
      );

      // Send non-fatal error to Crashlytics
      _sendToCrashlytics(message, error, stackTrace, fatal: false);
    }
  }

  /// Log a fatal error message
  static void fatal(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (_logLevel <= 4) {
      _log(
        'FATAL',
        message,
        tag: tag,
        level: 1200,
        context: context,
        error: error,
        stackTrace: stackTrace,
      );

      // Send fatal error to Crashlytics
      _sendToCrashlytics(message, error, stackTrace, fatal: true);
    }
  }

  /// Send breadcrumb log to Crashlytics
  static void _sendBreadcrumbToCrashlytics(String message) {
    try {
      FirebaseCrashlytics.instance.log(message);
    } catch (_) {
      // Silently fail to avoid recursion
    }
  }

  /// Send error to Crashlytics
  static void _sendToCrashlytics(
    String message,
    Object? error,
    StackTrace? stackTrace, {
    required bool fatal,
  }) {
    try {
      if (error != null) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: message,
          fatal: fatal,
        );
      } else {
        // If no error object provided, create one from message
        FirebaseCrashlytics.instance.recordError(
          Exception(message),
          stackTrace ?? StackTrace.current,
          reason: message,
          fatal: fatal,
        );
      }
    } catch (_) {
      // Silently fail to avoid recursion
    }
  }

  /// Internal logging method
  static void _log(
    String levelName,
    String message, {
    String? tag,
    required int level,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enableConsoleOutput) return;

    final logTag = tag ?? _tag;
    final timestamp = DateTime.now().toIso8601String();
    final env = _environment.name.toUpperCase();

    // Build log message with context
    final contextStr = context != null ? ' | Context: $context' : '';
    final fullMessage = '[$timestamp] [$env] [$levelName] $message$contextStr';

    developer.log(
      fullMessage,
      name: logTag,
      level: level,
      error: error,
      stackTrace: stackTrace,
    );

    // In production, you would also send to remote logger here
    // if (_environment == Environment.production) {
    //   _sendToRemoteLogger(levelName, message, context, error, stackTrace);
    // }
  }

  /// Log network request (for debugging)
  static void logNetworkRequest(
    String method,
    String url, {
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    if (_logLevel <= 0) {
      // Only log in debug mode
      debug(
        'Network Request: $method $url',
        context: {
          'headers': headers,
          'body': body,
        },
      );
    }
  }

  /// Log network response (for debugging)
  static void logNetworkResponse(
    String method,
    String url,
    int statusCode, {
    dynamic body,
    Duration? duration,
  }) {
    if (_logLevel <= 0) {
      // Only log in debug mode
      debug(
        'Network Response: $method $url [$statusCode]',
        context: {
          'statusCode': statusCode,
          'body': body,
          'duration': duration?.inMilliseconds,
        },
      );
    }
  }

  /// Log user action (for analytics/debugging)
  static void logUserAction(String action, {Map<String, dynamic>? metadata}) {
    info(
      'User Action: $action',
      context: metadata,
    );
    // Send detailed breadcrumb to Crashlytics
    final metadataStr = metadata != null ? ' | ${metadata.toString()}' : '';
    _sendBreadcrumbToCrashlytics('USER_ACTION: $action$metadataStr');
  }

  /// Log performance metric
  static void logPerformanceMetric(String metric, dynamic value) {
    info(
      'Performance: $metric',
      context: {'value': value},
    );
  }
}

