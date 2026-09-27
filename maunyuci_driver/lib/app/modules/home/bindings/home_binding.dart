import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/providers/driver_provider.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClientNetwork>(() => ApiClientNetwork());
    Get.lazyPut<DriverProvider>(() => DriverProvider(Get.find<ApiClientNetwork>()));
    Get.lazyPut<HomeController>(() => HomeController(Get.find<DriverProvider>()));
  }
}
