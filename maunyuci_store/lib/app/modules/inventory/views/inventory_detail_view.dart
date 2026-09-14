import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/utils/thousand_separator_input_formatter.dart';
import '../controllers/inventory_detail_controller.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

class InventoryDetailView extends GetView<InventoryDetailController> {
  const InventoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<InventoryDetailController>()) {
      Get.put(InventoryDetailController());
    }

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text('Detail Barang', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(18), color: AppColors.black87)),
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.info),
            tooltip: 'Ubah Barang',
            onPressed: () {
              controller.setupEditForm();
              _showEditBottomSheet(context);
            },
          ),
        ],
      ),
      body: Obx(() {
        final item = controller.item;
        final double stock = (item['currentStock'] ?? item['stockQuantity'] ?? item['stock'] ?? 0).toDouble();
        final String unit = (item['unit'] ?? 'Pcs').toString();
        final String name = (item['itemName'] ?? item['name'] ?? 'Barang').toString();
        final double minStock = (item['minStockLevel'] ?? item['minimumStockAlert'] ?? 0).toDouble();
        final bool isLowStock = minStock > 0 && stock <= minStock;
        final String? updatedAtRaw = item['updatedAt']?.toString();
        final DateTime? updatedAt = updatedAtRaw != null ? DateTime.tryParse(updatedAtRaw)?.toLocal() : null;

        return SingleChildScrollView(
          padding: EdgeInsets.all(R.w(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  backgroundColor: isLowStock ? AppColors.danger50 : AppColors.info50,
                  radius: R.r(48),
                  child: Icon(Icons.inventory_2, color: isLowStock ? AppColors.danger : AppColors.info, size: R.r(48)),
                ),
              ),
              SizedBox(height: R.h(24)),
              Text('Nama Barang', style: AppFonts.inter(fontSize: R.sp(14), color: AppColors.grey500)),
              SizedBox(height: R.h(4)),
              Text(name, style: AppFonts.inter(fontSize: R.sp(20), fontWeight: FontWeight.bold)),
              SizedBox(height: R.h(16)),

              Container(
                padding: EdgeInsets.all(R.w(16)),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(R.r(12)),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Satuan', unit),
                    Divider(height: R.h(24), color: AppColors.grey200),
                    _buildInfoRow(
                      'Batas Stok Minimum',
                      minStock > 0 ? '${_formatStock(minStock)} $unit' : '-',
                    ),
                    Divider(height: R.h(24), color: AppColors.grey200),
                    _buildInfoRow(
                      'Status',
                      isLowStock ? 'Stok Menipis' : 'Aman',
                      valueColor: isLowStock ? AppColors.danger : AppColors.success700,
                    ),
                    if (updatedAt != null) ...[
                      Divider(height: R.h(24), color: AppColors.grey200),
                      _buildInfoRow(
                        'Terakhir Diperbarui',
                        '${updatedAt.day.toString().padLeft(2, '0')}-'
                        '${updatedAt.month.toString().padLeft(2, '0')}-'
                        '${updatedAt.year} '
                        '${updatedAt.hour.toString().padLeft(2, '0')}:'
                        '${updatedAt.minute.toString().padLeft(2, '0')}',
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: R.h(24)),

              Container(
                padding: EdgeInsets.all(R.w(16)),
                decoration: BoxDecoration(
                  color: AppColors.deepPurple50,
                  borderRadius: BorderRadius.circular(R.r(12)),
                  border: Border.all(color: AppColors.deepPurple100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sisa Stok Saat Ini:', style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.w600)),
                    Text(
                      '$stock $unit',
                      style: AppFonts.inter(fontSize: R.sp(20), fontWeight: FontWeight.bold, color: AppColors.deepPurple),
                    ),
                  ],
                ),
              ),
              SizedBox(height: R.h(32)),

              SizedBox(
                width: double.infinity,
                height: R.h(50),
                child: ElevatedButton.icon(
                  onPressed: () => _showTransactionBottomSheet(context, unit),
                  icon: const Icon(Icons.sync_alt, color: AppColors.white),
                  label: Text('Transaksi Stok Manual', style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold, color: AppColors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.info,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _formatStock(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppFonts.inter(fontSize: R.sp(14), color: AppColors.grey500)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppFonts.inter(
              fontSize: R.sp(14),
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _showEditBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(R.w(24)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(24))),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: controller.editFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ubah Barang', style: AppFonts.inter(fontSize: R.sp(18), fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                  ],
                ),
                SizedBox(height: R.h(16)),
                TextFormField(
                  controller: controller.editNameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Barang',
                    hintText: 'Misal: Deterjen cair',
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Nama barang tidak boleh kosong' : null,
                ),
                SizedBox(height: R.h(16)),
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.unitOptions.contains(controller.editUnit.value)
                      ? controller.editUnit.value
                      : controller.unitOptions.first,
                  decoration: InputDecoration(
                    labelText: 'Satuan',
                    prefixIcon: const Icon(Icons.straighten_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                  items: controller.unitOptions.map((String unit) {
                    return DropdownMenuItem(value: unit, child: Text(unit));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) controller.editUnit.value = val;
                  },
                )),
                SizedBox(height: R.h(16)),
                TextFormField(
                  controller: controller.editMinStockController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandSeparatorInputFormatter()],
                  decoration: InputDecoration(
                    labelText: 'Batas Stok Minimum',
                    hintText: 'Misal: 10',
                    prefixIcon: const Icon(Icons.warning_amber_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                ),
                SizedBox(height: R.h(24)),
                SizedBox(
                  width: double.infinity,
                  height: R.h(50),
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isSubmitting.value ? null : controller.updateItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                        : Text('Simpan Perubahan', style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold, color: AppColors.white)),
                  )),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showTransactionBottomSheet(BuildContext context, String unit) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(R.w(24)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(24))),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Catat Transaksi Stok', style: AppFonts.inter(fontSize: R.sp(18), fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                  ],
                ),
                SizedBox(height: R.h(16)),
                
                Text('Tipe Transaksi', style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w600)),
                SizedBox(height: R.h(8)),
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Stok Masuk (In)', style: AppFonts.inter(fontSize: R.sp(14))),
                        value: 'In',
                        groupValue: controller.transactionType.value,
                        onChanged: (val) => controller.transactionType.value = val!,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.info,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('Stok Keluar (Out)', style: AppFonts.inter(fontSize: R.sp(14))),
                        value: 'Out',
                        groupValue: controller.transactionType.value,
                        onChanged: (val) => controller.transactionType.value = val!,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.danger,
                      ),
                    ),
                  ],
                )),
                SizedBox(height: R.h(16)),

                TextFormField(
                  controller: controller.quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandSeparatorInputFormatter()],
                  decoration: InputDecoration(
                    labelText: 'Jumlah',
                    hintText: 'Misal: 100',
                    suffixText: unit,
                    prefixIcon: const Icon(Icons.numbers),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Jumlah tidak boleh kosong' : null,
                ),
                SizedBox(height: R.h(16)),
                TextFormField(
                  controller: controller.notesController,
                  decoration: InputDecoration(
                    labelText: 'Catatan (Opsional)',
                    hintText: 'Misal: Stok datang dari supplier',
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                ),
                SizedBox(height: R.h(24)),
                SizedBox(
                  width: double.infinity,
                  height: R.h(50),
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isSubmitting.value ? null : controller.addTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.transactionType.value == 'In' ? AppColors.info : AppColors.danger,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                        : Text('Simpan Transaksi', style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold, color: AppColors.white)),
                  )),
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
