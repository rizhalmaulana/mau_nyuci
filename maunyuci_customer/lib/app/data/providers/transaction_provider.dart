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

  Future<ApiResponse<OrderModel>> getOrderById(String orderId) async {
    return await _network.getReq<OrderModel>(
      ApiConstants.getOrderById(orderId),
      fromJson: (data) => OrderModel.fromJson(data),
    );
  }

  Future<ApiResponse<void>> cancelOrder(String orderId, String reason) async {
    return await _network.putReq<void>(
      ApiConstants.customerCancelOrder(orderId), // make sure this maps to 'Order/$orderId/customer-cancel' in ApiConstants
      data: {'reason': reason},
    );
  }

  Future<ApiResponse<void>> uploadReceipt(String orderId, String imageUrl) async {
    return await _network.putReq<void>(
      ApiConstants.customerUploadReceipt(orderId),
      data: {'paymentReceiptUrl': imageUrl},
    );
  }
}