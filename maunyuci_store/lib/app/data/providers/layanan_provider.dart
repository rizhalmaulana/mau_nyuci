import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/layanan_model.dart';

class LayananProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<List<LayananModel>>> getMyCatalog() async {
    return await _network.getReq<List<LayananModel>>(
      ApiConstants.getMyCatalog,
      fromJson: (inner) {
        if (inner is List) {
          return inner.map((json) => LayananModel.fromJson(json)).toList();
        }
        return <LayananModel>[];
      },
    );
  }

  Future<ApiResponse<LayananModel>> addLayanan(LayananModel layanan) async {
    return await _network.postReq<LayananModel>(
      ApiConstants.addCatalog,
      data: layanan.toJson(),
      fromJson: (inner) {
        if (inner is Map<String, dynamic>) {
          return LayananModel.fromJson(inner);
        }
        return LayananModel.fromJson({});
      },
    );
  }

  Future<ApiResponse<LayananModel>> updateLayanan(String id, LayananModel layanan) async {
    return await _network.putReq<LayananModel>(
      ApiConstants.updateCatalog(id),
      data: layanan.toJson(),
      fromJson: (inner) {
        if (inner is Map<String, dynamic>) {
          return LayananModel.fromJson(inner);
        }
        return LayananModel.fromJson({});
      },
    );
  }

  Future<ApiResponse<void>> deleteLayanan(String id) async {
    final res = await _network.deleteReq<dynamic>(ApiConstants.deleteCatalog(id));
    return ApiResponse<void>(
      success: res.success,
      message: res.message,
      statusCode: res.statusCode,
    );
  }

  Future<ApiResponse<List<String>>> getAvailableIcons() async {
    return await _network.getReq<List<String>>(
      ApiConstants.getAvailableIcons,
      fromJson: (inner) {
        if (inner is List) {
          return inner.map((e) => e.toString()).toList();
        }
        return <String>[];
      },
    );
  }
}
