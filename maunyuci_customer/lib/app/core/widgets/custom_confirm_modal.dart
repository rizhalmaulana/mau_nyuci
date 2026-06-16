import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class CustomConfirmModal extends StatelessWidget {
  final String title;
  final String message;
  final String textConfirm;
  final String textCancel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Color? confirmColor;
  final Color? cancelColor;
  final IconData? icon;

  const CustomConfirmModal({
    super.key,
    required this.title,
    required this.message,
    required this.textConfirm,
    required this.textCancel,
    required this.onConfirm,
    required this.onCancel,
    this.confirmColor,
    this.cancelColor,
    this.icon,
  });

  static void show({
    required String title,
    required String message,
    String textConfirm = 'Ya',
    String textCancel = 'Batal',
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    Color? confirmColor,
    Color? cancelColor,
    IconData? icon,
  }) {
    Get.dialog(
      CustomConfirmModal(
        title: title,
        message: message,
        textConfirm: textConfirm,
        textCancel: textCancel,
        onConfirm: onConfirm,
        onCancel: onCancel ?? () => Get.back(),
        confirmColor: confirmColor ?? AppColors.primary,
        cancelColor: cancelColor ?? Colors.red,
        icon: icon,
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: confirmColor?.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: confirmColor?.withOpacity(0.2) ?? Colors.transparent,
                      width: 8,
                    ),
                  ),
                  child: Icon(icon, color: confirmColor, size: 32),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              title,
              style: AppFonts.fInterSubheadingSemibold.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppFonts.fInterBodySmallRegular.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: cancelColor ?? Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      textCancel,
                      style: AppFonts.fInterBodyMedium.copyWith(
                        color: cancelColor ?? Colors.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor ?? AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      textConfirm,
                      style: AppFonts.fInterBodyMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}