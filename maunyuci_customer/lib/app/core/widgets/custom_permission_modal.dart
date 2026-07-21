import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../utils/responsive_helper.dart';

class CustomPermissionModal extends StatelessWidget {
  final String title;
  final String message;
  final String textAllow;
  final String textDeny;
  final VoidCallback? onAllow;
  final VoidCallback? onDeny;

  const CustomPermissionModal({
    super.key,
    this.title = 'Izin Akses Lokasi',
    this.message = 'Mau Nyuci membutuhkan akses lokasi untuk menemukan laundry terdekat.',
    this.textAllow = 'Izinkan',
    this.textDeny = 'Tidak',
    this.onAllow,
    this.onDeny,
  });

  static Future<bool?> showLocationPermission({
    String title = 'Izin Akses Lokasi',
    String message = 'Mau Nyuci membutuhkan akses lokasi untuk menemukan laundry terdekat.',
    String textAllow = 'Izinkan',
    String textDeny = 'Tidak',
    VoidCallback? onAllow,
    VoidCallback? onDeny,
  }) async {
    return await Get.bottomSheet<bool>(
      CustomPermissionModal(
        title: title,
        message: message,
        textAllow: textAllow,
        textDeny: textDeny,
        onAllow: onAllow,
        onDeny: onDeny,
      ),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
    );
  }

  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    
    if (status.isGranted) {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _showEnableGpsDialog();
      }
      return true;
    }
    return false;
  }

  static Future<void> _showEnableGpsDialog() async {
    await Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nyalakan GPS',
              style: AppFonts.fInterSubheadingSemibold.copyWith(color: AppColors.textPrimary, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              'Buka pengaturan untuk mengaktifkan GPS agar mendapat lokasi akurat',
              style: AppFonts.fInterBodySmallRegular.copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Nanti', style: AppFonts.fInterBodyMedium.copyWith(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Geolocator.openLocationSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text('Buka Pengaturan', style: AppFonts.fInterBodyMedium.copyWith(color: AppColors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      isScrollControlled: true,
      isDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(R.r(16)),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_rounded,
              color: AppColors.primary,
              size: R.r(40),
            ),
          ),
          SizedBox(height: R.h(20)),
          Text(
            title,
            style: AppFonts.fInterSubheadingSemibold.copyWith(
              color: AppColors.textPrimary,
              fontSize: R.sp(18),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: R.r(12)),
          Text(
            message,
            style: AppFonts.fInterBodySmallRegular.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: R.h(32)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                onAllow?.call();
                final granted = await requestLocationPermission();
                Get.back(result: granted);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: R.h(16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                textAllow,
                style: AppFonts.fInterBodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: R.h(12)),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                onDeny?.call();
                Get.back(result: false);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: R.h(12)),
              ),
              child: Text(
                textDeny,
                style: AppFonts.fInterBodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}