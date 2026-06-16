import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:maunyuci_customer/app/data/model/transaction/transaction_response_model.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_fonts.dart';
import '../../constants/app_assets.dart';
import '../../utils/responsive_helper.dart';

class OrderItemCard extends StatelessWidget {
  final TransactionResponseModel transaction;

  const OrderItemCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(R.r(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    AppAssets.iconCalendar,
                    width: R.r(16),
                    height: R.r(16),
                    colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                  ),
                  SizedBox(width: R.w(8)),
                  Text(
                    DateFormat('dd MMM yyyy').format(transaction.createdAt),
                    style: AppFonts.fInterCaptionMedium,
                  ),
                ],
              ),
              _buildStatusBadge(transaction.status),
            ],
          ),
          const Divider(),
          SizedBox(height: R.h(8)),
          Text(
            transaction.storeName,
            style: AppFonts.fInterBodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: R.h(12)),
          Row(
            children: [
              Image.asset(
                AppAssets.imgLaundryItem,
                width: R.r(48),
                height: R.r(48),
              ),
              SizedBox(width: R.w(12)), // Perbaikan dari height ke width
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${transaction.id.substring(0, 8).toUpperCase()}', // Menampilkan potongan ID sebagai Order No
                      style: AppFonts.fInterCaptionRegular.copyWith(color: AppColors.textSecondary),
                    ),
                    SizedBox(height: R.h(2)),
                    Text(
                      _getServiceNames(transaction),
                      style: AppFonts.fInterBodySmallMedium.copyWith(color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: R.h(2)),
                    Text(
                      '${transaction.deliveryType} • ${transaction.paymentMethod}',
                      style: AppFonts.fInterCaptionRegular.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Berat: ${_calculateWeight(transaction)}',
                    style: AppFonts.fInterBodySmallMedium.copyWith(color: AppColors.textPrimary),
                  ),
                  SizedBox(height: R.h(4)),
                  Text(
                    transaction.expectedCompletionDate != null
                        ? 'Est: ${DateFormat('dd MMM').format(transaction.expectedCompletionDate!)}'
                        : 'Menunggu konfirmasi',
                    style: AppFonts.fInterCaptionRegular.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              Text(
                'Rp${NumberFormat('#,###').format(transaction.totalAmount)}',
                style: AppFonts.fInterBodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    switch (status.toLowerCase()) {
      case 'pending': badgeColor = Colors.orange; break;
      case 'washing': badgeColor = Colors.blue; break;
      case 'readyforpickup': badgeColor = Colors.purple; break;
      case 'completed': badgeColor = Colors.green; break;
      default: badgeColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(4)),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(R.r(16)),
      ),
      child: Text(
        status,
        style: AppFonts.fInterCaptionMedium.copyWith(color: badgeColor),
      ),
    );
  }

  String _calculateWeight(TransactionResponseModel tx) {
    double totalWeight = 0;
    for (var item in tx.items) {
      if (item.unit.toLowerCase() == 'kg') {
        totalWeight += item.quantity;
      }
    }
    return totalWeight > 0 ? '$totalWeight Kg' : '-';
  }

  String _getServiceNames(TransactionResponseModel tx) {
    if (tx.items.isEmpty) return 'Layanan Reguler';
    return tx.items.map((e) => e.itemName).join(', ');
  }
}