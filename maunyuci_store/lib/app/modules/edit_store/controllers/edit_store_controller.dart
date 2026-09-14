import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/models/store_model.dart';
import '../../../data/providers/store_provider.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/custom_location_picker.dart';

class EditStoreController extends GetxController {
  final StoreProvider _storeProvider = StoreProvider();
  
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final pickupFeeController = TextEditingController();
  final minOrderController = TextEditingController();

  final RxString selectedAddress = ''.obs;
  final RxDouble selectedLat = 0.0.obs;
  final RxDouble selectedLng = 0.0.obs;
  
  final RxString openTime = ''.obs;
  final RxString closeTime = ''.obs;

  final RxBool hasPickupDeliveryService = false.obs;
  final Rxn<File> selectedImage = Rxn<File>();
  final RxString existingImageUrl = ''.obs;

  final RxBool isLoading = false.obs;

  late StoreModel _store;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is StoreModel) {
      _store = Get.arguments as StoreModel;
      nameController.text = _store.name;
      phoneController.text = _store.phoneNumber ?? '';
      selectedAddress.value = _store.address;
      selectedLat.value = _store.latitude ?? 0.0;
      selectedLng.value = _store.longitude ?? 0.0;
      existingImageUrl.value = _store.storeImageUrl;
      
      final times = _store.operatingHoursFormatted.split('-');
      if (times.length == 2) {
        openTime.value = times[0].trim();
        closeTime.value = times[1].trim();
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    pickupFeeController.dispose();
    minOrderController.dispose();
    super.onClose();
  }

  void togglePickupDelivery(bool value) {
    hasPickupDeliveryService.value = value;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1080,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  Future<void> pickLocation() async {
    final result = await Get.bottomSheet(
      const CustomLocationPicker(),
      isScrollControlled: true,
    );
    if (result != null) {
      selectedAddress.value = result['address'];
      selectedLat.value = result['lat'];
      selectedLng.value = result['lng'];
    }
  }

  Future<void> selectTime(BuildContext context, bool isOpenTime) async {
    final initialTime = TimeOfDay.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: isOpenTime && openTime.value.isNotEmpty
          ? _parseTime(openTime.value)
          : (!isOpenTime && closeTime.value.isNotEmpty
              ? _parseTime(closeTime.value)
              : initialTime),
    );

    if (pickedTime != null) {
      final formattedTime = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
      if (isOpenTime) {
        openTime.value = formattedTime;
      } else {
        closeTime.value = formattedTime;
      }
    }
  }

  TimeOfDay _parseTime(String time) {
    try {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return TimeOfDay.now();
    }
  }

  Future<void> updateStore() async {
    if (nameController.text.trim().isEmpty || selectedAddress.value.isEmpty || openTime.value.isEmpty || closeTime.value.isEmpty) {
      CustomSnackbar.showError('Error', 'Harap isi semua field yang wajib');
      return;
    }

    isLoading.value = true;
    try {
      final formData = dio.FormData.fromMap({
        'Name': nameController.text.trim(),
        'Address': selectedAddress.value,
        'Latitude': selectedLat.value,
        'Longitude': selectedLng.value,
        'PhoneNumber': phoneController.text.trim(),
        'OpenTime': '${openTime.value}:00',
        'CloseTime': '${closeTime.value}:00',
      });

      if (selectedImage.value != null) {
        formData.files.add(MapEntry(
          'ImageFile',
          await dio.MultipartFile.fromFile(
            selectedImage.value!.path,
            filename: selectedImage.value!.path.split('/').last,
          ),
        ));
      }

      final response = await _storeProvider.updateStore(formData);
      if (response.success) {
        Get.back(result: true);
        Future.delayed(const Duration(milliseconds: 300), () {
          CustomSnackbar.showSuccess('Berhasil', 'Data toko berhasil diperbarui');
        });
      } else {
        CustomSnackbar.showError('Gagal', 'Gagal memperbarui toko');
      }
    } catch (e) {
      CustomSnackbar.showError('Terjadi Kesalahan', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
