import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_store_controller.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

class RegisterStoreView extends GetView<RegisterStoreController> {
  const RegisterStoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Daftar Toko Baru',
          style: AppFonts.fInterBodySemibold.copyWith(
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.deepPurple,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(R.w(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: R.h(8)),
              Text(
                'Lengkapi Data Toko Anda',
                style: AppFonts.fInterHeading6Semibold.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: R.sp(22),
                ),
              ),
              SizedBox(height: R.h(8)),
              Text(
                'Silakan isi informasi toko Anda dengan lengkap agar dapat mulai melayani pesanan dari pelanggan.',
                style: AppFonts.fInterBodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: R.sp(14),
                  height: 1.5,
                ),
              ),
              SizedBox(height: R.h(24)),
              
              Container(
                padding: EdgeInsets.all(R.w(20)),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(R.r(24)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('Foto Toko'),
                    Obx(() => GestureDetector(
                      onTap: controller.pickImage,
                      child: Container(
                        height: R.h(180),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(R.r(16)),
                          border: Border.all(
                            color: controller.imageError.value.isNotEmpty ? AppColors.danger : AppColors.border,
                            width: 1,
                          ),
                        ),
                        child: controller.selectedImage.value != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(R.r(15)),
                                child: Image.file(
                                  controller.selectedImage.value!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, size: R.r(48), color: AppColors.deepPurple300),
                                  SizedBox(height: R.h(12)),
                                  Text(
                                    'Pilih Foto Toko',
                                    style: AppFonts.fInterBodyMedium.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                      ),
                    )),
                    Obx(() {
                      if (controller.imageError.value.isNotEmpty) {
                        return Padding(
                          padding: EdgeInsets.only(top: R.h(8), left: R.w(16)),
                          child: Text(
                            controller.imageError.value,
                            style: AppFonts.fInterBodySmallRegular.copyWith(color: AppColors.danger),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    
                    SizedBox(height: R.h(20)),
                    _buildInputLabel('Nama Toko'),
                    Obx(() => _buildTextField(
                      controller: controller.nameController,
                      hintText: 'Misal: Laundry Bersih Wangi',
                      icon: Icons.storefront_outlined,
                      errorText: controller.nameError.value.isNotEmpty ? controller.nameError.value : null,
                    )),
                    
                    SizedBox(height: R.h(20)),
                    _buildInputLabel('Alamat Toko'),
                    Obx(() => GestureDetector(
                      onTap: controller.pickLocation,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(R.r(12)),
                          border: Border.all(
                            color: controller.addressError.value.isNotEmpty ? AppColors.danger : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: R.r(24)),
                            SizedBox(width: R.w(12)),
                            Expanded(
                              child: Text(
                                controller.selectedAddress.value.isEmpty
                                    ? 'Pilih lokasi dari Peta'
                                    : controller.selectedAddress.value,
                                style: AppFonts.fInterBodyMedium.copyWith(
                                  fontSize: R.sp(14),
                                  color: controller.selectedAddress.value.isEmpty
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.map_outlined, color: AppColors.deepPurple, size: R.r(24)),
                          ],
                        ),
                      ),
                    )),
                    Obx(() {
                      if (controller.addressError.value.isNotEmpty) {
                        return Padding(
                          padding: EdgeInsets.only(top: R.h(8), left: R.w(16)),
                          child: Text(
                            controller.addressError.value,
                            style: AppFonts.fInterBodySmallRegular.copyWith(color: AppColors.danger),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    
                    SizedBox(height: R.h(20)),
                    _buildInputLabel('Nomor HP Toko'),
                    Obx(() => _buildTextField(
                      controller: controller.phoneController,
                      hintText: 'Misal: 081234567890',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      errorText: controller.phoneError.value.isNotEmpty ? controller.phoneError.value : null,
                    )),
                    
                    SizedBox(height: R.h(20)),
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
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(R.r(12)),
                                    border: Border.all(
                                      color: controller.openTimeError.value.isNotEmpty ? AppColors.danger : AppColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time, color: AppColors.textSecondary, size: R.r(20)),
                                      SizedBox(width: R.w(8)),
                                      Text(
                                        controller.openTime.value.isEmpty ? '08:00' : controller.openTime.value,
                                        style: AppFonts.fInterBodyMedium.copyWith(
                                          fontSize: R.sp(14),
                                          color: controller.openTime.value.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                              Obx(() {
                                if (controller.openTimeError.value.isNotEmpty) {
                                  return Padding(
                                    padding: EdgeInsets.only(top: R.h(8), left: R.w(4)),
                                    child: Text(
                                      controller.openTimeError.value,
                                      style: AppFonts.fInterBodySmallRegular.copyWith(color: AppColors.danger),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
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
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(R.r(12)),
                                    border: Border.all(
                                      color: controller.closeTimeError.value.isNotEmpty ? AppColors.danger : AppColors.border,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time_filled, color: AppColors.textSecondary, size: R.r(20)),
                                      SizedBox(width: R.w(8)),
                                      Text(
                                        controller.closeTime.value.isEmpty ? '20:00' : controller.closeTime.value,
                                        style: AppFonts.fInterBodyMedium.copyWith(
                                          fontSize: R.sp(14),
                                          color: controller.closeTime.value.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                              Obx(() {
                                if (controller.closeTimeError.value.isNotEmpty) {
                                  return Padding(
                                    padding: EdgeInsets.only(top: R.h(8), left: R.w(4)),
                                    child: Text(
                                      controller.closeTimeError.value,
                                      style: AppFonts.fInterBodySmallRegular.copyWith(color: AppColors.danger),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: R.h(24)),
                    const Divider(),
                    SizedBox(height: R.h(16)),
                    
                    Obx(() => Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Layanan Antar Jemput',
                                style: AppFonts.fInterBodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: R.sp(16),
                                ),
                              ),
                              SizedBox(height: R.h(4)),
                              Text(
                                'Toko Anda melayani antar jemput cucian?',
                                style: AppFonts.fInterBodySmallRegular.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: R.sp(12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: controller.hasPickupDeliveryService.value,
                          onChanged: controller.togglePickupDelivery,
                          activeColor: AppColors.deepPurple,
                        ),
                      ],
                    )),
                    
                    Obx(() => controller.hasPickupDeliveryService.value ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: R.h(20)),
                        _buildInputLabel('Biaya Antar Jemput (Rp)'),
                        _buildTextField(
                          controller: controller.pickupFeeController,
                          hintText: 'Misal: 10000',
                          icon: Icons.payments_outlined,
                          keyboardType: TextInputType.number,
                          errorText: controller.pickupFeeError.value.isNotEmpty ? controller.pickupFeeError.value : null,
                        ),
                        SizedBox(height: R.h(20)),
                        _buildInputLabel('Minimal Order Jemput (kg)'),
                        _buildTextField(
                          controller: controller.minOrderController,
                          hintText: 'Minimal 5 kg',
                          icon: Icons.scale_outlined,
                          keyboardType: TextInputType.number,
                          errorText: controller.minOrderError.value.isNotEmpty ? controller.minOrderError.value : null,
                        ),
                      ],
                    ) : const SizedBox.shrink()),
                  ],
                ),
              ),
              SizedBox(height: R.h(100)), // Space for bottom button
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(R.w(20)),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.registerStore,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepPurple,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.deepPurple.withValues(alpha: 0.5),
                padding: EdgeInsets.symmetric(vertical: R.h(16)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(R.r(12)),
                ),
                elevation: 0,
              ),
              child: controller.isLoading.value
                  ? SizedBox(
                      height: R.r(24),
                      width: R.r(24),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                  : Text(
                      'Daftarkan Toko Sekarang',
                      style: AppFonts.fInterBodyMedium.copyWith(
                        color: AppColors.white,
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(8)),
      child: Text(
        label,
        style: AppFonts.fInterBodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: R.sp(14),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppFonts.fInterBodyMedium.copyWith(
        color: AppColors.textPrimary,
        fontSize: R.sp(14),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppFonts.fInterBodyMedium.copyWith(
          color: AppColors.textSecondary,
          fontSize: R.sp(14),
        ),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: R.r(22)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.background,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.r(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.r(12)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.r(12)),
          borderSide: const BorderSide(color: AppColors.deepPurple, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.r(12)),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(R.r(12)),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
      ),
    );
  }
}
