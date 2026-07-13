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
    return await Get.dialog<bool>(
      CustomPermissionModal(
        title: title,
        message: message,
        textAllow: textAllow,
        textDeny: textDeny,
        onAllow: onAllow,
        onDeny: onDeny,
      ),
      barrierDismissible: false,
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
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(20))),
        title: Text('Nyalakan GPS'),
        content: Text('Buka pengaturan untuk mengaktifkan GPS agar mendapat lokasi akurat'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Nanti'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Geolocator.openLocationSettings();
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(horizontal: R.w(32)),
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      child: Padding(
        padding: EdgeInsets.all(R.r(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            SizedBox(height: R.h(24)),
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
      ),
    );
  }
}