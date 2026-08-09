import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:maunyuci_core/maunyuci_core.dart';

class StoreProvider {
  final ApiClient _apiClient = ApiClient();

  Future<Response> getMyStore() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.getMyStore);
      return response;
    } on DioException catch (e) {
      debugPrint("StoreProvider getMyStore Error Message: ${e.message}");
      rethrow;
    }
  }

  Future<Response> registerStore(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.registerStore,
        data: data,
      );
      return response;
    } on DioException catch (e) {
      debugPrint("StoreProvider registerStore Error Message: ${e.message}");
      rethrow;
    }
  }
}
