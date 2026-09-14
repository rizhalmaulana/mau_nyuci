import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/widgets/custom_snackbar.dart';

class ChangePasswordController extends GetxController {
  final AuthProvider _authProvider = AuthProvider();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool isOldPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleOldPassword() => isOldPasswordVisible.value = !isOldPasswordVisible.value;
  void toggleNewPassword() => isNewPasswordVisible.value = !isNewPasswordVisible.value;
  void toggleConfirmPassword() => isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  Future<void> changePassword() async {
    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      CustomSnackbar.showError('Error', 'Semua kolom harus diisi');
      return;
    }

    if (newPassword.length < 6) {
      CustomSnackbar.showError('Error', 'Password baru minimal 6 karakter');
      return;
    }

    if (newPassword != confirmPassword) {
      CustomSnackbar.showError('Error', 'Konfirmasi password tidak cocok');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authProvider.changePassword(oldPassword, newPassword);
      if (response.success) {
        Get.back(); // kembali dulu, snackbar setelahnya
        Future.delayed(const Duration(milliseconds: 300), () {
          CustomSnackbar.showSuccess('Berhasil', 'Password berhasil diubah');
        });
      } else {
        CustomSnackbar.showError('Gagal', response.message ?? 'Gagal mengubah password');
      }
    } catch (e) {
      CustomSnackbar.showError('Terjadi Kesalahan', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
