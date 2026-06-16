import 'package:get/get.dart';
import 'package:maunyuci_customer/app/modules/order_history/controllers/order_history_controller.dart';
import '../../account/controllers/account_controller.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
          () => HomeController(),
    );
    Get.lazyPut<OrderHistoryController>(
          () => OrderHistoryController(),
    );
    Get.lazyPut<AccountController>(
          () => AccountController(),
    );
  }
}