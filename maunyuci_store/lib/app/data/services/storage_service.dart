import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  final _storage = const FlutterSecureStorage();

  // Inisialisasi service
  Future<StorageService> init() async {
    return this;
  }

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // Helper untuk User Token
  Future<void> saveToken(String token) async {
    await write('jwt_token', token);
  }

  Future<String?> getToken() async {
    return await read('jwt_token');
  }
}
