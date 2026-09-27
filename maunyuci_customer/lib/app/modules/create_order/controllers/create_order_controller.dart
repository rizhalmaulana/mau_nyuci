import 'package:get/get.dart';
import '../../../data/models/store_model.dart';
import '../../../data/providers/store_provider.dart';
import '../../home/controllers/home_controller.dart';
import '../../../core/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';

class CreateOrderController extends GetxController {
  final StoreProvider _storeProvider = StoreProvider();
  
  var isLoading = true.obs;
  var nearbyStores = <StoreModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNearbyStores();
  }

  Future<void> fetchNearbyStores() async {
    try {
      isLoading.value = true;
      
      // Try to get location from HomeController
      double lat = 0.0;
      double lng = 0.0;
      
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        lat = homeController.userLatitude.value ?? 0.0;
        lng = homeController.userLongitude.value ?? 0.0;
      }
      
      if (lat == 0.0 && lng == 0.0) {
        debugPrint("Warning: lat/lng is 0.0 in CreateOrderController");
      }

      final response = await _storeProvider.getNearbyStores(lat, lng);
      
      if (response.success || response.statusCode == 200) {
        nearbyStores.assignAll(response.data ?? []);
      } else {
        String errorMsg = (response.message == null || response.message!.isEmpty) 
            ? 'Gagal memuat toko terdekat' 
            : response.message!;
        CustomSnackbar.showError('Gagal', errorMsg);
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
