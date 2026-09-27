import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/responsive_helper.dart';
import '../controllers/delivery_detail_controller.dart';

class DeliveryDetailView extends GetView<DeliveryDetailController> {
  const DeliveryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Detail Pengantaran',
          style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isFetching.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final data = controller.taskData.value;
        if (data == null) {
          return Center(child: Text('Data tidak ditemukan', style: AppFonts.inter(fontSize: R.sp(14))));
        }

        final orderId = data.orderId;
        final paymentMethod = data.paymentMethod ?? '';
        final paymentStatus = data.paymentStatus ?? 'Unpaid';
        final paymentProvider = OrderDisplay.displayPaymentProvider(paymentMethod, null);
        return SingleChildScrollView(
          padding: EdgeInsets.all(R.w(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOrderBanner(orderId, data.distanceInKm),
              SizedBox(height: R.h(16)),
              _buildCustomerCard(data),
              SizedBox(height: R.h(16)),
              _buildLaundryImageCard(data),
              SizedBox(height: R.h(16)),
              _buildScheduleCard(data.pickupTimeSlot, data.deliveryTimeSlot),
              SizedBox(height: R.h(16)),
              _buildPaymentCard(paymentMethod, paymentStatus, paymentProvider, data.totalAmount),
              SizedBox(height: R.h(16)),
              _buildLocationCard(data),
              SizedBox(height: R.h(24)),
              OutlinedButton.icon(
                onPressed: controller.openGoogleMaps,
                icon: Icon(Icons.map_outlined, size: R.r(20), color: AppColors.primary),
                label: Text(
                  'Buka di Google Maps',
                  style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: EdgeInsets.symmetric(vertical: R.h(16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.r(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(R.w(24)),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Obx(() {
            final data = controller.taskData.value;
            final paymentMethod = data?.paymentMethod ?? '';
            final paymentStatus = data?.paymentStatus ?? 'Unpaid';
            final isCashDelivery = paymentMethod.trim().toLowerCase() == 'paylater' && 
                                   paymentStatus.trim().toLowerCase() != 'paid' && 
                                   paymentStatus.trim().toLowerCase() != 'lunas';

            return ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.confirmDelivery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  padding: EdgeInsets.symmetric(vertical: R.h(16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.r(12)),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                        height: R.r(20),
                        width: R.r(20),
                        child: const CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: R.r(20)),
                          SizedBox(width: R.w(8)),
                          Text(
                            isCashDelivery 
                              ? 'Pesanan Selesai Diantar & Uang Diterima' 
                              : 'Pesanan Selesai Diantar (Ambil Foto)',
                            style: AppFonts.inter(
                              fontSize: R.sp(14),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              );
          }),
        ),
      ),
    );
  }

  String _formatDistance(double km) {
    if (km <= 0) return '< 1 km';
    return km % 1 == 0 ? '${km.toInt()} km' : '${km.toStringAsFixed(1)} km';
  }

  // Banner ungu: ID order + badge Jemput + jarak.
  Widget _buildOrderBanner(String orderId, double distanceInKm) {
    return Container(
      padding: EdgeInsets.all(R.r(16)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary600, AppColors.primary800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(R.r(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(R.r(12)),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(R.r(12)),
            ),
            child: Icon(Icons.delivery_dining, color: AppColors.white, size: R.r(28)),
          ),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tugas Antar',
                  style: AppFonts.inter(
                    fontSize: R.sp(12),
                    color: AppColors.white.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: R.h(4)),
                Text(
                  '#${orderId.split('-').first.toUpperCase()}',
                  style: AppFonts.inter(
                    fontSize: R.sp(18),
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: R.w(10), vertical: R.h(6)),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(R.r(8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.route_outlined, size: R.r(14), color: AppColors.white),
                SizedBox(width: R.w(4)),
                Text(
                  _formatDistance(distanceInKm),
                  style: AppFonts.inter(
                    fontSize: R.sp(12),
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(R.r(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: R.r(18), color: AppColors.primary),
              SizedBox(width: R.w(8)),
              Text(
                title,
                style: AppFonts.inter(
                  fontSize: R.sp(14),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Divider(height: R.h(24)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildCustomerCard(dynamic data) {
    final photoUrl = data.customerPhotoUrl?.toString();
    return _buildSectionCard(
      title: 'Informasi Pelanggan',
      icon: Icons.person_outline,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: R.r(28),
              backgroundColor: AppColors.primary100,
              backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
              onBackgroundImageError: (_, __) {},
              child: (photoUrl == null || photoUrl.isEmpty)
                  ? Icon(Icons.person, size: R.r(28), color: AppColors.primary)
                  : null,
            ),
            SizedBox(width: R.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (data.customerName ?? 'Customer').toString(),
                    style: AppFonts.inter(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: R.h(2)),
                  Text(
                    (data.customerPhone ?? '-').toString(),
                    style: AppFonts.inter(fontSize: R.sp(13), color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: R.h(12)),
        _buildInfoRow(Icons.location_on, 'Alamat', (data.address ?? '-').toString()),
        _buildInfoRow(Icons.note, 'Detail Alamat & Patokan', (data.courierNotes ?? 'Tidak ada catatan').toString(),
            isLast: true),
      ],
    );
  }

  Widget _buildLaundryImageCard(dynamic data) {
    final url = data.customerLaundryImageUrl?.toString();
    final hasPhoto = url != null && url.isNotEmpty;

    return _buildSectionCard(
      title: 'Foto Cucian Pelanggan',
      icon: Icons.local_laundry_service_outlined,
      children: [
        if (hasPhoto)
          ClipRRect(
            borderRadius: BorderRadius.circular(R.r(8)),
            child: Image.network(
              url,
              width: double.infinity,
              height: R.h(200),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: R.h(200),
                  color: AppColors.grey200,
                  child: Center(
                    child: Icon(Icons.broken_image, size: R.r(48), color: AppColors.grey400),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: double.infinity,
                  height: R.h(200),
                  color: AppColors.grey100,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          )
        else
          Container(
            width: double.infinity,
            height: R.h(120),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(R.r(8)),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported_outlined, size: R.r(32), color: AppColors.grey400),
                SizedBox(height: R.h(8)),
                Text(
                  'Belum ada foto cucian',
                  style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Kartu jadwal: slot waktu jemput & antar.
  Widget _buildScheduleCard(String? pickupSlot, String? deliverySlot) {
    return _buildSectionCard(
      title: 'Jadwal Antar Jemput Customer',
      icon: Icons.schedule_outlined,
      children: [
        _buildScheduleTile(
          icon: Icons.delivery_dining,
          color: AppColors.primary,
          label: 'Waktu Jemput',
          value: (pickupSlot == null || pickupSlot.isEmpty) ? '-' : pickupSlot,
        ),
        SizedBox(height: R.h(12)),
        _buildScheduleTile(
          icon: Icons.local_shipping_outlined,
          color: AppColors.success600,
          label: 'Waktu Antar',
          value: (deliverySlot == null || deliverySlot.isEmpty) ? '-' : deliverySlot,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildScheduleTile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Container(
      padding: EdgeInsets.all(R.r(12)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(R.r(12)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(R.r(8)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(R.r(8)),
            ),
            child: Icon(icon, size: R.r(20), color: color),
          ),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppFonts.inter(fontSize: R.sp(11), color: AppColors.textSecondary),
                ),
                SizedBox(height: R.h(2)),
                Text(
                  value,
                  style: AppFonts.inter(
                    fontSize: R.sp(15),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Kartu lokasi: alamat + koordinat + jarak.
  Widget _buildLocationCard(dynamic data) {
    final lat = data.latitude;
    final lng = data.longitude;
    final coord = (lat != null && lng != null) ? '$lat, $lng' : '-';

    return _buildSectionCard(
      title: 'Lokasi Pengantaran',
      icon: Icons.location_on_outlined,
      children: [
        _buildInfoRow(Icons.home_outlined, 'Alamat', (data.address ?? '-').toString()),
        _buildInfoRow(Icons.my_location_outlined, 'Koordinat', coord),
        _buildInfoRow(Icons.route_outlined, 'Jarak', _formatDistance((data.distanceInKm ?? 0).toDouble()),
            isLast: true),
      ],
    );
  }

  // Kartu pembayaran: metode + status + penyedia + total, warna ikut tema.
  Widget _buildPaymentCard(String method, String status, String provider, double total) {
    final isPayNow = method.trim().toLowerCase() == 'paynow';
    final methodColor = isPayNow ? AppColors.success600 : AppColors.orange700;
    final statusColor = _paymentStatusColor(status);

    return _buildSectionCard(
      title: 'Informasi Pembayaran',
      icon: Icons.payments_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPaymentTile(
                label: 'Metode',
                value: OrderDisplay.paymentMethodLabel(method.isEmpty ? 'PayLater' : method),
                color: methodColor,
                icon: Icons.payments_outlined,
              ),
            ),
            SizedBox(width: R.w(12)),
            Expanded(
              child: _buildPaymentTile(
                label: 'Status',
                value: OrderDisplay.paymentStatusLabel(status),
                color: statusColor,
                icon: Icons.receipt_long_outlined,
              ),
            ),
          ],
        ),
        SizedBox(height: R.h(12)),
        if (provider != null && provider.isNotEmpty) ...[
          _buildInfoRow(
            Icons.account_balance_outlined,
            'Payment Provider',
            provider,
          ),
        ],
        _buildInfoRow(
          Icons.payments_outlined,
          'Total Tagihan',
          NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(total),
          isLast: true,
        ),
        if (method.trim().toLowerCase() == 'paylater' && status.trim().toLowerCase() != 'paid' && status.trim().toLowerCase() != 'lunas') ...[
          SizedBox(height: R.h(16)),
          Container(
            padding: EdgeInsets.all(R.w(12)),
            decoration: BoxDecoration(
              color: AppColors.danger50,
              borderRadius: BorderRadius.circular(R.r(8)),
              border: Border.all(color: AppColors.danger200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: R.r(24)),
                SizedBox(width: R.w(12)),
                Expanded(
                  child: Text(
                    'Tagih Uang Tunai sebesar ${NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(total)}',
                    style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.danger700, fontSize: R.sp(14)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentTile({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(R.r(12)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(R.r(12)),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: R.r(14), color: color),
              SizedBox(width: R.w(4)),
              Text(
                label,
                style: AppFonts.inter(fontSize: R.sp(11), color: AppColors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: R.h(4)),
          Text(
            value,
            style: AppFonts.inter(
              fontSize: R.sp(14),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _paymentStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'paid':
        return AppColors.success600;
      case 'verifying':
        return AppColors.info;
      case 'failed':
        return AppColors.danger;
      default:
        return AppColors.orange700;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : R.h(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: R.r(20), color: AppColors.textSecondary),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.textSecondary),
                ),
                SizedBox(height: R.h(2)),
                Text(
                  value,
                  style: AppFonts.inter(
                    fontSize: R.sp(14),
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
