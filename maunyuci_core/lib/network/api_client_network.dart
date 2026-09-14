import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_response.dart';

/// Wrapper resmi untuk semua HTTP call.
/// Provider/Controller wajib lewat sini, jangan pakai `ApiClient().dio`
/// langsung agar envelope backend, Bearer Token, dan error handling konsisten.
///
/// Bentuk envelope backend yang didukung:
/// `{ success: bool, data: <inner>, message: String }`
/// `fromJson` selalu menerima <inner> (sudah di-unwrap), bukan full body.
class ApiClientNetwork {
  final ApiClient _apiClient = ApiClient();

  ApiResponse<T> _handleResponse<T>(Response response, T Function(dynamic)? fromJson) {
    final statusCode = response.statusCode;
    final body = response.data;
    final httpOk = statusCode != null && statusCode >= 200 && statusCode < 300;

    dynamic inner = body;
    bool success = httpOk;
    String? message;

    if (body is Map<String, dynamic> &&
        (body.containsKey('data') || body.containsKey('success') || body.containsKey('message'))) {
      if (body['success'] is bool) {
        success = (body['success'] as bool) && httpOk;
      }
      message = body['message']?.toString();
      inner = body.containsKey('data') ? body['data'] : body;

      if (!success) {
        List<String>? errors;
        Map<String, dynamic>? errorDetails;
        final rawErrors = body['errors'];
        if (rawErrors is List) {
          errors = rawErrors.map((e) => e.toString()).toList();
        } else if (rawErrors is Map<String, dynamic>) {
          errorDetails = rawErrors;
        }
        return ApiResponse<T>(
          success: false,
          message: message ?? 'Request gagal',
          statusCode: statusCode,
          errors: errors,
          errorDetails: errorDetails,
        );
      }
    }

    if (fromJson == null) {
      try {
        if (inner == null) {
          return ApiResponse<T>(
            success: success,
            message: message ?? 'Success',
            statusCode: statusCode,
          );
        }
        // T == dynamic: teruskan inner apa adanya (Map/List/primitif).
        return ApiResponse<T>(
          success: success,
          data: inner as T,
          message: message ?? 'Success',
          statusCode: statusCode,
        );
      } catch (_) {
        return ApiResponse<T>(
          success: success,
          message: message ?? 'Success',
          statusCode: statusCode,
        );
      }
    }

    try {
      final parsed = fromJson(inner);
      return ApiResponse<T>(
        success: success,
        data: parsed,
        message: message ?? 'Success',
        statusCode: statusCode,
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: e.toString().replaceAll('Exception: ', ''),
        statusCode: statusCode,
      );
    }
  }

  ApiResponse<T> _handleError<T>(DioException e) {
    // Log mentah untuk debugging (pesan asli BE bisa ter-masking oleh handleErrorMessage).
    // ignore: avoid_print
    print('[API ERROR] ${e.requestOptions.method} ${e.requestOptions.path} '
        '-> HTTP ${e.response?.statusCode} | RAW: ${e.response?.data}');
    String message = ApiClient.handleErrorMessage(e.response?.data);
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      message = 'Koneksi terputus. Silakan periksa jaringan Anda.';
    } else if (e.type == DioExceptionType.connectionError) {
      message = 'Tidak ada koneksi internet.';
    }

    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: e.response?.statusCode,
      errorDetails: e.response?.data is Map<String, dynamic> ? e.response?.data : null,
    );
  }

  /// Content-type ditentukan per-request (tidak mutasi global Dio).
  Options _optionsFor(dynamic data, {bool isFormData = false}) {
    if (isFormData || data is FormData) {
      return Options(contentType: 'multipart/form-data');
    }
    return Options(contentType: 'application/json');
  }

  Future<ApiResponse<T>> getReq<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _apiClient.dio.get(path, queryParameters: queryParameters);
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>(success: false, message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<ApiResponse<T>> postReq<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    bool isFormData = false,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _optionsFor(data, isFormData: isFormData),
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>(success: false, message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<ApiResponse<T>> putReq<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    bool isFormData = false,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _optionsFor(data, isFormData: isFormData),
      );
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>(success: false, message: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<ApiResponse<T>> deleteReq<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _apiClient.dio.delete(path, queryParameters: queryParameters);
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>(success: false, message: e.toString().replaceAll('Exception: ', ''));
    }
  }
}
