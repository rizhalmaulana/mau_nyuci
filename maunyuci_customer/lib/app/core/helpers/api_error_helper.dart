import 'package:dio/dio.dart';
import 'package:maunyuci_core/maunyuci_core.dart';

String handleApiError(dynamic e) {
  if (e == null) {
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  if (e is DioException) {
    // 1. Try to extract message from response body first (specific business errors)
    final responseData = e.response?.data;
    if (responseData != null) {
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('message') && responseData['message'] != null && responseData['message'].toString().trim().isNotEmpty) {
          return responseData['message'].toString();
        }
        if (responseData.containsKey('errors')) {
          final errors = responseData['errors'];
          if (errors is List && errors.isNotEmpty) {
            return errors.join('\n');
          }
          if (errors is Map && errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError != null && firstError.toString().trim().isNotEmpty) {
              return firstError.toString();
            }
          }
        }
      } else if (responseData is String && responseData.trim().isNotEmpty) {
        if (!responseData.startsWith('<!DOCTYPE') && !responseData.startsWith('<html')) {
          return responseData;
        }
      }
    }

    // 2. Fall back to HTTP status codes
    if (e.response?.statusCode == 401) {
      return 'Sesi Anda telah berakhir. Silakan masuk kembali.';
    }
    if (e.response?.statusCode == 403) {
      return 'Anda tidak memiliki akses untuk melakukan tindakan ini.';
    }
    if (e.response?.statusCode == 404) {
      return 'Data tidak ditemukan.';
    }
    if (e.response?.statusCode == 500) {
      return 'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi terputus. Waktu permintaan habis.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak ada koneksi internet, Silahkan aktifkan koneksi di perangkat kamu.';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  if (e is Exception) {
    final errStr = e.toString();
    if (errStr.startsWith('Exception: ')) {
      return errStr.replaceFirst('Exception: ', '');
    }
    return errStr;
  }

  if (e is String) {
    if (e.trim().isEmpty) {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
    return e;
  }

  return e.toString();
}

String getFullImageUrl(String? path) {
  if (path == null || path.trim().isEmpty) return '';

  String fullUrl;
  if (path.startsWith('http://') || path.startsWith('https://')) {
    fullUrl = path;
  } else {
    String serverUrl = ApiConstants.baseUrl;
    if (serverUrl.endsWith('/api/')) {
      serverUrl = serverUrl.substring(0, serverUrl.length - 4);
    } else if (serverUrl.endsWith('/api')) {
      serverUrl = serverUrl.substring(0, serverUrl.length - 3);
    }

    fullUrl = path.startsWith('/')
        ? '$serverUrl${path.substring(1)}'
        : '$serverUrl$path';
  }

  return fullUrl;
}