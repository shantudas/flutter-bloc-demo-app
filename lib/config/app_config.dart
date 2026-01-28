import 'environment.dart';

/// Configuration model that holds all environment-specific settings
class AppConfig {
  /// The environment this configuration is for
  final Environment environment;

  /// API base URL for backend services
  final String apiBaseUrl;

  /// Firebase configuration
  final String firebaseApiKey;
  final String firebaseAppId;
  final String firebaseMessagingSenderId;
  final String firebaseProjectId;

  /// Feature flags
  final Map<String, bool> featureFlags;

  /// Debug mode flag
  final bool debugMode;

  /// Log level - controls what gets logged
  /// DEBUG = 0, INFO = 1, WARNING = 2, ERROR = 3, FATAL = 4
  final int logLevel;

  /// Optional: Google Maps API key (if using maps)
  final String? googleMapsApiKey;

  /// Optional: Stripe publishable key (if using payments)
  final String? stripePublishableKey;

  /// Optional: Sentry DSN (for additional error tracking)
  final String? sentryDsn;

  /// App encryption key for secure storage
  final String appEncryptionKey;

  /// App name (can differ between environments)
  final String appName;

  /// Application ID (bundle identifier)
  final String applicationId;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.firebaseApiKey,
    required this.firebaseAppId,
    required this.firebaseMessagingSenderId,
    required this.firebaseProjectId,
    required this.featureFlags,
    required this.debugMode,
    required this.logLevel,
    required this.appEncryptionKey,
    required this.appName,
    required this.applicationId,
    this.googleMapsApiKey,
    this.stripePublishableKey,
    this.sentryDsn,
  });

  /// Check if a feature is enabled
  bool isFeatureEnabled(String featureName) {
    return featureFlags[featureName] ?? false;
  }

  /// Get a human-readable log level name
  String get logLevelName {
    switch (logLevel) {
      case 0:
        return 'DEBUG';
      case 1:
        return 'INFO';
      case 2:
        return 'WARNING';
      case 3:
        return 'ERROR';
      case 4:
        return 'FATAL';
      default:
        return 'UNKNOWN';
    }
  }

  @override
  String toString() {
    return 'AppConfig('
        'environment: ${environment.name}, '
        'apiBaseUrl: $apiBaseUrl, '
        'appName: $appName, '
        'debugMode: $debugMode, '
        'logLevel: $logLevelName'
        ')';
  }
}

