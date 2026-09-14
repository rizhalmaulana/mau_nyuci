import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/store_bank_account_model.dart';

class StoreBankAccountProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<List<String>>> getMasterMethods() async {
    return await _network.getReq<List<String>>(
      ApiConstants.masterBankMethods,
      fromJson: (inner) {
        if (inner is List) {
          return inner.map((e) => e.toString()).toList();
        }
        return <String>[];
      },
    );
  }

  Future<ApiResponse<List<StoreBankAccountModel>>> getMyAccounts() async {
    return await _network.getReq<List<StoreBankAccountModel>>(
      ApiConstants.myBankAccounts,
      fromJson: (inner) {
        if (inner is List) {
          return inner.map((json) => StoreBankAccountModel.fromJson(json)).toList();
        }
        return <StoreBankAccountModel>[];
      },
    );
  }

  Future<ApiResponse<StoreBankAccountModel>> addAccount(String bankName, String accountNumber, String accountHolderName, {String? qrisImageUrl}) async {
    return await _network.postReq<StoreBankAccountModel>(
      ApiConstants.addBankAccount,
      data: {
        'bankName': bankName,
        'accountNumber': accountNumber,
        'accountHolderName': accountHolderName,
        if (qrisImageUrl != null) 'qrisImageUrl': qrisImageUrl,
      },
      fromJson: (inner) {
        if (inner is Map<String, dynamic>) {
          return StoreBankAccountModel.fromJson(inner);
        }
        return StoreBankAccountModel.fromJson({});
      },
    );
  }

  Future<ApiResponse<StoreBankAccountModel>> updateAccount(String id, String bankName, String accountNumber, String accountHolderName, {String? qrisImageUrl}) async {
    return await _network.putReq<StoreBankAccountModel>(
      ApiConstants.updateBankAccount(id),
      data: {
        'bankName': bankName,
        'accountNumber': accountNumber,
        'accountHolderName': accountHolderName,
        if (qrisImageUrl != null) 'qrisImageUrl': qrisImageUrl,
      },
      fromJson: (inner) {
        if (inner is Map<String, dynamic>) {
          return StoreBankAccountModel.fromJson(inner);
        }
        return StoreBankAccountModel.fromJson({});
      },
    );
  }

  Future<ApiResponse<void>> deleteAccount(String id) async {
    final res = await _network.deleteReq<dynamic>(ApiConstants.deleteBankAccount(id));
    return ApiResponse<void>(
      success: res.success,
      message: res.message,
      statusCode: res.statusCode,
    );
  }
}
