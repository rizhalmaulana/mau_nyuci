import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import 'app/core/constants/app_colors.dart';
import 'app/core/widgets/custom_snackbar.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set global handler untuk token expired (401)
  ApiClient.onUnauthorized = () {
    Get.offAllNamed(Routes.LOGIN);
    CustomSnackbar.showError(
      'Sesi Berakhir',
      'Sesi Anda telah berakhir. Silakan masuk kembali.',
    );
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
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
