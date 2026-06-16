import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/complete_profile_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/custom_text_field.dart';

class CompleteProfileView extends GetView<CompleteProfileController> {
  const CompleteProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.offAllNamed(Routes.LOGIN),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lengkapi Profil',
              style: AppFonts.fInterSubheadingSemibold.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mohon lengkapi data di bawah untuk\nmemproses akunmu.',
              style: AppFonts.fInterBodySmallRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            Obx(() => CustomTextField(
              label: 'No HP',
              isRequired: true,
              hintText: '08123456789',
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              errorText: controller.phoneError.value.isEmpty ? null : controller.phoneError.value,
            )),
            const SizedBox(height: 16),

            Obx(() => CustomTextField(
              label: 'Kata Sandi',
              isRequired: true,
              hintText: 'Masukan kata sandi',
              controller: controller.passwordController,
              obscureText: controller.isPasswordHidden.value,
              helperText: 'Minimal 8 karakter',
              errorText: controller.passwordError.value.isEmpty ? null : controller.passwordError.value,
              suffixIcon: IconButton(
                icon: controller.isPasswordHidden.value
                    ? SvgPicture.asset(
                        AppAssets.iconEyeClosed,
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(AppColors.border, BlendMode.srcIn),
                      )
                    : const Icon(
                        Icons.visibility_outlined,
                        color: AppColors.border,
                        size: 20,
                      ),
                onPressed: controller.togglePasswordVisibility,
              ),
            )),
            const SizedBox(height: 16),

            Obx(() => CustomTextField(
              label: 'Konfirmasi Kata Sandi',
              isRequired: true,
              hintText: 'Masukan kata sandi',
              controller: controller.confirmPasswordController,
              obscureText: controller.isConfirmPasswordHidden.value,
              errorText: controller.confirmPasswordError.value.isEmpty ? null : controller.confirmPasswordError.value,
              suffixIcon: IconButton(
                icon: controller.isConfirmPasswordHidden.value
                    ? SvgPicture.asset(
                        AppAssets.iconEyeClosed,
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(AppColors.border, BlendMode.srcIn),
                      )
                    : const Icon(
                        Icons.visibility_outlined,
                        color: AppColors.border,
                        size: 20,
                      ),
                onPressed: controller.toggleConfirmPasswordVisibility,
              ),
            )),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.7),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Simpan',
                        style: AppFonts.fInterBodySmallMedium.copyWith(color: AppColors.white),
                      ),
              )),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}