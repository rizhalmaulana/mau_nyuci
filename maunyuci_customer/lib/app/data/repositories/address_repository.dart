import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddressRepository {
  static const String _key = 'recent_addresses';
  static const _storage = FlutterSecureStorage();

  Future<List<Map<String, dynamic>>> getRecentAddresses({int limit = 5}) async {
    final data = await _storage.read(key: _key);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => Map<String, dynamic>.from(e))
        .take(limit)
        .toList();
  }

  Future<void> saveAddress(String address, double lat, double lng) async {
    final list = await getRecentAddresses(limit: 100);
    
    list.removeWhere((item) => item['address'] == address);
    
    list.insert(0, {
      'address': address,
      'lat': lat,
      'lng': lng,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    if (list.length > 5) {
      list.removeRange(5, list.length);
    }
    
    await _storage.write(key: _key, value: jsonEncode(list));
  }

  Future<void> clearHistory() async {
    await _storage.delete(key: _key);
  }

  Future<Map<String, dynamic>?> getLastAddress() async {
    final list = await getRecentAddresses(limit: 1);
    return list.isEmpty ? null : list.first;
  }
}