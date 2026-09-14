import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../routes/app_routes.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/store_provider.dart';
import '../../../data/services/storage_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

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
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      final response = await _authProvider.login(
        phoneController.text.trim(),
        passwordController.text,
      );

      if (response.success && response.data != null) {
        final data = response.data;
        final String? token = data['token'];
        final String? role = data['role'];
        final String? storeRole = data['storeRole'];
        final String? fullName = data['fullName'];
        final bool? isProfileComplete = data['isProfileComplete'];
        final String? membershipTier = data['membershipTier'];

        // Akses dikendalikan BE via respons Menu; aplikasi hanya memastikan
        // role yang dikenali (Owner / StoreStaff) bisa masuk.
        if (role != 'Owner' && role != 'StoreStaff') {
          _showErrorSnackbar(
            'Akses Ditolak!',
            'Akun Anda tidak memiliki akses ke aplikasi Store.'
          );
          isLoading.value = false;
          return;
        }

        if (token != null) {
          final storage = Get.find<StorageService>();
          await storage.saveToken(token);
          await storage.write('user_role', role!);
          if (storeRole != null && storeRole.isNotEmpty) {
            await storage.write('store_role', storeRole);
          }
          
          if (fullName != null) {
            await storage.write('full_name', fullName);
          }
          if (isProfileComplete != null) {
            await storage.write('is_profile_complete', isProfileComplete.toString());
          }
          if (membershipTier != null) {
            await storage.write('membership_tier', membershipTier);
          }

          // Cek status store dari backend.
          // Staff tidak pernah diarahkan ke Register Store (hanya Owner).
          final isStaff = role == 'StoreStaff';
          final storeResponse = await _storeProvider.getMyStore();
          if (storeResponse.success) {
            final storeData = storeResponse.data;

            // Jika API me-return response dengan isStoreRegistered: false (200 OK)
            if (!isStaff && storeData is Map && storeData['isStoreRegistered'] == false) {
              Get.offAllNamed(Routes.REGISTER_STORE);
              isLoading.value = false;
              return;
            }
            
            // Jika store ada, simpan storeId dan arahkan ke MAIN
            if (storeData is Map) {
              final storeId = storeData['data'] != null ? storeData['data']['id'] : storeData['id'];
              if (storeId != null) {
                await storage.write('storeId', storeId.toString());
              }
            }
            
            final fcmToken = await NotificationService().getFcmToken();
            if (fcmToken != null) {
              final syncResponse = await _authProvider.syncFcmToken(fcmToken);
              if (syncResponse.success) {
                debugPrint("FCM Token berhasil disinkronisasi");
              } else {
                debugPrint("Gagal sinkronisasi FCM token: ${syncResponse.message}");
              }
            }

            Get.offAllNamed(Routes.MAIN);
          } else {
            // Jika backend me-return HTTP Error (misal 400/404) dengan response isStoreRegistered.
            // Staff tidak pernah diarahkan ke Register Store.
            if (!isStaff && (storeResponse.message?.toLowerCase().contains('belum terdaftar') ?? false)) {
              Get.offAllNamed(Routes.REGISTER_STORE);
            } else if (isStaff) {
              // Staff: backend menjamin store terikat; lanjut ke MAIN.
              Get.offAllNamed(Routes.MAIN);
            } else {
              _showErrorSnackbar('Gagal Memeriksa Toko', storeResponse.message ?? 'Terjadi kesalahan');
            }
          }
        }
      } else {
        _showErrorSnackbar('Maaf, Login Masuk Gagal!', response.message ?? 'Terjadi kesalahan');
      }

      isLoading.value = false;
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
      backgroundColor: AppColors.danger.withValues(alpha: 0.9),
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: AppColors.white),
    );
  }
}
