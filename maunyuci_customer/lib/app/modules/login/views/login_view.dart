import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/responsive_helper.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: R.w(24.0), vertical: R.h(24.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                AppAssets.logoSvg,
                width: R.w(85),
                height: R.h(84),
              ),
              SizedBox(height: R.h(20)),
              Text(
                'Selamat datang kembali!',
                style: AppFonts.fInterSubheadingSemibold
                    .copyWith(color: AppColors.black, fontSize: R.sp(20)),
              ),
              SizedBox(height: R.h(8)),
              Text(
                'Masukkan no hp dan kata sandi kamu untuk kembali menikmati layanan kami.',
                style: AppFonts.fInterBodySmallRegular.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                    fontSize: R.sp(12) // Asumsi ukuran aslinya 12
                ),
              ),
              SizedBox(height: R.h(32)),

              Obx(() => CustomTextField(
                key: const ValueKey('phone_field'),
                label: 'No HP',
                isRequired: true,
                hintText: 'Masukan no hp',
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
              SizedBox(height: R.h(32)),
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: (controller.isLoading.value || controller.isGoogleLoading.value) ? null : controller.login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: R.h(12)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(8)),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.7),
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(
                    height: R.h(20),
                    width: R.w(20),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    'Masuk',
                    style: AppFonts.fInterBodySmallMedium
                        .copyWith(color: AppColors.white, fontSize: R.sp(14)), // Asumsi 14
                  ),
                )),
              ),
              SizedBox(height: R.h(12)),
              Center(
                child: Text(
                  'atau',
                  style: AppFonts.fInterBodySmallRegular
                      .copyWith(color: AppColors.textSecondary, fontSize: R.sp(12)),
                ),
              ),
              SizedBox(height: R.h(12)),
              SizedBox(
                width: double.infinity,
                child: Obx(() => OutlinedButton(
                  onPressed: (controller.isLoading.value || controller.isGoogleLoading.value) ? null : controller.loginWithGoogle,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: R.h(14)),
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(8)),
                    ),
                    disabledBackgroundColor: AppColors.background,
                  ),
                  child: controller.isGoogleLoading.value
                      ? SizedBox(
                    height: R.h(20),
                    width: R.w(20),
                    child: const CircularProgressIndicator(
                      color: AppColors.textSecondary,
                      strokeWidth: 2,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppAssets.iconGoogle,
                        width: R.w(24),
                        height: R.h(24),
                      ),
                      SizedBox(width: R.w(12)),
                      Text(
                        'Masuk dengan Google',
                        style: AppFonts.fInterBodySmallMedium
                            .copyWith(color: AppColors.textPrimary, fontSize: R.sp(14)),
                      ),
                    ],
                  ),
                )),
              ),
              SizedBox(height: R.h(28)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Kamu belum punya akun? ',
                    style: AppFonts.fInterBodySmallRegular
                        .copyWith(color: AppColors.textSecondary, fontSize: R.sp(12)),
                  ),
                  GestureDetector(
                    onTap: controller.goToRegister,
                    child: Text(
                      'Daftar sini !',
                      style: AppFonts.fInterBodySmallMedium
                          .copyWith(color: AppColors.primary, fontSize: R.sp(12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}