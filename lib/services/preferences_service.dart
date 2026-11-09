import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService._();

  static const _darkModeKey = 'dark_mode';
  static const _notificationsKey = 'notifications_enabled';
  static const _emailUpdatesKey = 'email_updates_enabled';

  static Future<bool> getDarkMode() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_darkModeKey) ?? true;
  }

  static Future<void> setDarkMode(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_darkModeKey, enabled);
  }

  static Future<bool> getNotificationsEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_notificationsKey) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_notificationsKey, enabled);
  }

  static Future<bool> getEmailUpdatesEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_emailUpdatesKey) ?? true;
  }

  static Future<void> setEmailUpdatesEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_emailUpdatesKey, enabled);
  }
}
