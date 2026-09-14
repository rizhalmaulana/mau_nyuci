import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import 'app/routes/app_pages.dart';
import 'app/core/utils/responsive_helper.dart';
import 'app/core/widgets/custom_snackbar.dart';
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
        return child!;
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
    ),
  );
}