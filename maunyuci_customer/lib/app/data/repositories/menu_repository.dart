import '../models/menu_model.dart';
import '../providers/menu_provider.dart';

class MenuRepository {
  final MenuProvider _provider = MenuProvider();

  Future<List<MenuModel>> fetchMenus() async {
    try {
      final response = await _provider.fetchMenus('Customer');
      
      if (response.success && response.data != null) {
        return response.data!;
      }
      throw Exception(response.message ?? "Gagal mengambil data menu");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
