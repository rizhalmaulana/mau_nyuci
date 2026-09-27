import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';
import '../utils/responsive_helper.dart';

/// Bottom-sheet konfirmasi dua tombol. Skema sama seperti
/// CustomConfirmModal di maunyuci_store / maunyuci_customer.
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

  static Future<T?> show<T>({
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
    return Get.bottomSheet<T>(
      CustomConfirmModal(
        title: title,
        message: message,
        textConfirm: textConfirm,
        textCancel: textCancel,
        onConfirm: onConfirm,
        onCancel: onCancel ?? () => Get.back(),
        confirmColor: confirmColor ?? AppColors.primary,
        cancelColor: cancelColor ?? AppColors.danger,
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
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(24))),
      ),
      padding: EdgeInsets.only(
        top: R.h(12),
        left: R.w(24),
        right: R.w(24),
        bottom: R.h(32) + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: R.w(48),
              height: R.h(4),
              decoration: BoxDecoration(
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(R.r(4)),
              ),
            ),
          ),
          SizedBox(height: R.h(24)),
          if (icon != null) ...[
            Center(
              child: Container(
                padding: EdgeInsets.all(R.r(16)),
                decoration: BoxDecoration(
                  color: (confirmColor ?? AppColors.primary).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (confirmColor ?? AppColors.primary).withValues(alpha: 0.2),
                    width: 8,
                  ),
                ),
                child: Icon(icon, color: confirmColor ?? AppColors.primary, size: R.r(32)),
              ),
            ),
            SizedBox(height: R.h(24)),
          ],
          Text(
            title,
            style: AppFonts.inter(
              fontSize: R.sp(16),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: R.h(12)),
          Text(
            message,
            style: AppFonts.inter(
              fontSize: R.sp(12),
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: R.h(32)),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: R.h(16)),
                    side: BorderSide(color: cancelColor ?? AppColors.danger),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(12)),
                    ),
                  ),
                  child: Text(
                    textCancel,
                    style: AppFonts.inter(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.w500,
                      color: cancelColor ?? AppColors.danger,
                    ),
                  ),
                ),
              ),
              SizedBox(width: R.w(16)),
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmColor ?? AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: R.h(16)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(12)),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    textConfirm,
                    style: AppFonts.inter(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.w500,
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
