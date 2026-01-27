class AppConstants {
  // App info
  static const String appName = 'Social App';
  static const String appVersion = '1.0.0';

  // Pagination
  static const int postsPerPage = 30;
  static const int commentsPerPage = 20;

  // Cache duration
  static const Duration cacheDuration = Duration(hours: 1);

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Retry
  static const int maxRetries = 3;

  // Splash screen
  static const Duration minSplashDuration = Duration(seconds: 2);
  static const Duration maxSplashDuration = Duration(seconds: 5);
}

class StorageKeys {
  // Secure storage keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';

  // SharedPreferences keys
  static const String onboardingCompleted = 'onboarding_completed';
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String notificationsEnabled = 'notifications_enabled';

  // Hive box names
  static const String postsBox = 'posts_box';
  static const String commentsBox = 'comments_box';
  static const String usersBox = 'users_box';
  static const String syncQueueBox = 'sync_queue_box';
}

