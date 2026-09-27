import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/constants/order_display.dart';
import '../controllers/order_detail_controller.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/responsive_helper.dart';

class OrderDetailView extends GetView<OrderDetailController> {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Detail Pesanan', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(16), color: AppColors.textPrimary)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final order = controller.order.value;
        if (order == null) {
          return Center(
            child: Text('Data pesanan tidak ditemukan.', style: AppFonts.inter(color: AppColors.grey500)),
          );
        }

        final isPending = order.status.toLowerCase() == 'pending';
        final isCourier = order.deliveryType.toLowerCase() == 'courier';
        final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

        return SingleChildScrollView(
          // + inset sistem agar "Total Bayar" paling bawah tidak tertutup
          // tombol navigasi HP (mode 3 tombol).
          padding: EdgeInsets.only(
            left: R.w(16),
            right: R.w(16),
            top: R.w(16),
            bottom: R.w(16) + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ID: ${order.id.split('-').first.toUpperCase()}', 
                          style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey500)),
                        _buildStatusBadge(order.status),
                      ],
                    ),
                    SizedBox(height: R.h(12)),
                    Text(order.storeName, style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold)),
                    SizedBox(height: R.h(4)),
                    Text(DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt),
                        style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey600)),
                  ],
                ),
              ),

              SizedBox(height: R.h(16)),

              // Info Pengiriman
              _buildSectionCard(
                title: 'Informasi Pengiriman',
                child: Column(
                  children: [
                    _buildInfoRow(Icons.local_shipping, 'Tipe', isCourier ? 'Antar-Jemput' : 'Antar Sendiri (Self-Service)'),
                    if (isCourier && order.pickupTimeSlot != null)
                      _buildInfoRow(Icons.schedule, 'Waktu Jemput', order.pickupTimeSlot!),
                    if (isCourier && order.deliveryTimeSlot != null)
                      _buildInfoRow(Icons.update, 'Waktu Antar', order.deliveryTimeSlot!),
                    if (isCourier && order.deliveryAddress != null)
                      _buildInfoRow(Icons.location_on, 'Alamat', order.deliveryAddress!),
                    if (isCourier && order.logisticsNote != null && order.logisticsNote!.isNotEmpty)
                      _buildInfoRow(Icons.note, 'Catatan / Patokan', order.logisticsNote!),
                  ],
                ),
              ),

              // Foto Cucian jika ada
              if (order.customerLaundryImageUrl != null && order.customerLaundryImageUrl!.isNotEmpty) ...[
                SizedBox(height: R.h(16)),
                _buildSectionCard(
                  title: 'Foto Cucian Anda',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(R.r(12)),
                    child: Image.network(
                      order.customerLaundryImageUrl!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 180,
                        color: AppColors.grey200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported, color: AppColors.grey400, size: 40),
                            SizedBox(height: 8),
                            Text('Gagal memuat foto', style: AppFonts.inter(color: AppColors.grey500, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              SizedBox(height: R.h(16)),

              // Ringkasan Pembayaran
              _buildSectionCard(
                title: 'Rincian Pembayaran',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Metode', style: AppFonts.inter(color: AppColors.grey600, fontSize: R.sp(13))),
                        Text(OrderDisplay.paymentMethodLabel(order.paymentMethod), style: AppFonts.inter(fontWeight: FontWeight.w600, fontSize: R.sp(13))),
                      ],
                    ),
                    SizedBox(height: R.h(12)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status Pembayaran', style: AppFonts.inter(color: AppColors.grey600, fontSize: R.sp(13))),
                        Text(OrderDisplay.paymentStatusLabel(order.paymentStatus), 
                          style: AppFonts.inter(
                            fontWeight: FontWeight.w600, 
                            fontSize: R.sp(13),
                            color: order.paymentStatus.toLowerCase() == 'lunas' ? AppColors.success : AppColors.orange700
                          )),
                      ],
                    ),
                    SizedBox(height: R.h(12)),
                    if (order.items != null && order.items!.isNotEmpty) ...[
                      const Divider(),
                      SizedBox(height: R.h(8)),
                      ...order.items!.map((item) => Padding(
                        padding: EdgeInsets.only(bottom: R.h(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('${item.quantity} ${item.unit} x ${item.itemName}', style: AppFonts.inter(color: AppColors.grey600, fontSize: R.sp(13)))),
                            Text(currencyFormat.format(item.subTotal), style: AppFonts.inter(fontSize: R.sp(13))),
                          ],
                        ),
                      )),
                    ],
                    const Divider(),
                    SizedBox(height: R.h(8)),
                    if (order.discountAmount > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Voucher Dipakai', style: AppFonts.inter(color: AppColors.grey600, fontSize: R.sp(13))),
                          Text(order.appliedPromoCode ?? 'Promo', style: AppFonts.inter(fontWeight: FontWeight.w600, fontSize: R.sp(13))),
                        ],
                      ),
                      SizedBox(height: R.h(8)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Diskon', style: AppFonts.inter(color: AppColors.grey600, fontSize: R.sp(13))),
                          Text('- ${currencyFormat.format(order.discountAmount)}', style: AppFonts.inter(fontWeight: FontWeight.w600, fontSize: R.sp(13), color: AppColors.danger)),
                        ],
                      ),
                      SizedBox(height: R.h(8)),
                      const Divider(),
                      SizedBox(height: R.h(8)),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Bayar', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14))),
                        Text(currencyFormat.format(order.totalAmount), style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14), color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),

            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value || controller.order.value == null) return const SizedBox.shrink();
        final order = controller.order.value!;
        final isPending = order.status.toLowerCase() == 'pending';
        final showUpload = order.status.toLowerCase() == 'awaitingpayment' && order.paymentStatus.toLowerCase() != 'lunas';

        if (!isPending && !showUpload) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.all(R.w(16)),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPending)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: controller.showCancelOrderSheet,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                        padding: EdgeInsets.symmetric(vertical: R.h(14)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                      ),
                      child: Text('Batalkan Pesanan', style: AppFonts.inter(fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (isPending && showUpload) SizedBox(height: R.h(12)),
                if (showUpload)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.pickAndUploadReceipt,
                      icon: const Icon(Icons.upload_file, color: AppColors.white),
                      label: Text('Upload Bukti Transfer', style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: R.h(16)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionCard({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title, style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14))),
            SizedBox(height: R.h(12)),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: R.r(18), color: AppColors.primary),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey500)),
                SizedBox(height: R.h(2)),
                Text(value, style: AppFonts.inter(fontSize: R.sp(13), fontWeight: FontWeight.w500, color: AppColors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final badgeColor = Color(OrderDisplay.statusColor(status));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: R.w(10), vertical: R.h(4)),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(R.r(8)),
      ),
      child: Text(
        OrderDisplay.customerLabel(status),
        style: AppFonts.inter(fontSize: R.sp(10), fontWeight: FontWeight.bold, color: badgeColor),
      ),
    );
  }
}
