import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/models/inventory_model.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/utils/thousand_separator_input_formatter.dart';
import '../../../routes/app_routes.dart';
import '../controllers/inventory_controller.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

class InventoryView extends GetView<InventoryController> {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<InventoryController>()) {
      Get.put(InventoryController());
    }

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text('Katalog Stok Toko', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(18), color: AppColors.black87)),
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemBottomSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.inventoryList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: R.r(64), color: AppColors.grey500),
                SizedBox(height: R.h(16)),
                Text('Belum ada barang di inventori', style: AppFonts.inter(fontSize: R.sp(16), color: AppColors.grey500)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchInventory,
          child: ListView.builder(
            padding: EdgeInsets.all(R.w(16)),
            itemCount: controller.inventoryList.length,
            itemBuilder: (context, index) {
              final item = controller.inventoryList[index];
              return _buildInventoryCard(item);
            },
          ),
        );
      }),
    );
  }

  void _showAddItemBottomSheet(BuildContext context) {
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
                Text('Tambah Barang Baru', style: AppFonts.inter(fontSize: R.sp(18), fontWeight: FontWeight.bold)),
                SizedBox(height: R.h(24)),
                
                TextFormField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Barang',
                    hintText: 'Misal: Deterjen cair',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Nama barang tidak boleh kosong' : null,
                ),
                SizedBox(height: R.h(16)),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller.stockController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [ThousandSeparatorInputFormatter()],
                        decoration: InputDecoration(
                          labelText: 'Stok Awal',
                          hintText: 'Misal: 100',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Harus diisi' : null,
                      ),
                    ),
                    SizedBox(width: R.w(16)),
                    Expanded(
                      child: Obx(() => DropdownButtonFormField<String>(
                        value: controller.unitOptions.contains(controller.selectedUnit.value)
                            ? controller.selectedUnit.value
                            : controller.unitOptions.first,
                        decoration: InputDecoration(
                          labelText: 'Satuan',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                        ),
                        items: controller.unitOptions.map((String unit) {
                          return DropdownMenuItem(value: unit, child: Text(unit));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedUnit.value = val;
                            controller.unitController.text = val;
                          }
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Harus diisi' : null,
                      )),
                    ),
                  ],
                ),
                SizedBox(height: R.h(16)),

                TextFormField(
                  controller: controller.minStockController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandSeparatorInputFormatter()],
                  decoration: InputDecoration(
                    labelText: 'Batas Stok Minimum',
                    hintText: 'Misal: 10',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                ),
                SizedBox(height: R.h(24)),

                Obx(() => ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : () => controller.addInventoryItem(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: R.h(16)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                  child: controller.isSubmitting.value
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : Text('Simpan Barang', style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold, color: AppColors.white)),
                )),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInventoryCard(InventoryModel item) {
    final double stock = item.currentStock;
    final double minStock = item.minStockLevel;
    final String unit = item.unit;
    final String name = item.itemName;
    final bool isLowStock = minStock > 0 && stock <= minStock;
    
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.INVENTORY_DETAIL, arguments: item.toJson())?.then((_) => controller.fetchInventory());
      },
      child: Container(
        margin: EdgeInsets.only(bottom: R.h(12)),
        padding: EdgeInsets.all(R.w(16)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.r(12)),
          border: isLowStock ? Border.all(color: AppColors.danger300, width: 1.5) : null,
          boxShadow: [
            BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isLowStock ? AppColors.danger50 : AppColors.info50,
              radius: R.r(24),
              child: Icon(Icons.inventory, color: isLowStock ? AppColors.danger : AppColors.info, size: R.r(24)),
            ),
            SizedBox(width: R.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: R.h(4)),
                  Text(
                    'Stok: $stock $unit',
                    style: AppFonts.inter(fontSize: R.sp(14), color: isLowStock ? AppColors.danger : AppColors.deepPurple, fontWeight: FontWeight.w600),
                  ),
                  if (isLowStock) ...[
                    SizedBox(height: R.h(4)),
                    Text('⚠️ Stok Menipis!', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.danger, fontWeight: FontWeight.bold)),
                  ]
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.grey500),
          ],
        ),
      ),
    );
  }
}
