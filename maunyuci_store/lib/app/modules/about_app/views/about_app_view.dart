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
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('Tentang Aplikasi', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(16), color: AppColors.black87)),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black87),
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
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: EdgeInsets.all(R.w(16)),
                child: Image.asset(AppAssets.mauNyuciPng, fit: BoxFit.contain), 
              ),
            ),
            SizedBox(height: R.h(24)),
            Text('MauNyuci Toko', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(24), color: AppColors.primary)),
            SizedBox(height: R.h(8)),
            Text('Versi 1.0.0 (Store)', style: AppFonts.inter(fontSize: R.sp(14), color: AppColors.grey600)),
            SizedBox(height: R.h(32)),
            Text(
              'Aplikasi MauNyuci Toko dirancang khusus untuk pemilik dan staf laundry agar dapat mengelola pesanan, katalog, keuangan, dan analitik bisnis dengan mudah dan profesional.',
              textAlign: TextAlign.center,
              style: AppFonts.inter(fontSize: R.sp(14), color: AppColors.grey700, height: 1.5),
            ),
            SizedBox(height: R.h(48)),
            const Divider(color: AppColors.grey200),
            SizedBox(height: R.h(24)),
            Text('© ${DateTime.now().year} PT. Beyond Talent Service', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey500)),
            Text('Semua Hak Dilindungi.', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey500)),
          ],
        ),
      ),
    );
  }
}
