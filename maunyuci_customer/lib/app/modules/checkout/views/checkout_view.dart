import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/checkout_controller.dart';
import '../../../data/models/promo_model.dart';
import '../../../data/models/store_bank_account_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/responsive_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../store_detail/controllers/store_detail_controller.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Checkout', style: AppFonts.fInterSubheadingSemibold.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(R.r(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Voucher & Diskon', style: AppFonts.fInterBodySemibold),
                    SizedBox(height: R.h(8)),
                    _buildPromoSelection(),
                    SizedBox(height: R.h(24)),
                    if (controller.selectedDeliveryType == DeliveryType.courier) ...[
                      Text('Foto Cucian (Wajib)', style: AppFonts.fInterBodySemibold),
                      SizedBox(height: R.h(8)),
                      _buildLaundryPhoto(),
                      SizedBox(height: R.h(24)),
                    ],
                    Text('Metode Pembayaran', style: AppFonts.fInterBodySemibold),
                    SizedBox(height: R.h(8)),
                    _buildPaymentSelection(),
                  ],
                ),
              ),
            ),
            _buildBottomSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoSelection() {
    return Container(
      padding: EdgeInsets.all(R.r(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(12)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
        child: DropdownButton<PromoModel>(
          isExpanded: true,
          value: controller.selectedPromo.value,
          hint: Text('Pilih Promo', style: AppFonts.fInterBodyMedium),
          items: [
            DropdownMenuItem<PromoModel>(
              value: null,
              child: Text('Tanpa Promo', style: AppFonts.fInterBodyMedium),
            ),
            ...controller.promos.map((promo) {
              return DropdownMenuItem<PromoModel>(
                value: promo,
                child: Text(
                  '${promo.promoCode} (${promo.discountType == 'Persentase' ? '${promo.discountValue}%' : 'Rp${NumberFormat('#,###', 'id').format(promo.discountValue)}'})',
                  style: AppFonts.fInterBodyMedium,
                ),
              );
            }).toList()
          ],
          onChanged: (PromoModel? val) {
            controller.selectedPromo.value = val;
          },
        ),
      )),
    );
  }

  Widget _buildPaymentSelection() {
    return Container(
      padding: EdgeInsets.all(R.r(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.r(12)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text('Tunai / Bayar Nanti', style: AppFonts.fInterBodyMedium),
                  value: 'Tunai / Bayar Nanti',
                  groupValue: controller.selectedPaymentMethod.value,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) controller.selectedPaymentMethod.value = val;
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: Text('Transfer / E-Wallet', style: AppFonts.fInterBodyMedium),
                  value: 'Transfer',
                  groupValue: controller.selectedPaymentMethod.value,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) controller.selectedPaymentMethod.value = val;
                  },
                ),
              ),
            ],
          ),
          if (controller.selectedPaymentMethod.value == 'Transfer') ...[
            SizedBox(height: R.h(12)),
            if (controller.bankAccounts.isEmpty)
              Text(
                'Toko tidak menyediakan metode transfer.',
                style: AppFonts.fInterCaptionRegular.copyWith(color: AppColors.danger400),
              )
            else
              DropdownButtonHideUnderline(
                child: DropdownButton<StoreBankAccountModel>(
                  isExpanded: true,
                  value: controller.selectedBankAccount.value,
                  hint: Text('Pilih Rekening Tujuan', style: AppFonts.fInterBodyMedium),
                  items: controller.bankAccounts.map((bank) {
                    return DropdownMenuItem<StoreBankAccountModel>(
                      value: bank,
                      child: Text(
                        '${bank.bankName} - ${bank.accountNumber} (${bank.accountHolderName})',
                        style: AppFonts.fInterBodyMedium,
                      ),
                    );
                  }).toList(),
                  onChanged: (StoreBankAccountModel? val) {
                    controller.selectedBankAccount.value = val;
                  },
                ),
              ),
          ]
        ],
      )),
    );
  }

  Widget _buildLaundryPhoto() {
    return Obx(() {
      final file = controller.laundryImageFile.value;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(R.r(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.r(12)),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            if (file != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(R.r(8)),
                child: Image.file(
                  file,
                  height: R.h(150),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: R.h(12)),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => controller.pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt, color: AppColors.primary),
                  label: Text('Kamera', style: AppFonts.fInterBodyMedium.copyWith(color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(8))),
                  ),
                ),
                SizedBox(width: R.w(12)),
                OutlinedButton.icon(
                  onPressed: () => controller.pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library, color: AppColors.primary),
                  label: Text('Galeri', style: AppFonts.fInterBodyMedium.copyWith(color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(8))),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    });
  }

  Widget _buildBottomSummary() {
    return Container(
      padding: EdgeInsets.all(R.r(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          final subtotal = controller.subtotal;
          final discount = controller.discountAmount;
          final delivery = controller.deliveryFee;
          final grandTotal = controller.grandTotal;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtotal', style: AppFonts.fInterCaptionRegular),
                  Text('Rp${NumberFormat('#,###', 'id').format(subtotal)}', style: AppFonts.fInterCaptionMedium),
                ],
              ),
              if (discount > 0)
                Padding(
                  padding: EdgeInsets.only(top: R.h(4)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Diskon', style: AppFonts.fInterCaptionRegular.copyWith(color: AppColors.success600)),
                      Text('- Rp${NumberFormat('#,###', 'id').format(discount)}', style: AppFonts.fInterCaptionMedium.copyWith(color: AppColors.success600)),
                    ],
                  ),
                ),
              if (delivery > 0)
                Padding(
                  padding: EdgeInsets.only(top: R.h(4)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ongkir', style: AppFonts.fInterCaptionRegular),
                      Text('Rp${NumberFormat('#,###', 'id').format(delivery)}', style: AppFonts.fInterCaptionMedium),
                    ],
                  ),
                ),
              Divider(height: R.h(16), thickness: 1, color: Colors.grey.shade200),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Pembayaran', style: AppFonts.fInterCaptionRegular.copyWith(color: AppColors.textSecondary)),
                      Text(
                        'Rp${NumberFormat('#,###', 'id').format(grandTotal)}',
                        style: AppFonts.fInterBodySemibold.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: R.h(44),
                    child: ElevatedButton(
                      onPressed: controller.isSubmitting.value ? null : () => controller.submitOrder(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(horizontal: R.w(24)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(R.r(8)),
                        ),
                      ),
                      child: controller.isSubmitting.value
                          ? SizedBox(
                              width: R.r(20),
                              height: R.r(20),
                              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'Buat Pesanan',
                              style: AppFonts.fInterBodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}
