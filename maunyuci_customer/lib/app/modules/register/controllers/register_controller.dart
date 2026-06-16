import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../core/widgets/custom_error_modal.dart';
import '../../../core/widgets/custom_success_modal.dart';
import '../../../routes/app_pages.dart';
import '../../../data/providers/auth_provider.dart';

class RegisterController extends GetxController {
  final AuthProvider _authProvider = AuthProvider();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  var nameError = ''.obs;
  var phoneError = ''.obs;
  var passwordError = ''.obs;

  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  bool _validateForm() {
    bool isValid = true;

    nameError.value = '';
    phoneError.value = '';
    passwordError.value = '';

    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text;

    if (name.isEmpty) {
      nameError.value = 'Nama lengkap belum terisi';
      isValid = false;
    }

    if (phone.isEmpty) {
      phoneError.value = 'No HP belum terisi';
      isValid = false;
    } else if (!GetUtils.isNumericOnly(phone)) {
      phoneError.value = 'No HP hanya boleh berisi angka';
      isValid = false;
    } else if (phone.length < 10 || phone.length > 13) {
      phoneError.value = 'No HP harus antara 10-13 digit';
      isValid = false;
    } else if (!phone.startsWith('08')) {
      phoneError.value = 'No HP harus dimulai dengan 08';
      isValid = false;
    }

    if (password.isEmpty) {
      passwordError.value = 'Kata sandi belum terisi';
      isValid = false;
    } else if (password.length < 8) {
      passwordError.value = 'Kata sandi minimal 8 karakter';
      isValid = false;
    }

    return isValid;
  }

  Future<void> register() async {
    if (_validateForm()) {
      try {
        isLoading.value = true;
        await Future.delayed(const Duration(seconds: 1));

        final response = await _authProvider.register(
          fullName: nameController.text.trim(),
          phoneNumber: phoneController.text.trim(),
          email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
          password: passwordController.text,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;
          final String? token = data['token'];
          final bool? isProfileComplete = data['isProfileComplete'];

          if (token != null) {
            await SecureStorageHelper.saveToken(token);
            await SecureStorageHelper.write('saved_phone', phoneController.text.trim());
            await SecureStorageHelper.write('saved_password', passwordController.text);
            await SecureStorageHelper.write('is_profile_complete', (isProfileComplete ?? true).toString());

            CustomSuccessModal.show(
              title: 'Yay, berhasil!',
              message: 'Akun kamu sudah terdaftar.\nSilakan login untuk menikmati\nsemua fitur yang ada.',
              buttonText: 'Login',
              onPressed: () {
                Get.back();
                Get.offAllNamed(Routes.LOGIN);
              },
            );
          }
        }
      } on DioException catch (e) {
        String errorMessage = AppConstants.defaultErrorMsg;

        if (e.response != null && e.response?.data != null) {
          final responseData = e.response!.data;
          
          if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('success') && responseData['success'] == false) {
              if (responseData.containsKey('errors') && responseData['errors'] is List) {
                final errors = responseData['errors'] as List;
                errorMessage = errors.join('\n');
              } else if (responseData.containsKey('message')) {
                errorMessage = responseData['message'];
              }
            } else if (responseData.containsKey('message')) {
              errorMessage = responseData['message'];
            }
          } else if (responseData is String) {
            errorMessage = responseData;
          }
        }

        CustomErrorModal.show(
          title: 'Ups, Gagal Daftar!',
          message: errorMessage,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  void goToLogin() {
    Get.back();
  }
}