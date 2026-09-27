import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/store_model.dart';

class StoreProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<List<StoreModel>>> getNearbyStores(double lat, double lng) async {
    return await _network.getReq<List<StoreModel>>(
      ApiConstants.getNearbyStores,
      queryParameters: {
        'lat': lat,
        'lng': lng,
        'radius': 5
      },
      fromJson: (data) {
        if (data is List) {
          return data.map((e) => StoreModel.fromJson(e)).toList();
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List).map((e) => StoreModel.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  Future<ApiResponse<StoreModel>> getStoreById(String storeId) async {
    return await _network.getReq<StoreModel>(
      ApiConstants.getStoreById(storeId),
      fromJson: (inner) {
        if (inner is Map<String, dynamic>) {
          return StoreModel.fromJson(inner);
        }
        return StoreModel.fromJson({});
      },
    );
  }
}
