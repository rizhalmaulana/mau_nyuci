import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
      debugPrint("Store Auth Error Message: ${e.message}");
      rethrow;
    }
  }
}
