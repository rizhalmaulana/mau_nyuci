import 'package:maunyuci_core/maunyuci_core.dart';
import '../model/transaction/transaction_response_model.dart';
import '../repositories/transaction_repository.dart';

class TransactionService {
  final TransactionRepository _repository = TransactionRepository();

  Future<List<TransactionResponseModel>> getActiveTransactions() async {
    final allOrders = await _repository.getCustomerOrders();
    return allOrders.where((o) => o.status != OrderStatus.completed.value && o.status != OrderStatus.cancelled.value).toList();
  }

  Future<List<TransactionResponseModel>> getHistoryTransactions() async {
    final allOrders = await _repository.getCustomerOrders();
    return allOrders.where((o) => o.status == OrderStatus.completed.value || o.status == OrderStatus.cancelled.value).toList();
  }
}