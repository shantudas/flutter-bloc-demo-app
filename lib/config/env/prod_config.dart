import '../app_config.dart';
import '../environment.dart';

/// Production environment configuration
///
/// This configuration is used for the live production app.
/// - Uses production API endpoints
/// - Production Firebase project
/// - Controlled feature rollout via feature flags
/// - Debug mode disabled
/// - Production logging (INFO/WARNING/ERROR only)
///
/// SECURITY: All sensitive values MUST come from --dart-define flags
/// NO defaults for production secrets - will throw error if missing
class ProdConfig {
  static AppConfig get config {
    // Production API endpoint - REQUIRED, no default
    final apiBaseUrl = const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );

    // Firebase Production Configuration - REQUIRED
    final firebaseApiKey = const String.fromEnvironment(
      'FIREBASE_API_KEY',
      defaultValue: '',
    );
    final firebaseAppId = const String.fromEnvironment(
      'FIREBASE_APP_ID',
      defaultValue: '',
    );
    final firebaseMessagingSenderId = const String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
      defaultValue: '',
    );
    final firebaseProjectId = const String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: '',
    );

    // Encryption key - REQUIRED
    final encryptionKey = const String.fromEnvironment(
      'ENCRYPTION_KEY',
      defaultValue: '',
    );

    // Validate required production values
    assert(
      apiBaseUrl.isNotEmpty,
      '❌ PRODUCTION BUILD ERROR: API_BASE_URL must be provided via --dart-define',
    );
    assert(
      firebaseApiKey.isNotEmpty,
      '❌ PRODUCTION BUILD ERROR: FIREBASE_API_KEY must be provided via --dart-define',
    );
    assert(
      firebaseAppId.isNotEmpty,
      '❌ PRODUCTION BUILD ERROR: FIREBASE_APP_ID must be provided via --dart-define',
    );
    assert(
      firebaseMessagingSenderId.isNotEmpty,
      '❌ PRODUCTION BUILD ERROR: FIREBASE_MESSAGING_SENDER_ID must be provided via --dart-define',
    );
    assert(
      firebaseProjectId.isNotEmpty,
      '❌ PRODUCTION BUILD ERROR: FIREBASE_PROJECT_ID must be provided via --dart-define',
    );
    assert(
      encryptionKey.isNotEmpty && encryptionKey.length >= 32,
      '❌ PRODUCTION BUILD ERROR: ENCRYPTION_KEY must be provided (min 32 characters) via --dart-define',
    );

    return AppConfig(
      environment: Environment.production,

      // Production API endpoint (from --dart-define)
      apiBaseUrl: apiBaseUrl,

      // Firebase Production Project Configuration (from --dart-define)
      firebaseApiKey: firebaseApiKey,
      firebaseAppId: firebaseAppId,
      firebaseMessagingSenderId: firebaseMessagingSenderId,
      firebaseProjectId: firebaseProjectId,

      // Feature Flags - Controlled rollout in production
      featureFlags: const {
        'enable_dark_mode': true,
        'enable_notifications': true,
        'enable_analytics': true,
        'enable_crashlytics': true,
        'enable_social_login': true,
        'enable_payments': true,
        'enable_chat': true,
        'enable_video_calls': false, // Example: Feature not yet released
        'enable_beta_features': false, // Beta features disabled in prod
      },

      // Debug settings
      debugMode: false,

      // Log level: 1 = INFO (production logging - no debug logs)
      logLevel: 1,

      // Encryption key for secure storage (from --dart-define)
      appEncryptionKey: encryptionKey,

      // App name
      appName: const String.fromEnvironment(
        'APP_NAME',
        defaultValue: 'Social App',
      ),

      // Application ID (bundle identifier)
      applicationId: const String.fromEnvironment(
        'APPLICATION_ID',
        defaultValue: 'com.yourapp.social',
      ),

      // Optional: Google Maps API Key (production key with appropriate quota)
      googleMapsApiKey: const String.fromEnvironment(
        'GOOGLE_MAPS_API_KEY',
        defaultValue: '',
      ).isEmpty
          ? null
          : const String.fromEnvironment('GOOGLE_MAPS_API_KEY'),

      // Optional: Stripe publishable key (live mode)
      stripePublishableKey: const String.fromEnvironment(
        'STRIPE_PUBLISHABLE_KEY',
        defaultValue: '',
      ).isEmpty
          ? null
          : const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY'),

      // Optional: Sentry DSN for additional error tracking
      sentryDsn: const String.fromEnvironment(
        'SENTRY_DSN',
        defaultValue: '',
      ).isEmpty
          ? null
          : const String.fromEnvironment('SENTRY_DSN'),
    );
  }
}

