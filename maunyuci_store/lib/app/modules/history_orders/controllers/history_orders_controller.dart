import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/providers/order_provider.dart';

class HistoryOrdersController extends GetxController {
  final StorageService _storageService = Get.find();
  final OrderProvider _orderProvider = OrderProvider();
  
  // Riwayat orders (Paginasi)
  final historyOrders = <OrderModel>[].obs;
  var isHistoryLoading = false.obs;
  int historyPage = 1;
  final int historyPageSize = 10;
  var hasMoreHistory = true.obs;
  final ScrollController scrollController = ScrollController();
  
  // Search & Filter
  final searchQuery = ''.obs;
  final searchController = TextEditingController();
  Timer? _debounce;
  
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    _fetchHistory(isRefresh: true);
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !isHistoryLoading.value && hasMoreHistory.value) {
      _fetchHistory();
    }
  }

  Future<void> _fetchHistory({bool isRefresh = false}) async {
    if (isRefresh) {
      historyPage = 1;
      hasMoreHistory.value = true;
      historyOrders.clear();
    }
    
    if (!hasMoreHistory.value || isHistoryLoading.value) return;

    isHistoryLoading.value = true;
    try {
      final storeId = await _storageService.read('storeId');
      if (storeId != null) {
        String? startStr = startDate.value != null ? "${startDate.value!.year}-${startDate.value!.month.toString().padLeft(2, '0')}-${startDate.value!.day.toString().padLeft(2, '0')}" : null;
        String? endStr = endDate.value != null ? "${endDate.value!.year}-${endDate.value!.month.toString().padLeft(2, '0')}-${endDate.value!.day.toString().padLeft(2, '0')}" : null;
        
        final response = await _orderProvider.getStoreOrderHistory(
          storeId, 
          historyPage, 
          historyPageSize,
          search: searchQuery.value,
          startDate: startStr,
          endDate: endStr
        );
        if (response.success && response.data != null) {
          final newOrders = response.data!;
          if (newOrders.length < historyPageSize) {
            hasMoreHistory.value = false;
          }
          historyOrders.addAll(newOrders);
          historyPage++;
        }
      }
    } catch (e) {
      debugPrint("Error _fetchHistory: $e");
    } finally {
      isHistoryLoading.value = false;
    }
  }

  Future<void> refreshHistory() async {
    await _fetchHistory(isRefresh: true);
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchQuery.value = query;
      refreshHistory();
    });
  }

  void setDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
    refreshHistory();
  }
  
  void clearDateRange() {
    startDate.value = null;
    endDate.value = null;
    refreshHistory();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
