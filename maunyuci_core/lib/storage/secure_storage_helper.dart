import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHelper {
  static const _storage = FlutterSecureStorage();

  static const _tokenKey = 'jwt_token';
  static const _roleKey = 'user_role';

  static Future<void> saveToken(String token) async => await _storage.write(key: _tokenKey, value: token);
  static Future<void> saveRole(String role) async => await _storage.write(key: _roleKey, value: role);

  static Future<String?> getToken() async => await _storage.read(key: _tokenKey);
  static Future<String?> getRole() async => await _storage.read(key: _roleKey);

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }
}