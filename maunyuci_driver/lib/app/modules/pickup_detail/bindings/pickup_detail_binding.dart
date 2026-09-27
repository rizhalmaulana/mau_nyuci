import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/providers/driver_provider.dart';
import '../controllers/pickup_detail_controller.dart';

class PickupDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClientNetwork>(() => ApiClientNetwork());
    Get.lazyPut<DriverProvider>(() => DriverProvider(Get.find<ApiClientNetwork>()));
    Get.lazyPut<PickupDetailController>(() => PickupDetailController(Get.find<DriverProvider>()));
  }
}
