import 'package:get/get.dart';
import '../../../core/services/printer_service.dart';

class PrinterSettingsController extends GetxController {
  final PrinterService printerService = PrinterService.to;

  @override
  void onInit() {
    super.onInit();
    // Jika belum scan, scan sekarang
    if (printerService.devices.isEmpty) {
      printerService.getDevices();
    }
  }

  void scanDevices() {
    printerService.getDevices();
  }

  void connectToDevice(device) {
    printerService.connect(device);
  }

  void disconnectDevice() {
    printerService.disconnect();
  }

  void testPrint() {
    printerService.printTest();
  }
}
