import 'package:dio/dio.dart'; // Still needed for FormData
import 'package:flutter/cupertino.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/user_model.dart';

class AuthProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<dynamic>> login(String phoneNumber, String password) async {
    return await _network.postReq<dynamic>(
      ApiConstants.login,
      data: {
        "phoneNumber": phoneNumber,
        "password": password,
        "appType": "Customer",
      },
    );
  }

  Future<ApiResponse<dynamic>> register({
    required String fullName,
    required String phoneNumber,
    String? email,
    required String password,
  }) async {
    return await _network.postReq<dynamic>(
      ApiConstants.register,
      data: {
        "fullName": fullName,
        "phoneNumber": phoneNumber,
        "email": email ?? '',
        "password": password,
      },
    );
  }

  Future<ApiResponse<dynamic>> checkUser(String email) async {
    return await _network.getReq<dynamic>(
      ApiConstants.checkUser,
      queryParameters: {"email": email},
    );
  }

  Future<ApiResponse<dynamic>> firebaseAuth(String idToken) async {
    return await _network.postReq<dynamic>(
      ApiConstants.firebaseAuth,
      data: {
        "idToken": idToken,
        "appType": "Customer",
        "fullName": null,
        "phoneNumber": null
      },
    );
  }

  Future<ApiResponse<UserModel>> updateProfile({
    required String fullName,
    String? phoneNumber,
    String? email,
    String? defaultAddress,
    double? defaultLatitude,
    double? defaultLongitude,
    String? profilePicturePath,
    String? password,
  }) async {
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

      final mediaResponse = await _network.postReq<dynamic>(
        ApiConstants.uploadProfilePicture,
        data: mediaFormData,
        isFormData: true,
      );
      
      if (mediaResponse.success && mediaResponse.data != null) {
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

    return await _network.putReq<UserModel>(
      ApiConstants.profile,
      data: dataMap,
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          if (data['data'] != null) return UserModel.fromJson(data['data']);
          return UserModel.fromJson(data);
        }
        return UserModel.fromJson({});
      },
    );
  }

  Future<ApiResponse<UserModel>> getProfile() async {
    return await _network.getReq<UserModel>(
      ApiConstants.profile,
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          if (data['id'] != null) return UserModel.fromJson(data);
          if (data['data'] != null) return UserModel.fromJson(data['data']);
        }
        return UserModel.fromJson({});
      },
    );
  }

  Future<ApiResponse<dynamic>> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return await _network.putReq<dynamic>(
      ApiConstants.changePassword,
      data: {
        "oldPassword": oldPassword,
        "newPassword": newPassword,
      },
    );
  }

  Future<ApiResponse<dynamic>> syncFcmToken(String token) async {
    return await _network.postReq<dynamic>(
      ApiConstants.syncFcmToken,
      data: {"token": token},
    );
  }
}