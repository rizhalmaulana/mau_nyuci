import 'package:get/get.dart';
import 'app_routes.dart';

import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
// import '../modules/home/bindings/home_binding.dart';
// import '../modules/home/views/home_view.dart';
import '../modules/register_store/bindings/register_store_binding.dart';
import '../modules/register_store/views/register_store_view.dart';
import 'package:flutter/material.dart';

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
      name: Routes.HOME,
      page: () => const Scaffold(
        body: Center(child: Text("Halaman Utama Toko (Segera Hadir)")),
      ),
      // binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.REGISTER_STORE,
      page: () => const RegisterStoreView(),
      binding: RegisterStoreBinding(),
    ),
  ];
}
