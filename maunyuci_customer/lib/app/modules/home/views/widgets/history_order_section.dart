import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/widgets/transactions/order_item_card.dart';
import '../../controllers/home_controller.dart';

class HistoryOrderSection extends GetView<HomeController> {
  const HistoryOrderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat',
                    style: AppFonts.fInterSubheadingSemibold.copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: R.h(4)),
                  Text(
                    'pesanan terakhirmu ada di sini.',
                    style: AppFonts.fInterCaptionRegular.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to all orders
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(6)),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(R.r(20)),
                  ),
                  child: Text(
                    'Lihat Semua',
                    style: AppFonts.fInterCaptionRegular.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(16)),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.orderHistory.isEmpty) {
              return _buildEmptyState();
            }
            return _buildOrderList();
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.r(24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppAssets.imgEmptyRiwayat,
            width: R.r(80),
            height: R.r(80),
            fit: BoxFit.contain,
          ),
          Text(
            'Belum ada riwayat transaksi',
            style: AppFonts.fInterBodySmallMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: R.h(4)),
          Text(
            'Riwayat pesananmu akan muncul di sini',
            style: AppFonts.fInterCaptionRegular.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.orderHistory.length > 3 ? 3 : controller.orderHistory.length, // Batasi 3 saja di Home
      separatorBuilder: (context, index) => SizedBox(height: R.h(16)),
      itemBuilder: (context, index) {
        final order = controller.orderHistory[index];
        return OrderItemCard(transaction: order);
      },
    );
  }
}
