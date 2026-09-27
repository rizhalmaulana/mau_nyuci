import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import 'app/core/utils/responsive_helper.dart';
import 'app/routes/app_pages.dart';
import 'app/core/constants/app_colors.dart';
import 'app/core/constants/app_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();

  // SOP Notifikasi: ketuk pop-up yang membawa orderId langsung
  // redirect ke halaman detail tugas (jemput / antar).
  NotificationService.onNotificationTap = (data) async {
    final orderId = NotificationService.extractOrderId(data);
    if (orderId == null) return;
    final token = await SecureStorageHelper.getToken();
    if (token == null || token.isEmpty) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }
    if (data['taskType']?.toString().toLowerCase() == 'delivery') {
      Get.toNamed(Routes.DELIVERY_DETAIL, arguments: orderId);
    } else {
      Get.toNamed(Routes.PICKUP_DETAIL, arguments: orderId);
    }
  };

  runApp(
    GetMaterialApp(
      title: "MauNyuci Driver",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        textTheme: AppFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
        ),
      ),
      builder: (context, child) {
        R.init(context);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(0.9),
            // Jika Anda menggunakan Flutter versi < 3.16, hapus baris di atas dan gunakan:
            // textScaleFactor: 0.9,
          ),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
    ),
  );
}
