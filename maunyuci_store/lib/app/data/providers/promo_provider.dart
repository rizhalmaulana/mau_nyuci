import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/promo_model.dart';

class PromoProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<List<PromoModel>>> getPromos() async {
    return await _network.getReq<List<PromoModel>>(
      ApiConstants.storePromo,
      fromJson: (inner) {
        if (inner is List) {
          return inner.map((e) => PromoModel.fromJson(e)).toList();
        }
        return <PromoModel>[];
      },
    );
  }

  Future<ApiResponse<PromoModel>> addPromo(Map<String, dynamic> data) async {
    return await _network.postReq<PromoModel>(
      ApiConstants.storePromo,
      data: data,
      fromJson: (inner) {
        if (inner is Map<String, dynamic>) {
          return PromoModel.fromJson(inner);
        }
        return PromoModel.fromJson({});
      },
    );
  }

  Future<ApiResponse<PromoModel>> updatePromo(String id, Map<String, dynamic> data) async {
    return await _network.putReq<PromoModel>(
      '${ApiConstants.storePromo}/$id',
      data: data,
      fromJson: (inner) {
        if (inner is Map<String, dynamic>) {
          return PromoModel.fromJson(inner);
        }
        return PromoModel.fromJson({});
      },
    );
  }

  Future<ApiResponse<dynamic>> deletePromo(String id) async {
    return await _network.deleteReq<dynamic>('${ApiConstants.storePromo}/$id');
  }
}
