import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../controllers/register_store_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

class RegisterStoreView extends GetView<RegisterStoreController> {
  const RegisterStoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Daftar Toko',
          style: AppFonts.fInterSubheadingSemibold.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lengkapi Data Toko Anda',
                style: AppFonts.fInterHeading6Semibold.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Silakan isi informasi toko Anda dengan lengkap agar dapat mulai melayani pesanan dari pelanggan.',
                style: AppFonts.fInterBodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildInputLabel('Nama Toko'),
              Obx(() => _buildTextField(
                controller: controller.nameController,
                hintText: 'Misal: Laundry Bersih Wangi',
                icon: Icons.storefront_outlined,
                errorText: controller.nameError.value.isNotEmpty ? controller.nameError.value : null,
              )),
              const SizedBox(height: 16),
              
              _buildInputLabel('Alamat Toko'),
              Obx(() => GestureDetector(
                onTap: controller.pickLocation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: controller.addressError.value.isNotEmpty ? Colors.red : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          controller.addressController.text.isEmpty
                              ? 'Pilih lokasi dari Peta'
                              : controller.addressController.text,
                          style: AppFonts.fInterBodyMedium.copyWith(
                            color: controller.addressController.text.isEmpty
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.map_outlined, color: AppColors.primary),
                    ],
                  ),
                ),
              )),
              Obx(() {
                if (controller.addressError.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8, left: 16),
                    child: Text(
                      controller.addressError.value,
                      style: AppFonts.fInterBodySmallRegular.copyWith(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              const SizedBox(height: 16),

              _buildInputLabel('Nomor HP Toko'),
              Obx(() => _buildTextField(
                controller: controller.phoneController,
                hintText: 'Misal: 081234567890',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                errorText: controller.phoneError.value.isNotEmpty ? controller.phoneError.value : null,
              )),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('Waktu Buka'),
                        Obx(() => GestureDetector(
                          onTap: () => controller.selectTime(context, controller.openTimeController),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: controller.openTimeError.value.isNotEmpty ? Colors.red : AppColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, color: AppColors.textSecondary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  controller.openTimeController.text.isEmpty ? '08:00' : controller.openTimeController.text,
                                  style: AppFonts.fInterBodyMedium.copyWith(
                                    color: controller.openTimeController.text.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                        Obx(() {
                          if (controller.openTimeError.value.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8, left: 4),
                              child: Text(
                                controller.openTimeError.value,
                                style: AppFonts.fInterBodySmallRegular.copyWith(color: Colors.red),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('Waktu Tutup'),
                        Obx(() => GestureDetector(
                          onTap: () => controller.selectTime(context, controller.closeTimeController),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: controller.closeTimeError.value.isNotEmpty ? Colors.red : AppColors.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_filled, color: AppColors.textSecondary, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  controller.closeTimeController.text.isEmpty ? '20:00' : controller.closeTimeController.text,
                                  style: AppFonts.fInterBodyMedium.copyWith(
                                    color: controller.closeTimeController.text.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                        Obx(() {
                          if (controller.closeTimeError.value.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8, left: 4),
                              child: Text(
                                controller.closeTimeError.value,
                                style: AppFonts.fInterBodySmallRegular.copyWith(color: Colors.red),
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
              const SizedBox(height: 24),
              
              const Divider(),
              const SizedBox(height: 16),
              
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
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toko Anda melayani antar jemput cucian?',
                          style: AppFonts.fInterBodySmallRegular.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: controller.hasPickupDeliveryService.value,
                    onChanged: controller.togglePickupDelivery,
                    activeColor: AppColors.primary,
                  ),
                ],
              )),
              
              Obx(() => controller.hasPickupDeliveryService.value ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildInputLabel('Biaya Antar Jemput (Rp)'),
                  _buildTextField(
                    controller: controller.pickupFeeController,
                    hintText: 'Misal: 10000',
                    icon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                    errorText: controller.pickupFeeError.value.isNotEmpty ? controller.pickupFeeError.value : null,
                  ),
                  const SizedBox(height: 16),
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
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.registerStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Daftarkan Toko',
                          style: AppFonts.fInterBodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: AppFonts.fInterBodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
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
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppFonts.fInterBodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.white,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
