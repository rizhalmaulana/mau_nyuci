import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../routes/app_routes.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/store_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthProvider _authProvider = AuthProvider();
  final StoreProvider _storeProvider = StoreProvider();

  var phoneError = ''.obs;
  var passwordError = ''.obs;
  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  bool _validateForm() {
    bool isValid = true;
    phoneError.value = '';
    passwordError.value = '';

    String phone = phoneController.text.trim();
    String password = passwordController.text;

    if (phone.isEmpty) {
      phoneError.value = 'Nomor HP tidak boleh kosong';
      isValid = false;
    } else if (!phone.startsWith('08')) {
      phoneError.value = 'Nomor HP harus diawali dengan 08';
      isValid = false;
    } else if (phone.length < 9 || phone.length > 15) {
      phoneError.value = 'Nomor HP tidak valid';
      isValid = false;
    }

    if (password.isEmpty) {
      passwordError.value = 'Kata sandi tidak boleh kosong';
      isValid = false;
    }

    return isValid;
  }

  Future<void> login() async {
    if (_validateForm()) {
      try {
        isLoading.value = true;
        await Future.delayed(const Duration(seconds: 1));

        final response = await _authProvider.login(
          phoneController.text.trim(),
          passwordController.text,
        );

        if (response.statusCode == 200) {
          final data = response.data;
          final String? token = data['token'];
          final String? role = data['role'];
          final String? fullName = data['fullName'];
          final bool? isProfileComplete = data['isProfileComplete'];

          // Validasi Kritis: Pastikan rolenya adalah Owner
          if (role != 'Owner') {
            // Tolak akses jika bukan Owner
            _showErrorSnackbar(
              'Akses Ditolak!', 
              'Aplikasi ini khusus untuk Pemilik Toko (Owner).'
            );
            return;
          }

          if (token != null) {
            await SecureStorageHelper.saveToken(token);
            await SecureStorageHelper.saveRole(role!);
            
            if (fullName != null) {
              await SecureStorageHelper.write('full_name', fullName);
            }
            if (isProfileComplete != null) {
              await SecureStorageHelper.write('is_profile_complete', isProfileComplete.toString());
            }

            // Cek status store dari backend
            try {
              final storeResponse = await _storeProvider.getMyStore();
              if (storeResponse.statusCode == 200) {
                final storeData = storeResponse.data;
                
                // Jika API me-return response dengan isStoreRegistered: false (200 OK)
                if (storeData is Map && storeData['isStoreRegistered'] == false) {
                  Get.offAllNamed(Routes.REGISTER_STORE);
                  return; 
                }
                
                // Jika store ada, arahkan ke HOME
                Get.offAllNamed(Routes.HOME);
              }
            } on DioException catch (e) {
              // Jika backend me-return HTTP Error (misal 400/404) dengan response isStoreRegistered
              final errorData = e.response?.data;
              if (errorData is Map && errorData['isStoreRegistered'] == false) {
                Get.offAllNamed(Routes.REGISTER_STORE);
                return;
              }

              // Menangani error umum (server down, dsb)
              final errorMessage = ApiClient.handleErrorMessage(e.response?.data);
              _showErrorSnackbar('Gagal Memeriksa Toko', errorMessage);
              return;
            }
          }
        }
      } on DioException catch (e) {
        final errorMessage = ApiClient.handleErrorMessage(e.response?.data);
        _showErrorSnackbar('Maaf, Login Masuk Gagal!', errorMessage);
      } catch (e) {
        _showErrorSnackbar('Error', 'Terjadi kesalahan sistem.');
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> openWhatsAppSupport() async {
    const phoneNumber = '+6281234567890'; // TODO: Ganti dengan nomor asli
    const message = 'Halo CS MauNyuci, saya butuh bantuan terkait akun Store saya (Lupa Kata Sandi).';
    final Uri url = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackbar('Gagal', 'Tidak dapat membuka WhatsApp');
    }
  }

  void _showErrorSnackbar(String title, String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}
