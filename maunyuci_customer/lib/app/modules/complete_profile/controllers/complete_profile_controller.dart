import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../routes/app_pages.dart';
import '../../../data/repositories/auth_repository.dart';

class CompleteProfileController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var phoneError = ''.obs;
  var passwordError = ''.obs;
  var confirmPasswordError = ''.obs;
  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;
  var isLoading = false.obs;

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  bool _validateForm() {
    bool isValid = true;
    phoneError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';

    String phone = phoneController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (phone.isEmpty) {
      phoneError.value = 'No. HP tidak boleh kosong';
      isValid = false;
    } else if (!GetUtils.isNumericOnly(phone)) {
      phoneError.value = 'No. HP hanya boleh berisi angka';
      isValid = false;
    } else if (phone.length < 9 || phone.length > 12) {
      phoneError.value = 'No. HP harus antara 9-12 digit';
      isValid = false;
    } else if (!phone.startsWith('08')) {
      phoneError.value = 'No. HP harus dimulai dengan 08';
      isValid = false;
    }

    if (password.isEmpty) {
      passwordError.value = 'Kata sandi tidak boleh kosong';
      isValid = false;
    } else if (password.length < 8) {
      passwordError.value = 'Kata sandi minimal 8 karakter';
      isValid = false;
    } else if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[*#]).{8,}$').hasMatch(password)) {
      passwordError.value = 'Harus mengandung huruf besar, angka, dan karakter (* atau #)';
      isValid = false;
    }

    if (confirmPassword.isEmpty) {
      confirmPasswordError.value = 'Konfirmasi kata sandi tidak boleh kosong';
      isValid = false;
    } else if (confirmPassword != password) {
      confirmPasswordError.value = 'Kata sandi tidak cocok';
      isValid = false;
    }

    return isValid;
  }

  Future<void> saveProfile() async {
    if (_validateForm()) {
      try {
        isLoading.value = true;

        double? lat;
        double? lng;

        try {
          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (!serviceEnabled) {
            await Geolocator.openLocationSettings();
            serviceEnabled = await Geolocator.isLocationServiceEnabled();
          }

          if (serviceEnabled) {
            LocationPermission permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.denied) {
              permission = await Geolocator.requestPermission();
            }

            if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
              Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
              lat = position.latitude;
              lng = position.longitude;
            }
          }
        } catch (e) {
          debugPrint('Gagal mendapatkan lokasi: $e');
        }

        final currentProfile = await _authRepository.getProfile();

        await _authRepository.updateProfile(
          fullName: currentProfile.fullName,
          email: currentProfile.email,
          phoneNumber: phoneController.text.trim(),
          defaultLatitude: lat,
          defaultLongitude: lng,
          password: passwordController.text,
        );

        await SecureStorageHelper.write('phone_number', phoneController.text.trim());
        await SecureStorageHelper.write('is_profile_complete', 'true');
        await SecureStorageHelper.write('saved_phone', phoneController.text.trim());
        await SecureStorageHelper.write('saved_password', passwordController.text);

        Get.offAllNamed(Routes.HOME);
      } catch (e) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');

        CustomSnackbar.showError(
          'Ups, Gagal Menyimpan!',
          errorMessage,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }
}