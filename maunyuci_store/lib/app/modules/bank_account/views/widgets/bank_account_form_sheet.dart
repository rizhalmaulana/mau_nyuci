import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../data/models/store_bank_account_model.dart';
import '../../controllers/bank_account_controller.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class BankAccountFormSheet {
  static Future<void> show(BuildContext context, {StoreBankAccountModel? account}) async {
    final controller = Get.find<BankAccountController>();
    
    // Setup form
    if (account != null) {
      controller.selectedBankName.value = account.bankName;
      controller.bankNameController.text = account.bankName;
      controller.accountNumberController.text = account.accountNumber;
      controller.accountHolderNameController.text = account.accountHolderName;
      controller.qrisImageUrl.value = account.qrisImageUrl ?? '';
    } else {
      controller.resetForm();
    }

    await Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(R.w(24)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(24))),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    account == null ? 'Tambah Rekening Baru' : 'Ubah Rekening',
                    style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(18)),
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    child: Icon(Icons.close, color: AppColors.grey600),
                  ),
                ],
              ),
              SizedBox(height: R.h(24)),
              
              // Nama Bank (Dropdown or Text if not in master)
              Text('Nama Bank / E-Wallet', style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w500, color: AppColors.grey700)),
              SizedBox(height: R.h(8)),
              Obx(() {
                if (controller.masterBankMethods.isNotEmpty) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: R.w(16)),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey300),
                      borderRadius: BorderRadius.circular(R.r(12)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: Text('Pilih Bank', style: AppFonts.inter(color: AppColors.grey500, fontSize: R.sp(14))),
                        value: controller.selectedBankName.value.isEmpty ? null : controller.selectedBankName.value,
                        items: controller.masterBankMethods.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(method, style: AppFonts.inter(fontSize: R.sp(14))),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedBankName.value = val;
                          }
                        },
                      ),
                    ),
                  );
                } else {
                  // Fallback if master methods are empty
                  return _buildTextField(controller.bankNameController, 'Contoh: BCA', TextInputType.text);
                }
              }),
              
              Obx(() {
                if (controller.isCashSelected) {
                  return const SizedBox.shrink();
                }

                if (controller.isQrisSelected) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: R.h(16)),
                      Text('Gambar QRIS', style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w500, color: AppColors.grey700)),
                      SizedBox(height: R.h(8)),
                      InkWell(
                        onTap: controller.pickQrisImage,
                        child: Container(
                          width: double.infinity,
                          height: R.h(200),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey300, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(R.r(12)),
                            color: AppColors.grey50,
                          ),
                          child: controller.qrisImageFile.value != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(R.r(12)),
                                  child: Image.file(controller.qrisImageFile.value!, fit: BoxFit.contain),
                                )
                              : controller.qrisImageUrl.value.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(R.r(12)),
                                      child: Image.network(controller.qrisImageUrl.value, fit: BoxFit.contain),
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.upload_file, size: R.sp(48), color: AppColors.grey400),
                                        SizedBox(height: R.h(8)),
                                        Text('Upload QR Code', style: AppFonts.inter(color: AppColors.grey600, fontSize: R.sp(14))),
                                      ],
                                    ),
                        ),
                      ),
                      SizedBox(height: R.h(16)),
                      Text('Atas Nama', style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w500, color: AppColors.grey700)),
                      SizedBox(height: R.h(8)),
                      _buildTextField(controller.accountHolderNameController, 'Contoh: Toko ABC', TextInputType.name),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: R.h(16)),
                    Text(
                      controller.isEWalletSelected ? 'Nomor HP' : 'Nomor Rekening',
                      style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w500, color: AppColors.grey700),
                    ),
                    SizedBox(height: R.h(8)),
                    _buildTextField(
                      controller.accountNumberController,
                      controller.isEWalletSelected ? 'Contoh: 081234567890' : 'Contoh: 1234567890',
                      TextInputType.number,
                    ),
                    
                    SizedBox(height: R.h(16)),
                    
                    Text('Atas Nama', style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w500, color: AppColors.grey700)),
                    SizedBox(height: R.h(8)),
                    _buildTextField(controller.accountHolderNameController, 'Contoh: Tere Liye', TextInputType.name),
                  ],
                );
              }),
              
              SizedBox(height: R.h(32)),
              
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isSaving.value ? null : () => controller.saveAccount(id: account?.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: R.h(16)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                  child: controller.isSaving.value
                      ? SizedBox(height: R.h(20), width: R.h(20), child: const CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                      : Text('Simpan Rekening', style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.white, fontSize: R.sp(14))),
                )),
              ),
              
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  static Widget _buildTextField(TextEditingController controller, String hint, TextInputType type) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      style: AppFonts.inter(fontSize: R.sp(14)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppFonts.inter(color: AppColors.grey400, fontSize: R.sp(14)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: BorderSide(color: AppColors.grey300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: BorderSide(color: AppColors.grey300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: AppColors.primary)),
        contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
      ),
    );
  }
}
