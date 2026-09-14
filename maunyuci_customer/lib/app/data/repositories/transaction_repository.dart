import '../model/transaction/transaction_response_model.dart';
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
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw Exception(response.message ?? "Gagal mengambil data transaksi");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}