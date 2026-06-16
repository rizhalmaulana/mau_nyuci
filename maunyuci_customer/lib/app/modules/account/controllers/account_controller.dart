import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../core/widgets/custom_confirm_modal.dart';
import '../../../core/widgets/custom_error_modal.dart';

class AccountController extends GetxController {
  final AuthRepository _repository = AuthRepository();

  var fullName = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var profilePictureUrl = RxnString();
  var authProvider = 'Local'.obs;
  var isLoading = false.obs;
  var isFetchingProfile = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isFetchingProfile.value = true;
      final profile = await _repository.getProfile();
      fullName.value = profile.fullName;
      email.value = profile.email;
      phone.value = profile.phoneNumber;
      profilePictureUrl.value = profile.profilePictureUrl;
      authProvider.value = profile.authProvider;
    } catch (e) {
      fullName.value = 'Gagal memuat profil';
      email.value = '-';
      phone.value = '-';
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Error', errorMessage);
    } finally {
      isFetchingProfile.value = false;
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String get initials {
    if (fullName.value.isEmpty) return 'U';
    List<String> names = fullName.value.split(' ');
    if (names.length > 1) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return names[0].substring(0, 2).toUpperCase();
  }

  Future<void> logout() async {
    CustomConfirmModal.show(
      title: "Kamu mau kemana?",
      message: "Kamu yakin mau keluar dari aplikasi ini? pastikan tidak ada transaksi yang belum beres ya.",
      textCancel: "Gak Jadi",
      textConfirm: "Mau Keluar",
      onConfirm: () async {
        try {
          Get.back();
          isLoading.value = true;

          await Future.delayed(const Duration(milliseconds: 500));
          await SecureStorageHelper.clearAll();

          try {
            await FirebaseAuth.instance.signOut();
          } catch (e) {
            debugPrint("Firebase SignOut Error: $e");
          }

          try {
            if (await _googleSignIn.isSignedIn()) {
              await _googleSignIn.signOut();
              await _googleSignIn.disconnect();
            }
          } catch (e) {
            debugPrint("Google SignOut Error: $e");
          }

          Get.offAllNamed(Routes.LOGIN);
        } catch (e) {
          isLoading.value = false;
          CustomErrorModal.show(
            title: 'Ups, Gagal Keluar!',
            message: 'Terjadi kesalahan saat mencoba logout. Silakan coba lagi.',
          );
        }
      },
    );
  }
}