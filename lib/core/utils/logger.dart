import 'dart:developer' as developer;

class Logger {
  static const String _tag = 'SocialApp';

  static void d(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 500,
    );
  }

  static void i(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 800,
    );
  }

  static void w(String message, {String? tag}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 900,
    );
  }

  static void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag ?? _tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

