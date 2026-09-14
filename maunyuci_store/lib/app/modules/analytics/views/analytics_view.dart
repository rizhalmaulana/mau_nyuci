import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/premium_paywall_widget.dart';
import '../controllers/analytics_controller.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AnalyticsController>()) {
      Get.put(AnalyticsController());
    }

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text('Dashboard Analitik', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(18), color: AppColors.black87)),
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!controller.isPremium.value) {
          return const PremiumPaywallWidget();
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAnalytics,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(R.w(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(),
                SizedBox(height: R.h(24)),
                _buildTrendChart(),
                SizedBox(height: R.h(24)),
                _buildTopServices(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard('Pemasukan', controller.revenue.value, AppColors.success)),
            SizedBox(width: R.w(12)),
            Expanded(child: _buildMetricCard('Pengeluaran', controller.expense.value, AppColors.danger)),
          ],
        ),
        SizedBox(height: R.h(12)),
        Row(
          children: [
            Expanded(child: _buildMetricCard('Laba Bersih', controller.netProfit.value, AppColors.info)),
          ],
        ),
        SizedBox(height: R.h(12)),
        Row(
          children: [
            Expanded(child: _buildInfoCard('Pesanan Selesai', '${controller.orderCount.value} Nota', Icons.receipt_long)),
            SizedBox(width: R.w(12)),
            Expanded(child: _buildInfoCard('Rata-rata Nilai', NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(controller.averageOrderValue.value), Icons.payments)),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, double amount, Color color) {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppFonts.inter(fontSize: R.sp(14), color: AppColors.grey600)),
          SizedBox(height: R.h(8)),
          Text(
            NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(amount),
            style: AppFonts.inter(fontSize: R.sp(18), fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.deepPurple, size: R.r(24)),
          SizedBox(width: R.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey600)),
                SizedBox(height: R.h(4)),
                Text(value, style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart() {
    if (controller.revenueTrend.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tren Keuangan', style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold)),
          SizedBox(height: R.h(24)),
          SizedBox(
            height: R.h(200),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: controller.revenueTrend.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), (e.value['value'] as num).toDouble());
                    }).toList(),
                    isCurved: true,
                    color: AppColors.success,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppColors.success.withValues(alpha: 0.2)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopServices() {
    if (controller.topSellingServices.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        boxShadow: [
          BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Layanan Terlaris', style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold)),
          SizedBox(height: R.h(16)),
          ...controller.topSellingServices.map((service) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.deepPurple50,
                child: Icon(Icons.local_laundry_service, color: AppColors.deepPurple),
              ),
              title: Text(service['name'] ?? '', style: AppFonts.inter(fontWeight: FontWeight.w600)),
              trailing: Text('${service['count'] ?? 0}x', style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.deepPurple)),
            );
          }),
        ],
      ),
    );
  }
}
