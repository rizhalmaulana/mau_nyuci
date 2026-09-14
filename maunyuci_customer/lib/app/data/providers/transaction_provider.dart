import 'package:flutter/foundation.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../model/transaction/transaction_response_model.dart';

class TransactionProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<List<TransactionResponseModel>>> fetchTransactionsCustomer({
    int page = 1,
    int limit = 15,
    String? status,
    String? dateFilter,
  }) async {
    final Map<String, dynamic> query = {
      'page': page,
      'pageSize': limit,
    };
    if (status != null && status.isNotEmpty && status != 'Semua') {
      query['status'] = status;
    }
    if (dateFilter != null && dateFilter.isNotEmpty && dateFilter != 'Semua') {
      query['dateFilter'] = dateFilter;
    }
    return await _network.getReq<List<TransactionResponseModel>>(
      ApiConstants.customerOrders,
      queryParameters: query,
      fromJson: (data) {
        if (data is List) {
          return data.map((e) => TransactionResponseModel.fromJson(e)).toList();
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List).map((e) => TransactionResponseModel.fromJson(e)).toList();
        }
        return [];
      },
    );
  }
}