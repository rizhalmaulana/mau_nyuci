import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/promo_model.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/premium_paywall_widget.dart';
import '../../../core/utils/thousand_separator_input_formatter.dart';
import '../controllers/promo_controller.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_confirm_modal.dart';

class PromoView extends GetView<PromoController> {
  const PromoView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PromoController>()) {
      Get.put(PromoController());
    }

    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: Text('Promo & Voucher', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(18), color: AppColors.black)),
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              controller.setupForm();
              _showPromoFormBottomSheet(context);
            },
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!controller.isPremium.value) {
          return const PremiumPaywallWidget();
        }

        if (controller.promos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_offer_outlined, size: R.r(64), color: AppColors.textSecondary),
                SizedBox(height: R.h(16)),
                Text('Belum ada promo', style: AppFonts.inter(fontSize: R.sp(16), color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchPromos,
          child: ListView.builder(
            padding: EdgeInsets.all(R.w(16)),
            itemCount: controller.promos.length,
            itemBuilder: (context, index) {
              final promo = controller.promos[index];
              return _buildPromoCard(context, promo);
            },
          ),
        );
      }),
    );
  }

  void _showPromoFormBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(R.w(24)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(24))),
        ),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(controller.currentEditId == null ? 'Tambah Promo Baru' : 'Edit Promo', style: AppFonts.inter(fontSize: R.sp(18), fontWeight: FontWeight.bold)),
                SizedBox(height: R.h(24)),
                
                TextFormField(
                  controller: controller.promoCodeController,
                  decoration: InputDecoration(
                    labelText: 'Kode Promo',
                    hintText: 'Misal: LEBARAN10',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
                ),
                SizedBox(height: R.h(16)),

                Text('Tipe Diskon', style: AppFonts.inter(fontSize: R.sp(14), color: AppColors.textSecondary)),
                SizedBox(height: R.h(8)),
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Nominal (Rp)', style: AppFonts.inter(fontSize: R.sp(14))),
                        value: 'Nominal',
                        groupValue: controller.discountType.value,
                        onChanged: (val) => controller.discountType.value = val!,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Persen (%)', style: AppFonts.inter(fontSize: R.sp(14))),
                        value: 'Percentage',
                        groupValue: controller.discountType.value,
                        onChanged: (val) => controller.discountType.value = val!,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                )),
                SizedBox(height: R.h(16)),

                Text('Target Diskon', style: AppFonts.inter(fontSize: R.sp(14), color: AppColors.textSecondary)),
                SizedBox(height: R.h(8)),
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.discountTargetOptions.contains(controller.discountTarget.value)
                      ? controller.discountTarget.value
                      : controller.discountTargetOptions.first,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                    helperText: '* Sasaran berlakunya promo',
                    helperStyle: TextStyle(color: AppColors.primary, fontStyle: AppFonts.fInterCaptionLight.fontStyle)
                  ),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('Semua')),
                    DropdownMenuItem(value: 'Order', child: Text('Transaksi Biasa')),
                    DropdownMenuItem(value: 'DeliveryFee', child: Text('Ongkir')),
                  ],
                  onChanged: (val) {
                    if (val != null) controller.discountTarget.value = val;
                  },
                )),
                SizedBox(height: R.h(16)),

                Row(
                  children: [
                    Expanded(
                      child: Obx(() => TextFormField(
                        controller: controller.discountValueController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [ThousandSeparatorInputFormatter()],
                        decoration: InputDecoration(
                          labelText: 'Nilai Diskon',
                          hintText: controller.discountType.value == 'Percentage'
                              ? 'Misal: 10'
                              : 'Misal: 10.000',
                          prefixText: controller.discountType.value == 'Percentage' ? null : 'Rp ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
                      )),
                    ),
                    SizedBox(width: R.w(16)),
                    Expanded(
                      child: Obx(() {
                        final isPercentage = controller.discountType.value == 'Percentage';
                        return TextFormField(
                          controller: controller.maxDiscountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [ThousandSeparatorInputFormatter()],
                          enabled: isPercentage,
                          decoration: InputDecoration(
                            labelText: 'Maks. Diskon (Rp)',
                            hintText: isPercentage ? 'Misal: 50.000' : 'Hanya untuk tipe Persen',
                            prefixText: isPercentage ? 'Rp ' : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                SizedBox(height: R.h(16)),
                Obx(() => controller.discountType.value == 'Percentage'
                    ? Container(
                        margin: EdgeInsets.only(bottom: R.h(16)),
                        padding: EdgeInsets.all(R.w(12)),
                        decoration: BoxDecoration(
                          color: AppColors.info50,
                          borderRadius: BorderRadius.circular(R.r(8)),
                          border: Border.all(color: AppColors.info100),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: AppColors.info700, size: R.r(20)),
                            SizedBox(width: R.w(8)),
                            Expanded(
                              child: Text(
                                'Maks. Diskon adalah batas potongan dalam Rupiah. Misal: 10% dengan maks Rp 50.000, maka order Rp 1.000.000 tetap dipotong Rp 50.000 (bukan Rp 100.000).',
                                style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.info900, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink()),
                SizedBox(height: R.h(16)),

                TextFormField(
                  controller: controller.minOrderController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandSeparatorInputFormatter()],
                  decoration: InputDecoration(
                    labelText: 'Minimal Transaksi',
                    hintText: 'Misal: 20.000',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                ),
                SizedBox(height: R.h(16)),

                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: controller.expiryDate.value ?? DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) {
                      controller.expiryDate.value = picked;
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(16)),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textSecondary),
                      borderRadius: BorderRadius.circular(R.r(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                          controller.expiryDate.value == null 
                            ? 'Pilih Tanggal Kedaluwarsa' 
                            : 'Kedaluwarsa: ${DateFormat('dd MMM yyyy').format(controller.expiryDate.value!)}',
                          style: AppFonts.inter(fontSize: R.sp(14), color: controller.expiryDate.value == null ? AppColors.textSecondary : AppColors.black),
                        )),
                        const Icon(Icons.calendar_month, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: R.h(16)),

                Obx(() => SwitchListTile(
                  title: Text('Status Aktif', style: AppFonts.inter(fontSize: R.sp(16))),
                  value: controller.isActive.value,
                  onChanged: (val) => controller.isActive.value = val,
                  contentPadding: EdgeInsets.zero,
                )),
                SizedBox(height: R.h(24)),

                Obx(() => ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : () => controller.savePromo(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: R.h(16)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                  child: controller.isSubmitting.value
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : Text('Simpan Promo', style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold, color: AppColors.white)),
                )),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDelete(String id) {
    CustomConfirmModal.show(
      title: 'Hapus Promo',
      message: 'Apakah Anda yakin ingin menghapus promo ini?',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmColor: AppColors.softRed,
      icon: Icons.delete_outline,
      onConfirm: () {
        Get.back();
        controller.deletePromo(id);
      },
    );
  }

  String _targetLabel(String value) {
    switch (value) {
      case 'All':
        return 'Semua';
      case 'Order':
        return 'Transaksi Biasa';
      case 'DeliveryFee':
        return 'Ongkir';
      default:
        return value.isNotEmpty ? value : 'Semua';
    }
  }

  Widget _buildPromoCard(BuildContext context, PromoModel promo) {
    final type = promo.discountType;
    final amount = promo.discountValue;
    final code = promo.promoCode;
    final id = promo.id;

    String displayAmount;
    if (type == 'Percentage') {
      displayAmount = '${amount.toInt()}%';
    } else {
      displayAmount = NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(amount);
    }

    final bool isActive = promo.isActive;
    final DateTime? expiry = promo.expiryDate;
    final bool isExpired = expiry != null && expiry.isBefore(DateTime.now());
    final bool actuallyActive = isActive && !isExpired;

    return Container(
      margin: EdgeInsets.only(bottom: R.h(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        border: actuallyActive ? null : Border.all(color: AppColors.textPrimary),
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: R.w(80),
            padding: EdgeInsets.symmetric(vertical: R.h(24)),
            decoration: BoxDecoration(
              color: actuallyActive ? AppColors.primary : AppColors.textPrimary,
              borderRadius: BorderRadius.horizontal(left: Radius.circular(R.r(16))),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('DISKON', style: AppFonts.inter(color: AppColors.border, fontSize: R.sp(10), fontWeight: FontWeight.bold)),
                Text(displayAmount, style: AppFonts.inter(color: AppColors.white, fontSize: R.sp(16), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(R.w(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(code, style: AppFonts.inter(fontSize: R.sp(18), fontWeight: FontWeight.bold, color: actuallyActive ? AppColors.black : AppColors.textSecondary)),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              controller.setupForm(existingData: promo);
                              _showPromoFormBottomSheet(context);
                            },
                            child: const Icon(Icons.edit, color: AppColors.primary, size: 20),
                          ),
                          SizedBox(width: R.w(12)),
                          InkWell(
                            onTap: () => _confirmDelete(id),
                            child: const Icon(Icons.delete_outline, color: AppColors.softRed, size: 20),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: R.h(8)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
                    decoration: BoxDecoration(
                      color: AppColors.info50,
                      borderRadius: BorderRadius.circular(R.r(8)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.group_outlined, size: R.r(14), color: AppColors.info700),
                        SizedBox(width: R.w(4)),
                        Text(
                          'Untuk: ${_targetLabel(promo.discountTarget)}',
                          style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.info700, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  if (promo.minOrderAmount > 0) ...[
                    SizedBox(height: R.h(8)),
                    Text('Min. Transaksi: ${NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(promo.minOrderAmount)}', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.primary)),
                  ],
                  if (expiry != null) ...[
                    SizedBox(height: R.h(4)),
                    Text('S/d: ${DateFormat('dd MMM yyyy').format(expiry)}', style: AppFonts.inter(fontSize: R.sp(12), color: isExpired ? AppColors.softRed : AppColors.textPrimary)),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
