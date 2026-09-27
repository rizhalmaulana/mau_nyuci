import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/providers/driver_provider.dart';
import '../../../data/models/driver_task_model.dart';

class PickupDetailController extends GetxController {
  final DriverProvider _driverProvider;
  PickupDetailController(this._driverProvider);

  late final String orderId;
  final taskData = Rx<DriverTaskDetailModel?>(null);
  final isLoading = false.obs;
  final isFetching = false.obs;

  @override
  void onInit() {
    super.onInit();
    orderId = Get.arguments?.toString() ?? '';
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    isFetching.value = true;
    try {
      final detail = await _driverProvider.getTaskDetail(orderId);
      taskData.value = detail;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat detail tugas: ${ApiClient.handleErrorMessage(e)}');
    } finally {
      isFetching.value = false;
    }
  }

  void openGoogleMaps() async {
    final lat = taskData.value?.latitude;
    final lng = taskData.value?.longitude;
    
    if (lat != null && lng != null) {
      final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
      final uri = Uri.parse(url);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        Get.snackbar('Error', 'Tidak dapat membuka Google Maps: $e');
      }
    } else {
      Get.snackbar('Info', 'Koordinat lokasi Customer tidak tersedia');
    }
  }

  Future<void> confirmPickup() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50, // Kompresi untuk menghemat kuota
    );

    if (pickedFile != null) {
      isLoading.value = true;
      try {
        await _driverProvider.confirmPickup(orderId, pickedFile.path);
        
        Get.snackbar('Sukses', 'Penjemputan berhasil dikonfirmasi', 
          backgroundColor: Colors.green, colorText: Colors.white);
        
        // Kembali ke Home dan refresh (opsional)
        Get.offAllNamed('/home');
      } catch (e) {
        Get.snackbar('Gagal', ApiClient.handleErrorMessage(e),
          backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        isLoading.value = false;
      }
    }
  }
}
