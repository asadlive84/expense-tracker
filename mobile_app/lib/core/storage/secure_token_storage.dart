import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  static const _tokenKey = 'jwt_token';
  static const _expiryKey = 'jwt_expiry';
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    // EncryptedSharedPreferences works reliably on all real Android devices,
    // unlike the default Android Keystore which can hang on Samsung/MIUI.
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> writeToken(String token, DateTime? expiresAt) async {
    await _storage.write(key: _tokenKey, value: token);
    if (expiresAt != null) {
      await _storage.write(
        key: _expiryKey, 
        value: expiresAt.toIso8601String(),
      );
    }
  }

  Future<String?> readToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<DateTime?> readExpiry() async {
    final expiryStr = await _storage.read(key: _expiryKey);
    if (expiryStr == null) return null;
    return DateTime.tryParse(expiryStr);
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expiryKey);
  }
}
