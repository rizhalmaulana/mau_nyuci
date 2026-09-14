import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/change_password_controller.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text('Ubah Password', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(16))),
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(R.w(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(R.w(16)),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(R.r(16)),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Buat Password Baru', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14), color: AppColors.grey800)),
                        SizedBox(height: R.h(8)),
                        Text('Password baru Anda harus berbeda dari password sebelumnya demi keamanan.', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey500)),
                        SizedBox(height: R.h(24)),

                        _buildInputLabel('Password Lama'),
                        Obx(() => _buildPasswordField(
                          controller: controller.oldPasswordController,
                          hintText: 'Masukkan password lama',
                          isVisible: controller.isOldPasswordVisible.value,
                          onToggleVisibility: controller.toggleOldPassword,
                        )),
                        SizedBox(height: R.h(16)),

                        _buildInputLabel('Password Baru'),
                        Obx(() => _buildPasswordField(
                          controller: controller.newPasswordController,
                          hintText: 'Minimal 6 karakter',
                          isVisible: controller.isNewPasswordVisible.value,
                          onToggleVisibility: controller.toggleNewPassword,
                        )),
                        SizedBox(height: R.h(16)),

                        _buildInputLabel('Konfirmasi Password Baru'),
                        Obx(() => _buildPasswordField(
                          controller: controller.confirmPasswordController,
                          hintText: 'Masukkan ulang password baru',
                          isVisible: controller.isConfirmPasswordVisible.value,
                          onToggleVisibility: controller.toggleConfirmPassword,
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(8)),
      child: Text(
        label,
        style: AppFonts.inter(fontSize: R.sp(13), fontWeight: FontWeight.w500, color: AppColors.inputText),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      style: AppFonts.inter(fontSize: R.sp(14)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppFonts.inter(color: AppColors.hint, fontSize: R.sp(13)),
        prefixIcon: Icon(Icons.lock_outline, color: AppColors.hint, size: R.r(20)),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.hint, size: R.r(20)),
          onPressed: onToggleVisibility,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: AppColors.primary)),
        contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: R.h(16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
              elevation: 0,
            ),
            child: controller.isLoading.value
                ? SizedBox(height: R.r(20), width: R.r(20), child: const CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                : Text('Simpan Password', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14), color: AppColors.white)),
          )),
        ),
      ),
    );
  }
}
