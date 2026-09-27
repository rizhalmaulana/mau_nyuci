import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import 'app/routes/app_pages.dart';
import 'app/core/utils/responsive_helper.dart';
import 'app/core/widgets/custom_snackbar.dart';
import 'app/data/providers/auth_provider.dart';
import 'app/data/repositories/database_binding.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await Firebase.initializeApp();
  await NotificationService().init();

  // SOP Notifikasi: ketuk pop-up / item notifikasi yang membawa orderId
  // langsung redirect ke halaman Detail Pesanan.
  NotificationService.onNotificationTap = (data) async {
    final orderId = NotificationService.extractOrderId(data);
    if (orderId == null) return;
    final token = await SecureStorageHelper.getToken();
    if (token == null || token.isEmpty) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }
    Get.toNamed(Routes.ORDER_DETAIL, arguments: orderId);
  };

  // Token FCM bisa basi (rotate) — sync ulang agar push tetap sampai.
  NotificationService.onFcmTokenRefresh = (newToken) async {
    final session = await SecureStorageHelper.getToken();
    if (session == null || session.isEmpty) return; // belum login
    await AuthProvider().syncFcmToken(newToken);
  };

  // Setup global 401 unauthorized redirect to login
  bool isRedirecting = false;
  ApiClient.onUnauthorized = () {
    if (isRedirecting) return;
    isRedirecting = true;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAllNamed(Routes.LOGIN);
      CustomSnackbar.showError(
        'Sesi Berakhir',
        'Sesi Anda telah berakhir. Silakan masuk kembali.',
      );
    });

    Future.delayed(const Duration(seconds: 2), () {
      isRedirecting = false;
    });
  };

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // await initializeDependencies();

  runApp(
    GetMaterialApp(
      title: AppConstants.appName,
      initialBinding: DatabaseBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
    ),
  );
}