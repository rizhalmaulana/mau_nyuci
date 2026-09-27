import 'package:maunyuci_core/maunyuci_core.dart';

class AuthProvider {
  final ApiClientNetwork _apiClient;

  AuthProvider(this._apiClient);

  Future<ApiResponse<dynamic>> login(String phone, String password) async {
    return await _apiClient.postReq<dynamic>(
      ApiConstants.login,
      data: {
        "phoneNumber": phone,
        "password": password,
        "appType": "Driver",
      },
    );
  }
}
