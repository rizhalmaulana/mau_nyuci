import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_shimmer.dart';
import '../../home/views/widgets/order_list_item_widget.dart';
import '../controllers/history_orders_controller.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

class HistoryOrdersView extends GetView<HistoryOrdersController> {
  const HistoryOrdersView({super.key});

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text('Riwayat Pesanan', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(18))),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: EdgeInsets.all(R.w(16)),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.searchController,
                        onChanged: controller.onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Cari nama atau ID pesanan...',
                          hintStyle: TextStyle(color: AppColors.grey400, fontSize: R.sp(14)),
                          prefixIcon: Icon(Icons.search, color: AppColors.grey400),
                          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: AppColors.grey500),
                                  onPressed: () {
                                    controller.searchController.clear();
                                    controller.onSearchChanged('');
                                  },
                                )
                              : const SizedBox.shrink()),
                          filled: true,
                          fillColor: AppColors.grey100,
                          contentPadding: EdgeInsets.symmetric(vertical: R.h(12)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(R.r(12)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: R.w(12)),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(R.r(12)),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.calendar_month, color: AppColors.primary),
                        onPressed: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.primary,
                                    onPrimary: AppColors.white,
                                    onSurface: AppColors.black,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            controller.setDateRange(picked.start, picked.end);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  if (controller.startDate.value != null && controller.endDate.value != null) {
                    return Padding(
                      padding: EdgeInsets.only(top: R.h(12)),
                      child: InputChip(
                        label: Text(
                          "${_formatDate(controller.startDate.value!)} - ${_formatDate(controller.endDate.value!)}",
                          style: TextStyle(fontSize: R.sp(12), color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                        onDeleted: controller.clearDateRange,
                        deleteIconColor: AppColors.primary,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(R.r(20)),
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
          
          Expanded(
            child: Obx(() {
              if (controller.historyOrders.isEmpty && controller.isHistoryLoading.value) {
                return ListView.builder(
                  padding: EdgeInsets.all(R.w(16)),
                  itemCount: 5,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(bottom: R.h(12)),
                    child: CustomShimmer.listOrder(),
                  ),
                );
              }

              if (controller.historyOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAssets.imgEmptyRiwayat,
                        width: R.r(140),
                        height: R.r(140),
                      ),
                      SizedBox(height: R.h(8)),
                      Text(
                        (controller.searchQuery.value.isNotEmpty || controller.startDate.value != null)
                          ? 'Riwayat pesanan tidak ditemukan' 
                          : 'Belum ada riwayat pesanan',
                        style: TextStyle(color: AppColors.grey600, fontSize: R.sp(14)),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshHistory,
                color: AppColors.primary,
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: EdgeInsets.all(R.w(16)),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: controller.historyOrders.length + (controller.hasMoreHistory.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.historyOrders.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: R.h(16)),
                        child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      );
                    }
                    final order = controller.historyOrders[index];
                    return OrderListItemWidget(order: order);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
