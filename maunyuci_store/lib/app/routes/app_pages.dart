import 'package:get/get.dart';
import 'package:maunyuci_store/app/modules/all_orders/bindings/all_orders_binding.dart';
import 'app_routes.dart';

import '../modules/staff/views/staff_view.dart' as maunyuci_staff_view;
import '../modules/inventory/views/inventory_view.dart' as maunyuci_inventory_view;
import '../modules/inventory/views/inventory_detail_view.dart' as maunyuci_inventory_detail_view;

import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/main/bindings/main_binding.dart';
import '../modules/main/views/main_view.dart';
import '../modules/register_store/bindings/register_store_binding.dart';
import '../modules/register_store/views/register_store_view.dart';
import '../modules/pos/bindings/pos_binding.dart';
import '../modules/pos/views/pos_view.dart';
import '../modules/bank_account/bindings/bank_account_binding.dart';
import '../modules/bank_account/views/bank_account_view.dart';
import '../modules/order_detail/bindings/order_detail_binding.dart';
import '../modules/order_detail/views/order_detail_view.dart';
import '../modules/all_orders/views/all_orders_view.dart';
import '../modules/history_orders/bindings/history_orders_binding.dart';
import '../modules/history_orders/views/history_orders_view.dart';
import '../modules/notification/bindings/notification_binding.dart';
import '../modules/notification/views/notification_view.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/edit_store/bindings/edit_store_binding.dart';
import '../modules/edit_store/views/edit_store_view.dart';
import '../modules/printer_settings/bindings/printer_settings_binding.dart';
import '../modules/printer_settings/views/printer_settings_view.dart';
import '../modules/change_password/bindings/change_password_binding.dart';
import '../modules/change_password/views/change_password_view.dart';
import '../modules/privacy_policy/views/privacy_policy_view.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.MAIN,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: Routes.REGISTER_STORE,
      page: () => const RegisterStoreView(),
      binding: RegisterStoreBinding(),
    ),
    GetPage(
      name: Routes.POS,
      page: () => const PosView(),
      binding: PosBinding(),
    ),
    GetPage(
      name: Routes.BANK_ACCOUNT,
      page: () => const BankAccountView(),
      binding: BankAccountBinding(),
    ),
    GetPage(
      name: Routes.ORDER_DETAIL,
      page: () => const OrderDetailView(),
      binding: OrderDetailBinding(),
    ),
    GetPage(
      name: Routes.ALL_ORDERS,
      page: () => const AllOrdersView(),
      binding: AllOrdersBinding(),
    ),
    GetPage(
      name: Routes.HISTORY_ORDERS,
      page: () => const HistoryOrdersView(),
      binding: HistoryOrdersBinding(),
    ),
    GetPage(
      name: Routes.NOTIFICATION,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: Routes.EDIT_STORE,
      page: () => const EditStoreView(),
      binding: EditStoreBinding(),
    ),
    GetPage(
      name: Routes.CHANGE_PASSWORD,
      page: () => const ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: Routes.PRIVACY_POLICY,
      page: () => const PrivacyPolicyView(),
    ),
    GetPage(
      name: Routes.PRINTER_SETTINGS,
      page: () => const PrinterSettingsView(),
      binding: PrinterSettingsBinding(),
    ),
    GetPage(
      name: Routes.STAFF,
      page: () => const maunyuci_staff_view.StaffView(),
    ),
    GetPage(
      name: Routes.INVENTORY,
      page: () => const maunyuci_inventory_view.InventoryView(),
    ),
    GetPage(
      name: Routes.INVENTORY_DETAIL,
      page: () => const maunyuci_inventory_detail_view.InventoryDetailView(),
    ),
  ];
}
