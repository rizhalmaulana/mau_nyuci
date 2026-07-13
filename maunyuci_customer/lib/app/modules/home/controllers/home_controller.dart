import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import 'package:maunyuci_customer/app/data/model/transaction/transaction_response_model.dart';
import '../../../core/helpers/api_error_helper.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../data/services/transaction_service.dart';
import '../../../core/widgets/custom_snackbar.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  final UserProvider _userProvider = UserProvider();
  final TransactionService _transactionService = TransactionService();
  
  var selectedIndex = 0.obs;
  var userName = 'User'.obs;
  var tabIndex = 0.obs;
  var isLoading = true.obs;
  
  var userAddress = 'Belum ada alamat'.obs;
  var userLatitude = Rxn<double>();
  var userLongitude = Rxn<double>();
  
  // Location and Permission State
  var locationPermissionStatus = PermissionStatus.denied.obs;
  var isGpsEnabled = false.obs;
  var isLocationLoading = false.obs;
  
  var currentTransactions = <TransactionResponseModel>[].obs;
  var orderHistory = <TransactionResponseModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _loadTransactionData();
    checkLocationPermissionAndFetch();
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  Future<void> _loadUserData() async {
    final name = await SecureStorageHelper.read('full_name');
    if (name != null && name.isNotEmpty) {
      userName.value = name;
    }
    
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await _userProvider.getProfile();
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        if (data['fullName'] != null) {
          userName.value = data['fullName'];
          await SecureStorageHelper.write('full_name', data['fullName']);
        }
        
        if (data['defaultAddress'] != null) {
          userAddress.value = data['defaultAddress'];
        }
        
        if (data['defaultLatitude'] != null) {
          userLatitude.value = data['defaultLatitude'].toDouble();
        }
        
        if (data['defaultLongitude'] != null) {
          userLongitude.value = data['defaultLongitude'].toDouble();
        }
      }
    } on DioException catch (e) {
      final errorMessage = handleApiError(e);
      print('Error fetching profile: $errorMessage');
    }
  }

  Future<void> _loadTransactionData() async {
    try {
      isLoading.value = true;

      final activeData = await _transactionService.getActiveTransactions();
      currentTransactions.assignAll(activeData);

      final historyData = await _transactionService.getHistoryTransactions();
      orderHistory.assignAll(historyData);
    } catch (e) {
      debugPrint('Error Home: $e');
      if (e is DioException && e.response?.statusCode == 401) {
        // Handled by the global onUnauthorized interceptor
      } else {
        final errorMessage = handleApiError(e);
        CustomSnackbar.showError(
          'Gagal Memuat Data',
          errorMessage,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void changePage(int index) {
    selectedIndex.value = index;
  }

  Future<void> updateAddress(String address, double? lat, double? lng) async {
    userAddress.value = address;
    if (lat != null) userLatitude.value = lat;
    if (lng != null) userLongitude.value = lng;
    
    if (!Get.isRegistered<AddressRepository>()) {
      Get.put(AddressRepository());
    }
    await Get.find<AddressRepository>().saveAddress(address, lat ?? 0.0, lng ?? 0.0);
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _fetchProfile(),
        _loadTransactionData(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkLocationPermissionAndFetch();
    }
  }

  Future<void> checkLocationPermissionAndFetch() async {
    final status = await Permission.location.status;
    locationPermissionStatus.value = status;
    
    if (status.isGranted) {
      final gpsEnabled = await Geolocator.isLocationServiceEnabled();
      isGpsEnabled.value = gpsEnabled;
      
      if (gpsEnabled) {
        if (userAddress.value == 'Belum ada alamat' || userAddress.value.isEmpty) {
          await fetchCurrentLocation();
        }
      }
    } else {
      isGpsEnabled.value = false;
    }
  }

  Future<void> fetchCurrentLocation() async {
    try {
      isLocationLoading.value = true;
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final address = await _reverseGeocode(position.latitude, position.longitude);
      
      await updateAddress(
        address,
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      debugPrint('Error fetching current location: $e');
    } finally {
      isLocationLoading.value = false;
    }
  }

  Future<String> _reverseGeocode(double lat, double lon) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://us1.locationiq.com/v1/reverse.php',
        queryParameters: {
          'key': 'pk.ec69b070d8e0ca24dd6cf88f750ceede',
          'lat': lat,
          'lon': lon,
          'format': 'json',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['display_name'] ?? 'Unknown location';
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
      if (e is DioException && e.response?.statusCode == 429) {
        return 'Terlalu banyak permintaan (Tunggu sebentar)';
      }
    }
    return 'Unknown location';
  }
}