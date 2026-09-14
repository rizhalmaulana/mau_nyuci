import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../core/utils/thousand_separator_input_formatter.dart';
import '../../../data/providers/inventory_provider.dart';
import '../../../data/services/storage_service.dart';
import '../../../core/widgets/custom_snackbar.dart';

class InventoryDetailController extends GetxController {
  final InventoryProvider _inventoryProvider = InventoryProvider();
  final StorageService _storageService = Get.find<StorageService>();
  
  final isSubmitting = false.obs;
  
  final RxMap<String, dynamic> item = <String, dynamic>{}.obs;
  
  final formKey = GlobalKey<FormState>();
  final quantityController = TextEditingController();
  final notesController = TextEditingController();

  // Edit barang
  final editFormKey = GlobalKey<FormState>();
  final editNameController = TextEditingController();
  final editMinStockController = TextEditingController();
  final editUnit = 'Pcs'.obs;
  final List<String> unitOptions = [
    'Pcs',
    'Kg',
    'Gram',
    'Liter',
    'Ml',
    'Pack',
    'Dus',
    'Botol',
    'Dirigen',
    'Sachet',
    'Roll',
    'Meter',
  ];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      item.value = Map<String, dynamic>.from(Get.arguments);
    }
  }

  final transactionType = 'Out'.obs; // Default to Out

  Future<void> addTransaction() async {
    if (!formKey.currentState!.validate()) return;

    final qty = parseThousand(quantityController.text);
    if (qty <= 0) {
      CustomSnackbar.showError('Gagal', 'Jumlah tidak valid');
      return;
    }

    isSubmitting.value = true;
    try {
      final storeId = await _storageService.read('storeId');
      if (storeId == null) return;
      
      final itemId = item['id'];
      if (itemId == null) return;

      final data = {
        "transactionType": transactionType.value,
        "quantity": qty,
        "notes": notesController.text.trim(),
      };

      final response = await _inventoryProvider.addInventoryTransaction(storeId, itemId, data);
      
      if (response.success) {
        // Update local state instantly without reloading.
        // Key 'currentStock' mengikuti InventoryModel.toJson(); alias BE dibaca juga.
        final currentStock = (item['currentStock'] ?? item['stockQuantity'] ?? item['stock'] ?? 0).toDouble();
        final updatedStock = transactionType.value == 'In'
            ? currentStock + qty
            : currentStock - qty;
        item['currentStock'] = updatedStock;
        item['stock'] = updatedStock;
        item.refresh();

        Get.back(); // tutup bottom sheet dulu, snackbar setelahnya
        quantityController.clear();
        notesController.clear();
        Future.delayed(const Duration(milliseconds: 300), () {
          CustomSnackbar.showSuccess('Berhasil', 'Transaksi stok berhasil disimpan');
        });
      }
    } on DioException catch (e) {
      CustomSnackbar.showError('Gagal Menyimpan Transaksi', ApiClient.handleErrorMessage(e.response?.data));
    } finally {
      isSubmitting.value = false;
    }
  }

  void setupEditForm() {
    editNameController.text = (item['itemName'] ?? item['name'] ?? '').toString();
    final minStock = (item['minStockLevel'] ?? item['minimumStockAlert'] ?? 0);
    final minStockNum = minStock is num ? minStock : num.tryParse(minStock.toString()) ?? 0;
    editMinStockController.text = formatThousand(minStockNum.toInt().toString());
    final currentUnit = (item['unit'] ?? 'Pcs').toString();
    editUnit.value = unitOptions.contains(currentUnit) ? currentUnit : unitOptions.first;
  }

  Future<void> updateItem() async {
    if (!editFormKey.currentState!.validate()) return;

    isSubmitting.value = true;
    try {
      final storeId = await _storageService.read('storeId');
      if (storeId == null) return;

      final itemId = item['id']?.toString();
      if (itemId == null || itemId.isEmpty) return;

      final currentStock = (item['currentStock'] ?? item['stockQuantity'] ?? item['stock'] ?? 0).toDouble();
      final data = {
        "itemName": editNameController.text.trim(),
        "unit": editUnit.value,
        "minStockLevel": parseThousand(editMinStockController.text),
        "currentStock": currentStock,
      };

      final response = await _inventoryProvider.updateInventoryItem(storeId, itemId, data);

      if (response.success && response.data != null) {
        final updated = response.data!.toJson();
        // Pertahankan updatedAt lama bila BE tidak mengembalikannya.
        updated['updatedAt'] ??= item['updatedAt'];
        item.value = updated;

        Get.back(); // tutup bottom sheet dulu, snackbar setelahnya
        Future.delayed(const Duration(milliseconds: 300), () {
          CustomSnackbar.showSuccess('Berhasil', 'Data barang berhasil diperbarui');
        });
      } else {
        CustomSnackbar.showError('Gagal', response.message ?? 'Gagal memperbarui barang');
      }
    } catch (e) {
      CustomSnackbar.showError('Terjadi Kesalahan', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    quantityController.dispose();
    notesController.dispose();
    editNameController.dispose();
    editMinStockController.dispose();
    super.onClose();
  }
}
