import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final AuthProvider _authProvider;

  LoginController(this._authProvider);

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  
  final phoneError = ''.obs;
  final passwordError = ''.obs;
  final isPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    phoneError.value = '';
    passwordError.value = '';

    if (phone.isEmpty) {
      phoneError.value = 'No HP tidak boleh kosong';
    } else if (!GetUtils.isNumericOnly(phone)) {
      phoneError.value = 'No. HP hanya boleh berisi angka';
    } else if (phone.length < 9 || phone.length > 12) {
      phoneError.value = 'No. HP harus antara 9-12 digit';
    } else if (!phone.startsWith('08')) {
      phoneError.value = 'No. HP harus diawali dengan 08';
    }

    if (password.isEmpty) {
      passwordError.value = 'Kata sandi tidak boleh kosong';
    }

    if (phoneError.value.isNotEmpty || passwordError.value.isNotEmpty) {
      return;
    }

    isLoading.value = true;
    
    final response = await _authProvider.login(phone, password);
    
    if (response.success && response.data != null) {
      final data = response.data;
      final String? token = data['token'];
      final String? role = data['role'];

      if (token != null) {
        await SecureStorageHelper.saveToken(token);

        // Cek Role (Driver / StoreStaff)
        if (role == 'Driver' || role == 'StoreStaff') {
          // WAJIB simpan role: splash memakai getRole() untuk session login.
          // Tanpa ini user selalu dilempar ke LOGIN setiap buka aplikasi.
          await SecureStorageHelper.saveRole(role!);
          Get.offAllNamed(Routes.HOME);
        } else {
          await SecureStorageHelper.clearAll();
          Get.snackbar('Error', 'Akun ini bukan akun Driver.',
            backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } else {
      Get.snackbar('Login Gagal', response.message ?? 'Terjadi kesalahan sistem',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
    
    isLoading.value = false;
  }
}
