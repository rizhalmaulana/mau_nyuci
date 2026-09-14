import 'package:dio/dio.dart'; // Untuk FormData
import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/store_model.dart';

class StoreProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<dynamic>> getMyStore() async {
    return await _network.getReq<dynamic>(
      ApiConstants.getMyStore,
    );
  }

  Future<ApiResponse<dynamic>> registerStore(FormData data) async {
    return await _network.postReq<dynamic>(
      ApiConstants.registerStore,
      data: data,
      isFormData: true,
    );
  }

  Future<ApiResponse<dynamic>> updateStore(FormData data) async {
    return await _network.putReq<dynamic>(
      ApiConstants.updateStore,
      data: data,
      isFormData: true,
    );
  }

  Future<ApiResponse<StoreModel>> getStoreProfile() async {
    return await _network.getReq<StoreModel>(
      ApiConstants.getMyStore,
      // inner sudah di-unwrap dari envelope {success,data,message} oleh ApiClientNetwork.
      fromJson: (inner) {
        if (inner is Map<String, dynamic>) {
          if (inner['isStoreRegistered'] == false) {
            throw Exception(inner['message'] ?? 'Toko belum terdaftar');
          }
          return StoreModel.fromJson(inner);
        }
        return StoreModel.fromJson({});
      },
    );
  }

  Future<ApiResponse<DashboardTransactionModel>> getStoreTransactions(String storeId, {String? startDate, String? endDate}) async {
    final queryParams = <String, dynamic>{};
    if (startDate != null && startDate.isNotEmpty) queryParams['startDate'] = startDate;
    if (endDate != null && endDate.isNotEmpty) queryParams['endDate'] = endDate;

    return await _network.getReq<DashboardTransactionModel>(
      ApiConstants.storeTransactions(storeId),
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (inner) {
        if (inner is Map<String, dynamic>) {
          return DashboardTransactionModel.fromJson(inner);
        }
        return DashboardTransactionModel.fromJson({});
      },
    );
  }
}
