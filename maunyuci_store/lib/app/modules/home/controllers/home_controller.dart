import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import 'package:intl/intl.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/providers/order_provider.dart';
import '../../../data/providers/store_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/notification_provider.dart';

class HomeController extends GetxController {
  final StorageService _storageService = Get.find();
  final OrderProvider _orderProvider = OrderProvider();
  final StoreProvider _storeProvider = StoreProvider();
  
  final SignalRClient _signalRClient = SignalRClient();

  final storeName = 'Toko Anda'.obs;
  final storeImageUrl = ''.obs;
  
  // Dashboard stats
  var dashboardStats = Rxn<DashboardTransactionModel>();

  final lastUpdated = ''.obs;
  var isLoading = false.obs;

  // Daftar pesanan
  final orderList = <OrderModel>[].obs;
  var unreadNotificationCount = 0.obs;

  // Scroll Controller untuk parallax efek
  final ScrollController scrollController = ScrollController();

  String? _storeId;

  @override
  void onInit() {
    super.onInit();
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    _storeId = await _storageService.read('storeId');
    
    // Fallback jika storeId belum ada di storage (misal user hanya Hot Reload)
    if (_storeId == null) {
      final storeResponse = await _storeProvider.getStoreProfile();
      if (storeResponse.success && storeResponse.data != null) {
        _storeId = storeResponse.data!.id;
        storeName.value = storeResponse.data!.name;
        storeImageUrl.value = storeResponse.data!.storeImageUrl;
        await _storageService.write('storeId', _storeId!);
      }
    }

    await refreshData();
    
    // Sync FCM Token & Fetch unread count
    _fetchUnreadCount();
    final fcmToken = await NotificationService().getFcmToken();
    if (fcmToken != null) {
      try {
        await AuthProvider().syncFcmToken(fcmToken);
      } catch (e) {
        debugPrint("Gagal sinkron FCM saat Home load: $e");
      }
    }

    // Connect to SignalR
    _signalRClient.initConnection();
    await _signalRClient.startConnection();
    if (_storeId != null) {
      await _signalRClient.joinStoreGroup(_storeId!);
      _signalRClient.listenToDashboardUpdates(() {
        // Silent refresh on update
        refreshData(silent: true);
      });
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
          _fetchUnreadCount();
        }
      });
    }
  }

  Future<void> refreshData({bool silent = false}) async {
    if (!silent) {
      isLoading.value = true;
      orderList.clear();
      dashboardStats.value = null;
    }
    
    if (_storeId != null) {
      debugPrint("refreshData: using storeId = $_storeId");
      
      // Ambil profil toko terbaru
      final storeResponse = await _storeProvider.getStoreProfile();
      if (storeResponse.success && storeResponse.data != null) {
        storeName.value = storeResponse.data!.name;
        storeImageUrl.value = storeResponse.data!.storeImageUrl;
      }
      // 1. Ambil data pesanan
      final orderResponse = await _orderProvider.getStoreOrders(_storeId!);
      if (orderResponse.success && orderResponse.data != null) {
        orderList.assignAll(orderResponse.data!);
        debugPrint("refreshData: orderList updated, length = ${orderList.length}");
      } else {
        debugPrint("Failed to fetch orderList: ${orderResponse.message}");
      }

      // 2. Ambil data statistik dashboard (Hanya hari ini)
      final statsResponse = await _storeProvider.getStoreTransactions(_storeId!);
      if (statsResponse.success && statsResponse.data != null) {
        dashboardStats.value = statsResponse.data;
        debugPrint("refreshData: dashboardStats updated = ${statsResponse.data?.totalOrders}");
      } else {
        debugPrint("Failed to fetch dashboardStats: ${statsResponse.message}");
      }
    } else {
      debugPrint("refreshData: _storeId is null!");
    }
    await _fetchUnreadCount();
    lastUpdated.value = DateFormat('dd-MM-yyyy | HH:mm').format(DateTime.now());
    if (!silent) isLoading.value = false;
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final NotificationProvider notifProvider = NotificationProvider();
      final response = await notifProvider.getUnreadCount();
      if (response.success && response.data != null) {
        unreadNotificationCount.value = response.data!;
      }
    } catch (e) {
      debugPrint("Failed to fetch unread notifications count: $e");
    }
  }

  @override
  void onClose() {
    if (_storeId != null) {
      _signalRClient.leaveStoreGroup(_storeId!);
    }
    _signalRClient.stopListeningToDashboardUpdates();
    scrollController.dispose();
    super.onClose();
  }
}
