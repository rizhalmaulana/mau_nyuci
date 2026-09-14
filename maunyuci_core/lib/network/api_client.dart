import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage_helper.dart';

class ApiClient {
  late Dio dio;
  static void Function()? onUnauthorized;
  static void Function()? onForbidden; // Added for 403 handling

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
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
          final path = e.requestOptions.path;
          if (path.contains(ApiConstants.login) ||
              path.contains(ApiConstants.firebaseAuth) ||
              path.contains(ApiConstants.register)) {
            return handler.next(e);
          }

          await SecureStorageHelper.clearAll();
          if (onUnauthorized != null) {
            onUnauthorized!();
          }
        } else if (e.response?.statusCode == 403) {
          if (onForbidden != null) {
            onForbidden!();
          }
        }
        return handler.next(e);
      },
    ));
  }

  /// Transport internal. Jangan panggil [dio] langsung dari Provider/Controller.
  /// Gunakan [ApiClientNetwork] agar parsing envelope, error handling,
  /// dan content-type (JSON vs multipart) konsisten.
  /// Getter ini dipertahankan hanya untuk kompatibilitas internal.
  @Deprecated('Gunakan ApiClientNetwork agar tidak bypass interceptor/parsing envelope')
  Dio get formDataClient => dio;

  static String handleErrorMessage(dynamic responseData) {
    if (responseData == null) {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }

    String extractMessage() {
      if (responseData is String) {
        return responseData;
      }

      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('message')) {
          return responseData['message'].toString();
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

    String message = extractMessage();

    // Saring pesan error teknis (database/server exception) menjadi bahasa yang dimengerti user
    final technicalKeywords = [
      'inner exception',
      'saving the entity changes',
      'SqlException',
      'NullReferenceException',
      'System.Exception',
      'Stack trace',
    ];

    for (var keyword in technicalKeywords) {
      if (message.toLowerCase().contains(keyword.toLowerCase())) {
        return 'Maaf, terjadi kendala pada sistem kami. Silakan periksa kembali kelengkapan data Anda atau coba beberapa saat lagi.';
      }
    }

    return message;
  }
}