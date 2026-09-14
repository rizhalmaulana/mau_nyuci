import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/staff_model.dart';

class StaffProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<List<StaffModel>>> getStaffs(String storeId) async {
    return await _network.getReq<List<StaffModel>>(
      ApiConstants.storeStaffs(storeId),
      fromJson: (inner) {
        if (inner is List) {
          return inner.map((e) => StaffModel.fromJson(e)).toList();
        }
        return <StaffModel>[];
      },
    );
  }

  Future<ApiResponse<StaffModel>> addStaff(String storeId, Map<String, dynamic> data) async {
    return await _network.postReq<StaffModel>(
      ApiConstants.storeStaffs(storeId),
      data: data,
      fromJson: (inner) {
        if (inner is Map<String, dynamic>) {
          return StaffModel.fromJson(inner);
        }
        return StaffModel.fromJson({});
      },
    );
  }
}
