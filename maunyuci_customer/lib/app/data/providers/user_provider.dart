import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/user_model.dart';

class UserProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

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

  Future<ApiResponse<UserModel>> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? profilePictureUrl,
    String? defaultAddress,
    double? defaultLatitude,
    double? defaultLongitude,
  }) async {
    final data = <String, dynamic>{};
    
    if (fullName != null) data['fullName'] = fullName;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (email != null) data['email'] = email;
    if (profilePictureUrl != null) data['profilePictureUrl'] = profilePictureUrl;
    if (defaultAddress != null) data['defaultAddress'] = defaultAddress;
    if (defaultLatitude != null) data['defaultLatitude'] = defaultLatitude;
    if (defaultLongitude != null) data['defaultLongitude'] = defaultLongitude;

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
}
