import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider _provider = AuthProvider();

  Future<UserModel> getProfile() async {
    try {
      final response = await _provider.getProfile();
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw Exception(response.message ?? "Gagal mengambil data profil");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserModel> updateProfile({
    required String fullName,
    String? phoneNumber,
    String? email,
    String? defaultAddress,
    double? defaultLatitude,
    double? defaultLongitude,
    String? profilePicturePath,
    String? password,
  }) async {
    try {
      final response = await _provider.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        defaultAddress: defaultAddress,
        defaultLatitude: defaultLatitude,
        defaultLongitude: defaultLongitude,
        profilePicturePath: profilePicturePath,
        password: password,
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
      throw Exception(response.message ?? "Gagal memperbarui profil");
    } catch (e) {
      debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _provider.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (!response.success) {
        throw Exception(response.message ?? "Gagal mengubah password");
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }
}
