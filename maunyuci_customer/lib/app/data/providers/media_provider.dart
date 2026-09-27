import 'package:dio/dio.dart';
import 'package:maunyuci_core/maunyuci_core.dart';

class MediaProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<String>> uploadLaundryImage(String filePath) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    // We expect { "message": "Upload berhasil", "url": "https://..." }
    final response = await _network.postReq<Map<String, dynamic>>(
      ApiConstants.uploadLaundryImage,
      data: formData,
      isFormData: true,
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      final url = data['url']?.toString();
      if (url != null && url.isNotEmpty) {
        return ApiResponse<String>(
          success: true,
          data: url,
          message: response.message,
        );
      }
    }

    return ApiResponse<String>(
      success: false,
      message: response.message ?? 'Gagal mengunggah foto cucian',
    );
  }
}
