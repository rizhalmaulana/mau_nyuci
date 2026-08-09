import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../account/controllers/account_controller.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../data/repositories/user_profile_repository.dart';

class EditProfileController extends GetxController {
  final AuthRepository _repository = AuthRepository();
  final AccountController _accountController = Get.find<AccountController>();

  final formKey = GlobalKey<FormState>();

  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  final isLoading = false.obs;
  final profilePicturePath = RxnString();
  final isGoogleConnected = false.obs;

  String get initials => _accountController.initials;
  String? get currentProfilePictureUrl => _accountController.profilePictureUrl.value;

  @override
  void onInit() {
    super.onInit();
    fullNameController = TextEditingController(text: _accountController.fullName.value);

    // Convert 'Email belum dilengkapi' back to empty string for editing
    String currentEmail = _accountController.email.value;
    if (currentEmail == 'Email belum dilengkapi' || currentEmail == '-') {
      currentEmail = '';
    }
    emailController = TextEditingController(text: currentEmail);

    String currentPhone = _accountController.phone.value;
    if (currentPhone == 'No HP belum dilengkapi' || currentPhone == '-') {
      currentPhone = '';
    }
    phoneController = TextEditingController(text: currentPhone);
    
    isGoogleConnected.value = _accountController.authProvider.value == 'Firebase';
  }

  @override
  void onClose() {
    // fullNameController.dispose();
    // emailController.dispose();
    // phoneController.dispose();
    super.onClose();
  }

  Future<String> sanitizeAndCompressImage(String originalPath) async {
    final bytes = await File(originalPath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Gagal membaca gambar');

    // Resize + paksa encode ulang sebagai JPEG RGB standar
    final resized = img.copyResize(decoded, width: 1024);
    final jpgBytes = img.encodeJpg(resized, quality: 85);

    final newPath = '${originalPath}_sanitized.jpg';
    await File(newPath).writeAsBytes(jpgBytes);
    return newPath;
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85, // built-in compression dari image_picker
    );
    if (image != null) {
      final sanitizedPath = await sanitizeAndCompressImage(image.path);
      profilePicturePath.value = sanitizedPath;
    }
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));
      
      final updatedProfile = await _repository.updateProfile(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        profilePicturePath: profilePicturePath.value,
      );

      // Update AccountController's reactive variables
      _accountController.fullName.value = updatedProfile.fullName;
      _accountController.email.value = updatedProfile.email;
      _accountController.phone.value = updatedProfile.phoneNumber;
      _accountController.profilePictureUrl.value = updatedProfile.profilePictureUrl;
      
      try {
        final userProfileRepo = Get.find<UserProfileRepository>();
        await userProfileRepo.saveProfile(
          odUserId: updatedProfile.id,
          fullName: updatedProfile.fullName,
          phoneNumber: updatedProfile.phoneNumber,
          email: updatedProfile.email,
          profilePictureUrl: updatedProfile.profilePictureUrl,
          defaultAddress: updatedProfile.defaultAddress,
          defaultLatitude: updatedProfile.defaultLatitude,
          defaultLongitude: updatedProfile.defaultLongitude,
          role: updatedProfile.role,
        );
      } catch (e) {
        debugPrint("Gagal menyimpan profil ke lokal: $e");
      }
      
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      Get.back();
      CustomSnackbar.showSuccess('Sukses', 'Profil berhasil diperbarui');
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
