import 'package:dio/dio.dart';
import 'package:maunyuci_customer/app/core/helpers/api_error_helper.dart';
import 'package:maunyuci_customer/app/data/model/transaction/transaction_response_model.dart';

import '../providers/transaction_provider.dart';

class TransactionRepository {
  final TransactionProvider _provider = TransactionProvider();

  Future<List<TransactionResponseModel>> getCustomerOrders() async {
    try {
      final response = await _provider.fetchTransactionsCustomer();
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((json) => TransactionResponseModel.fromJson(json)).toList();
      }
      throw Exception("Gagal mengambil data transaksi");
    } on DioException catch (e) {
      throw Exception(handleApiError(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}