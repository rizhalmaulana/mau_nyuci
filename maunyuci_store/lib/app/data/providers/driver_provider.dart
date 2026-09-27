import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/driver_model.dart';

class DriverProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  /// GET Driver/store/{storeId}/drivers — Auth Bearer owner/staff
  /// ditangani otomatis oleh ApiClient.
  Future<ApiResponse<List<StoreDriverModel>>> getStoreDrivers(String storeId) async {
    return await _network.getReq<List<StoreDriverModel>>(
      ApiConstants.storeDrivers(storeId),
      fromJson: (inner) {
        if (inner is List) {
          return inner
              .map((e) => StoreDriverModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <StoreDriverModel>[];
      },
    );
  }
}
