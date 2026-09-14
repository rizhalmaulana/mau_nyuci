import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/model/transaction/transaction_response_model.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../data/services/transaction_service.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../data/models/menu_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/notification_provider.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  final UserProvider _userProvider = UserProvider();
  final TransactionService _transactionService = TransactionService();
  final MenuRepository _menuRepository = MenuRepository();
  
  var selectedIndex = 0.obs;
  var userName = 'User'.obs;
  var tabIndex = 0.obs;
  var isLoading = true.obs;
  
  var menus = <MenuModel>[].obs;
  var isMenuLoading = true.obs;
  var menuErrorMessage = ''.obs;
  
  var userAddress = 'Belum ada alamat'.obs;
  var userLatitude = Rxn<double>();
  var userLongitude = Rxn<double>();
  
  // Location and Permission State
  var locationPermissionStatus = PermissionStatus.denied.obs;
  var isGpsEnabled = false.obs;
  var isLocationLoading = false.obs;
  
  var currentTransactions = <TransactionResponseModel>[].obs;
  var orderHistory = <TransactionResponseModel>[].obs;
  var unreadNotificationCount = 0.obs;
  
  final SignalRClient _signalRClient = SignalRClient();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _fetchMenus();
    _loadUserData();
    _loadTransactionData();
    checkLocationPermissionAndFetch();
    _initSignalR();
  }

  void _initSignalR() async {
    _signalRClient.initConnection();
    await _signalRClient.startConnection();
    _signalRClient.listenToNotifications((arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        String title = "Notifikasi Baru";
        String body = "Anda mendapat pemberitahuan baru";
        
        try {
          if (arguments.length >= 2) {
             title = arguments[0].toString();
             body = arguments[1].toString();
          } else if (arguments.isNotEmpty) {
             body = arguments[0].toString();
          }
        } catch (e) {
          debugPrint("Parse SignalR arg error: $e");
        }
        
        NotificationService().showSignalRNotification(title: title, body: body);
      }
    });
  }

  Future<void> _fetchMenus() async {
    try {
      isMenuLoading.value = true;
      menuErrorMessage.value = '';
      
      final fetchedMenus = await _menuRepository.fetchMenus();
      fetchedMenus.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      
      menus.assignAll(fetchedMenus);
    } catch (e) {
      menuErrorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isMenuLoading.value = false;
    }
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
    _fetchUnreadCount();

    final fcmToken = await NotificationService().getFcmToken();
    if (fcmToken != null) {
      try {
        final authProvider = AuthProvider();
        await authProvider.syncFcmToken(fcmToken);
        debugPrint("FCM Token disinkronisasi saat Home load");
      } catch (e) {
        debugPrint("Gagal sinkron FCM saat Home load: $e");
      }
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await _userProvider.getProfile();
      
      if (response.success && response.data != null) {
        final data = response.data!;
        
        if (data.fullName != null) {
          userName.value = data.fullName!;
          await SecureStorageHelper.write('full_name', data.fullName!);
        }
        
        if (data.defaultAddress != null) {
          userAddress.value = data.defaultAddress!;
        }
        
        if (data.defaultLatitude != null) {
          userLatitude.value = data.defaultLatitude;
        }
        
        if (data.defaultLongitude != null) {
          userLongitude.value = data.defaultLongitude;
        }
      } else {
        print('Error fetching profile: ${response.message}');
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  Future<void> _loadTransactionData() async {
    try {
      isLoading.value = true;

      // Note: _transactionService also needs to be checked if it uses Dio directly
      // but let's assume it returns what we need or catches cleanly
      final activeData = await _transactionService.getActiveTransactions();
      // activeData might be List<TransactionResponseModel> still if _transactionService is not updated
      // Wait, TransactionService is in lib/app/data/services/transaction_service.dart
      // If it returns List<dynamic>, we can assign it if type matches
      // Let's assume TransactionService is already updated to return TransactionModel.
      // We'll update TransactionService if it complains.
      currentTransactions.assignAll(activeData);

      final historyData = await _transactionService.getHistoryTransactions();
      orderHistory.assignAll(historyData);
    } catch (e) {
      debugPrint('Error Home: $e');
      if (e.toString().contains('401')) {
        // Handled by the global onUnauthorized interceptor
      } else {
        CustomSnackbar.showError(
          'Mode Offline',
          e.toString(),
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
        _fetchMenus(),
        _fetchProfile(),
        _loadTransactionData(),
        _fetchUnreadCount(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final NotificationProvider notifProvider = NotificationProvider();
      final response = await notifProvider.getUnreadCount();
      if (response.success) {
        unreadNotificationCount.value = response.data ?? 0;
      }
    } catch (e) {
      debugPrint("Failed to fetch unread notifications count: $e");
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _signalRClient.stopListeningToNotifications();
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
      String errMsg = 'Tidak dapat mendapatkan lokasi';
      if (e is String) errMsg = e;
      CustomSnackbar.showError(
        'Gagal Memuat Lokasi',
        errMsg,
      );
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
    } on DioException catch (e) {
      debugPrint('Reverse geocode error: $e');
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.unknown) {
        throw 'Koneksi internet diperlukan untuk memuat detail alamat terkini.';
      }
      if (e.response?.statusCode == 429) {
        throw 'Terlalu banyak permintaan (Tunggu sebentar)';
      }
    } catch (e) {
      debugPrint('Reverse geocode unknown error: $e');
    }
    throw 'Gagal mendapatkan alamat dari koordinat';
  }
}