import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/helpers/api_error_helper.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/responsive_helper.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Ubah Profil Akun',
          style: AppFonts.fInterSubheadingSemibold.copyWith(
            color: Colors.black,
            fontSize: R.sp(16),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Form(
        key: controller.formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(R.w(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.all(R.w(16)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(R.r(16)),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Lengkapi Profil Anda', style: AppFonts.fInterBodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
                          SizedBox(height: R.h(8)),
                          Text('Ubah foto profil atau nama lengkap Anda di sini.', style: AppFonts.fInterBodySmallRegular.copyWith(color: Colors.grey.shade500)),
                          SizedBox(height: R.h(32)),
                          Center(
                            child: GestureDetector(
                              onTap: controller.pickImage,
                              child: Obx(() {
                                final selectedImage = controller.profilePicturePath.value;
                                final existingUrl = controller.currentProfilePictureUrl;
                                final imgUrl = getFullImageUrl(existingUrl);
                                final hasValidUrl = imgUrl.isNotEmpty && imgUrl.startsWith('http');
                                
                                return Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Container(
                                      width: R.r(100),
                                      height: R.r(100),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey.shade100,
                                        border: Border.all(color: Colors.grey.shade300, width: 2),
                                      ),
                                      child: ClipOval(
                                        child: selectedImage != null
                                            ? Image.file(File(selectedImage), fit: BoxFit.cover)
                                            : (hasValidUrl
                                                ? Image.network(imgUrl, fit: BoxFit.cover)
                                                : Icon(Icons.person, size: R.r(40), color: Colors.grey.shade400)),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(R.w(6)),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      child: Icon(Icons.camera_alt, color: Colors.white, size: R.r(16)),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                          SizedBox(height: R.h(32)),
                          _buildInputLabel('Nama Lengkap', isRequired: true),
                          _buildTextField(
                            controller: controller.fullNameController,
                            hintText: 'Contoh: Jhon Taruna',
                            icon: Icons.person_outline,
                            validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                          ),
                          SizedBox(height: R.h(16)),
                          
                          _buildInputLabel('Alamat Email (Opsional)', isRequired: false),
                          _buildTextField(
                            controller: controller.emailController,
                            hintText: 'Contoh: rizal@example.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: R.h(16)),
                          
                          _buildInputLabel('No. Handphone', isRequired: true),
                          _buildTextField(
                            controller: controller.phoneController,
                            hintText: 'Contoh: 08123456789',
                            icon: Icons.phone_android_outlined,
                            keyboardType: TextInputType.phone,
                            readOnly: true, // Phone number cannot be changed directly
                            validator: (value) => value!.isEmpty ? 'No HP tidak boleh kosong' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(8)),
      child: RichText(
        text: TextSpan(
          text: label,
          style: AppFonts.fInterBodySmallMedium.copyWith(color: Colors.black87),
          children: [
            if (isRequired)
              TextSpan(
                text: ' *',
                style: AppFonts.fInterBodySmallMedium.copyWith(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: validator,
      style: AppFonts.fInterBodySmallMedium.copyWith(
        color: readOnly ? Colors.grey.shade600 : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppFonts.fInterBodySmallMedium.copyWith(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: R.r(20)),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: AppColors.primary)),
        contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: R.h(16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
              elevation: 0,
            ),
            child: controller.isLoading.value
                ? SizedBox(height: R.r(20), width: R.r(20), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Simpan Perubahan', style: AppFonts.fInterBodySmallMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
          )),
        ),
      ),
    );
  }
}
