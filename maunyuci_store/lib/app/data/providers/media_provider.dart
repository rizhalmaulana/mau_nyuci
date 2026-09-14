import 'dart:io';
import 'package:dio/dio.dart';
import 'package:maunyuci_core/maunyuci_core.dart';

class MediaProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  String _extractUrl(dynamic inner) {
    if (inner == null) return '';
    if (inner is String) return inner;
    if (inner is Map<String, dynamic>) {
      final url = inner['url'] ?? inner['profilePictureUrl'] ?? inner['data'];
      if (url is String) return url;
      return url?.toString() ?? '';
    }
    return inner.toString();
  }

  Future<ApiResponse<String>> uploadProfilePicture(File file) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    return await _network.postReq<String>(
      ApiConstants.uploadProfilePicture,
      data: formData,
      isFormData: true,
      fromJson: _extractUrl,
    );
  }

  Future<ApiResponse<String>> uploadCatalogImage(File file) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    return await _network.postReq<String>(
      ApiConstants.uploadCatalogImage,
      data: formData,
      isFormData: true,
      fromJson: _extractUrl,
    );
  }

  Future<ApiResponse<String>> uploadQrisImage(File file) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    return await _network.postReq<String>(
      ApiConstants.uploadQrisImage,
      data: formData,
      isFormData: true,
      fromJson: _extractUrl,
    );
  }
}
