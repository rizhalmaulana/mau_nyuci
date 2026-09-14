import 'package:get/get.dart';
import '../controllers/layanan_controller.dart';

class LayananBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LayananController>(
      () => LayananController(),
    );
  }
}
