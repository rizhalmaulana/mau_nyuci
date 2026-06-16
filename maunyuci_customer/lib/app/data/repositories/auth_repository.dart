import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../model/auth/auth_profile_response_model.dart';
import '../providers/auth_provider.dart';

class AuthRepository {
  final AuthProvider _provider = AuthProvider();

  Future<AuthProfileResponseModel> getProfile() async {
    try {
      final response = await _provider.getProfile();
      if (response.statusCode == 200 && response.data != null) {
        return AuthProfileResponseModel.fromJson(response.data);
      }
      throw Exception("Gagal mengambil data profil");
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Koneksi terputus. Waktu permintaan habis (timeout).");
      }
      throw Exception(e.message ?? "Gagal menghubungi server");
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<AuthProfileResponseModel> updateProfile({
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

      if (response.statusCode == 200 && response.data != null) {
        return AuthProfileResponseModel.fromJson(response.data);
      }
      throw Exception("Gagal memperbarui profil");
    } on DioException catch (e) {
      debugPrint("Status Code: ${e.response?.statusCode}");
      debugPrint("Response Data: ${e.response?.data}");

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Koneksi terputus. Waktu permintaan habis (timeout).");
      }
      
      String errorMsg = e.message ?? "Gagal menghubungi server";
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
           final dataMap = e.response!.data as Map;
           if (dataMap.containsKey('message')) {
             errorMsg = dataMap['message'].toString();
           } else {
             errorMsg = dataMap.toString();
           }
        } else {
           errorMsg = e.response!.data.toString();
        }
      }
      throw Exception(errorMsg);
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

      if (response.statusCode != 200) {
        throw Exception("Gagal mengubah password");
      }
    } on DioException catch (e) {
      debugPrint("Status Code: ${e.response?.statusCode}");
      debugPrint("Response Data: ${e.response?.data}");

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception("Koneksi terputus. Waktu permintaan habis (timeout).");
      }
      
      String errorMsg = e.message ?? "Gagal menghubungi server";
      if (e.response?.data != null) {
        if (e.response!.data is Map) {
           final dataMap = e.response!.data as Map;
           if (dataMap.containsKey('message')) {
             errorMsg = dataMap['message'].toString();
           } else {
             errorMsg = dataMap.toString();
           }
        } else {
           errorMsg = e.response!.data.toString();
        }
      }
      throw Exception(errorMsg);
    } catch (e) {
      debugPrint(e.toString());
      throw Exception(e.toString());
    }
  }
}
