import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_confirm_modal.dart';
import '../../../data/providers/driver_provider.dart';
import '../../../data/models/driver_task_model.dart';
import '../../../core/services/location_service.dart';

class HomeController extends GetxController {
  final DriverProvider _driverProvider;

  HomeController(this._driverProvider);

  final unsettledCash = 0.0.obs;
  final pickupTasks = <DriverTaskModel>[].obs;
  final deliveryTasks = <DriverTaskModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
    _initLocationService();
  }

  Future<void> _initLocationService() async {
    await LocationService.initialize();
    await LocationService.startService();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchUnsettledCash(),
        fetchTasks(),
      ]);
    } catch (e) {
      Get.snackbar('Error', ApiClient.handleErrorMessage(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnsettledCash() async {
    try {
      final data = await _driverProvider.getUnsettledCash();
      unsettledCash.value = (data['amount'] ?? 0.0).toDouble();
    } catch (e) {
      // Tangani error diam-diam atau log
    }
  }

  Future<void> fetchTasks() async {
    try {
      final tasks = await _driverProvider.getTasks();
      pickupTasks.clear();
      deliveryTasks.clear();

      for (var task in tasks) {
        // Asumsi struktur data: ada field 'taskType' dengan value 'Pickup' atau 'Delivery'
        final type = task.taskType;
        if (type.toLowerCase() == 'pickup') {
          pickupTasks.add(task);
        } else if (type.toLowerCase() == 'delivery') {
          deliveryTasks.add(task);
        }
      }
    } catch (e) {
      // Tangani error
    }
  }
  
  Future<void> logout() async {
    final confirmed = await CustomConfirmModal.show<bool>(
      title: 'Keluar dari Akun?',
      message: 'Kamu yakin mau keluar? Pastikan tidak ada tugas yang belum beres ya.',
      textCancel: 'Batal',
      textConfirm: 'Ya, Keluar',
      confirmColor: AppColors.danger,
      icon: Icons.logout_rounded,
      onConfirm: () => Get.back(result: true),
    );
    if (confirmed != true) return;

    await SecureStorageHelper.clearAll();
    Get.offAllNamed('/login');
  }
}
