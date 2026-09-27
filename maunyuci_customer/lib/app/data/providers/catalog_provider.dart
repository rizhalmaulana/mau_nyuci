import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/catalog_model.dart';

class CatalogProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<List<CatalogModel>>> getStoreCatalog(String storeId) async {
    return await _network.getReq<List<CatalogModel>>(
      ApiConstants.getStoreCatalog(storeId),
      fromJson: (data) {
        if (data is List) {
          return data.map((e) => CatalogModel.fromJson(e)).toList();
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List).map((e) => CatalogModel.fromJson(e)).toList();
        }
        return [];
      },
    );
  }
}
