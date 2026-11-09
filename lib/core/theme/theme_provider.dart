import 'package:flutter/material.dart';
import '../../services/preferences_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({bool isDark = true})
      : _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> toggleTheme() async {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    await PreferencesService.setDarkMode(isDark);
  }

  Future<void> setDark() async {
    _themeMode = ThemeMode.dark;
    notifyListeners();
    await PreferencesService.setDarkMode(true);
  }

  Future<void> setLight() async {
    _themeMode = ThemeMode.light;
    notifyListeners();
    await PreferencesService.setDarkMode(false);
  }
}
