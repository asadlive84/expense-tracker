import 'package:shared_preferences/shared_preferences.dart';

const _defaultUrl = 'https://hisabkhata.duckdns.org/v1';
const _key = 'server_base_url';

class ServerUrlStorage {
  static Future<String> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? _defaultUrl;
  }

  static Future<void> write(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final clean = url.trim().replaceAll(RegExp(r'/+$'), '');
    await prefs.setString(_key, clean);
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static String get defaultUrl => _defaultUrl;
}
