import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/models/expense_model.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/utils/thousand_separator_input_formatter.dart';
import '../../../core/widgets/premium_paywall_widget.dart';
import '../controllers/expense_controller.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_confirm_modal.dart';

class ExpenseView extends GetView<ExpenseController> {
  const ExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ExpenseController>()) {
      Get.put(ExpenseController());
    }

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text('Pencatatan Pengeluaran', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(18), color: AppColors.black)),
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              controller.setupForm();
              _showExpenseFormBottomSheet(context);
            },
          )
        ],
      ),
      body: Obx(() {
        if (!controller.isPremium.value) {
          return const PremiumPaywallWidget();
        }

        return Column(
          children: [
            _buildDateFilter(context),
            Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.expenses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined, size: R.r(64), color: AppColors.textSecondary),
                              SizedBox(height: R.h(16)),
                              Text('Belum ada catatan pengeluaran', style: AppFonts.inter(fontSize: R.sp(16), color: AppColors.textSecondary)),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: controller.fetchExpenses,
                          child: ListView.builder(
                            padding: EdgeInsets.all(R.w(16)),
                            itemCount: controller.expenses.length,
                            itemBuilder: (context, index) {
                              final expense = controller.expenses[index];
                              return _buildExpenseCard(context, expense);
                            },
                          ),
                        ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDateFilter(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(12)),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Filter Tanggal:', style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.bold)),
          InkWell(
            onTap: () async {
              final initialStart = controller.filterStartDate.value ?? DateTime.now().subtract(const Duration(days: 7));
              final initialEnd = controller.filterEndDate.value ?? DateTime.now();
              
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
              );
              if (picked != null) {
                controller.updateDateFilter(picked.start, picked.end);
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(8)),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(R.r(8)),
              ),
              child: Row(
                children: [
                  Icon(Icons.date_range, size: R.r(16), color: AppColors.primary),
                  SizedBox(width: R.w(8)),
                  Text(
                    controller.filterStartDate.value != null && controller.filterEndDate.value != null
                        ? '${DateFormat('dd MMM').format(controller.filterStartDate.value!)} - ${DateFormat('dd MMM yyyy').format(controller.filterEndDate.value!)}'
                        : 'Pilih Tanggal',
                    style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showExpenseFormBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(R.w(24)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(24))),
        ),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(controller.currentEditId == null ? 'Catat Pengeluaran Baru' : 'Edit Pengeluaran', style: AppFonts.inter(fontSize: R.sp(18), fontWeight: FontWeight.bold)),
                SizedBox(height: R.h(24)),
                
                TextFormField(
                  controller: controller.amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [ThousandSeparatorInputFormatter()],
                  decoration: InputDecoration(
                    labelText: 'Nominal Pengeluaran',
                    hintText: 'Misal: 50.000',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
                ),
                SizedBox(height: R.h(16)),

                DropdownButtonFormField<String>(
                  value: controller.categoryController.text.isNotEmpty && controller.categories.contains(controller.categoryController.text) 
                      ? controller.categoryController.text 
                      : 'Lainnya',
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                  items: controller.categories.map((String cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      controller.categoryController.text = val;
                    }
                  },
                ),
                SizedBox(height: R.h(16)),

                TextFormField(
                  controller: controller.descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Catatan / Deskripsi (Opsional)',
                    hintText: 'Misal: Beli deterjen 5 dirigen',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                ),
                SizedBox(height: R.h(16)),

                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: controller.expenseDate.value ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      controller.expenseDate.value = picked;
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(16)),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textSecondary),
                      borderRadius: BorderRadius.circular(R.r(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => Text(
                          controller.expenseDate.value == null 
                            ? 'Pilih Tanggal Pengeluaran' 
                            : 'Tanggal: ${DateFormat('dd MMM yyyy').format(controller.expenseDate.value!)}',
                          style: AppFonts.inter(fontSize: R.sp(14), color: controller.expenseDate.value == null ? AppColors.textSecondary : AppColors.black),
                        )),
                        const Icon(Icons.calendar_today, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: R.h(24)),

                Obx(() => ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : () => controller.saveExpense(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: R.h(16)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                  child: controller.isSubmitting.value
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : Text('Simpan Pengeluaran', style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold, color: AppColors.white)),
                )),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDelete(String id) {
    CustomConfirmModal.show(
      title: 'Hapus Pengeluaran',
      message: 'Apakah Anda yakin ingin menghapus catatan pengeluaran ini?',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmColor: AppColors.softRed,
      icon: Icons.delete_outline,
      onConfirm: () {
        Get.back();
        controller.deleteExpense(id);
      },
    );
  }

  Widget _buildExpenseCard(BuildContext context, ExpenseModel expense) {
    final id = expense.id;
    final amount = expense.amount;
    final category = expense.category;
    final date = expense.expenseDate;

    IconData getCategoryIcon() {
      switch (category.toLowerCase()) {
        case 'listrik': return Icons.bolt;
        case 'air': return Icons.water_drop;
        case 'deterjen': return Icons.local_laundry_service;
        case 'gaji': return Icons.people;
        default: return Icons.receipt;
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: R.h(12)),
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.softRed,
            radius: R.r(24),
            child: Icon(getCategoryIcon(), color: AppColors.white, size: R.r(24)),
          ),
          SizedBox(width: R.w(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold)),
                SizedBox(height: R.h(4)),
                Text(expense.description ?? '-', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '- ${NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(amount)}',
                style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.bold, color: AppColors.softRed),
              ),
              SizedBox(height: R.h(4)),
              Text(
                DateFormat('dd MMM yyyy').format(date),
                style: AppFonts.inter(fontSize: R.sp(10), color: AppColors.textSecondary),
              ),
              SizedBox(height: R.h(8)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      controller.setupForm(existingData: expense);
                      _showExpenseFormBottomSheet(context);
                    },
                    child: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 18),
                  ),
                  SizedBox(width: R.w(12)),
                  InkWell(
                    onTap: () => _confirmDelete(id),
                    child: const Icon(Icons.delete_rounded, color: AppColors.softRed, size: 18),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
