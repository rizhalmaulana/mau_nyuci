import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/responsive_helper.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../controllers/order_detail_controller.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

class OrderDetailView extends GetView<OrderDetailController> {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text('Detail Pesanan', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(16))),
        centerTitle: true,
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: AppColors.primary),
            onPressed: () => controller.printReceipt(),
            tooltip: 'Cetak Struk',
          ),
          SizedBox(width: R.w(8)),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.order.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final order = controller.order.value;
        if (order == null) {
          return const Center(child: Text('Data pesanan tidak ditemukan'));
        }

        final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(R.w(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Order ID & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#${order.id.split('-').first.toUpperCase()}',
                          style: AppFonts.inter(fontSize: R.sp(18), fontWeight: FontWeight.bold),
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
                              padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(6)),
                              decoration: BoxDecoration(
                                color: AppColors.deepPurple50,
                                borderRadius: BorderRadius.circular(R.r(8)),
                              ),
                              child: Text(
                                OrderTranslation.translateOrderStatus(order.status),
                                style: AppFonts.inter(color: AppColors.deepPurple, fontWeight: FontWeight.bold, fontSize: R.sp(12)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: R.h(8)),
                    Row(
                      children: [
                        if (order.isManualOrder) ...[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
                            decoration: BoxDecoration(
                              color: AppColors.info50,
                              borderRadius: BorderRadius.circular(R.r(4)),
                            ),
                            child: Text(
                              'Manual',
                              style: TextStyle(color: AppColors.info700, fontSize: R.sp(10), fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: R.w(8)),
                        ],
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
                          decoration: BoxDecoration(
                            color: order.paymentMethod.toLowerCase() == 'paynow' ? AppColors.success50 : AppColors.orange50,
                            borderRadius: BorderRadius.circular(R.r(4)),
                          ),
                          child: Text(
                            OrderTranslation.translatePaymentMethod(order.paymentMethod),
                            style: TextStyle(
                              color: order.paymentMethod.toLowerCase() == 'paynow' ? AppColors.success700 : AppColors.orange700,
                              fontSize: R.sp(10),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: R.w(8)),
                        Text(
                          DateFormat('dd MMMM yyyy, HH:mm').format(order.createdAt),
                          style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey500),
                        ),
                      ],
                    ),
                    SizedBox(height: R.h(24)),

                    // Customer Info
                    _buildSectionTitle('Informasi Pelanggan'),
                    SizedBox(height: R.h(12)),
                    _buildInfoRow('Nama', (order.guestCustomerName?.isNotEmpty == true) ? order.guestCustomerName! : order.customerName),
                    if (order.guestCustomerPhone?.isNotEmpty == true || order.customerPhone?.isNotEmpty == true)
                      _buildInfoRow('Telepon', (order.guestCustomerPhone?.isNotEmpty == true) ? order.guestCustomerPhone! : order.customerPhone!),
                    _buildInfoRow('Pengiriman', OrderTranslation.translateDeliveryType(order.deliveryType)),
                    SizedBox(height: R.h(24)),

                    // Items List
                    _buildSectionTitle('Daftar Layanan'),
                    SizedBox(height: R.h(12)),
                    ...(order.items ?? []).map((item) => Padding(
                      padding: EdgeInsets.only(bottom: R.h(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (item.itemImageUrl != null && item.itemImageUrl!.isNotEmpty) ...[
                            Container(
                              width: R.w(40),
                              height: R.h(40),
                              margin: EdgeInsets.only(right: R.w(12)),
                              decoration: BoxDecoration(
                                color: AppColors.grey100,
                                borderRadius: BorderRadius.circular(R.r(8)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(R.r(8)),
                                child: Image.network(
                                  '${ApiConstants.cloudflareCatalogIconUrl}${item.itemImageUrl}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.local_laundry_service, color: AppColors.purple300, size: R.sp(20)),
                                ),
                              ),
                            ),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.itemName, style: AppFonts.inter(fontWeight: FontWeight.w600, fontSize: R.sp(14))),
                                SizedBox(height: R.h(4)),
                                Text('${item.quantity} ${item.unit} x ${formatter.format(item.unitPrice)}', style: AppFonts.inter(color: AppColors.grey500, fontSize: R.sp(12))),
                              ],
                            ),
                          ),
                          Text(formatter.format(item.subTotal), style: AppFonts.inter(fontWeight: FontWeight.w600, fontSize: R.sp(14))),
                        ],
                      ),
                    )),
                    Divider(height: R.h(24)),
                    
                    // Payment Summary
                    _buildSectionTitle('Rincian Pembayaran'),
                    SizedBox(height: R.h(12)),
                    _buildInfoRow('Metode', (order.selectedStoreBankName != null && order.selectedStoreBankName != '-') 
                                              ? order.selectedStoreBankName! 
                                              : OrderTranslation.translatePaymentMethod(order.paymentMethod)),
                    _buildInfoRow('Status', OrderTranslation.translatePaymentStatus(order.paymentStatus.trim().isEmpty ? 'Unpaid' : order.paymentStatus)),
                    _buildInfoRow('Subtotal', formatter.format(order.totalAmount - order.deliveryFee)),
                    _buildInfoRow('Ongkos Kirim', formatter.format(order.deliveryFee)),
                    Divider(height: R.h(24)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Pembayaran', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14))),
                        Text(formatter.format(order.totalAmount), style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(16), color: AppColors.deepPurple)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons based on Status
            _buildActionButtons(order),
          ],
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14), color: AppColors.grey800));
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppFonts.inter(color: AppColors.grey600, fontSize: R.sp(13))),
          Text(value, style: AppFonts.inter(fontWeight: FontWeight.w500, fontSize: R.sp(13))),
        ],
      ),
    );
  }

  Widget _buildActionButtons(OrderModel order) {
    List<Widget> orderButtons = [];
    final lowerStatus = order.status.toLowerCase();
    
    // Order Status Buttons (Berlaku untuk Manual maupun Aplikasi)
    if (lowerStatus == 'pending') {
      orderButtons.add(_buildPrimaryButton('Terima Pesanan', 'accept'));
      orderButtons.add(SizedBox(width: R.w(12)));
      orderButtons.add(_buildSecondaryButton('Tolak', 'cancel'));
    } else if (lowerStatus == 'washing' || lowerStatus == 'confirmed') {
      orderButtons.add(_buildPrimaryButton('Tandai Selesai Dicuci', 'finish-washing'));
    } else if (lowerStatus == 'ready' || lowerStatus == 'readyforpickup') {
      bool isPayNow = order.paymentMethod.toLowerCase() == 'paynow' || 
                      (order.selectedStoreBankName != null && order.selectedStoreBankName!.trim().isNotEmpty && order.selectedStoreBankName != '-') || 
                      (order.paymentProvider != null && order.paymentProvider!.toLowerCase().contains('qris'));
      
      final currentPaymentStatus = (order.paymentStatus.trim().isEmpty) ? 'unpaid' : order.paymentStatus.toLowerCase();
      
      if (isPayNow && currentPaymentStatus != 'paid') {
        orderButtons.add(
          Expanded(
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: AppColors.grey300,
                padding: EdgeInsets.symmetric(vertical: R.h(16)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Diserahkan / Selesai', style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.grey600)),
                  const SizedBox(height: 2),
                  Text('(Verifikasi Lunas Dulu)', style: AppFonts.inter(fontSize: 10, color: AppColors.grey600)),
                ],
              ),
            ),
          )
        );
      } else {
        orderButtons.add(
          Expanded(
            child: ElevatedButton(
              onPressed: () => controller.handleCompleteOrder(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: R.h(16)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
              ),
              child: Text('Diserahkan / Selesai', style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.white)),
            ),
          )
        );
      }
    }

    // Payment Status Buttons
    Widget? paymentButtonsWidget;
    final lowerPaymentStatus = (order.paymentStatus.trim().isEmpty) ? 'unpaid' : order.paymentStatus.toLowerCase();

    if (lowerPaymentStatus == 'unpaid' || lowerPaymentStatus == 'awaitingpayment') {
      bool isTransfer = (order.selectedStoreBankName != null && order.selectedStoreBankName!.trim().isNotEmpty && order.selectedStoreBankName != '-') || 
                        (order.paymentProvider != null && order.paymentProvider!.toLowerCase().contains('qris')) ||
                        (order.paymentMethod.toLowerCase() == 'paynow');

      if (isTransfer) {
        // Transfer/QRIS
        paymentButtonsWidget = Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => controller.uploadReceiptQris(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: EdgeInsets.symmetric(vertical: R.h(16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                ),
                child: Text('Upload Bukti Bayar', textAlign: TextAlign.center, style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(12))),
              ),
            ),
          ],
        );
      }
    } else if (lowerPaymentStatus == 'verifying') {
      paymentButtonsWidget = Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => controller.verifyPaymentAction(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: EdgeInsets.symmetric(vertical: R.h(16)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
              ),
              child: Text('Valid', textAlign: TextAlign.center, style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.white, fontSize: R.sp(12))),
            ),
          ),
          SizedBox(width: R.w(12)),
          Expanded(
            child: OutlinedButton(
              onPressed: () => controller.verifyPaymentAction(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                padding: EdgeInsets.symmetric(vertical: R.h(16)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
              ),
              child: Text('Tolak', textAlign: TextAlign.center, style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(12))),
            ),
          ),
        ],
      );
    }

    if (orderButtons.isEmpty && paymentButtonsWidget == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(R.w(24)),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: controller.isLoading.value 
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (paymentButtonsWidget != null) ...[
                  paymentButtonsWidget,
                  if (orderButtons.isNotEmpty) SizedBox(height: R.h(12)),
                ],
                if (orderButtons.isNotEmpty)
                  Row(children: orderButtons),
              ],
            ),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, String action) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => controller.updateStatus(action),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: R.h(16)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
        ),
        child: Text(text, style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.white)),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, String action) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => controller.updateStatus(action),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          side: const BorderSide(color: AppColors.danger),
          padding: EdgeInsets.symmetric(vertical: R.h(16)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
        ),
        child: Text(text, style: AppFonts.inter(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
