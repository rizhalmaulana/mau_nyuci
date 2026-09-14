import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../core/utils/thousand_separator_input_formatter.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/providers/expense_provider.dart';
import '../../../data/models/expense_model.dart';

class ExpenseController extends GetxController {
  final ExpenseProvider _expenseProvider = ExpenseProvider();
  final StorageService _storageService = Get.find<StorageService>();
  
  final isLoading = true.obs;
  final isPremium = true.obs;
  final expenses = <ExpenseModel>[].obs;

  // Filter Date Variables
  final filterStartDate = Rxn<DateTime>(DateTime.now().subtract(const Duration(days: 7)));
  final filterEndDate = Rxn<DateTime>(DateTime.now());

  // Form Variables
  final formKey = GlobalKey<FormState>();
  final categoryController = TextEditingController();
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  final expenseDate = Rxn<DateTime>(DateTime.now());
  
  final isSubmitting = false.obs;
  String? currentEditId;

  final List<String> categories = ['Listrik', 'Air', 'Gaji', 'Bahan Baku', 'Lainnya'];

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
    fetchExpenses();
  }

  Future<void> fetchExpenses() async {
    if (!isPremium.value) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    
    final start = filterStartDate.value?.toIso8601String();
    final end = filterEndDate.value?.toIso8601String();
    final response = await _expenseProvider.getExpenses(startDate: start, endDate: end);
    
    if (response.success && response.data != null) {
      expenses.value = response.data!;
    } else {
      if (response.errorDetails != null && response.errorDetails!['statusCode'] == 403) {
        isPremium.value = false;
      } else {
        CustomSnackbar.showError('Error', response.message ?? 'Gagal mengambil data pengeluaran');
      }
    }
    
    isLoading.value = false;
  }

  void updateDateFilter(DateTime start, DateTime end) {
    filterStartDate.value = start;
    filterEndDate.value = end;
    fetchExpenses();
  }

  void setupForm({ExpenseModel? existingData}) {
    if (existingData != null) {
      currentEditId = existingData.id;
      categoryController.text = existingData.category;
      amountController.text = formatThousand(existingData.amount.toInt().toString());
      descriptionController.text = existingData.description ?? '';
      expenseDate.value = existingData.expenseDate;
    } else {
      currentEditId = null;
      categoryController.text = 'Lainnya';
      amountController.clear();
      descriptionController.clear();
      expenseDate.value = DateTime.now();
    }
  }

  Future<void> saveExpense() async {
    if (!formKey.currentState!.validate()) return;
    if (expenseDate.value == null) {
      CustomSnackbar.showError('Peringatan', 'Tanggal pengeluaran wajib diisi');
      return;
    }

    isSubmitting.value = true;
    
    final payload = {
      "category": categoryController.text.trim(),
      "amount": parseThousand(amountController.text),
      "description": descriptionController.text.trim(),
      "expenseDate": expenseDate.value!.toIso8601String(),
    };

    ApiResponse<ExpenseModel> response;
    if (currentEditId == null) {
      response = await _expenseProvider.addExpense(payload);
    } else {
      response = await _expenseProvider.updateExpense(currentEditId!, payload);
    }

    if (response.success) {
      final isNew = currentEditId == null;
      Get.back(); // tutup bottom sheet dulu, snackbar setelahnya
      fetchExpenses();
      Future.delayed(const Duration(milliseconds: 300), () {
        CustomSnackbar.showSuccess('Berhasil', isNew ? 'Pengeluaran berhasil dicatat' : 'Pengeluaran berhasil diupdate');
      });
    } else {
      CustomSnackbar.showError('Gagal', response.message ?? 'Terjadi kesalahan');
    }
    
    isSubmitting.value = false;
  }

  Future<void> deleteExpense(String id) async {
    final response = await _expenseProvider.deleteExpense(id);
    if (response.success) {
      CustomSnackbar.showSuccess('Berhasil', 'Pengeluaran berhasil dihapus');
      fetchExpenses();
    } else {
      CustomSnackbar.showError('Gagal Menghapus', response.message ?? 'Terjadi kesalahan');
    }
  }

  @override
  void onClose() {
    categoryController.dispose();
    amountController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
