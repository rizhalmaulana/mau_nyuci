import 'package:get/get.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../data/providers/analytics_provider.dart';
import '../../../data/services/storage_service.dart';

class AnalyticsController extends GetxController {
  final AnalyticsProvider _provider = AnalyticsProvider();
  final StorageService _storageService = Get.find<StorageService>();

  final isLoading = true.obs;
  final isPremium = true.obs;
  final revenue = 0.0.obs;
  final expense = 0.0.obs;
  final netProfit = 0.0.obs;
  final orderCount = 0.obs;
  final averageOrderValue = 0.0.obs;

  final topSellingServices = <Map<String, dynamic>>[].obs;
  final revenueTrend = <Map<String, dynamic>>[].obs;
  final expenseTrend = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _checkMembershipAndFetch();
  }

  Future<void> _checkMembershipAndFetch() async {
    final tier = await _storageService.read('membership_tier');
    if (tier != 'Premium') {
      isPremium.value = false;
      isLoading.value = false;
      return;
    }
    isPremium.value = true;
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    isLoading.value = true;
    try {
      final response = await _provider.getSummary();
      if (!response.success) {
        if (response.statusCode == 403) {
          isPremium.value = false;
          return;
        }
        CustomSnackbar.showError('Error', response.message ?? 'Gagal memuat analitik');
        return;
      }

      final data = response.data ?? <String, dynamic>{};

      revenue.value = (data['totalRevenue'] ?? 0).toDouble();
      expense.value = (data['totalExpense'] ?? 0).toDouble();
      netProfit.value = (data['netProfit'] ?? 0).toDouble();
      orderCount.value = data['orderCount'] ?? 0;
      averageOrderValue.value = (data['averageOrderValue'] ?? 0).toDouble();

      if (data['topSellingServices'] != null) {
        topSellingServices.value = List<Map<String, dynamic>>.from(data['topSellingServices']);
      }
      if (data['revenueTrend'] != null) {
        revenueTrend.value = List<Map<String, dynamic>>.from(data['revenueTrend']);
      }
      if (data['expenseTrend'] != null) {
        expenseTrend.value = List<Map<String, dynamic>>.from(data['expenseTrend']);
      }
    } catch (e) {
      CustomSnackbar.showError('Error', e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }
}
