import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddressStorage {
  static const String _key = 'recent_addresses';
  static const _storage = FlutterSecureStorage();

  static Future<List<Map<String, dynamic>>> getRecentAddresses() async {
    final data = await _storage.read(key: _key);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  static Future<void> saveAddress(String address, double lat, double lng) async {
    final list = await getRecentAddresses();
    
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

  static Future<void> clear() async {
    await _storage.delete(key: _key);
  }
}