import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/utils/responsive_helper.dart';

class AboutAppView extends StatelessWidget {
  const AboutAppView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Tentang Aplikasi', style: AppFonts.fInterSubheadingSemibold.copyWith(fontSize: R.sp(16), color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(R.w(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: R.h(32)),
            Container(
              width: R.r(120),
              height: R.r(120),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(R.w(16)),
                child: Image.asset(AppAssets.mauNyuciPng, fit: BoxFit.contain),
              ),
            ),
            SizedBox(height: R.h(24)),
            Text('MauNyuci', style: AppFonts.fInterSubheadingSemibold.copyWith(fontSize: R.sp(24), color: AppColors.primary)),
            SizedBox(height: R.h(8)),
            Text('Versi 1.0.0 (Customer)', style: AppFonts.fInterBodySmallRegular.copyWith(color: Colors.grey.shade600)),
            SizedBox(height: R.h(32)),
            Text(
              'Aplikasi MauNyuci dibuat untuk memudahkan Anda dalam menemukan, memesan, dan mengelola layanan laundry kesayangan Anda dari genggaman tangan.',
              textAlign: TextAlign.center,
              style: AppFonts.fInterBodySmallRegular.copyWith(color: Colors.grey.shade700, height: 1.5),
            ),
            SizedBox(height: R.h(48)),
            Divider(color: Colors.grey.shade200),
            SizedBox(height: R.h(24)),
            Text('© ${DateTime.now().year} PT. Beyond Talent Service', style: AppFonts.fInterCaptionRegular.copyWith(color: Colors.grey.shade500)),
            Text('Semua Hak Dilindungi.', style: AppFonts.fInterCaptionRegular.copyWith(color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }
}
