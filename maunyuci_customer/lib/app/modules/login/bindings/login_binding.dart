import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // fenix: true — LoginController wajib bisa dibuat ulang otomatis jika
    // instance lama terhapus (mis. offAllNamed(LOGIN) saat sudah di LOGIN
    // dari 401-handler, double-tap logout, atau hot restart). Tanpa ini
    // LoginView crash "LoginController not found".
    Get.lazyPut<LoginController>(() => LoginController(), fenix: true);
  }
}