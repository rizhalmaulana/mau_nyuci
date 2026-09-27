import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/change_password_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/responsive_helper.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Ubah Password',
          style: AppFonts.fInterSubheadingSemibold.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: R.w(24), vertical: R.h(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Info
            Container(
              padding: EdgeInsets.all(R.r(12)),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F0FF), // Light blue banner background
                borderRadius: BorderRadius.circular(R.r(8)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info,
                    color: const Color(0xFF1C64F2), // Info icon color
                    size: R.r(20),
                  ),
                  SizedBox(width: R.w(8)),
                  Expanded(
                    child: Text(
                      'Pastikan password baru kamu sulit dan kamu ingat. Jangan sampe lupa ya!',
                      style: AppFonts.fInterBodySmallRegular.copyWith(
                        color: const Color(0xFF1C64F2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: R.h(32)),

            // Form Fields
            Obx(() => CustomTextField(
              key: const ValueKey('old_password_field'),
              label: 'Password Lama',
              isRequired: true,
              hintText: 'Masukan password lama',
              controller: controller.oldPasswordController,
              obscureText: controller.isOldPasswordHidden.value,
              errorText: controller.oldPasswordError.value.isEmpty ? null : controller.oldPasswordError.value,
              suffixIcon: IconButton(
                icon: controller.isOldPasswordHidden.value
                    ? SvgPicture.asset(
                        AppAssets.iconEyeClosed,
                        width: R.r(20),
                        height: R.r(20),
                        colorFilter: const ColorFilter.mode(AppColors.border, BlendMode.srcIn),
                      )
                    : Icon(
                        Icons.visibility_outlined,
                        color: AppColors.border,
                        size: R.r(20),
                      ),
                onPressed: controller.toggleOldPasswordVisibility,
              ),
            )),
            SizedBox(height: R.h(24)),

            Obx(() => CustomTextField(
              key: const ValueKey('new_password_field'),
              label: 'Password Baru',
              isRequired: true,
              hintText: 'Masukan password baru',
              controller: controller.newPasswordController,
              obscureText: controller.isNewPasswordHidden.value,
              helperText: 'Minimal 8 karakter',
              errorText: controller.newPasswordError.value.isEmpty ? null : controller.newPasswordError.value,
              suffixIcon: IconButton(
                icon: controller.isNewPasswordHidden.value
                    ? SvgPicture.asset(
                        AppAssets.iconEyeClosed,
                        width: R.r(20),
                        height: R.r(20),
                        colorFilter: const ColorFilter.mode(AppColors.border, BlendMode.srcIn),
                      )
                    : Icon(
                        Icons.visibility_outlined,
                        color: AppColors.border,
                        size: R.r(20),
                      ),
                onPressed: controller.toggleNewPasswordVisibility,
              ),
            )),
            SizedBox(height: R.h(24)),

            Obx(() => CustomTextField(
              key: const ValueKey('confirm_password_field'),
              label: 'Konfirmasi Password Baru',
              isRequired: true,
              hintText: 'Masukan konfirmasi password baru',
              controller: controller.confirmPasswordController,
              obscureText: controller.isConfirmPasswordHidden.value,
              helperText: 'Minimal 8 karakter',
              errorText: controller.confirmPasswordError.value.isEmpty ? null : controller.confirmPasswordError.value,
              suffixIcon: IconButton(
                icon: controller.isConfirmPasswordHidden.value
                    ? SvgPicture.asset(
                        AppAssets.iconEyeClosed,
                        width: R.r(20),
                        height: R.r(20),
                        colorFilter: const ColorFilter.mode(AppColors.border, BlendMode.srcIn),
                      )
                    : Icon(
                        Icons.visibility_outlined,
                        color: AppColors.border,
                        size: R.r(20),
                      ),
                onPressed: controller.toggleConfirmPasswordVisibility,
              ),
            )),
            SizedBox(height: R.h(48)),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.savePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: R.h(16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.r(12)),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.7),
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                        height: R.r(20),
                        width: R.r(20),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Simpan',
                        style: AppFonts.fInterBodySmallMedium.copyWith(
                          color: AppColors.white,
                          fontSize: R.sp(16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              )),
            ),
            SizedBox(height: R.h(24)),
          ],
        ),
      ),
    );
  }
}
