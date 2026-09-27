import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../all_orders/controllers/all_orders_controller.dart';
import '../../layanan/controllers/layanan_controller.dart';
import '../../akun/controllers/akun_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(
      () => MainController(),
    );
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<AllOrdersController>(
      () => AllOrdersController(),
    );
    Get.lazyPut<LayananController>(
      () => LayananController(),
    );
    Get.lazyPut<AkunController>(
      () => AkunController(),
    );
  }
}
