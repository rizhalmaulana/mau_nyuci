import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_shimmer.dart';
import '../../home/views/widgets/order_list_item_widget.dart';
import '../controllers/all_orders_controller.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

class AllOrdersView extends GetView<AllOrdersController> {
  const AllOrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text('Pesanan Aktif', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(16))),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
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
              children: [
                // Search Bar Modern
                TextField(
                  controller: controller.searchController,
                  onChanged: controller.onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Cari nama, no hp, atau ID pesanan...',
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
                SizedBox(height: R.h(16)),
                // Horizontal Status Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: controller.statusFilters.map((status) {
                      return Obx(() {
                        final isSelected = controller.selectedStatus.value == status;
                        return Padding(
                          padding: EdgeInsets.only(right: R.w(8)),
                          child: ChoiceChip(
                            label: Text(
                              controller.statusLabels[status] ?? status,
                              style: TextStyle(
                                color: isSelected ? AppColors.white : AppColors.grey700,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: R.sp(12),
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                controller.setStatusFilter(status);
                              }
                            },
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.grey100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(R.r(20)),
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : AppColors.grey300,
                              ),
                            ),
                          ),
                        );
                      });
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // List of Active Orders
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return ListView.builder(
                  padding: EdgeInsets.all(R.w(16)),
                  itemCount: 5,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(bottom: R.h(12)),
                    child: CustomShimmer.listOrder(),
                  ),
                );
              }

              final filteredOrders = controller.filteredOrders;
              
              if (filteredOrders.isEmpty) {
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
                        'Belum ada pesanan aktif',
                        style: TextStyle(color: AppColors.grey600, fontSize: R.sp(14)),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshOrders,
                color: AppColors.primary,
                child: ListView.builder(
                  padding: EdgeInsets.all(R.w(16)),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
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
