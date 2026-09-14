import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/providers/order_provider.dart';
import '../../../core/constants/app_colors.dart';

class AllOrdersController extends GetxController {
  final StorageService _storageService = Get.find();
  final OrderProvider _orderProvider = OrderProvider();
  
  var isLoading = false.obs;
  
  // Semua order dari API
  final _allOrders = <OrderModel>[].obs;
  
  // State untuk filter dan search
  final selectedStatus = 'Semua'.obs;
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  final List<String> statusFilters = ['Semua', 'Pending', 'Washing', 'Ready'];
  final Map<String, String> statusLabels = {
    'Semua': 'Semua',
    'Pending': 'Menunggu',
    'Washing': 'Dicuci',
    'Ready': 'Siap Ambil',
  };

  @override
  void onInit() {
    super.onInit();
    
    // Cek arguments dari Home (bila user klik status kotak ungu)
    if (Get.arguments != null && Get.arguments is Map) {
      final initialStatus = Get.arguments['initialStatus'];
      if (initialStatus != null && statusFilters.contains(initialStatus)) {
        selectedStatus.value = initialStatus;
      }
    }
    
    _fetchOrders();
  }
  
  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> _fetchOrders() async {
    isLoading.value = true;
    try {
      final storeId = await _storageService.read('storeId');
      if (storeId != null) {
        final response = await _orderProvider.getStoreOrders(storeId);
        if (response.success && response.data != null) {
          _allOrders.assignAll(response.data!);
        } else {
          Get.snackbar('Gagal', response.message ?? 'Gagal memuat orderan',
              snackPosition: SnackPosition.TOP, backgroundColor: AppColors.danger, colorText: AppColors.white);
        }
      }
    } catch (e) {
      debugPrint("Error _fetchOrders: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders() async {
    await _fetchOrders();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void setStatusFilter(String status) {
    selectedStatus.value = status;
  }

  // Getter yang komputasi list terfilter secara real-time
  List<OrderModel> get filteredOrders {
    var list = _allOrders.toList();
    
    // Filter berdasarkan status
    if (selectedStatus.value != 'Semua') {
      list = list.where((order) {
        final orderStatus = order.status.toLowerCase();
        final selected = selectedStatus.value.toLowerCase();
        
        // Handle ReadyForPickup
        if (selected == 'ready' && (orderStatus == 'readyforpickup' || orderStatus == 'ready')) {
          return true;
        }
        
        return orderStatus == selected;
      }).toList();
    }
    
    // Filter berdasarkan pencarian (ID Pesanan atau Nama Pelanggan atau Telepon Pelanggan)
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      list = list.where((order) {
        final nameMatch = order.customerName.toLowerCase().contains(query);
        final guestNameMatch = (order.guestCustomerName ?? '').toLowerCase().contains(query);
        final guestPhoneMatch = (order.guestCustomerPhone ?? '').toLowerCase().contains(query);
        final phoneMatch = (order.customerPhone ?? '').toLowerCase().contains(query);
        final idMatch = order.id.toLowerCase().contains(query);
        
        return nameMatch || guestNameMatch || guestPhoneMatch || phoneMatch || idMatch;
      }).toList();
    }
    
    return list;
  }
}
