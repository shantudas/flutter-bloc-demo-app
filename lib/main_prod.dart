import 'dart:async';
import 'package:flutter/material.dart';

import 'app.dart';
import 'config/env/prod_config.dart';
import 'config/environment.dart';
import 'core/di/injection_container.dart';
import 'core/services/firebase_service.dart';
import 'core/utils/app_logger.dart';

/// Production entry point
///
/// Run this file for production builds:
/// flutter run -t lib/main_prod.dart
///
/// Or for build:
/// flutter build apk -t lib/main_prod.dart --flavor prod
/// flutter build appbundle -t lib/main_prod.dart --flavor prod
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set the environment to production
  EnvironmentConfig.setEnvironment(Environment.production);

  // Load production configuration
  final config = ProdConfig.config;

  // Initialize the logger with production configuration
  AppLogger.init(
    logLevel: config.logLevel,
    enableConsoleOutput: false, // Disable console logs in production
    environment: config.environment,
  );

  // Log app startup (INFO level, so it will appear in production logs)
  AppLogger.info('🚀 Starting app in PRODUCTION mode');

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

  // Handle errors globally with runZonedGuarded
  runZonedGuarded(
    () {
      runApp(MyApp(config: config));
    },
    (error, stackTrace) {
      AppLogger.fatal('Uncaught error', error: error, stackTrace: stackTrace);
      FirebaseService.instance.recordException(
        error,
        stackTrace,
        reason: 'Uncaught error in runZonedGuarded',
        fatal: true,
      );
    },
  );
}

