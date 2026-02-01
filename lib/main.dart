import 'package:flutter/material.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'config/env_loader.dart';
import 'config/environment.dart';
import 'core/di/injection_container.dart';
import 'core/services/firebase_service.dart';
import 'core/utils/app_logger.dart';

/// Default entry point - loads configuration from .env.dev
///
/// This entry point automatically loads environment variables from .env.dev
/// when running from Android Studio/VS Code.
///
/// Works with both:
/// - IDE run (loads from .env.dev file)
/// - make dev-run (uses --dart-define flags)
///
/// For production builds, use:
/// flutter run -t lib/main_prod.dart --flavor prod
/// flutter build apk -t lib/main_prod.dart --flavor prod
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env.dev file
  // This allows running from IDE without --dart-define flags
  final env = await EnvLoader.load('.env.dev');

  // Detect environment (--dart-define takes priority, then .env file)
  final envString = EnvLoader.getVar('ENV', env, defaultValue: 'dev');
  final environment = envString == 'prod'
      ? Environment.production
      : Environment.development;

  // Set the environment
  EnvironmentConfig.setEnvironment(environment);

  // Create configuration loading from .env.dev
  // Priority: --dart-define (make dev-run) > .env file (IDE run)
  final config = AppConfig(
    environment: environment,

    // API Configuration - loaded from .env.dev
    apiBaseUrl: EnvLoader.getVar('API_BASE_URL', env),

    // Firebase Configuration - loaded from .env.dev
    firebaseApiKey: EnvLoader.getVar('FIREBASE_API_KEY', env),
    firebaseAppId: EnvLoader.getVar('FIREBASE_APP_ID', env),
    firebaseMessagingSenderId: EnvLoader.getVar('FIREBASE_MESSAGING_SENDER_ID', env),
    firebaseProjectId: EnvLoader.getVar('FIREBASE_PROJECT_ID', env),

    // Feature Flags - all enabled for development
    featureFlags: const {
      'enable_dark_mode': true,
      'enable_notifications': true,
      'enable_analytics': true,
      'enable_crashlytics': true,
      'enable_social_login': true,
      'enable_payments': false,
      'enable_chat': true,
      'enable_video_calls': true,
      'enable_beta_features': true,
    },

    // Debug settings
    debugMode: environment == Environment.development,

    // Log level: 0 = DEBUG for development
    logLevel: environment == Environment.development ? 0 : 1,

    // Encryption key - loaded from .env.dev
    appEncryptionKey: EnvLoader.getVar('ENCRYPTION_KEY', env),

    // App name - must be in .env.dev
    appName: EnvLoader.getVar('APP_NAME', env),

    // Application ID - must be in .env.dev
    applicationId: EnvLoader.getVar('APPLICATION_ID', env),

    // Optional services
    googleMapsApiKey: null,
    stripePublishableKey: null,
    sentryDsn: null,
  );

  // Initialize the logger with dev configuration
  AppLogger.init(
    logLevel: config.logLevel,
    enableConsoleOutput: true,
    environment: config.environment,
  );

  // Log app startup
  AppLogger.info('🚀 Starting app in ${environment == Environment.development ? 'DEVELOPMENT' : 'PRODUCTION'} mode');
  AppLogger.debug('Configuration loaded from .env.dev');
  AppLogger.debug('API Base URL: ${config.apiBaseUrl}');

  // Initialize Firebase and Crashlytics
  try {
    await FirebaseService.instance.initialize(config);
    AppLogger.info('✅ Firebase services initialized');
  } catch (e, stackTrace) {
    AppLogger.error(
      'Failed to initialize Firebase services',
      error: e,
      stackTrace: stackTrace,
    );
  }

  // Initialize dependencies with the config
  await initDependencies(config);

  // Run the app
  runApp(MyApp(config: config));
}

