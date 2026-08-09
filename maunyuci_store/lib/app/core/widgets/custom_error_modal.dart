import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../constants/app_assets.dart';
import '../constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomErrorModal extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onPressed;
  final bool isNoSignal;

  const CustomErrorModal({
    super.key,
    required this.title,
    required this.message,
    required this.buttonText,
    this.onPressed,
    this.isNoSignal = false,
  });

  static void show({
    required String title,
    required String message,
    String buttonText = 'Mengerti',
    VoidCallback? onPressed,
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    
    final bool isOfflineError = message.toLowerCase().contains('koneksi') || 
                                message.toLowerCase().contains('jaringan') || 
                                message.toLowerCase().contains('offline') || 
                                message.toLowerCase().contains('sinyal') || 
                                message.toLowerCase().contains('timeout');

    Get.bottomSheet(
      CustomErrorModal(
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
        isNoSignal: isOfflineError,
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
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
          // Error Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.red.shade100,
                width: 8,
              ),
            ),
            child: isNoSignal
                ? SvgPicture.asset(
                    AppAssets.iconNoSignal,
                    width: 40,
                    height: 40,
                    colorFilter: ColorFilter.mode(Colors.red.shade600, BlendMode.srcIn),
                  )
                : Icon(Icons.error_outline_rounded, color: Colors.red.shade600, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600).copyWith(
              color: AppColors.textPrimary,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400).copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                if (onPressed != null) onPressed!();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.black54).copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}