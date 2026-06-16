import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_fonts.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            alignment: Alignment.center, // Pusatkan semua element stack
            children: [
              Lottie.asset(
                AppAssets.lottieMauNyuci,
                width: 180,
                height: 180,
                fit: BoxFit.contain,
                repeat: true,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Obx(() => Text(
                    controller.appVersion.value.isEmpty
                        ? ''
                        : 'Versi ${controller.appVersion.value}',
                    textAlign: TextAlign.center,
                    style: AppFonts.fInterBodySmallRegular.copyWith(
                      color: Colors.grey,
                    ),
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}