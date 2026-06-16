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
      final Map<String, dynamic> dataMap = {
        'FullName': fullName,
      };

      if (phoneNumber != null && phoneNumber.isNotEmpty) dataMap['PhoneNumber'] = phoneNumber;
      if (email != null && email.isNotEmpty) dataMap['Email'] = email;
      if (defaultAddress != null && defaultAddress.isNotEmpty) dataMap['DefaultAddress'] = defaultAddress;
      if (defaultLatitude != null) dataMap['DefaultLatitude'] = defaultLatitude.toString();
      if (defaultLongitude != null) dataMap['DefaultLongitude'] = defaultLongitude.toString();
      if (password != null && password.isNotEmpty) dataMap['Password'] = password;

      final formData = FormData.fromMap(dataMap);

      if (profilePicturePath != null && profilePicturePath.isNotEmpty) {
        String fileName = profilePicturePath.split('/').last;
        String lowerName = fileName.toLowerCase();
        if (!lowerName.endsWith('.jpg') && !lowerName.endsWith('.jpeg') && !lowerName.endsWith('.png')) {
          fileName = '$fileName.jpg';
        }
        formData.files.add(
          MapEntry(
            'ProfilePicture',
            await MultipartFile.fromFile(
              profilePicturePath,
              filename: fileName,
            ),
          ),
        );
      }

      final response = await _apiClient.dio.put(
        ApiConstants.profile,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
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