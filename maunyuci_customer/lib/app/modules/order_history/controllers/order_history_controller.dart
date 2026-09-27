import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/model/transaction/transaction_response_model.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../core/widgets/custom_snackbar.dart';

class OrderHistoryController extends GetxController {
  final TransactionRepository _repository = TransactionRepository();

  final selectedFilter = 'Semua'.obs;
  final filters = ['Semua', '1 Minggu', '3 Bulan', 'Status'];

  /// Opsi filter status — label manusiawi dari mapping terpusat.
  /// Urutan mengikuti alur: Pending -> ... -> Completed, Cancelled terakhir.
  List<String> get orderStatuses => OrderDisplay.customerFilterLabels;
  List<String> get paymentStatuses => const ['Belum Bayar', 'Lunas'];

  final appliedOrderStatuses = <String>[].obs;
  final appliedPaymentStatus = RxnString();

  final tempOrderStatuses = <String>[].obs;
  final tempPaymentStatus = RxnString();

  final isLoading = true.obs;
  final allOrders = <TransactionResponseModel>[].obs;
  
  int currentPage = 1;
  final int limit = 15;
  var hasMoreData = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders(isRefresh: false);
  }

  void openFilterBottomSheet() {
    tempOrderStatuses.assignAll(appliedOrderStatuses);
    tempPaymentStatus.value = appliedPaymentStatus.value;
  }

  void applyFilter() {
    appliedOrderStatuses.assignAll(tempOrderStatuses);
    appliedPaymentStatus.value = tempPaymentStatus.value;
    selectedFilter.value = 'Status';
    Get.back();
  }

  void resetFilter() {
    tempOrderStatuses.clear();
    tempPaymentStatus.value = null;
  }

  void toggleTempOrderStatus(String status) {
    if (tempOrderStatuses.contains(status)) {
      tempOrderStatuses.remove(status);
    } else {
      tempOrderStatuses.add(status);
    }
  }

  void setTempPaymentStatus(String status) {
    tempPaymentStatus.value = status;
  }

  Future<void> fetchOrders({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage = 1;
        hasMoreData.value = true;
      }
      
      if (!hasMoreData.value && !isRefresh) return;
      
      if (currentPage == 1) isLoading(true);

      String? statusQuery;
      if (selectedFilter.value == 'Status' && appliedOrderStatuses.isNotEmpty) {
        statusQuery = _mapIndoToEnum(appliedOrderStatuses.first);
      }

      final data = await _repository.getCustomerOrders(
        page: currentPage,
        limit: limit, // Limit di repository akan diteruskan sebagai pageSize di provider
        status: statusQuery,
        dateFilter: selectedFilter.value != 'Status' ? selectedFilter.value : null,
      );
      
      if (data.length < limit) {
        hasMoreData.value = false;
      }
      
      if (isRefresh || currentPage == 1) {
        allOrders.assignAll(data);
      } else {
        allOrders.addAll(data);
      }
      currentPage++;
    } catch (e) {
      if (isRefresh) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        CustomSnackbar.showError('Mohon Maaf', errorMessage);
      }
    } finally {
      isLoading(false);
    }
  }

  void loadNextPage() {
    if (!isLoading.value && hasMoreData.value) {
      fetchOrders();
    }
  }

  List<TransactionResponseModel> get filteredOrders => allOrders;

  /// Label manusiawi -> nilai backend untuk query API.
  /// Pakai reverse-lookup mapping terpusat agar tidak kedaluwarsa
  /// saat backend menambah status baru.
  String _mapIndoToEnum(String label) {
    return OrderDisplay.valueForCustomerLabel(label) ?? label;
  }

  String _mapPaymentStatus(String label) {
    switch (label.trim().toLowerCase()) {
      case 'belum bayar':
      case 'belum dibayar':
        return 'Unpaid';
      case 'lunas':
      case 'selesai':
        return 'Paid';
      default:
        return label;
    }
  }
}