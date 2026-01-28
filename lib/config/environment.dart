/// Enum representing the different environments the app can run in
enum Environment {
  /// Development environment - for development and testing
  development,

  /// Production environment - for live users
  production,
}

/// Global variable to hold the current environment
class EnvironmentConfig {
  static Environment _environment = Environment.development;

  /// Get the current environment
  static Environment get environment => _environment;

  /// Set the current environment
  /// Should only be called at app startup
  static void setEnvironment(Environment env) {
    _environment = env;
  }

  /// Check if the app is running in development mode
  static bool get isDevelopment => _environment == Environment.development;

  /// Check if the app is running in production mode
  static bool get isProduction => _environment == Environment.production;
}

