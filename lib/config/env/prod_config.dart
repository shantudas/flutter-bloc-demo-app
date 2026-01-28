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
class ProdConfig {
  static AppConfig get config => const AppConfig(
        environment: Environment.production,

        // Production API endpoint
        // TODO: Replace with your actual production API URL
        apiBaseUrl: 'https://api.yourapp.com',

        // Firebase Production Project Configuration
        // TODO: Replace with your actual Firebase production project credentials
        firebaseApiKey: 'YOUR_PROD_FIREBASE_API_KEY',
        firebaseAppId: 'YOUR_PROD_FIREBASE_APP_ID',
        firebaseMessagingSenderId: 'YOUR_PROD_MESSAGING_SENDER_ID',
        firebaseProjectId: 'your-app-prod',

        // Feature Flags - Controlled rollout in production
        featureFlags: {
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

        // Encryption key for secure storage (production key)
        // TODO: Replace with your actual production encryption key
        // IMPORTANT: Keep this secure and different from dev
        appEncryptionKey: 'prod_encryption_key_32_chars!!',

        // App name
        appName: 'Social App',

        // Application ID (bundle identifier)
        applicationId: 'com.yourapp.social',

        // Optional: Google Maps API Key (production key with appropriate quota)
        googleMapsApiKey: null, // Add if needed: 'YOUR_PROD_GOOGLE_MAPS_KEY',

        // Optional: Stripe publishable key (live mode)
        stripePublishableKey: null, // Add if needed: 'pk_live_YOUR_PROD_STRIPE_KEY',

        // Optional: Sentry DSN for additional error tracking
        sentryDsn: null, // Add if needed: 'https://YOUR_PROD_SENTRY_DSN',
      );
}

