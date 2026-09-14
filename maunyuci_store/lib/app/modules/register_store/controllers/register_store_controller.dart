import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/providers/store_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../core/widgets/custom_location_picker.dart';
import '../../../core/constants/app_colors.dart';

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
  var selectedAddress = ''.obs;
  var openTime = ''.obs;
  var closeTime = ''.obs;

  var nameError = ''.obs;
  var addressError = ''.obs;
  var phoneError = ''.obs;
  var openTimeError = ''.obs;
  var closeTimeError = ''.obs;
  var pickupFeeError = ''.obs;
  var minOrderError = ''.obs;
  var imageError = ''.obs;

  var isLoading = false.obs;

  var selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      selectedImage.value = File(image.path);
      imageError.value = '';
    }
  }

  @override
  void onInit() {
    super.onInit();
    openTimeController.text = '08:00';
    openTime.value = '08:00';
    closeTimeController.text = '20:00';
    closeTime.value = '20:00';
  }

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
      selectedAddress.value = result['address'];
      latitude.value = result['lat'];
      longitude.value = result['lng'];
      addressError.value = '';
    }
  }

  Future<void> selectTime(BuildContext context, bool isOpenTime) async {
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
      if (isOpenTime) {
        openTimeController.text = formattedTime;
        openTime.value = formattedTime;
        openTimeError.value = '';
      } else {
        closeTimeController.text = formattedTime;
        closeTime.value = formattedTime;
        closeTimeError.value = '';
      }
      _validateTimeRealtime();
    }
  }

  void _validateTimeRealtime() {
    if (openTimeController.text.isNotEmpty && closeTimeController.text.isNotEmpty) {
      int openH = int.parse(openTimeController.text.split(':')[0]);
      int openM = int.parse(openTimeController.text.split(':')[1]);
      int closeH = int.parse(closeTimeController.text.split(':')[0]);
      int closeM = int.parse(closeTimeController.text.split(':')[1]);

      int openMinutes = openH * 60 + openM;
      int closeMinutes = closeH * 60 + closeM;

      if (openMinutes > closeMinutes) {
        closeTimeError.value = 'Waktu tutup tidak valid (harus setelah waktu buka)';
      }
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
    imageError.value = '';

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

    if (openTimeController.text.isNotEmpty && closeTimeController.text.isNotEmpty) {
      int openH = int.parse(openTimeController.text.split(':')[0]);
      int openM = int.parse(openTimeController.text.split(':')[1]);
      int closeH = int.parse(closeTimeController.text.split(':')[0]);
      int closeM = int.parse(closeTimeController.text.split(':')[1]);

      int openMinutes = openH * 60 + openM;
      int closeMinutes = closeH * 60 + closeM;

      if (openMinutes > closeMinutes) {
        closeTimeError.value = 'Waktu tutup tidak valid (harus setelah waktu buka)';
        isValid = false;
      }
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

    if (selectedImage.value == null) {
      imageError.value = 'Foto toko wajib diunggah';
      isValid = false;
    }

    return isValid;
  }

  Future<void> registerStore() async {
    if (_validateForm()) {
      int openH = int.parse(openTimeController.text.split(':')[0]);
      int openM = int.parse(openTimeController.text.split(':')[1]);
      int closeH = int.parse(closeTimeController.text.split(':')[0]);
      int closeM = int.parse(closeTimeController.text.split(':')[1]);

      int diffMinutes = (closeH * 60 + closeM) - (openH * 60 + openM);
      if (diffMinutes <= 180) {
        Get.defaultDialog(
          title: 'Konfirmasi Waktu Buka',
          middleText: 'Apakah Anda yakin Toko hanya buka 3 Jam atau kurang per hari?',
          textConfirm: 'Ya, Yakin',
          textCancel: 'Batal',
          confirmTextColor: AppColors.white,
          onConfirm: () {
            Get.back(); // Tutup dialog
            _proceedRegister();
          },
        );
      } else {
        _proceedRegister();
      }
    }
  }

  Future<void> _proceedRegister() async {
    try {
      isLoading.value = true;
      
      double pickupFee = 0;
      double minOrder = 0;
      
      if (hasPickupDeliveryService.value) {
         pickupFee = double.tryParse(pickupFeeController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
         minOrder = double.tryParse(minOrderController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      }

      final data = FormData.fromMap({
        "Name": nameController.text.trim(),
        "Address": addressController.text.trim(),
        "Latitude": latitude.value,
        "Longitude": longitude.value,
        "PhoneNumber": phoneController.text.trim(),
        "OperatingHours": '${openTimeController.text.trim()} - ${closeTimeController.text.trim()}',
        "OpenTime": openTimeController.text.trim(),
        "CloseTime": closeTimeController.text.trim(),
        "HasPickupDeliveryService": hasPickupDeliveryService.value,
        "PickupDeliveryFee": pickupFee,
        "MinOrderForPickup": minOrder,
        "ImageFile": await MultipartFile.fromFile(
          selectedImage.value!.path,
          filename: selectedImage.value!.path.split('/').last,
        ),
      });

      final response = await _storeProvider.registerStore(data);

      if (response.success) {
        Get.offAllNamed(Routes.HOME);
      } else {
        _showErrorSnackbar('Pendaftaran Gagal', response.message ?? 'Gagal mendaftar toko');
      }
    } catch (e) {
      _showErrorSnackbar('Error', 'Terjadi kesalahan sistem.');
    } finally {
      isLoading.value = false;
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
      backgroundColor: AppColors.danger.withValues(alpha: 0.9),
      colorText: AppColors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: AppColors.white),
    );
  }
}
