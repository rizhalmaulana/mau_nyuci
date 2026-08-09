import 'package:dio/dio.dart';
import 'package:maunyuci_customer/app/core/helpers/api_error_helper.dart';
import 'package:maunyuci_customer/app/data/model/transaction/transaction_response_model.dart';

import '../providers/transaction_provider.dart';

class TransactionRepository {
  final TransactionProvider _provider = TransactionProvider();

  Future<List<TransactionResponseModel>> getCustomerOrders({
    int page = 1,
    int limit = 15,
    String? status,
    String? dateFilter,
  }) async {
    try {
      final response = await _provider.fetchTransactionsCustomer(
        page: page,
        limit: limit,
        status: status,
        dateFilter: dateFilter,
      );
      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        List dataList = [];
        
        if (responseData is Map) {
          if (responseData.containsKey('items')) {
            dataList = responseData['items'];
          } else if (responseData.containsKey('data')) {
            dataList = responseData['data'];
          } else {
            // Jika ada format lain di Map, fallback ke iterasi value atau throw
            throw Exception("Format pagination tidak dikenali: keys=${responseData.keys}");
          }
        } else if (responseData is List) {
          dataList = responseData;
        } else {
          throw Exception("Tipe response tidak dikenali: ${responseData.runtimeType}");
        }

        return dataList.map((json) => TransactionResponseModel.fromJson(json)).toList();
      }
      throw Exception("Gagal mengambil data transaksi");
    } on DioException catch (e) {
      throw Exception(handleApiError(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}