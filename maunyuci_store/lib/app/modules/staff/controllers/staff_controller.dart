import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/providers/staff_provider.dart';
import '../../../data/services/storage_service.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../data/models/staff_model.dart';

class StaffController extends GetxController {
  final StaffProvider _staffProvider = StaffProvider();
  final StorageService _storageService = Get.find<StorageService>();
  
  final isLoading = true.obs;
  final isSubmitting = false.obs;
  final staffs = <StaffModel>[].obs;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final role = 'Cashier'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStaffs();
  }

  Future<void> fetchStaffs() async {
    isLoading.value = true;
    
    final storeId = await _storageService.read('storeId');
    if (storeId == null) {
      isLoading.value = false;
      return;
    }
    
    final response = await _staffProvider.getStaffs(storeId);
    if (response.success && response.data != null) {
      staffs.value = response.data!;
    } else {
      CustomSnackbar.showError('Error', response.message ?? 'Gagal mengambil data kasir');
    }
    
    isLoading.value = false;
  }

  Future<void> addStaff() async {
    if (!formKey.currentState!.validate()) return;

    isSubmitting.value = true;
    
    final storeId = await _storageService.read('storeId');
    if (storeId == null) {
      isSubmitting.value = false;
      return;
    }

    // UI menjanjikan password default 123456 ke staff, jadi wajib dikirim.
    // Tanpa ini backend menolak dengan "Validasi Gagal".
    final data = {
      "fullName": nameController.text.trim(),
      "phoneNumber": phoneController.text.trim(),
      "password": "123456",
      "role": role.value,
    };

    final response = await _staffProvider.addStaff(storeId, data);

    if (response.success) {
      Get.back(); // tutup bottom sheet dulu, snackbar setelahnya
      nameController.clear();
      phoneController.clear();
      role.value = 'Cashier';
      fetchStaffs();
      Future.delayed(const Duration(milliseconds: 300), () {
        CustomSnackbar.showSuccess('Berhasil', 'Kasir berhasil didaftarkan');
      });
    } else {
      final details = <String>[];
      if (response.errors != null && response.errors!.isNotEmpty) {
        details.addAll(response.errors!);
      }
      if (response.errorDetails != null && response.errorDetails!.isNotEmpty) {
        details.addAll(response.errorDetails!.entries.map((e) => '${e.key}: ${e.value}'));
      }
      final message = details.isNotEmpty
          ? '${response.message ?? 'Validasi gagal'}\n${details.join('\n')}'
          : (response.message ?? 'Terjadi kesalahan');
      CustomSnackbar.showError('Gagal', message);
    }
    
    isSubmitting.value = false;
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
