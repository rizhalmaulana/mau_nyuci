import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/widgets/custom_snackbar.dart';

import '../../../data/providers/media_provider.dart';

class EditProfileController extends GetxController {
  final AuthProvider _authProvider = AuthProvider();
  final MediaProvider _mediaProvider = MediaProvider();
  
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  
  final Rxn<File> selectedImage = Rxn<File>();
  final RxString existingImageUrl = ''.obs;
  
  final RxBool isLoading = false.obs;
  
  late UserModel _user;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is UserModel) {
      _user = Get.arguments as UserModel;
      fullNameController.text = _user.fullName;
      emailController.text = _user.email;
      phoneController.text = _user.phoneNumber;
      existingImageUrl.value = _user.profilePictureUrl;
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  Future<void> updateProfile() async {
    if (fullNameController.text.trim().isEmpty) {
      CustomSnackbar.showError('Error', 'Nama lengkap tidak boleh kosong');
      return;
    }
    if (emailController.text.trim().isEmpty) {
      CustomSnackbar.showError('Error', 'Email tidak boleh kosong');
      return;
    }

    isLoading.value = true;
    try {
      String finalImageUrl = existingImageUrl.value;
      
      // 1. Upload image if selected
      if (selectedImage.value != null) {
        final uploadResponse = await _mediaProvider.uploadProfilePicture(selectedImage.value!);
        if (uploadResponse.success && uploadResponse.data != null) {
          finalImageUrl = uploadResponse.data!;
        } else {
          CustomSnackbar.showError('Gagal', uploadResponse.message ?? 'Gagal mengupload foto');
          isLoading.value = false;
          return;
        }
      }

      // 2. Prepare JSON payload
      final payload = {
        'fullName': fullNameController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'profilePictureUrl': finalImageUrl,
        'defaultAddress': '', // Nilai default kosong jika tidak ada input khusus
        'defaultLatitude': 0.0,
        'defaultLongitude': 0.0,
      };

      // 3. Update Profile via JSON API
      final response = await _authProvider.updateProfile(payload);
      if (response.success) {
        Get.back(result: true); // Return true so AkunController can refresh
        Future.delayed(const Duration(milliseconds: 300), () {
          CustomSnackbar.showSuccess('Berhasil', 'Profil berhasil diperbarui');
        });
      } else {
        CustomSnackbar.showError('Gagal', response.message ?? 'Gagal memperbarui profil');
      }
    } catch (e) {
      CustomSnackbar.showError('Terjadi Kesalahan', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
