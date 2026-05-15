import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeKey = 'app_locale';

// StateProvider — same pattern as serverUrlProvider, overrideable at startup
final localeProvider = StateProvider<Locale>((ref) => const Locale('bn'));

Future<void> saveLocale(Locale locale) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_localeKey, locale.languageCode);
}

Future<Locale> loadLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_localeKey);
  return saved != null ? Locale(saved) : const Locale('bn');
}
