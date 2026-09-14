import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_profile_controller.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text('Ubah Profil Akun', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(16))),
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Column(
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
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(R.r(16)),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lengkapi Profil Anda', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14), color: AppColors.grey800)),
                        SizedBox(height: R.h(8)),
                        Text('Ubah foto profil atau nama lengkap Anda di sini.', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey500)),
                        SizedBox(height: R.h(32)),
                        Center(
                          child: GestureDetector(
                            onTap: controller.pickImage,
                            child: Obx(() {
                              final selectedImage = controller.selectedImage.value;
                              final existingUrl = controller.existingImageUrl.value;
                              
                              return Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: R.r(100),
                                    height: R.r(100),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.grey100,
                                      border: Border.all(color: AppColors.grey300, width: 2),
                                    ),
                                    child: ClipOval(
                                      child: selectedImage != null
                                          ? Image.file(selectedImage, fit: BoxFit.cover)
                                          : (existingUrl.isNotEmpty
                                              ? Image.network(existingUrl, fit: BoxFit.cover)
                                              : Icon(Icons.person, size: R.r(40), color: AppColors.grey400)),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(R.w(6)),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.white, width: 2),
                                    ),
                                    child: Icon(Icons.camera_alt, color: AppColors.white, size: R.r(16)),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                        SizedBox(height: R.h(32)),
                        _buildInputLabel('Nama Lengkap'),
                        _buildTextField(
                          controller: controller.fullNameController,
                          hintText: 'Masukkan nama lengkap',
                          icon: Icons.person_outline,
                        ),
                        SizedBox(height: R.h(16)),
                        
                        _buildInputLabel('Alamat Email'),
                        _buildTextField(
                          controller: controller.emailController,
                          hintText: 'Masukkan alamat email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: R.h(16)),
                        
                        _buildInputLabel('No. Handphone'),
                        _buildTextField(
                          controller: controller.phoneController,
                          hintText: 'Masukkan nomor handphone',
                          icon: Icons.phone_android_outlined,
                          keyboardType: TextInputType.phone,
                          readOnly: true, // Nomor HP biasanya jadi primary login, jadi tidak bisa diubah langsung
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
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(8)),
      child: Text(
        label,
        style: AppFonts.inter(fontSize: R.sp(13), fontWeight: FontWeight.w500, color: AppColors.inputText),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: AppFonts.inter(
        fontSize: R.sp(14),
        color: readOnly ? AppColors.grey600 : AppColors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppFonts.inter(color: AppColors.hint, fontSize: R.sp(13)),
        prefixIcon: Icon(icon, color: AppColors.hint, size: R.r(20)),
        filled: readOnly,
        fillColor: readOnly ? AppColors.grey100 : Colors.transparent,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: AppColors.primary)),
        contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(vertical: R.h(16)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
              elevation: 0,
            ),
            child: controller.isLoading.value
                ? SizedBox(height: R.r(20), width: R.r(20), child: const CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                : Text('Simpan Perubahan', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14), color: AppColors.white)),
          )),
        ),
      ),
    );
  }
}
