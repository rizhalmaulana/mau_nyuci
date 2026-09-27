import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/store_bank_account_model.dart';

class StoreBankAccountProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<List<StoreBankAccountModel>>> getBankAccountsByStoreId(String storeId) async {
    return await _network.getReq<List<StoreBankAccountModel>>(
      ApiConstants.getStoreBankAccountsByStore(storeId),
      fromJson: (data) {
        if (data is List) {
          return data.map((e) => StoreBankAccountModel.fromJson(e)).toList();
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List).map((e) => StoreBankAccountModel.fromJson(e)).toList();
        }
        return [];
      },
    );
  }
}
