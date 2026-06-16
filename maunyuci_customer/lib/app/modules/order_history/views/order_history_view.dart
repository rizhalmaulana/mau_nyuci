import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_customer/app/core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/transactions/order_item_card.dart';
import '../controllers/order_history_controller.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Riwayat',
          style: AppFonts.fInterSubheadingSemibold.copyWith(
            color: AppColors.black,
            fontSize: R.sp(20),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterList(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredOrders.isEmpty) {
                return Center(
                  child: Text(
                    "Belum ada riwayat transaksi.",
                    style: AppFonts.fInterBodyMedium.copyWith(color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(R.r(16)),
                itemCount: controller.filteredOrders.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: R.r(16)),
                    child: OrderItemCard(transaction: controller.filteredOrders[index]),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterList() {
    return Container(
      height: R.h(60),
      padding: EdgeInsets.symmetric(vertical: R.h(10)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: R.w(16)),
        itemCount: controller.filters.length,
        itemBuilder: (context, index) {
          final filter = controller.filters[index];
          return Obx(() {
            bool isSelected = controller.selectedFilter.value == filter;
            return GestureDetector(
              onTap: () {
                if (filter == 'Status') {
                  _showFilterBottomSheet(context);
                } else {
                  controller.selectedFilter.value = filter;
                }
              },
              child: Container(
                margin: EdgeInsets.only(right: R.r(8)),
                padding:
                    EdgeInsets.symmetric(horizontal: R.w(20), vertical: R.h(8)),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF7E57C2) : Colors.white,
                  borderRadius: BorderRadius.circular(R.r(10)),
                  border: Border.all(
                    color:
                        isSelected ? Colors.transparent : Colors.grey.shade400,
                  ),
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: AppFonts.fInterStatusRegular.copyWith(
                      color: isSelected ? AppColors.white : AppColors.black,
                      fontSize: R.sp(14),
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    controller.openFilterBottomSheet();
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.only(
          left: R.w(24),
          right: R.w(24),
          top: R.h(24),
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(24))),
        ),
        child: SafeArea(
          bottom: true,
          child: Padding(
            padding: EdgeInsets.only(bottom: R.h(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: R.w(40),
                    height: R.h(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(R.r(2)),
                    ),
                  ),
                ),
                SizedBox(height: R.h(16)),
                Center(
                  child: Text(
                    'Filter Status',
                    style: AppFonts.fInterSubheadingSemibold.copyWith(fontSize: R.sp(16)),
                  ),
                ),
                SizedBox(height: R.h(24)),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status Order',
                          style: AppFonts.fInterBodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: R.h(8)),
                        ...controller.orderStatuses.map((status) => Obx(() {
                              bool isChecked = controller.tempOrderStatuses.contains(status);
                              return Theme(
                                data: ThemeData(
                                  unselectedWidgetColor: Colors.grey.shade400,
                                ),
                                child: CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    status,
                                    style: AppFonts.fInterBodyMedium,
                                  ),
                                  value: isChecked,
                                  activeColor: const Color(0xFF7E57C2),
                                  checkboxShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(R.r(4)),
                                  ),
                                  controlAffinity: ListTileControlAffinity.trailing,
                                  onChanged: (bool? value) {
                                    controller.toggleTempOrderStatus(status);
                                  },
                                ),
                              );
                            })),
                        Divider(height: R.h(24)),
                        Text(
                          'Status Pembayaran',
                          style: AppFonts.fInterBodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: R.h(8)),
                        ...controller.paymentStatuses.map((status) => Obx(() {
                              return Theme(
                                data: ThemeData(
                                  unselectedWidgetColor: Colors.grey.shade400,
                                ),
                                child: RadioListTile<String>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    status,
                                    style: AppFonts.fInterBodyMedium,
                                  ),
                                  value: status,
                                  groupValue: controller.tempPaymentStatus.value,
                                  activeColor: AppColors.primary,
                                  controlAffinity: ListTileControlAffinity.trailing,
                                  onChanged: (String? value) {
                                    if (value != null) {
                                      controller.setTempPaymentStatus(value);
                                    }
                                  },
                                ),
                              );
                            })),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: R.h(24)),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.resetFilter,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: EdgeInsets.symmetric(vertical: R.h(16)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                        ),
                        child: Text(
                          'Reset',
                          style: AppFonts.fInterBodyMedium.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(width: R.w(16)),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.applyFilter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7E57C2),
                          padding: EdgeInsets.symmetric(vertical: R.h(16)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                          elevation: 0,
                        ),
                        child: Text(
                          'Terapkan',
                          style: AppFonts.fInterBodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: true,
      enterBottomSheetDuration: const Duration(milliseconds: 400),
      exitBottomSheetDuration: const Duration(milliseconds: 300),
    );
  }
}
