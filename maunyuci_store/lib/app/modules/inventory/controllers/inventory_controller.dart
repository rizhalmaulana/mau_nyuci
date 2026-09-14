import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../core/utils/thousand_separator_input_formatter.dart';
import '../../../data/providers/inventory_provider.dart';
import '../../../data/services/storage_service.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../data/models/inventory_model.dart';

class InventoryController extends GetxController {
  final InventoryProvider _inventoryProvider = InventoryProvider();
  final StorageService _storageService = Get.find<StorageService>();
  
  final isLoading = true.obs;
  final inventoryList = <InventoryModel>[].obs;

  // Create Item Form
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final stockController = TextEditingController();
  final unitController = TextEditingController();
  final minStockController = TextEditingController();
  final isSubmitting = false.obs;

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
  final selectedUnit = 'Pcs'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInventory();
  }

  Future<void> fetchInventory() async {
    isLoading.value = true;
    
    final storeId = await _storageService.read('storeId');
    if (storeId == null) {
      isLoading.value = false;
      return;
    }
    
    final response = await _inventoryProvider.getInventory(storeId);
    if (response.success && response.data != null) {
      inventoryList.value = response.data!;
    } else {
      CustomSnackbar.showError('Error', response.message ?? 'Gagal mengambil data inventaris');
    }
    
    isLoading.value = false;
  }

  Future<void> addInventoryItem() async {
    if (!formKey.currentState!.validate()) return;

    isSubmitting.value = true;
    
    final storeId = await _storageService.read('storeId');
    if (storeId == null) {
      isSubmitting.value = false;
      return;
    }

    final data = {
      "itemName": nameController.text.trim(),
      "currentStock": parseThousand(stockController.text),
      "unit": selectedUnit.value,
      "minStockLevel": parseThousand(minStockController.text),
    };

    final response = await _inventoryProvider.addInventoryItem(storeId, data);

    if (response.success) {
      Get.back(); // tutup bottom sheet dulu, snackbar setelahnya
      nameController.clear();
      stockController.clear();
      unitController.clear();
      minStockController.clear();
      selectedUnit.value = 'Pcs';
      fetchInventory();
      Future.delayed(const Duration(milliseconds: 300), () {
        CustomSnackbar.showSuccess('Berhasil', 'Barang baru berhasil ditambahkan');
      });
    } else {
      CustomSnackbar.showError('Gagal', response.message ?? 'Terjadi kesalahan');
    }
    
    isSubmitting.value = false;
  }

  @override
  void onClose() {
    nameController.dispose();
    stockController.dispose();
    unitController.dispose();
    minStockController.dispose();
    super.onClose();
  }
}
