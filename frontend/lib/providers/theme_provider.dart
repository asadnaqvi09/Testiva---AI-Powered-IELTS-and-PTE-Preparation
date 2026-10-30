import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists dark/light choice across app restarts (SharedPreferences).
class ThemeProvider extends ChangeNotifier {
  static const _prefsKey = 'theme_is_dark';

  bool _isDarkMode = false;
  bool _loaded = false;

  bool get isDarkMode => _isDarkMode;
  bool get isLoaded => _loaded;

  ThemeProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_prefsKey) ?? false;
    } catch (e) {
      debugPrint('[ThemeProvider] load failed: $e');
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, value);
    } catch (e) {
      debugPrint('[ThemeProvider] save failed: $e');
    }
  }
}
