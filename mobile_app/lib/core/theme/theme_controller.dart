import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeControllerProvider = NotifierProvider<ThemeController, ThemeMode>(() {
  return ThemeController();
});

class ThemeController extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';
  late SharedPreferences _prefs;

  @override
  ThemeMode build() {
    // Initial state is system until prefs are loaded
    _init();
    return ThemeMode.system;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedMode = _prefs.getString(_key);
    if (savedMode != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.name == savedMode,
        orElse: () => ThemeMode.system,
      );
    }
  }

  // Alias so Settings screen can call either name
  Future<void> setTheme(ThemeMode mode) => setThemeMode(mode);

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_key, mode.name);
  }
}
