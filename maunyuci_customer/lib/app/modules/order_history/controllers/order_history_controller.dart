import 'package:get/get.dart';
import '../../../data/model/transaction/transaction_response_model.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../core/widgets/custom_snackbar.dart';

class OrderHistoryController extends GetxController {
  final TransactionRepository _repository = TransactionRepository();

  final selectedFilter = 'Semua'.obs;
  final filters = ['Semua', '1 Minggu', '3 Bulan', 'Status'];

  final orderStatuses = [
    'Menunggu',
    'Pesanan Dibatalkan',
    'Sedang Dijemput',
    'Sedang Diantar',
    'Konfirmasi',
    'Proses',
    'Selesai'
  ];
  final paymentStatuses = ['Belum Dibayar', 'Selesai'];

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
        CustomSnackbar.showError('Error', errorMessage);
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

  String _mapIndoToEnum(String idn) {
    switch (idn) {
      case 'Menunggu':
        return 'Pending';
      case 'Proses':
        return 'Washing';
      case 'Sedang Dijemput':
        return 'PickingUp';
      case 'Sedang Diantar':
        return 'Delivering';
      case 'Konfirmasi':
        return 'Confirmed';
      case 'Selesai':
        return 'Completed';
      case 'Pesanan Dibatalkan':
        return 'Cancelled';
      default:
        return idn;
    }
  }
  
  String _mapPaymentStatus(String idn) {
    switch (idn) {
      case 'Belum Dibayar':
        return 'Unpaid';
      case 'Selesai':
        return 'Paid';
      default:
        return idn;
    }
  }
}