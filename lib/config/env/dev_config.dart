import '../app_config.dart';
import '../environment.dart';

/// Development environment configuration
///
/// This configuration is used for development and testing.
/// - Uses development/staging API endpoints
/// - Separate Firebase project for dev
/// - All features enabled for testing
/// - Debug mode enabled
/// - Verbose logging (DEBUG level)
class DevConfig {
  static AppConfig get config => const AppConfig(
        environment: Environment.development,

        // Development API endpoint
        apiBaseUrl: 'https://dummyjson.com',

        // Firebase Development Project Configuration
        firebaseApiKey: 'BO46YTub21vXot8ycIVzWmIU2bln2ABIIrlOqeMrZTCPHuNtDGkbRShEM1ZEFQuvt67Z7Mn0DUhRsMbQ9Ol1sfA', // Get from Firebase Console → Project Settings → Cloud Messaging → Web configuration
        firebaseAppId: '1:1067516417535:android:1db2e3791146e20fac43ca',
        firebaseMessagingSenderId: '1067516417535', // Get from Firebase Console → Project Settings → Cloud Messaging → Sender ID
        firebaseProjectId: 'flutter-bloc-demo-app-2026',

        // Feature Flags - All enabled for testing in development
        featureFlags: {
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

        // Encryption key for secure storage (dev key)
        // TODO: Replace with your actual dev encryption key
        appEncryptionKey: 'dev_encryption_key_32_characters',

        // App name with dev indicator
        appName: 'Social App Dev',

        // Application ID with dev suffix
        applicationId: 'com.yourapp.social.dev',

        // Optional: Google Maps API Key (development key with limited quota)
        googleMapsApiKey: null, // Add if needed: 'YOUR_DEV_GOOGLE_MAPS_KEY',

        // Optional: Stripe publishable key (test mode)
        stripePublishableKey: null, // Add if needed: 'pk_test_YOUR_DEV_STRIPE_KEY',

        // Optional: Sentry DSN for additional error tracking
        sentryDsn: null, // Add if needed: 'https://YOUR_DEV_SENTRY_DSN',
      );
}

