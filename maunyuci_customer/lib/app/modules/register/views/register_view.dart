import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/responsive_helper.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: R.w(24), vertical: R.h(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daftar Akun',
              style: AppFonts.fInterSubheadingSemibold.copyWith(
                color: AppColors.textPrimary
              ),
            ),
            SizedBox(height: R.h(8)),
            Text(
              'Isi dengan baik ya oke, jangan sampe lupa !',
              style: AppFonts.fInterBodySmallRegular.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: R.h(32)),

            // Form Fields
            Obx(() => CustomTextField(
              key: const ValueKey('name_field'),
              label: 'Nama Lengkap',
              isRequired: true,
              hintText: 'contoh : Jhon Taruna',
              controller: controller.nameController,
              errorText: controller.nameError.value.isEmpty ? null : controller.nameError.value,
            )),
            SizedBox(height: R.h(16)),

            CustomTextField(
              key: const ValueKey('email_field'),
              label: 'Email (Opsional)',
              hintText: 'jhon@example.com',
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: R.h(16)),

            Obx(() => CustomTextField(
              key: const ValueKey('phone_field'),
              label: 'No HP',
              isRequired: true,
              hintText: '08123456789',
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              errorText: controller.phoneError.value.isEmpty ? null : controller.phoneError.value,
            )),
            SizedBox(height: R.h(16)),

            Obx(() => CustomTextField(
              key: const ValueKey('password_field'),
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
                        width: R.r(20),
                        height: R.r(20),
                        colorFilter: const ColorFilter.mode(AppColors.border, BlendMode.srcIn),
                      )
                    : Icon(
                        Icons.visibility_outlined,
                        color: AppColors.border,
                        size: R.r(20),
                      ),
                onPressed: controller.togglePasswordVisibility,
              ),
            )),
            SizedBox(height: R.h(40)),

            // Tombol Daftar
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: R.h(16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.r(8)),
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
                        'Daftar Sekarang',
                        style: AppFonts.fInterBodySmallMedium.copyWith(color: AppColors.white),
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