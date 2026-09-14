import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../controllers/home_controller.dart';
import '../../../all_orders/controllers/all_orders_controller.dart';
import '../../../../core/constants/app_colors.dart';

class OrderListItemWidget extends StatelessWidget {
  final OrderModel order;

  const OrderListItemWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed('/order-detail', arguments: order.id)?.then((_) {
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().refreshData(silent: true);
          }
          if (Get.isRegistered<AllOrdersController>()) {
            Get.find<AllOrdersController>().refreshOrders();
          }
        });
      },
      borderRadius: BorderRadius.circular(R.r(12)),
      child: Container(
        margin: EdgeInsets.only(bottom: R.h(12)),
        padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(12)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(12)),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.02),
            blurRadius: R.r(4),
            offset: Offset(0, R.h(2)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tanggal & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: R.sp(14), color: AppColors.deepPurple),
                      SizedBox(width: R.w(8)),
                      Text(
                        DateFormat('dd MMM yyyy').format(order.createdAt),
                        style: TextStyle(fontSize: R.sp(12), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  if (order.expectedCompletionDate != null) ...[
                    SizedBox(height: R.h(4)),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: R.sp(14), color: AppColors.orange),
                        SizedBox(width: R.w(8)),
                        Text(
                          'Estimasi: ${DateFormat('dd MMM yyyy').format(order.expectedCompletionDate!)}',
                          style: TextStyle(fontSize: R.sp(11), color: AppColors.orange700, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
              Row(
                children: [
                  if (order.isLate && (order.status != 'Completed' && order.status != 'Cancelled'))
                    Container(
                      margin: EdgeInsets.only(right: R.w(8)),
                      padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
                      decoration: BoxDecoration(
                        color: AppColors.danger50,
                        borderRadius: BorderRadius.circular(R.r(4)),
                        border: Border.all(color: AppColors.danger200),
                      ),
                      child: Text(
                        'TERLAMBAT',
                        style: TextStyle(color: AppColors.danger700, fontSize: R.sp(10), fontWeight: FontWeight.bold),
                      ),
                    ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
                    decoration: BoxDecoration(
                      color: AppColors.success50,
                      borderRadius: BorderRadius.circular(R.r(4)),
                    ),
                    child: Text(
                      OrderTranslation.translateOrderStatus(order.status),
                      style: TextStyle(color: AppColors.success700, fontSize: R.sp(10), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
            ],
          ),
          Divider(height: R.h(24)),
          
          // Nama & No HP Customer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  (order.guestCustomerName?.isNotEmpty == true) ? order.guestCustomerName! : order.customerName,
                  style: TextStyle(fontSize: R.sp(14), fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if ((order.guestCustomerPhone?.isNotEmpty == true) || (order.customerPhone?.isNotEmpty == true)) ...[
                SizedBox(width: R.w(8)),
                Row(
                  children: [
                    Icon(Icons.phone, size: R.sp(12), color: AppColors.grey600),
                    SizedBox(width: R.w(4)),
                    Text(
                      (order.guestCustomerPhone?.isNotEmpty == true) ? order.guestCustomerPhone! : order.customerPhone!,
                      style: TextStyle(fontSize: R.sp(12), color: AppColors.grey600),
                    ),
                  ],
                ),
              ],
            ],
          ),
          SizedBox(height: R.h(8)),
          
          // Informasi ID dan Total Berat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#${order.id.split('-').first.toUpperCase()}', style: TextStyle(fontSize: R.sp(12), color: AppColors.grey500, fontWeight: FontWeight.bold)),
              Text(
                'Total Berat: ${order.totalQuantity ?? '-'} Kg',
                style: TextStyle(fontSize: R.sp(12), fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: R.h(12)),
          
          // List of Items
          if (order.itemsSummary != null && order.itemsSummary!.isNotEmpty)
            ...order.itemsSummary!.map((item) => Container(
              margin: EdgeInsets.only(bottom: R.h(8)),
              padding: EdgeInsets.all(R.w(8)),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(R.r(8)),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Row(
                children: [
                  Container(
                    width: R.w(36),
                    height: R.h(36),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(R.r(6)),
                    ),
                    child: (item.itemImageUrl != null && item.itemImageUrl!.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(R.r(6)),
                            child: Image.network(
                              '${ApiConstants.cloudflareCatalogIconUrl}${item.itemImageUrl}',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.local_laundry_service, color: AppColors.purple300, size: R.sp(18)),
                            ),
                          )
                        : Icon(Icons.local_laundry_service, color: AppColors.purple300, size: R.sp(18)),
                  ),
                  SizedBox(width: R.w(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.itemName,
                          style: TextStyle(fontSize: R.sp(12), fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: R.h(2)),
                        Text(
                          '${item.quantity} ${item.unit} x ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(item.unitPrice)}',
                          style: TextStyle(fontSize: R.sp(11), color: AppColors.grey600),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )).toList()
          else
            Text('-', style: TextStyle(color: AppColors.grey500)),
            
          SizedBox(height: R.h(8)),
          
          // Footer: Berat & Harga
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pembayaran: ${OrderTranslation.translatePaymentStatus(order.paymentStatus)}',
                style: TextStyle(fontSize: R.sp(12), fontWeight: FontWeight.w600),
              ),
              Text(
                NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(order.totalAmount),
                style: TextStyle(fontSize: R.sp(14), fontWeight: FontWeight.bold, color: AppColors.deepPurple),
              ),
            ],
          )
        ],
      ),
    ));
  }
}
