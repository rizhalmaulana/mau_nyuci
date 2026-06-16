import 'package:maunyuci_core/maunyuci_core.dart';

class UserProfileRepository {
  Future<Map<String, dynamic>?> getProfile(String odUserId) async {
    final name = await SecureStorageHelper.read('full_name');
    final phone = await SecureStorageHelper.read('phone_number');
    final email = await SecureStorageHelper.read('email');
    final profilePicture = await SecureStorageHelper.read('profile_picture');
    final defaultAddress = await SecureStorageHelper.read('default_address');
    final defaultLat = await SecureStorageHelper.read('default_latitude');
    final defaultLng = await SecureStorageHelper.read('default_longitude');
    final role = await SecureStorageHelper.getRole();

    if (name == null && phone == null) {
      return null;
    }

    return {
      'fullName': name ?? '',
      'phoneNumber': phone ?? '',
      'email': email,
      'profilePictureUrl': profilePicture,
      'defaultAddress': defaultAddress,
      'defaultLatitude': defaultLat != null ? double.tryParse(defaultLat) : null,
      'defaultLongitude': defaultLng != null ? double.tryParse(defaultLng) : null,
      'role': role,
    };
  }

  Future<void> saveProfile({
    required String odUserId,
    required String fullName,
    required String phoneNumber,
    String? email,
    String? profilePictureUrl,
    String? defaultAddress,
    double? defaultLatitude,
    double? defaultLongitude,
    String? role,
  }) async {
    await SecureStorageHelper.write('full_name', fullName);
    await SecureStorageHelper.write('phone_number', phoneNumber);
    
    if (email != null) {
      await SecureStorageHelper.write('email', email);
    }
    if (profilePictureUrl != null) {
      await SecureStorageHelper.write('profile_picture', profilePictureUrl);
    }
    if (defaultAddress != null) {
      await SecureStorageHelper.write('default_address', defaultAddress);
    }
    if (defaultLatitude != null) {
      await SecureStorageHelper.write('default_latitude', defaultLatitude.toString());
    }
    if (defaultLongitude != null) {
      await SecureStorageHelper.write('default_longitude', defaultLongitude.toString());
    }
    if (role != null) {
      await SecureStorageHelper.saveRole(role);
    }
  }

  Future<void> updateDefaultAddress(
    String odUserId,
    String address,
    double lat,
    double lng,
  ) async {
    await SecureStorageHelper.write('default_address', address);
    await SecureStorageHelper.write('default_latitude', lat.toString());
    await SecureStorageHelper.write('default_longitude', lng.toString());
  }

  Future<void> clearProfile() async {
    await SecureStorageHelper.write('full_name', '');
    await SecureStorageHelper.write('phone_number', '');
    await SecureStorageHelper.write('email', '');
    await SecureStorageHelper.write('profile_picture', '');
    await SecureStorageHelper.write('default_address', '');
    await SecureStorageHelper.write('default_latitude', '');
    await SecureStorageHelper.write('default_longitude', '');
  }
}