import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/user_model.dart';

class AuthProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<dynamic>> login(String phoneNumber, String password) async {
    return await _network.postReq<dynamic>(
      ApiConstants.login,
      data: {
        "phoneNumber": phoneNumber,
        "password": password,
        "appType": "Store",
      },
    );
  }

  Future<ApiResponse<UserModel>> getProfile() async {
    return await _network.getReq<UserModel>(
      ApiConstants.profile,
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          if (data['id'] != null) return UserModel.fromJson(data);
          if (data['data'] != null) return UserModel.fromJson(data['data']);
        }
        return UserModel.fromJson({});
      },
    );
  }

  Future<ApiResponse<dynamic>> syncFcmToken(String token) async {
    return await _network.postReq<dynamic>(
      ApiConstants.syncFcmToken,
      data: {"token": token},
    );
  }

  Future<ApiResponse<UserModel>> updateProfile(Map<String, dynamic> data) async {
    return await _network.putReq<UserModel>(
      ApiConstants.profile,
      data: data,
      fromJson: (data) {
        if (data is Map<String, dynamic>) {
          if (data['data'] != null) return UserModel.fromJson(data['data']);
          return UserModel.fromJson(data);
        }
        return UserModel.fromJson({});
      },
    );
  }

  Future<ApiResponse<dynamic>> changePassword(String oldPassword, String newPassword) async {
    return await _network.putReq<dynamic>(
      ApiConstants.changePassword,
      data: {
        "oldPassword": oldPassword,
        "newPassword": newPassword,
      },
    );
  }
}
