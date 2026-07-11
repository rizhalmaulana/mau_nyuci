import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:maunyuci_core/maunyuci_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/widgets/custom_error_modal.dart';
import '../../../core/helpers/api_error_helper.dart';
import '../../../routes/app_pages.dart';
import '../../../data/providers/auth_provider.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthProvider _authProvider = AuthProvider();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  var phoneError = ''.obs;
  var passwordError = ''.obs;
  var isPasswordHidden = true.obs;
  var isLoading = false.obs;
  var isGoogleLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> _loadSavedCredentials() async {
    final savedPhone = await SecureStorageHelper.read('saved_phone');
    final savedPassword = await SecureStorageHelper.read('saved_password');

    if (savedPhone != null && savedPassword != null) {
      phoneController.text = savedPhone;
      passwordController.text = savedPassword;
    }
  }

  bool _validateForm() {
    bool isValid = true;
    phoneError.value = '';
    passwordError.value = '';

    String phone = phoneController.text.trim();
    String password = passwordController.text;

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
      phoneError.value = 'No. HP harus diawali dengan 08';
      isValid = false;
    }

    if (password.isEmpty) {
      passwordError.value = 'Kata sandi tidak boleh kosong';
      isValid = false;
    } else if (password.length < 8) {
      passwordError.value = 'Kata sandi minimal 8 karakter';
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
          final String? fullName = data['fullName'];
          final String? role = data['role'];
          final bool? isProfileComplete = data['isProfileComplete'];

          if (token != null) {
            await SecureStorageHelper.saveToken(token);
            if (role != null) {
              await SecureStorageHelper.saveRole(role);
            }
            if (fullName != null) {
              await SecureStorageHelper.write('full_name', fullName);
            }
            if (isProfileComplete != null) {
              await SecureStorageHelper.write('is_profile_complete', isProfileComplete.toString());
            }

            await SecureStorageHelper.write('saved_phone', phoneController.text.trim());
            await SecureStorageHelper.write('saved_password', passwordController.text);

            _checkPermissionsAfterLogin();

            Get.offAllNamed(Routes.HOME);
          }
        }
      } on DioException catch (e) {
        final errorMessage = handleApiError(e);
        CustomErrorModal.show(
          title: 'Ups, Gagal Masuk!',
          message: errorMessage,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      isGoogleLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        isGoogleLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null && accessToken == null) {
        CustomErrorModal.show(
          title: 'Ups, Gagal Masuk!',
          message: 'Tidak dapat mengambil kredensial dari Google',
        );
        isGoogleLoading.value = false;
        return;
      }

      // Login to Firebase Auth
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final String? firebaseIdToken = await userCredential.user?.getIdToken();

      if (firebaseIdToken == null) {
        CustomErrorModal.show(
          title: 'Ups, Gagal Masuk!',
          message: 'Gagal mendapatkan token autentikasi Firebase',
        );
        isGoogleLoading.value = false;
        return;
      }

      try {
        final response = await _authProvider.firebaseAuth(firebaseIdToken);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = response.data;
          final String? token = data['token'];
          final bool? isProfileComplete = data['isProfileComplete'];

          if (token != null) {
            await SecureStorageHelper.saveToken(token);
            await SecureStorageHelper.write('is_profile_complete', (isProfileComplete ?? false).toString());

            if (isProfileComplete == false) {
              Get.offAllNamed(Routes.COMPLETE_PROFILE);
            } else {
              _checkPermissionsAfterLogin();
              Get.offAllNamed(Routes.HOME);
            }
          }
        }
      } on DioException catch (e) {
        final errorMessage = handleApiError(e);
        CustomErrorModal.show(
          title: 'Ups, Gagal Masuk!',
          message: errorMessage,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Google Sign In Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      CustomErrorModal.show(
        title: 'Ups, Gagal Masuk!',
        message: 'Terjadi kesalahan saat login dengan Google: ${e.toString()}',
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }

  void goToRegister() {
    Get.toNamed(Routes.REGISTER);
  }

  Future<void> _checkPermissionsAfterLogin() async {
    await Permission.camera.request();
    await Permission.location.request();
    await Permission.photos.request();
    
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      await Geolocator.openLocationSettings();
    }
  }
}