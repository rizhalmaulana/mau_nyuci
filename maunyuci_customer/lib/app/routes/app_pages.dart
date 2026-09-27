import 'package:get/get.dart';
import 'package:maunyuci_customer/app/modules/account/bindings/account_binding.dart';
import 'package:maunyuci_customer/app/modules/account/views/account_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/complete_profile/bindings/complete_profile_binding.dart';
import '../modules/complete_profile/views/complete_profile_view.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/change_password/bindings/change_password_binding.dart';
import '../modules/change_password/views/change_password_view.dart';
import '../modules/notification/bindings/notification_binding.dart';
import '../modules/notification/views/notification_view.dart';
import '../modules/main/bindings/main_binding.dart';
import '../modules/main/views/main_view.dart';
import '../modules/static_pages/views/terms_of_service_view.dart';
import '../modules/static_pages/views/privacy_policy_view.dart';
import '../modules/static_pages/views/about_app_view.dart';
import '../modules/create_order/bindings/create_order_binding.dart';
import '../modules/create_order/views/create_order_view.dart';
import '../modules/store_detail/bindings/store_detail_binding.dart';
import '../modules/store_detail/views/store_detail_view.dart';
import '../modules/checkout/bindings/checkout_binding.dart';
import '../modules/checkout/views/checkout_view.dart';
import '../modules/order_detail/bindings/order_detail_binding.dart';
import '../modules/order_detail/views/order_detail_view.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;
  static const LOGIN = Routes.LOGIN;
  static const REGISTER = Routes.REGISTER;
  static const HOME = Routes.HOME;
  static const ACCOUNT = Routes.ACCOUNT;
  static const NOTIFICATION = Routes.NOTIFICATION;
  static const MAIN = Routes.MAIN;
  static const TERMS_OF_SERVICE = Routes.TERMS_OF_SERVICE;
  static const PRIVACY_POLICY = Routes.PRIVACY_POLICY;
  static const ABOUT_APP = Routes.ABOUT_APP;

  static final routes = [
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.leftToRight,
    ),
    GetPage(
        name: Routes.REGISTER,
        page: () => const RegisterView(),
        binding: RegisterBinding(),
        transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.ACCOUNT,
      page: () => AccountView(),
      binding: AccountBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.COMPLETE_PROFILE,
      page: () => const CompleteProfileView(),
      binding: CompleteProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.CHANGE_PASSWORD,
      page: () => const ChangePasswordView(),
      binding: ChangePasswordBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: Routes.NOTIFICATION,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.MAIN,
      page: () => const MainView(),
      binding: MainBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.TERMS_OF_SERVICE,
      page: () => const TermsOfServiceView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.PRIVACY_POLICY,
      page: () => const PrivacyPolicyView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.ABOUT_APP,
      page: () => const AboutAppView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.CREATE_ORDER,
      page: () => const CreateOrderView(),
      binding: CreateOrderBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.STORE_DETAIL,
      page: () => const StoreDetailView(),
      binding: StoreDetailBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.CHECKOUT,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: Routes.ORDER_DETAIL,
      page: () => const OrderDetailView(),
      binding: OrderDetailBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}