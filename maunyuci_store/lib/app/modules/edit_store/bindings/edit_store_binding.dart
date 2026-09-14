import 'package:get/get.dart';
import '../controllers/edit_store_controller.dart';

class EditStoreBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditStoreController>(
      () => EditStoreController(),
    );
  }
}
