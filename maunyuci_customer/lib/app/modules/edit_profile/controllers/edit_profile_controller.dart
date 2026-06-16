import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../account/controllers/account_controller.dart';
import '../../../core/widgets/custom_error_modal.dart';

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
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profilePicturePath.value = image.path;
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
      
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      Get.back();
      Get.snackbar('Sukses', 'Profil berhasil diperbarui',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      CustomErrorModal.show(
        title: 'Ups, Gagal Menyimpan!',
        message: errorMessage,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
