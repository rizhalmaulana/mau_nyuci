import 'package:get/get.dart';
import '../controllers/history_orders_controller.dart';

class HistoryOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryOrdersController>(
      () => HistoryOrdersController(),
    );
  }
}
