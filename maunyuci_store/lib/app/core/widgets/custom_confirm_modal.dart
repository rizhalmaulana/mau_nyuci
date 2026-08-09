import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

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
    Get.bottomSheet(
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
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle pill
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
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400).copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: cancelColor ?? Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    textCancel,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500).copyWith(
                      color: cancelColor ?? Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmColor ?? AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    textConfirm,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500).copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}