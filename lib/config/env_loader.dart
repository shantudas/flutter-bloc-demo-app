import 'dart:io';

import 'package:flutter/foundation.dart';

/// Environment variable loader
///
/// Loads environment variables from .env.dev or .env.prod files
/// when running directly from IDE (without --dart-define flags).
///
/// This allows the app to run from Android Studio/VS Code
/// without requiring build scripts.
class EnvLoader {
  static Map<String, String>? _envCache;

  /// Load environment variables from a .env file
  ///
  /// Returns a map of environment variable keys to values.
  /// Returns empty map if file doesn't exist or can't be read.
  static Future<Map<String, String>> load(String envFile) async {
    // Return cached values if already loaded
    if (_envCache != null) {
      return _envCache!;
    }

    final env = <String, String>{};

    try {
      final file = File(envFile);

      if (!await file.exists()) {
        debugPrint('⚠️  Environment file not found: $envFile');
        debugPrint('💡 Running with --dart-define values or defaults');
        return env;
      }

      final lines = await file.readAsLines();

      for (var line in lines) {
        // Skip empty lines and comments
        line = line.trim();
        if (line.isEmpty || line.startsWith('#')) {
          continue;
        }

        // Parse KEY=VALUE format
        final separatorIndex = line.indexOf('=');
        if (separatorIndex == -1) {
          continue;
        }

        final key = line.substring(0, separatorIndex).trim();
        var value = line.substring(separatorIndex + 1).trim();

        // Remove quotes if present
        if (value.startsWith('"') && value.endsWith('"')) {
          value = value.substring(1, value.length - 1);
        } else if (value.startsWith("'") && value.endsWith("'")) {
          value = value.substring(1, value.length - 1);
        }

        env[key] = value;
      }

      debugPrint('✅ Loaded ${env.length} environment variables from $envFile');
      _envCache = env;
    } catch (e) {
      debugPrint('❌ Error loading environment file: $e');
    }

    return env;
  }

  /// Get an environment variable value
  ///
  /// First checks --dart-define values (from build scripts),
  /// then falls back to loaded .env file values.
  static String get(
    String key,
    Map<String, String> envMap, {
    String defaultValue = '',
  }) {
    // First try --dart-define (higher priority)
    const dartDefineValue = String.fromEnvironment('');
    if (dartDefineValue.isNotEmpty) {
      final value = String.fromEnvironment(key, defaultValue: '');
      if (value.isNotEmpty) {
        return value;
      }
    }

    // Then try .env file
    if (envMap.containsKey(key)) {
      return envMap[key]!;
    }

    // Finally use default
    return defaultValue;
  }

  /// Get an environment variable with compile-time and runtime fallback
  ///
  /// Priority:
  /// 1. --dart-define value (from make dev-run)
  /// 2. .env file value (from IDE run)
  /// 3. Default value
  static String getVar(
    String key,
    Map<String, String> envMap, {
    String defaultValue = '',
  }) {
    // Check if we have a --dart-define value
    final compileTimeValue = String.fromEnvironment(key, defaultValue: '');
    if (compileTimeValue.isNotEmpty) {
      return compileTimeValue;
    }

    // Check .env file (for IDE runs)
    if (envMap.containsKey(key) && envMap[key]!.isNotEmpty) {
      return envMap[key]!;
    }

    // Use default
    return defaultValue;
  }

  /// Clear the cache (useful for testing)
  static void clearCache() {
    _envCache = null;
  }
}

