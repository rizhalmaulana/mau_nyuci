import 'package:get/get.dart';
import '../controllers/printer_settings_controller.dart';

class PrinterSettingsBinding extends Bindings {
  @override
  void dependencies() {
    // fenix: true — controller wajib bisa dibuat ulang otomatis jika
    // instance lama terhapus (mis. navigasi off/back dari order detail
    // lalu Obx rebuild). Tanpa ini muncul "PrinterSettingsController
    // not found" + cascade RenderFlex raksasa saat Pindai Ulang.
    Get.lazyPut<PrinterSettingsController>(
      () => PrinterSettingsController(),
      fenix: true,
    );
  }
}
