import 'package:dio/dio.dart';

String handleApiError(dynamic responseData) {
  if (responseData == null) {
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  if (responseData is String) {
    return responseData;
  }

  if (responseData is Map<String, dynamic>) {
    if (responseData.containsKey('message')) {
      return responseData['message'];
    }
    
    if (responseData.containsKey('errors')) {
      final errors = responseData['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.join('\n');
      }
      if (errors is Map && errors.isNotEmpty) {
        return errors.values.first?.toString() ?? 'Terjadi kesalahan.';
      }
    }
  }

  return 'Terjadi kesalahan. Silakan coba lagi.';
}
