import 'package:dio/dio.dart';
import 'package:maunyuci_core/maunyuci_core.dart';

class OrderProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  List<OrderModel> _parseOrderList(dynamic inner) {
    if (inner is List) {
      return inner.map((json) => OrderModel.fromJson(json)).toList();
    }
    if (inner is Map<String, dynamic> && inner['data'] is List) {
      return (inner['data'] as List).map((json) => OrderModel.fromJson(json)).toList();
    }
    return <OrderModel>[];
  }

  Future<ApiResponse<List<OrderModel>>> getStoreOrders(String storeId) async {
    return await _network.getReq<List<OrderModel>>(
      ApiConstants.getStoreOrders(storeId),
      fromJson: _parseOrderList,
    );
  }

  Future<ApiResponse<List<OrderModel>>> getStoreOrderHistory(String storeId, int page, int pageSize, {String? search, String? startDate, String? endDate}) async {
    return await _network.getReq<List<OrderModel>>(
      ApiConstants.getStoreOrderHistory(storeId, page, pageSize, search: search, startDate: startDate, endDate: endDate),
      fromJson: _parseOrderList,
    );
  }

  Future<ApiResponse<OrderModel>> getOrderById(String orderId) async {
    return await _network.getReq<OrderModel>(
      ApiConstants.getOrderById(orderId),
      fromJson: (inner) {
        if (inner is Map<String, dynamic>) {
          return OrderModel.fromJson(inner);
        }
        return OrderModel.fromJson({});
      },
    );
  }

  Future<ApiResponse<String>> posCheckoutOrder(PosCheckoutPayload payload) async {
    return await _network.postReq<String>(
      ApiConstants.posCheckout,
      data: payload.toJson(),
      fromJson: (inner) {
        if (inner is Map<String, dynamic>) {
          return inner['id']?.toString() ?? '';
        }
        return inner?.toString() ?? '';
      },
    );
  }

  Future<ApiResponse<String>> updateOrderStatus(String orderId, String endpoint) async {
    // PUT tanpa body; message sukses diambil dari envelope oleh ApiClientNetwork.
    return await _network.putReq<String>(
      endpoint,
      fromJson: (inner) => inner?.toString() ?? '',
    );
  }

  Future<ApiResponse<String>> completeOrderWithPayment(String orderId, String finalPaymentProvider) async {
    return await _network.putReq<String>(
      ApiConstants.completeOrder(orderId),
      data: {'finalPaymentProvider': finalPaymentProvider},
      fromJson: (inner) => inner?.toString() ?? '',
    );
  }

  Future<ApiResponse<String>> verifyPayment(String orderId, bool isApproved) async {
    return await _network.putReq<String>(
      ApiConstants.verifyPayment(orderId),
      data: {'isApproved': isApproved},
      fromJson: (inner) => inner?.toString() ?? '',
    );
  }

  Future<ApiResponse<String>> uploadStoreReceipt(String orderId, String filePath) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });

    return await _network.postReq<String>(
      ApiConstants.uploadStoreReceipt(orderId),
      data: formData,
      isFormData: true,
      fromJson: (inner) => inner?.toString() ?? '',
    );
  }
}
