import 'package:dio/dio.dart';
import 'package:maunyuci_core/maunyuci_core.dart';

class UserProvider {
  final ApiClient _apiClient = ApiClient();

  Future<Response> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.profile);
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Response> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? profilePictureUrl,
    String? defaultAddress,
    double? defaultLatitude,
    double? defaultLongitude,
  }) async {
    try {
      final data = <String, dynamic>{};
      
      if (fullName != null) data['fullName'] = fullName;
      if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
      if (email != null) data['email'] = email;
      if (profilePictureUrl != null) data['profilePictureUrl'] = profilePictureUrl;
      if (defaultAddress != null) data['defaultAddress'] = defaultAddress;
      if (defaultLatitude != null) data['defaultLatitude'] = defaultLatitude;
      if (defaultLongitude != null) data['defaultLongitude'] = defaultLongitude;

      final response = await _apiClient.dio.put(
        ApiConstants.profile,
        data: data,
      );
      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }
}
