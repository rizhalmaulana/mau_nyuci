import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../home/controllers/home_controller.dart';
// import '../../orders/controllers/orders_controller.dart'; // TODO: Uncomment later
// import '../../services/controllers/services_controller.dart'; // TODO: Uncomment later
// import '../../profile/controllers/profile_controller.dart'; // TODO: Uncomment later

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(
      () => MainController(),
    );
    // Inisialisasi controller lain yang ada di tab pertama (Home)
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}
