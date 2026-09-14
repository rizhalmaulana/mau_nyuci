import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import 'app/core/widgets/custom_snackbar.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/core/utils/responsive_helper.dart';
import 'app/core/services/printer_service.dart';
import 'app/core/utils/http_overrides.dart';
import 'app/core/constants/app_fonts.dart';
import 'app/core/constants/app_colors.dart';

import 'app/data/services/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().init();
  
  // Inisialisasi StorageService
  await Get.putAsync(() => StorageService().init());
  
  // Inisialisasi PrinterService
  Get.put(PrinterService());
  
  // Setup global 401 unauthorized redirect to login
  bool isRedirecting = false;
  ApiClient.onUnauthorized = () {
    if (isRedirecting) return;
    if (Get.currentRoute == Routes.LOGIN) return;
    
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

  // Setup global 403 forbidden interceptor (Premium Paywall)
  ApiClient.onForbidden = () {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isBottomSheetOpen == true) return;
      
      Get.bottomSheet(
        Container(
          padding: EdgeInsets.all(R.w(24)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(24))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.workspace_premium, size: R.r(64), color: AppColors.warning),
              SizedBox(height: R.h(16)),
              Text('Fitur Premium', style: AppFonts.inter(fontSize: R.sp(20), fontWeight: FontWeight.bold)),
              SizedBox(height: R.h(8)),
              Text(
                'Ups, fitur ini eksklusif untuk Mitra Premium MauNyuci. Yuk berlangganan sekarang untuk menikmati analitik canggih, manajemen promo, dan pencatatan keuangan otomatis!',
                textAlign: TextAlign.center,
                style: AppFonts.inter(fontSize: R.sp(14), color: AppColors.grey600, height: 1.5),
              ),
              SizedBox(height: R.h(24)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    // Navigate to subscription page if available later
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning600,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: R.h(16)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                  child: Text('Tingkatkan ke Premium', style: AppFonts.inter(fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: R.h(12)),
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Mungkin Nanti', style: AppFonts.inter(color: AppColors.grey500)),
              ),
            ],
          ),
        ),
        isScrollControlled: true,
      );
    });
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MauNyuci Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        textTheme: AppFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      builder: (context, child) {
        R.init(context);
        return child!;
      },
    );
  }
}
