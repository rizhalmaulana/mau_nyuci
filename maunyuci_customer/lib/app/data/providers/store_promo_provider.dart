import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/promo_model.dart';

class StorePromoProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<List<PromoModel>>> getStorePromos(String storeId) async {
    return await _network.getReq<List<PromoModel>>(
      ApiConstants.getStorePromosByStore(storeId),
      fromJson: (data) {
        if (data is List) {
          return data.map((e) => PromoModel.fromJson(e)).toList();
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List).map((e) => PromoModel.fromJson(e)).toList();
        }
        return [];
      },
    );
  }
}
