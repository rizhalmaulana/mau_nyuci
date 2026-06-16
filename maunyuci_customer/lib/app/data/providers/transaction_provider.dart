import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:maunyuci_core/constants/api_constants.dart';
import 'package:maunyuci_core/network/api_client.dart';

class TransactionProvider {
  final ApiClient _apiClient = ApiClient();

  Future<Response> fetchTransactionsCustomer() async {
    return await _apiClient.dio.get(ApiConstants.customerOrders);
  }
}