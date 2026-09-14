import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/inventory_model.dart';

class InventoryProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<List<InventoryModel>>> getInventory(String storeId) async {
    return await _network.getReq<List<InventoryModel>>(
      ApiConstants.storeInventory(storeId),
      fromJson: (inner) {
        if (inner is List) {
          return inner.map((e) => InventoryModel.fromJson(e)).toList();
        }
        if (inner is Map<String, dynamic> && inner['items'] is List) {
          return (inner['items'] as List).map((e) => InventoryModel.fromJson(e)).toList();
        }
        return <InventoryModel>[];
      },
    );
  }

  Future<ApiResponse<InventoryModel>> addInventoryItem(String storeId, Map<String, dynamic> data) async {
    return await _network.postReq<InventoryModel>(
      ApiConstants.storeInventory(storeId),
      data: data,
      fromJson: (inner) {
        if (inner is Map<String, dynamic>) {
          return InventoryModel.fromJson(inner);
        }
        return InventoryModel.fromJson({});
      },
    );
  }

  Future<ApiResponse<InventoryModel>> updateInventoryItem(String storeId, String itemId, Map<String, dynamic> data) async {
    return await _network.putReq<InventoryModel>(
      ApiConstants.inventoryItem(storeId, itemId),
      data: data,
      fromJson: (inner) {
        if (inner is Map<String, dynamic>) {
          return InventoryModel.fromJson(inner);
        }
        return InventoryModel.fromJson({});
      },
    );
  }

  Future<ApiResponse<dynamic>> addInventoryTransaction(String storeId, String itemId, Map<String, dynamic> data) async {
    return await _network.postReq<dynamic>(
      ApiConstants.inventoryTransactions(storeId, itemId),
      data: data,
    );
  }
}
