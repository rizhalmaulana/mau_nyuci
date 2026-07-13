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

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
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

  Future<void> fetchOrders() async {
    try {
      isLoading(true);
      final data = await _repository.getCustomerOrders();
      data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      allOrders.assignAll(data);
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      CustomSnackbar.showError('Error', 'Gagal memuat riwayat pesanan: $errorMessage');
    } finally {
      isLoading(false);
    }
  }

  List<TransactionResponseModel> get filteredOrders {
    final now = DateTime.now();

    if (selectedFilter.value == 'Semua') {
      return allOrders;
    } else if (selectedFilter.value == '1 Minggu') {
      final oneWeekAgo = now.subtract(const Duration(days: 7));
      return allOrders.where((order) => order.createdAt.isAfter(oneWeekAgo)).toList();
    } else if (selectedFilter.value == '3 Bulan') {
      final threeMonthsAgo = now.subtract(const Duration(days: 90));
      return allOrders.where((order) => order.createdAt.isAfter(threeMonthsAgo)).toList();
    } else if (selectedFilter.value == 'Status') {
      return allOrders.where((order) {
        bool matchOrder = true;
        if (appliedOrderStatuses.isNotEmpty) {
          matchOrder = appliedOrderStatuses.any((status) =>
              order.status.toLowerCase() == status.toLowerCase() ||
              _mapStatus(status).toLowerCase() == order.status.toLowerCase());
        }

        bool matchPayment = true;
        if (appliedPaymentStatus.value != null) {
          matchPayment = order.paymentStatus.toLowerCase() ==
                  appliedPaymentStatus.value!.toLowerCase() ||
              _mapPaymentStatus(appliedPaymentStatus.value!).toLowerCase() ==
                  order.paymentStatus.toLowerCase();
        }

        return matchOrder && matchPayment;
      }).toList();
    }
    return allOrders;
  }

  String _mapStatus(String idn) {
    switch (idn) {
      case 'Menunggu':
        return 'Pending';
      case 'Proses':
        return 'Washing';
      case 'Konfirmasi':
        return 'Confirmed';
      case 'Selesai':
        return 'Completed';
      case 'Pesanan Dibatalkan':
        return 'Canceled';
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