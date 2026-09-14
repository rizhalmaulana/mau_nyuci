import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_fonts.dart';
import '../../core/constants/app_colors.dart';

import '../utils/responsive_helper.dart';

class PremiumPaywallWidget extends StatelessWidget {
  final String title;
  final String description;

  const PremiumPaywallWidget({
    super.key,
    this.title = 'Fitur Premium',
    this.description = 'Tingkatkan akun toko Anda ke Premium untuk membuka akses ke fitur eksklusif ini.',
  });

  Future<void> _openWhatsAppSupport() async {
    const phoneNumber = '+6281234567890'; // TODO: Ganti dengan nomor asli
    const message = 'Halo CS MauNyuci, saya tertarik untuk berlangganan fitur Premium untuk toko saya.';
    final Uri url = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Gagal',
        'Tidak dapat membuka WhatsApp',
        backgroundColor: AppColors.danger.withValues(alpha: 0.9),
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(R.w(24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium,
              size: R.r(100),
              color: AppColors.warning,
            ),
            SizedBox(height: R.h(24)),
            Text(
              title,
              style: AppFonts.inter(
                fontSize: R.sp(22),
                fontWeight: FontWeight.bold,
                color: AppColors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: R.h(16)),
            Text(
              description,
              style: AppFonts.inter(
                fontSize: R.sp(14),
                color: AppColors.grey600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: R.h(32)),
            SizedBox(
              width: double.infinity,
              height: R.h(50),
              child: ElevatedButton.icon(
                onPressed: _openWhatsAppSupport,
                icon: const Icon(Icons.star, color: AppColors.white),
                label: Text(
                  'Upgrade Sekarang',
                  style: AppFonts.inter(
                    fontSize: R.sp(16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.r(12)),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
