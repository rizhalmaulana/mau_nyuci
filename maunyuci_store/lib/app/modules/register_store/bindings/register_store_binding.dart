import 'package:get/get.dart';
import '../controllers/register_store_controller.dart';

class RegisterStoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterStoreController>(
      () => RegisterStoreController(),
    );
  }
}
