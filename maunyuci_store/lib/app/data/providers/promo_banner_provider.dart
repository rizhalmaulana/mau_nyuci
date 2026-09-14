import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/promo_banner_model.dart';

class PromoBannerProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<List<PromoBannerModel>>> getBanners(String appType) async {
    return await _network.getReq<List<PromoBannerModel>>(
      ApiConstants.promoBanners(appType),
      fromJson: (inner) {
        if (inner is List) {
          return inner.map((e) => PromoBannerModel.fromJson(e)).toList();
        }
        return <PromoBannerModel>[];
      },
    );
  }
}
