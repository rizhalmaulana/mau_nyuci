import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/widgets/transactions/order_item_card.dart';
import '../../controllers/home_controller.dart';

class ActiveTransactionSection extends GetView<HomeController> {
  const ActiveTransactionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(24)),
      child: Container(
        padding: EdgeInsets.all(R.r(16)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.r(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaksi Berjalan',
                  style: AppFonts.fInterSubheadingSemibold.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to all transactions
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(6)),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(R.r(20)),
                    ),
                    child: Text(
                      'Lihat Semua',
                      style: AppFonts.fInterCaptionMedium.copyWith(color: AppColors.primary),
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

              if (controller.currentTransactions.isEmpty) {
                return _buildEmptyState();
              }

              return _buildTransactionList();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppAssets.imgEmptyTransaksi,
            width: R.r(70),
            height: R.r(70),
            fit: BoxFit.contain,
          ),
          Text(
            'Belum ada transaksi berjalan',
            style: AppFonts.fInterBodySmallMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: R.h(4)),
          Text(
            'Yuk mulai transaksi pertama kamu.',
            style: AppFonts.fInterCaptionRegular.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    bool hasWarning = controller.currentTransactions.any((o) => o.status == 'AwaitingPayment');

    return Column(
      children: [
        if (hasWarning) ...[
          Container(
            padding: EdgeInsets.all(R.r(12)),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(R.r(8)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info, color: Colors.orange, size: R.r(20)),
                SizedBox(width: R.w(8)),
                Expanded(
                  child: Text(
                    'Ada Transaksi yang butuh konfirmasi kamu nih, Lihat Transaksi Lainnya ya',
                    style: AppFonts.fInterCaptionRegular.copyWith(
                      color: Colors.orange.shade800,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: R.h(16)),
        ],

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.currentTransactions.length,
          separatorBuilder: (context, index) => SizedBox(height: R.h(16)),
          itemBuilder: (context, index) {
            final order = controller.currentTransactions[index];
            return OrderItemCard(transaction: order);
          },
        )
      ],
    );
  }
}
