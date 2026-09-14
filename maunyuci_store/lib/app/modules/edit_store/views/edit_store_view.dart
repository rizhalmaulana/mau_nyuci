import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_store_controller.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

class EditStoreView extends GetView<EditStoreController> {
  const EditStoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text('Ubah Profil Toko', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(16))),
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
                        Text('Lengkapi Data Toko Anda', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14), color: AppColors.grey800)),
                        SizedBox(height: R.h(8)),
                        Text('Silakan ubah informasi toko Anda di bawah ini.', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey500)),
                        SizedBox(height: R.h(24)),
                        
                        _buildInputLabel('Foto Toko'),
                        Obx(() => GestureDetector(
                          onTap: controller.pickImage,
                          child: Container(
                            height: R.h(180),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.grey50,
                              borderRadius: BorderRadius.circular(R.r(12)),
                              border: Border.all(color: AppColors.grey300),
                            ),
                            child: controller.selectedImage.value != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(R.r(11)),
                                    child: Image.file(
                                      controller.selectedImage.value!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  )
                                : (controller.existingImageUrl.value.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(R.r(11)),
                                        child: Image.network(
                                          controller.existingImageUrl.value,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo_outlined, size: R.r(40), color: AppColors.grey400),
                                          SizedBox(height: R.h(8)),
                                          Text('Ubah Foto Toko', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey500)),
                                        ],
                                      )),
                          ),
                        )),
                        SizedBox(height: R.h(16)),
                        
                        _buildInputLabel('Nama Toko'),
                        _buildTextField(
                          controller: controller.nameController,
                          hintText: 'Misal: Laundry Bersih Wangi',
                          icon: Icons.storefront_outlined,
                        ),
                        SizedBox(height: R.h(16)),
                        
                        _buildInputLabel('Alamat Toko'),
                        Obx(() => GestureDetector(
                          onTap: controller.pickLocation,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(12)),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(R.r(12)),
                              border: Border.all(color: AppColors.grey300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.location_on_outlined, color: AppColors.grey400, size: R.r(20)),
                                SizedBox(width: R.w(12)),
                                Expanded(
                                  child: Text(
                                    controller.selectedAddress.value.isEmpty
                                        ? 'Pilih lokasi dari Peta'
                                        : controller.selectedAddress.value,
                                    style: AppFonts.inter(
                                      fontSize: R.sp(14),
                                      color: controller.selectedAddress.value.isEmpty ? AppColors.grey500 : AppColors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.map_outlined, color: AppColors.primary, size: R.r(20)),
                              ],
                            ),
                          ),
                        )),
                        SizedBox(height: R.h(16)),

                        _buildInputLabel('Nomor HP Toko'),
                        _buildTextField(
                          controller: controller.phoneController,
                          hintText: 'Misal: 081234567890',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: R.h(16)),
                        
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInputLabel('Waktu Buka'),
                                  Obx(() => GestureDetector(
                                    onTap: () => controller.selectTime(context, true),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(R.r(12)),
                                        border: Border.all(color: AppColors.grey300),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.access_time, color: AppColors.grey400, size: R.r(20)),
                                          SizedBox(width: R.w(8)),
                                          Text(
                                            controller.openTime.value.isEmpty ? '08:00' : controller.openTime.value,
                                            style: AppFonts.inter(
                                              fontSize: R.sp(14),
                                              color: controller.openTime.value.isEmpty ? AppColors.grey500 : AppColors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                                ],
                              ),
                            ),
                            SizedBox(width: R.w(16)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInputLabel('Waktu Tutup'),
                                  Obx(() => GestureDetector(
                                    onTap: () => controller.selectTime(context, false),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(R.r(12)),
                                        border: Border.all(color: AppColors.grey300),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.access_time_filled, color: AppColors.grey400, size: R.r(20)),
                                          SizedBox(width: R.w(8)),
                                          Text(
                                            controller.closeTime.value.isEmpty ? '20:00' : controller.closeTime.value,
                                            style: AppFonts.inter(
                                              fontSize: R.sp(14),
                                              color: controller.closeTime.value.isEmpty ? AppColors.grey500 : AppColors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ],
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppFonts.inter(fontSize: R.sp(14)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppFonts.inter(color: AppColors.hint, fontSize: R.sp(13)),
        prefixIcon: Icon(icon, color: AppColors.hint, size: R.r(20)),
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
            onPressed: controller.isLoading.value ? null : controller.updateStore,
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
