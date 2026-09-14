import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/login_controller.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: R.w(24.0), vertical: R.h(20.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: R.h(40)),
              // Logo
              SvgPicture.asset(
                'assets/images/logo.svg',
                height: R.h(80),
              ),
              SizedBox(height: R.h(32)),
              
              // Teks Judul
              Text(
                'Masuk ke Toko Laundry Kamu!',
                style: AppFonts.inter(
                  fontSize: R.sp(24),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
              SizedBox(height: R.h(8)),
              
              // Teks Subjudul
              Text(
                'Kami siap membantu toko laundry mu berkembang lebih besar!',
                style: AppFonts.inter(
                  fontSize: R.sp(14),
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
              SizedBox(height: R.h(32)),

              // Form Input Phone
              Text(
                'No. Handphone',
                style: AppFonts.inter(
                  fontSize: R.sp(14),
                  fontWeight: FontWeight.w500,
                  color: AppColors.inputText,
                ),
              ),
              SizedBox(height: R.h(8)),
              Obx(() => TextField(
                controller: controller.phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Misal: 081234567890',
                  hintStyle: AppFonts.inter(color: AppColors.hint, fontSize: R.sp(14)),
                  errorText: controller.phoneError.value.isEmpty ? null : controller.phoneError.value,
                  contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(R.r(12)),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(R.r(12)),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(R.r(12)),
                    borderSide: const BorderSide(color: AppColors.danger),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(R.r(12)),
                    borderSide: const BorderSide(color: AppColors.danger),
                  ),
                ),
              )),
              SizedBox(height: R.h(20)),

              // Form Input Password
              Text(
                'Kata Sandi',
                style: AppFonts.inter(
                  fontSize: R.sp(14),
                  fontWeight: FontWeight.w500,
                  color: AppColors.inputText,
                ),
              ),
              SizedBox(height: R.h(8)),
              Obx(() => TextField(
                controller: controller.passwordController,
                obscureText: controller.isPasswordHidden.value,
                decoration: InputDecoration(
                  hintText: 'Masukan kata sandi',
                  hintStyle: AppFonts.inter(color: AppColors.hint, fontSize: R.sp(14)),
                  errorText: controller.passwordError.value.isEmpty ? null : controller.passwordError.value,
                  contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(R.r(12)),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(R.r(12)),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(R.r(12)),
                    borderSide: const BorderSide(color: AppColors.danger),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(R.r(12)),
                    borderSide: const BorderSide(color: AppColors.danger),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordHidden.value 
                        ? Icons.visibility_off_outlined 
                        : Icons.visibility_outlined,
                      color: AppColors.hint,
                      size: R.r(20),
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                ),
              )),
              
              SizedBox(height: R.h(12)),
              
              // Bantuan / Lupa Sandi Link ke WA
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: controller.openWhatsAppSupport,
                  child: Text(
                    'Lupa Kata Sandi?',
                    style: AppFonts.inter(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              SizedBox(height: R.h(32)),

              // Tombol Masuk
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                    padding: EdgeInsets.symmetric(vertical: R.h(16)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(R.r(12)),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(
                          height: R.r(20),
                          width: R.r(20),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : Text(
                          'Masuk',
                          style: AppFonts.inter(
                            fontSize: R.sp(16),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
