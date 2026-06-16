import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import 'package:maunyuci_customer/app/data/model/transaction/transaction_response_model.dart';
import '../../../core/helpers/api_error_helper.dart';
import '../../../data/model/order/order_history_model.dart';
import '../../../data/model/transaction/transaction_model.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../data/services/transaction_service.dart';

class HomeController extends GetxController {
  final UserProvider _userProvider = UserProvider();
  final TransactionService _transactionService = TransactionService();
  
  var selectedIndex = 0.obs;
  var userName = 'User'.obs;
  var tabIndex = 0.obs;
  var isLoading = true.obs;
  
  var userAddress = 'Belum ada alamat'.obs;
  var userLatitude = Rxn<double>();
  var userLongitude = Rxn<double>();
  
  var currentTransactions = <TransactionResponseModel>[].obs;
  var orderHistory = <TransactionResponseModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _loadTransactionData();
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
      final errorMessage = handleApiError(e.response?.data);
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
}