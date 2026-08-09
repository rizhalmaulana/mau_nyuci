import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../core/helpers/api_error_helper.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/responsive_helper.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Ubah Profil',
          style: AppFonts.fInterSubheadingSemibold.copyWith(
            color: AppColors.black,
            fontSize: R.sp(20),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(R.r(24)),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Foto Profil',
                  style: AppFonts.fInterSubheadingSemibold.copyWith(fontSize: R.sp(14)),
                ),
                SizedBox(height: R.h(16)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: controller.pickImage,
                          child: Obx(() {
                            if (controller.profilePicturePath.value != null) {
                              return CircleAvatar(
                                radius: R.r(36),
                                backgroundImage: FileImage(File(controller.profilePicturePath.value!)),
                              );
                            }
                            final rawUrl = controller.currentProfilePictureUrl;
                            final imgUrl = getFullImageUrl(rawUrl);

                            final hasValidUrl = imgUrl.isNotEmpty && imgUrl.startsWith('http');
                            if (hasValidUrl) {
                              return ClipOval(
                                child: Image.network(
                                  imgUrl,
                                  width: R.r(72),
                                  height: R.r(72),
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return SizedBox(
                                      width: R.r(72),
                                      height: R.r(72),
                                      child: const CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: R.r(72),
                                    height: R.r(72),
                                    color: AppColors.primary,
                                    child: Center(
                                      child: Text(
                                        controller.initials,
                                        style: AppFonts.fInterSubheadingSemibold.copyWith(
                                          color: AppColors.white,
                                          fontSize: R.sp(24),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return CircleAvatar(
                              radius: R.r(36),
                              backgroundColor: AppColors.primary,
                              child: Text(
                                controller.initials,
                                style: AppFonts.fInterSubheadingSemibold.copyWith(
                                  color: Colors.white,
                                  fontSize: R.sp(24),
                                ),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: R.h(8)),
                        Text(
                          'Ganti',
                          style: AppFonts.fInterBodySmallRegular.copyWith(color: AppColors.black),
                        ),
                      ],
                    ),
                    SizedBox(width: R.w(16)),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: R.h(24)),
                        child: Text(
                          'Pasang foto yang bagus, biar makin keren!',
                          style: AppFonts.fInterBodyMedium.copyWith(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: R.h(32)),
                _buildLabel('Nama Lengkap', isRequired: true),
                SizedBox(height: R.h(8)),
                TextFormField(
                  controller: controller.fullNameController,
                  style: AppFonts.fInterBodyMedium.copyWith(fontSize: R.sp(14)),
                  decoration: _inputDecoration('Contoh: Jhon Taruna'),
                  validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                ),
                SizedBox(height: R.h(24)),
                _buildLabel('Email (Opsional)', isRequired: false),
                SizedBox(height: R.h(8)),
                TextFormField(
                  controller: controller.emailController,
                  style: AppFonts.fInterBodyMedium.copyWith(fontSize: R.sp(14)),
                  decoration: _inputDecoration('Contoh: rizal@example.com'),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: R.h(24)),
                _buildLabel('No HP', isRequired: true),
                SizedBox(height: R.h(8)),
                TextFormField(
                  controller: controller.phoneController,
                  style: AppFonts.fInterBodyMedium.copyWith(fontSize: R.sp(14)),
                  decoration: _inputDecoration('Contoh: 08123456789'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? 'No HP tidak boleh kosong' : null,
                ),
                SizedBox(height: R.h(32)),
                Text(
                  'Akun terhubung',
                  style: AppFonts.fInterSubheadingSemibold.copyWith(fontSize: R.sp(14)),
                ),
                SizedBox(height: R.h(16)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(4)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(R.r(12)),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      // Temporary icon container until asset is provided
                      Container(
                        width: R.w(24),
                        height: R.h(24),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: SvgPicture.asset(
                          AppAssets.iconGoogle,
                          width: R.r(20),
                          height: R.r(20)
                        ),
                      ),
                      SizedBox(width: R.w(12)),
                      Expanded(
                        child: Text(
                          'Google',
                          style: AppFonts.fInterBodyMedium,
                        ),
                      ),
                      Obx(() => Switch(
                            value: controller.isGoogleConnected.value,
                            activeColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(4)),
                            onChanged: (val) {
                              // TBD Google Connection Logic
                            },
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(R.r(24)),
          child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: R.h(16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.r(12)),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Simpan',
                        style: AppFonts.fInterSubheadingSemibold.copyWith(color: Colors.white),
                      ),
              )),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: AppFonts.fInterBodyMedium.copyWith(color: AppColors.black),
        children: [
          if (isRequired)
            TextSpan(
              text: ' *',
              style: AppFonts.fInterBodyMedium.copyWith(color: Colors.red),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppFonts.fInterBodyMedium.copyWith(color: Colors.grey.shade400, fontSize: R.sp(14)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: R.w(14), vertical: R.h(12)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(R.r(12)),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(R.r(12)),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(R.r(12)),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }
}
