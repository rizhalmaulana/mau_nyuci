import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:maunyuci_core/maunyuci_core.dart';

class AuthProvider {
  final ApiClient _apiClient = ApiClient();

  Future<Response> login(String phoneNumber, String password) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {
          "phoneNumber": phoneNumber,
          "password": password,
        },
      );
      return response;
    } on DioException catch (e) {
      debugPrint("Error Message: ${e.message}");
      rethrow;
    }
  }

  Future<Response> register({
    required String fullName,
    required String phoneNumber,
    String? email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.register,
        data: {
          "fullName": fullName,
          "phoneNumber": phoneNumber,
          "email": email ?? '',
          "password": password,
        },
      );
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Response> checkUser(String email) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.checkUser,
        queryParameters: {"email": email},
      );
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Response> firebaseAuth(String idToken) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.firebaseAuth,
        data: {
          "idToken": idToken,
          "fullName": null,
          "phoneNumber": null
        },
      );
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Response> updateProfile({
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
      String? profilePictureUrl;
      
      // Tahap 1: Upload gambar jika ada (dan jika format filepath lokal)
      if (profilePicturePath != null && profilePicturePath.isNotEmpty && !profilePicturePath.startsWith('http')) {
        String fileName = profilePicturePath.split('/').last;
        String lowerName = fileName.toLowerCase();
        if (!lowerName.endsWith('.jpg') && !lowerName.endsWith('.jpeg') && !lowerName.endsWith('.png')) {
          fileName = '$fileName.jpg';
        }
        
        final mediaFormData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            profilePicturePath,
            filename: fileName,
          ),
        });

        final mediaResponse = await _apiClient.dio.post(
          ApiConstants.uploadProfilePicture,
          data: mediaFormData,
          options: Options(
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );
        
        if (mediaResponse.statusCode == 200 && mediaResponse.data != null) {
          profilePictureUrl = mediaResponse.data['url'];
        }
      }

      // Tahap 2: Update profil menggunakan JSON
      final Map<String, dynamic> dataMap = {
        'fullName': fullName,
      };

      if (phoneNumber != null && phoneNumber.isNotEmpty) dataMap['phoneNumber'] = phoneNumber;
      if (email != null && email.isNotEmpty) dataMap['email'] = email;
      if (defaultAddress != null && defaultAddress.isNotEmpty) dataMap['defaultAddress'] = defaultAddress;
      if (defaultLatitude != null) dataMap['defaultLatitude'] = defaultLatitude;
      if (defaultLongitude != null) dataMap['defaultLongitude'] = defaultLongitude;
      if (password != null && password.isNotEmpty) dataMap['password'] = password;
      if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) dataMap['profilePictureUrl'] = profilePictureUrl;

      final response = await _apiClient.dio.put(
        ApiConstants.profile,
        data: dataMap,
      );
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Response> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.profile);
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Response> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConstants.changePassword,
        data: {
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        },
      );
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }
}