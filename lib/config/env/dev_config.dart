import '../app_config.dart';
import '../env_loader.dart';
import '../environment.dart';

/// Development environment configuration
///
/// This configuration is used for development and testing.
/// - Uses development/staging API endpoints
/// - Separate Firebase project for dev
/// - All features enabled for testing
/// - Debug mode enabled
/// - Verbose logging (DEBUG level)
///
/// Values are loaded from:
/// 1. --dart-define flags (when using make dev-run)
/// 2. .env.dev file (when running from IDE)
///
/// Run with:
/// - make dev-run (uses --dart-define from .env.dev)
/// - Android Studio: Run lib/main_dev.dart directly
class DevConfig {
  static Future<AppConfig> loadConfig() async {
    // Load environment variables from .env.dev file
    // This allows running from IDE without --dart-define flags
    final env = await EnvLoader.load('.env.dev');

    return AppConfig(
      environment: Environment.development,

      // Development API endpoint
      // Priority: --dart-define > .env.dev file
      apiBaseUrl: EnvLoader.getVar('API_BASE_URL', env),

      // Firebase Development Project Configuration
      // All values loaded from .env.dev (IDE) or --dart-define (make dev-run)
      firebaseApiKey: EnvLoader.getVar('FIREBASE_API_KEY', env),
      firebaseAppId: EnvLoader.getVar('FIREBASE_APP_ID', env),
      firebaseMessagingSenderId: EnvLoader.getVar('FIREBASE_MESSAGING_SENDER_ID', env),
      firebaseProjectId: EnvLoader.getVar('FIREBASE_PROJECT_ID', env),

      // Feature Flags - All enabled for testing in development
      featureFlags: const {
        'enable_dark_mode': true,
        'enable_notifications': true,
        'enable_analytics': true,
        'enable_crashlytics': true,
        'enable_social_login': true,
        'enable_payments': false, // Usually keep payments disabled in dev
        'enable_chat': true,
        'enable_video_calls': true,
        'enable_beta_features': true,
      },

      // Debug settings
      debugMode: true,

      // Log level: 0 = DEBUG (verbose logging for development)
      logLevel: 0,

      // Encryption key for secure storage
      appEncryptionKey: EnvLoader.getVar('ENCRYPTION_KEY', env),

      // App name with dev indicator - must be in .env.dev
      appName: EnvLoader.getVar('APP_NAME', env),

      // Application ID with dev suffix - must be in .env.dev
      applicationId: EnvLoader.getVar('APPLICATION_ID', env),

      // Optional: Google Maps API Key (development key with limited quota)
      googleMapsApiKey: EnvLoader.getVar('GOOGLE_MAPS_API_KEY', env).isEmpty
          ? null
          : EnvLoader.getVar('GOOGLE_MAPS_API_KEY', env),

      // Optional: Stripe publishable key (test mode)
      stripePublishableKey: EnvLoader.getVar('STRIPE_PUBLISHABLE_KEY', env).isEmpty
          ? null
          : EnvLoader.getVar('STRIPE_PUBLISHABLE_KEY', env),

      // Optional: Sentry DSN for additional error tracking
      sentryDsn: EnvLoader.getVar('SENTRY_DSN', env).isEmpty
          ? null
          : EnvLoader.getVar('SENTRY_DSN', env),
    );
  }
}

