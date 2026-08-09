import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:maunyuci_core/constants/api_constants.dart';
import 'package:maunyuci_core/network/api_client.dart';

class TransactionProvider {
  final ApiClient _apiClient = ApiClient();

  Future<Response> fetchTransactionsCustomer({
    int page = 1,
    int limit = 15,
    String? status,
    String? dateFilter,
  }) async {
    final Map<String, dynamic> query = {
      'page': page,
      'pageSize': limit, // Sesuaikan dengan API yang menggunakan pageSize
    };
    if (status != null && status.isNotEmpty && status != 'Semua') {
      query['status'] = status;
    }
    if (dateFilter != null && dateFilter.isNotEmpty && dateFilter != 'Semua') {
      query['dateFilter'] = dateFilter;
    }
    return await _apiClient.dio.get(
      ApiConstants.customerOrders,
      queryParameters: query,
    );
  }
}