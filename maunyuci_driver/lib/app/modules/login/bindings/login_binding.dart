import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/providers/auth_provider.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClientNetwork>(() => ApiClientNetwork());
    Get.lazyPut<AuthProvider>(() => AuthProvider(Get.find<ApiClientNetwork>()));
    Get.lazyPut<LoginController>(() => LoginController(Get.find<AuthProvider>()));
  }
}
