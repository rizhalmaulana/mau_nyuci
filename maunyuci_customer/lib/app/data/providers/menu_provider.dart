import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/menu_model.dart';

class MenuProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<List<MenuModel>>> fetchMenus(String appType) async {
    return await _network.getReq<List<MenuModel>>(
      'Menu?appType=$appType',
      fromJson: (data) {
        if (data is List) {
          return data.map((e) => MenuModel.fromJson(e)).toList();
        } else if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List).map((e) => MenuModel.fromJson(e)).toList();
        }
        return [];
      },
    );
  }
}
