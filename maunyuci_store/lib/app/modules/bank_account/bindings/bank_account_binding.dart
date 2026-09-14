import 'package:get/get.dart';
import '../controllers/bank_account_controller.dart';

class BankAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BankAccountController>(
      () => BankAccountController(),
    );
  }
}
