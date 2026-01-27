import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class SettingsStorageService {
  final SharedPreferences _prefs;

  SettingsStorageService(this._prefs);

  // Onboarding
  bool get isOnboardingCompleted {
    return _prefs.getBool(StorageKeys.onboardingCompleted) ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    await _prefs.setBool(StorageKeys.onboardingCompleted, value);
  }

  // Theme
  String get themeMode {
    return _prefs.getString(StorageKeys.themeMode) ?? 'system';
  }

  Future<void> setThemeMode(String value) async {
    await _prefs.setString(StorageKeys.themeMode, value);
  }

  // Language
  String get language {
    return _prefs.getString(StorageKeys.language) ?? 'en';
  }

  Future<void> setLanguage(String value) async {
    await _prefs.setString(StorageKeys.language, value);
  }

  // Notifications
  bool get notificationsEnabled {
    return _prefs.getBool(StorageKeys.notificationsEnabled) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(StorageKeys.notificationsEnabled, value);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

