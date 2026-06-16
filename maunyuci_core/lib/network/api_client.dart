import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_helper.dart';

class ApiClient {
  late Dio dio;

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      contentType: 'application/json',
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorageHelper.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          await SecureStorageHelper.clearAll();
        }
        return handler.next(e);
      },
    ));
  }

  Dio get formDataClient {
    dio.options.contentType = 'multipart/form-data';
    return dio;
  }

  static String handleErrorMessage(dynamic responseData) {
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
}