import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/menu_model.dart';

class MenuProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<List<MenuModel>> fetchMenus(String appType) async {
    final response = await _network.getReq<List<MenuModel>>(
      'Menu?appType=$appType',
      fromJson: (inner) {
        if (inner is List) {
          return inner.map((json) => MenuModel.fromJson(json)).toList();
        }
        return <MenuModel>[];
      },
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message ?? 'Gagal mengambil data menu');
  }
}
