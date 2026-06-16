import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class CustomErrorModal extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  const CustomErrorModal({
    super.key,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  static void show({
    required String title,
    required String message,
    String buttonText = 'Tutup',
    VoidCallback? onPressed,
  }) {
    Get.dialog(
      CustomErrorModal(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed ?? () => Get.back(),
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
                color: Colors.red.shade400,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red.shade100, width: 8),
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 25),
            ),
            const SizedBox(height: 21), // Jarak sama persis
            Text(
              title,
              style: AppFonts.fInterBodySmallSemibold.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppFonts.fInterStatusRegular.copyWith(
                color: AppColors.textSecondary
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 21),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade500,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: AppFonts.fInterCaptionMedium.copyWith(color: AppColors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}