import 'package:flutter/material.dart';

import 'app.dart';
import 'config/env/dev_config.dart';
import 'config/environment.dart';
import 'core/di/injection_container.dart';
import 'core/services/firebase_service.dart';
import 'core/utils/app_logger.dart';

/// Development entry point
///
/// Run this file for development builds:
/// flutter run -t lib/main_dev.dart
///
/// Or for build:
/// flutter build apk -t lib/main_dev.dart --flavor dev
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set the environment to development
  EnvironmentConfig.setEnvironment(Environment.development);

  // Load development configuration
  final config = DevConfig.config;

  // Initialize the logger with dev configuration
  AppLogger.init(
    logLevel: config.logLevel,
    enableConsoleOutput: true,
    environment: config.environment,
  );

  // Log app startup
  AppLogger.info('🚀 Starting app in DEVELOPMENT mode');
  AppLogger.debug('Configuration: $config');

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

