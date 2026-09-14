import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/pos_controller.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_confirm_modal.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/models/layanan_model.dart';
import '../../bank_account/controllers/bank_account_controller.dart';
import '../../bank_account/views/widgets/bank_account_form_sheet.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

class PosView extends GetView<PosController> {
  const PosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text('Buat Order Manual', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(16))),
        backgroundColor: AppColors.white,
        elevation: 0,
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
                  _buildCustomerForm(),
                  SizedBox(height: R.h(24)),
                  Text('Pilih Katalog Layanan', style: AppFonts.inter(fontSize: R.sp(14), color: AppColors.grey600, fontWeight: FontWeight.bold)),
                  SizedBox(height: R.h(12)),
                  _buildCatalogGrid(),
                  SizedBox(height: R.h(12)),
                  Text('Keranjang Pesanan', style: AppFonts.inter(fontSize: R.sp(14), color: AppColors.grey600, fontWeight: FontWeight.bold)),
                  SizedBox(height: R.h(12)),
                  _buildCartList(),
                  SizedBox(height: R.h(24)),
                  _buildPaymentOptions(context),
                  SizedBox(height: R.h(32)),
                ],
              ),
            ),
          ),
          _buildCheckoutBar(),
        ],
      ),
    );
  }

  Widget _buildCustomerForm() {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Pelanggan', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(12), color: AppColors.grey600)),
          SizedBox(height: R.h(16)),
          Text('Nama Pelanggan (Wajib)', style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w500, color: AppColors.inputText)),
          SizedBox(height: R.h(8)),
          TextFormField(
            controller: controller.customerNameController,
            style: AppFonts.inter(fontSize: R.sp(14)),
            decoration: InputDecoration(
              hintText: 'Contoh: Tere Liye',
              hintStyle: AppFonts.inter(color: AppColors.hint, fontSize: R.sp(14)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: AppColors.primary)),
              contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
            ),
          ),
          SizedBox(height: R.h(16)),
          Text('Nomor WhatsApp (Opsional)', style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w500, color: AppColors.inputText)),
          SizedBox(height: R.h(8)),
          TextFormField(
            controller: controller.customerWaController,
            keyboardType: TextInputType.phone,
            style: AppFonts.inter(fontSize: R.sp(14)),
            decoration: InputDecoration(
              hintText: 'Contoh: 08123456789',
              hintStyle: AppFonts.inter(color: AppColors.hint, fontSize: R.sp(14)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: AppColors.primary)),
              contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogGrid() {
    return Obx(() {
      if (controller.isLoadingCatalog.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.catalogs.isEmpty) {
        return const Center(child: Text('Katalog kosong.'));
      }
      
      Map<String, List<LayananModel>> grouped = {};
      for (var item in controller.catalogs) {
        if (!grouped.containsKey(item.category)) grouped[item.category] = [];
        grouped[item.category]!.add(item);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: grouped.entries.map((entry) {
          return Container(
            margin: EdgeInsets.only(bottom: R.h(16)),
            padding: EdgeInsets.all(R.w(16)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(R.r(16)),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key, style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14), color: AppColors.grey800)),
                SizedBox(height: R.h(12)),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: entry.value.length,
                  separatorBuilder: (context, index) => SizedBox(height: R.h(8)),
                  itemBuilder: (context, index) {
                    final item = entry.value[index];
                    return InkWell(
                      onTap: () => _showAddItemDialog(context, item),
                      borderRadius: BorderRadius.circular(R.r(12)),
                      child: Container(
                        padding: EdgeInsets.all(R.w(12)),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(R.r(12)),
                          border: Border.all(color: AppColors.grey200),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: R.r(24),
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              child: item.imageAsset.isNotEmpty
                                  ? (item.imageAsset.startsWith('http')
                                      ? Image.network(item.imageAsset, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.local_laundry_service, color: AppColors.primary))
                                      : Image.network('${ApiConstants.cloudflareCatalogIconUrl}${item.imageAsset}', fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.local_laundry_service, color: AppColors.primary)))
                                  : const Icon(Icons.local_laundry_service, color: AppColors.primary),
                            ),
                            SizedBox(width: R.w(12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: R.h(4)),
                                  Text(
                                    '${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(item.price)}/${item.unit}',
                                    style: AppFonts.inter(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: R.sp(13)),
                                  ),
                                  SizedBox(height: R.h(6)),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: R.w(6), vertical: R.h(2)),
                                    decoration: BoxDecoration(
                                      color: AppColors.orange50,
                                      borderRadius: BorderRadius.circular(R.r(4)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.access_time, size: R.sp(10), color: AppColors.orange700),
                                        SizedBox(width: R.w(4)),
                                        Text(item.timeEstimate != null ? "Estimasi ${item.timeEstimate}" : '-', style: AppFonts.inter(fontSize: R.sp(10), color: AppColors.orange700)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Obx(() {
                              final count = controller.cartItems.where((c) => c.id == item.id).length;
                              if (count > 0) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => controller.reduceFromCart(item.id, 1),
                                      child: Icon(Icons.remove_circle_outline, color: AppColors.primary, size: R.r(24)),
                                    ),
                                    SizedBox(width: R.w(8)),
                                    InkWell(
                                      onTap: () => _showAddItemDialog(context, item),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(4)),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(R.r(16)),
                                        ),
                                        child: Text(
                                          '$count',
                                          style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: R.sp(12)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: R.w(8)),
                                    InkWell(
                                      onTap: () => _showAddItemDialog(context, item), // Selalu buka dialog untuk item kg/pcs
                                      child: Icon(Icons.add_circle_outline, color: AppColors.primary, size: R.r(24)),
                                    ),
                                  ],
                                );
                              }
                              return InkWell(
                                onTap: () => _showAddItemDialog(context, item),
                                child: Icon(Icons.add_circle_outline, color: AppColors.primary, size: R.r(24)),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildCartList() {
    return Obx(() {
      if (controller.cartItems.isEmpty) {
        return Container(
          padding: EdgeInsets.all(R.w(24)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(R.r(12)),
            border: Border.all(color: AppColors.grey300, style: BorderStyle.solid),
          ),
          alignment: Alignment.center,
          child: Text('Belum ada layanan yang dipilih', style: AppFonts.inter(color: AppColors.grey500)),
        );
      }
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero, // Menghilangkan default padding dari ListView
        itemCount: controller.cartItems.length,
        separatorBuilder: (_, __) => SizedBox(height: R.h(8)),
        itemBuilder: (context, index) {
          final cartItem = controller.cartItems[index];
          return Container(
            padding: EdgeInsets.all(R.w(12)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(R.r(12)),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cartItem.name, style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(13))),
                      Text('${cartItem.quantity} ${cartItem.unit} x ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(cartItem.price)}',
                          style: AppFonts.inter(color: AppColors.grey600, fontSize: R.sp(11))),
                    ],
                  ),
                ),
                Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(cartItem.subtotal),
                    style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildPaymentOptions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pembayaran & Pengiriman', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(12), color: AppColors.grey600)),

          Obx(() => SwitchListTile(
            title: Text('Bayar Sekarang?', style: AppFonts.inter(fontSize: R.sp(14))),
            subtitle: Text(controller.paymentStatus.value == 'Lunas' ? '*Lunas (Bayar di Muka)' : '*Bayar Nanti (Saat Diambil)', style: AppFonts.inter(color: AppColors.primary, fontSize: R.sp(10), fontStyle: FontStyle.italic)),
            value: controller.paymentStatus.value == 'Lunas',
            onChanged: (val) => controller.paymentStatus.value = val ? 'Lunas' : 'Belum Lunas',
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          )),

          Obx(() {
            if (controller.paymentStatus.value == 'Lunas') {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  SizedBox(height: R.h(8)),
                  Text('Metode Pembayaran', style: AppFonts.inter(fontSize: R.sp(12))),
                  SizedBox(height: R.h(8)),
                  
                  if (controller.isLoadingBankAccounts.value)
                     const Center(child: CircularProgressIndicator())
                  else if (controller.bankAccounts.isEmpty)
                     Container(
                       padding: EdgeInsets.all(R.w(16)),
                       margin: EdgeInsets.only(top: R.h(8)),
                       decoration: BoxDecoration(
                         color: AppColors.orange50,
                         borderRadius: BorderRadius.circular(R.r(8)),
                         border: Border.all(color: AppColors.orange200),
                       ),
                       child: Column(
                         children: [
                           Text('Belum ada metode pembayaran yang ditambahkan.', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.orange800), textAlign: TextAlign.center),
                           SizedBox(height: R.h(12)),
                           ElevatedButton.icon(
                             onPressed: () async {
                               if (!Get.isRegistered<BankAccountController>()) {
                                 Get.put(BankAccountController());
                               }
                               await BankAccountFormSheet.show(context);
                               controller.fetchBankAccounts();
                             },
                             icon: Icon(Icons.add_card, size: R.sp(16)),
                             label: Text('Tambah Metode', style: AppFonts.inter(fontSize: R.sp(12))),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: AppColors.orange600,
                               foregroundColor: AppColors.white,
                               elevation: 0,
                               minimumSize: const Size(double.infinity, 36),
                             ),
                           )
                         ]
                       )
                     )
                  else
                    Column(
                      children: controller.bankAccounts.map((method) {
                        return RadioListTile<String>(
                          title: Row(
                            children: [
                              _buildBankIconForPos(method.bankName, controller.paymentMethodId.value == method.id),
                              SizedBox(width: R.w(8)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(method.bankName, style: AppFonts.inter(fontSize: R.sp(13), color: controller.paymentMethodId.value == method.id ? AppColors.primary : AppColors.black87), overflow: TextOverflow.ellipsis),
                                    if (method.accountNumber != '-')
                                      Text('${method.accountNumber} - ${method.accountHolderName}', style: AppFonts.inter(fontSize: R.sp(10), color: AppColors.grey600), overflow: TextOverflow.ellipsis),
                                    if (method.bankName.toLowerCase().contains('qris') && method.qrisImageUrl != null && method.qrisImageUrl!.isNotEmpty && controller.paymentMethodId.value == method.id)
                                      Padding(
                                        padding: EdgeInsets.only(top: R.h(8), bottom: R.h(8)),
                                        child: InkWell(
                                          onTap: () => _showQrisImageDetail(context, method.qrisImageUrl!),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(R.r(8)),
                                                child: Image.network(method.qrisImageUrl!, height: R.h(120), fit: BoxFit.cover),
                                              ),
                                              SizedBox(height: R.h(6)),
                                              Row(
                                                children: [
                                                  Icon(Icons.zoom_in, size: R.sp(12), color: AppColors.info700),
                                                  SizedBox(width: R.w(4)),
                                                  Text('Klik untuk memperbesar', style: AppFonts.inter(fontSize: R.sp(10), color: AppColors.info700, fontStyle: FontStyle.italic)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          value: method.id,
                          groupValue: controller.paymentMethodId.value,
                          onChanged: (val) => controller.paymentMethodId.value = val!,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                          controlAffinity: ListTileControlAffinity.trailing,
                        );
                      }).toList(),
                    ),
                ],
              );
            }
            return const SizedBox();
          }),

          Obx(() {
            if (!controller.isDeliveryFeatureEnabled.value) return const SizedBox();
            return Column(
              children: [
                const Divider(),
                SwitchListTile(
                  title: Text('Perlu Diantar (Delivery)?', style: AppFonts.inter(fontSize: R.sp(13))),
                  value: controller.isDeliverySelected.value,
                  onChanged: (val) => controller.isDeliverySelected.value = val,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total Pembayaran', style: AppFonts.inter(color: AppColors.grey600, fontSize: R.sp(12))),
                  Obx(() => Text(
                    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(controller.grandTotal),
                    style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(18), color: AppColors.primary),
                  )),
                ],
              ),
            ),
            Obx(() => ElevatedButton(
              onPressed: controller.isSubmitting.value ? null : () {
                CustomConfirmModal.show(
                  title: 'Konfirmasi Pesanan',
                  message: 'Apakah Anda yakin ingin membuat pesanan manual ini? Pastikan data sudah benar.',
                  icon: Icons.check_circle_outline,
                  onConfirm: () {
                    Get.back(); // Tutup modal
                    controller.submitOrder();
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: R.w(32), vertical: R.h(16)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
              ),
              child: controller.isSubmitting.value 
                  ? SizedBox(width: R.w(20), height: R.w(20), child: const CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                  : Text('Buat Pesanan', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14), color: AppColors.white)),
            )),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, LayananModel item) {
    final qtyController = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(R.w(24)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(24))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tambah ${item.name}', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(16))),
            SizedBox(height: R.h(8)),
            Text('Harga: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(item.price)}/${item.unit}', style: AppFonts.inter(color: AppColors.grey600)),
            SizedBox(height: R.h(24)),
            TextField(
              controller: qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  return newValue.copyWith(text: newValue.text.replaceAll(',', '.'));
                }),
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: item.unit == 'Kg' ? 'Masukkan Berat (Kg)' : 'Masukkan Jumlah (Pcs)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(8))),
                suffixText: item.unit,
              ),
              autofocus: true,
            ),
            SizedBox(height: R.h(24)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final val = double.tryParse(qtyController.text) ?? 0;
                  if (val > 0) {
                    controller.addToCart(item, val);
                    Get.back();
                  } else {
                    Get.snackbar('Error', 'Jumlah tidak valid');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: R.h(16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                ),
                child: Text('Tambah ke Keranjang', style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.white)),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + R.h(16)), // Adjust for keyboard and nav bar
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildBankIconForPos(String bankName, bool isSelected) {
    final l = bankName.toLowerCase();
    IconData icon = Icons.account_balance;
    Color color = isSelected ? AppColors.primary : AppColors.grey500;
    
    if (l.contains('cash') || l.contains('tunai')) {
      icon = Icons.payments_outlined;
    } else if (l.contains('qris')) {
      icon = Icons.qr_code_2;
    } else if (l.contains('gopay') || l.contains('ovo') || l.contains('dana') || l.contains('shopee') || l.contains('linkaja') || l.contains('e-wallet')) {
      icon = Icons.account_balance_wallet;
    }

    return Icon(icon, size: R.sp(16), color: color);
  }

  void _showQrisImageDetail(BuildContext context, String imageUrl) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(R.w(16)),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              margin: EdgeInsets.all(R.w(12)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(R.r(16)),
                child: Container(
                  color: AppColors.white,
                  padding: EdgeInsets.all(R.w(16)),
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
