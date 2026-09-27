import 'package:get/get.dart';
import '../controllers/weigh_laundry_controller.dart';

class WeighLaundryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeighLaundryController>(
      () => WeighLaundryController(),
    );
  }
}
