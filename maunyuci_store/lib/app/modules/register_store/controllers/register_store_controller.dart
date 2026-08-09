import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/providers/store_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../core/widgets/custom_location_picker.dart';

class RegisterStoreController extends GetxController {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final openTimeController = TextEditingController();
  final closeTimeController = TextEditingController();
  final pickupFeeController = TextEditingController();
  final minOrderController = TextEditingController();

  final StoreProvider _storeProvider = StoreProvider();

  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var hasPickupDeliveryService = true.obs;

  var nameError = ''.obs;
  var addressError = ''.obs;
  var phoneError = ''.obs;
  var openTimeError = ''.obs;
  var closeTimeError = ''.obs;
  var pickupFeeError = ''.obs;
  var minOrderError = ''.obs;

  var isLoading = false.obs;

  void togglePickupDelivery(bool value) {
    hasPickupDeliveryService.value = value;
  }

  Future<void> pickLocation() async {
    final result = await Get.bottomSheet(
      const CustomLocationPicker(),
      isScrollControlled: true,
    );
    if (result != null) {
      addressController.text = result['address'];
      latitude.value = result['lat'];
      longitude.value = result['lng'];
    }
  }

  Future<void> selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final String formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      controller.text = formattedTime;
    }
  }

  bool _validateForm() {
    bool isValid = true;
    nameError.value = '';
    addressError.value = '';
    phoneError.value = '';
    openTimeError.value = '';
    closeTimeError.value = '';
    pickupFeeError.value = '';
    minOrderError.value = '';

    if (nameController.text.trim().isEmpty) {
      nameError.value = 'Nama toko tidak boleh kosong';
      isValid = false;
    }
    
    if (addressController.text.trim().isEmpty) {
      addressError.value = 'Alamat toko tidak boleh kosong';
      isValid = false;
    }
    
    String phone = phoneController.text.trim();
    if (phone.isEmpty) {
      phoneError.value = 'Nomor HP tidak boleh kosong';
      isValid = false;
    } else if (!phone.startsWith('08')) {
      phoneError.value = 'Nomor HP harus diawali dengan 08';
      isValid = false;
    } else if (phone.length < 9 || phone.length > 15) {
      phoneError.value = 'Nomor HP tidak valid';
      isValid = false;
    }

    if (openTimeController.text.isEmpty) {
      openTimeError.value = 'Waktu buka harus diisi';
      isValid = false;
    }

    if (closeTimeController.text.isEmpty) {
      closeTimeError.value = 'Waktu tutup harus diisi';
      isValid = false;
    }

    if (hasPickupDeliveryService.value) {
      if (pickupFeeController.text.isEmpty) {
        pickupFeeError.value = 'Biaya antar jemput harus diisi';
        isValid = false;
      }
      
      String minOrderText = minOrderController.text.replaceAll(RegExp(r'[^0-9.]'), '');
      double? minOrder = double.tryParse(minOrderText);
      if (minOrderText.isEmpty || minOrder == null) {
        minOrderError.value = 'Minimal order harus diisi';
        isValid = false;
      } else if (minOrder < 5) {
        minOrderError.value = 'Minimal order antar jemput adalah 5kg';
        isValid = false;
      }
    }

    if (latitude.value == 0.0 || longitude.value == 0.0) {
      _showErrorSnackbar('Lokasi', 'Silakan pilih lokasi toko dari peta');
      isValid = false;
    }

    return isValid;
  }

  Future<void> registerStore() async {
    if (_validateForm()) {
      try {
        isLoading.value = true;
        
        double pickupFee = 0;
        double minOrder = 0;
        
        if (hasPickupDeliveryService.value) {
           pickupFee = double.tryParse(pickupFeeController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
           minOrder = double.tryParse(minOrderController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        }

        final data = {
          "name": nameController.text.trim(),
          "address": addressController.text.trim(),
          "latitude": latitude.value,
          "longitude": longitude.value,
          "storePhoneNumber": phoneController.text.trim(),
          "openTime": openTimeController.text.trim(),
          "closeTime": closeTimeController.text.trim(),
          "hasPickupDeliveryService": hasPickupDeliveryService.value,
          "pickupDeliveryFee": pickupFee,
          "minOrderForPickup": minOrder,
        };

        final response = await _storeProvider.registerStore(data);

        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.offAllNamed(Routes.HOME);
        }
      } on DioException catch (e) {
        final errorMessage = ApiClient.handleErrorMessage(e.response?.data);
        _showErrorSnackbar('Pendaftaran Gagal', errorMessage);
      } catch (e) {
        _showErrorSnackbar('Error', 'Terjadi kesalahan sistem.');
      } finally {
        isLoading.value = false;
      }
    }
  }

  void _showErrorSnackbar(String title, String message) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }
}
