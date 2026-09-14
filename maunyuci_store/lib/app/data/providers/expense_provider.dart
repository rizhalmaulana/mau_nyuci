import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/expense_model.dart';

class ExpenseProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<List<ExpenseModel>>> getExpenses({String? startDate, String? endDate}) async {
    final Map<String, dynamic> query = {};
    if (startDate != null && endDate != null) {
      query['startDate'] = startDate;
      query['endDate'] = endDate;
    }

    return await _network.getReq<List<ExpenseModel>>(
      ApiConstants.storeExpense,
      queryParameters: query.isNotEmpty ? query : null,
      fromJson: (inner) {
        if (inner is List) {
          return inner.map((e) => ExpenseModel.fromJson(e)).toList();
        }
        if (inner is Map<String, dynamic> && inner['items'] is List) {
          return (inner['items'] as List).map((e) => ExpenseModel.fromJson(e)).toList();
        }
        return <ExpenseModel>[];
      },
    );
  }

  Future<ApiResponse<ExpenseModel>> addExpense(Map<String, dynamic> data) async {
    return await _network.postReq<ExpenseModel>(
      ApiConstants.storeExpense,
      data: data,
      fromJson: (inner) {
        if (inner is Map<String, dynamic>) {
          return ExpenseModel.fromJson(inner);
        }
        return ExpenseModel.fromJson({});
      },
    );
  }

  Future<ApiResponse<ExpenseModel>> updateExpense(String id, Map<String, dynamic> data) async {
    return await _network.putReq<ExpenseModel>(
      '${ApiConstants.storeExpense}/$id',
      data: data,
      fromJson: (inner) {
        if (inner is Map<String, dynamic>) {
          return ExpenseModel.fromJson(inner);
        }
        return ExpenseModel.fromJson({});
      },
    );
  }

  Future<ApiResponse<dynamic>> deleteExpense(String id) async {
    return await _network.deleteReq<dynamic>('${ApiConstants.storeExpense}/$id');
  }
}
