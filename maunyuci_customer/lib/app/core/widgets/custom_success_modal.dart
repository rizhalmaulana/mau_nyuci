import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class CustomSuccessModal extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  const CustomSuccessModal({
    super.key,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  static void show({
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    Get.dialog(
      CustomSuccessModal(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40.0),
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 40.0, 24.0, 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent500,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent100, width: 8),
              ),
              child: const Icon(Icons.check, color: AppColors.white, size: 32),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: AppFonts.fInterSubheadingSemibold.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppFonts.fInterBodySmallRegular.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32), // Jarak sebelum button disamakan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16), // Padding button disamakan dengan form
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: AppFonts.fInterBodyMedium.copyWith(color: AppColors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}