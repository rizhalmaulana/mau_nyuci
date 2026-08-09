import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../core/widgets/custom_snackbar.dart';

class ChangePasswordController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var oldPasswordError = ''.obs;
  var newPasswordError = ''.obs;
  var confirmPasswordError = ''.obs;

  var isOldPasswordHidden = true.obs;
  var isNewPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  
  var isLoading = false.obs;

  @override
  void onClose() {
    // oldPasswordController.dispose();
    // newPasswordController.dispose();
    // confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleOldPasswordVisibility() => isOldPasswordHidden.value = !isOldPasswordHidden.value;
  void toggleNewPasswordVisibility() => isNewPasswordHidden.value = !isNewPasswordHidden.value;
  void toggleConfirmPasswordVisibility() => isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;

  bool _validateForm() {
    bool isValid = true;
    
    oldPasswordError.value = '';
    newPasswordError.value = '';
    confirmPasswordError.value = '';

    String oldPass = oldPasswordController.text;
    String newPass = newPasswordController.text;
    String confirmPass = confirmPasswordController.text;

    if (oldPass.isEmpty) {
      oldPasswordError.value = 'Masukan password lama';
      isValid = false;
    }

    if (newPass.isEmpty) {
      newPasswordError.value = 'Masukan password baru';
      isValid = false;
    } else {
      if (newPass.length < 8) {
        newPasswordError.value = 'Password minimal 8 karakter';
        isValid = false;
      } else if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[*#]).{8,}$').hasMatch(newPass)) {
        newPasswordError.value = 'Harus mengandung huruf besar, angka, dan karakter (* atau #)';
        isValid = false;
      }
    }

    if (confirmPass.isEmpty) {
      confirmPasswordError.value = 'Masukan konfirmasi password baru';
      isValid = false;
    } else if (confirmPass != newPass) {
      confirmPasswordError.value = 'Password tidak cocok';
      isValid = false;
    }

    return isValid;
  }

  Future<void> savePassword() async {
    if (_validateForm()) {
      try {
        isLoading.value = true;
        await Future.delayed(const Duration(seconds: 1));

        await _authRepository.updatePassword(
          oldPassword: oldPasswordController.text,
          newPassword: newPasswordController.text,
        );

        Get.back();
        CustomSnackbar.showSuccess(
          'Sukses', 
          'Password berhasil diubah!',
        );
      } catch (e) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        CustomSnackbar.showError(
          'Gagal Mengubah Password',
          errorMessage,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }
}
