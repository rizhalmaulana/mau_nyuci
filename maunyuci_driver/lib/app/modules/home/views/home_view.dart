import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/responsive_helper.dart';
import '../controllers/home_controller.dart';
import '../../../routes/app_pages.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.fetchData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: R.h(16)),
                _buildCashCard(),
                SizedBox(height: R.h(16)),
                _buildStatRow(),
                SizedBox(height: R.h(16)),
                _buildTaskTabs(),
                SizedBox(height: R.h(24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header ungu: sapaan + tombol logout. Skema sama seperti beranda customer/store.
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary600, AppColors.primary800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(R.r(32)),
          bottomRight: Radius.circular(R.r(32)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(R.w(24), R.h(16), R.w(24), R.h(28)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, Driver!',
                      style: AppFonts.inter(
                        fontSize: R.sp(20),
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: R.h(4)),
                    Text(
                      'Siap antar jemput cucian hari ini?',
                      style: AppFonts.inter(
                        fontSize: R.sp(12),
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: controller.logout,
                child: Container(
                  padding: EdgeInsets.all(R.r(10)),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(R.r(16)),
                  ),
                  child: SvgPicture.asset(
                    AppAssets.iconLogout,
                    width: R.r(24),
                    height: R.r(24),
                    colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Kartu saldo kas COD yang dibawa driver.
  Widget _buildCashCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(24)),
      child: Container(
        padding: EdgeInsets.all(R.r(16)),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
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
              child: Icon(
                Icons.account_balance_wallet,
                color: AppColors.white,
                size: R.r(28),
              ),
            ),
            SizedBox(width: R.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saldo Kas COD',
                    style: AppFonts.inter(
                      fontSize: R.sp(12),
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: R.h(4)),
                  Obx(() => Text(
                        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0)
                            .format(controller.unsettledCash.value),
                        style: AppFonts.inter(
                          fontSize: R.sp(20),
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      )),
                  SizedBox(height: R.h(2)),
                  Text(
                    'Segera setor ke toko ya',
                    style: AppFonts.inter(
                      fontSize: R.sp(11),
                      color: AppColors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Ringkasan jumlah tugas jemput & antar.
  Widget _buildStatRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(24)),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.delivery_dining,
                  color: AppColors.secondary600,
                  label: 'Jemput',
                  count: controller.pickupTasks.length,
                ),
              ),
              SizedBox(width: R.w(12)),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_shipping_outlined,
                  color: AppColors.success600,
                  label: 'Antar',
                  count: controller.deliveryTasks.length,
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String label,
    required int count,
  }) {
    return Container(
      padding: EdgeInsets.all(R.r(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.r(16)),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(R.r(10)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(R.r(12)),
            ),
            child: Icon(icon, color: color, size: R.r(22)),
          ),
          SizedBox(width: R.w(12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: AppFonts.inter(
                  fontSize: R.sp(20),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: AppFonts.inter(
                  fontSize: R.sp(12),
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTabs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(24)),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(R.r(12)),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(R.r(12)),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppFonts.inter(fontSize: R.sp(13), fontWeight: FontWeight.w600),
              unselectedLabelStyle: AppFonts.inter(fontSize: R.sp(13)),
              tabs: const [
                Tab(text: 'Tugas Jemput'),
                Tab(text: 'Tugas Antar'),
              ],
            ),
          ),
          SizedBox(height: R.h(16)),
          SizedBox(
            height: R.h(420),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return TabBarView(
                children: [
                  _buildTaskList(controller.pickupTasks, true),
                  _buildTaskList(controller.deliveryTasks, false),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<dynamic> tasks, bool isPickup) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.imgEmptyTransaksi,
              width: R.r(80),
              height: R.r(80),
              fit: BoxFit.contain,
            ),
            SizedBox(height: R.h(12)),
            Text(
              'Tidak ada tugas saat ini',
              style: AppFonts.inter(
                fontSize: R.sp(14),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: R.h(4)),
            Text(
              isPickup
                  ? 'Tugas jemput baru akan muncul di sini'
                  : 'Tugas antar baru akan muncul di sini',
              style: AppFonts.inter(
                fontSize: R.sp(12),
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: tasks.length,
      separatorBuilder: (_, __) => SizedBox(height: R.h(12)),
      itemBuilder: (context, index) {
        final task = tasks[index];
        final orderId = task.orderId;
        final customerName = task.customerName;
        final address = task.address;

        return InkWell(
          onTap: () {
            if (isPickup) {
              Get.toNamed(Routes.PICKUP_DETAIL, arguments: orderId);
            } else {
              Get.toNamed(Routes.DELIVERY_DETAIL, arguments: orderId);
            }
          },
          borderRadius: BorderRadius.circular(R.r(16)),
          child: Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(R.r(6)),
                      ),
                      child: Text(
                        '#${orderId.split('-').first.toUpperCase()}',
                        style: AppFonts.inter(
                          fontSize: R.sp(11),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    _buildTypeBadge(isPickup),
                  ],
                ),
                SizedBox(height: R.h(12)),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        customerName,
                        style: AppFonts.inter(
                          fontSize: R.sp(15),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: R.r(14),
                      color: AppColors.grey400,
                    ),
                  ],
                ),
                SizedBox(height: R.h(8)),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: R.r(14),
                      color: AppColors.primary,
                    ),
                    SizedBox(width: R.w(4)),
                    Expanded(
                      child: Text(
                        address,
                        style: AppFonts.inter(
                          fontSize: R.sp(12),
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: R.h(12)),
                Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: R.r(14),
                      color: AppColors.secondary600,
                    ),
                    SizedBox(width: R.w(4)),
                    Text(
                      '${task.distanceInKm.toStringAsFixed(1)} km',
                      style: AppFonts.inter(
                        fontSize: R.sp(12),
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _buildTypeBadge(bool isPickup) {
    final color = isPickup ? AppColors.secondary600 : AppColors.success600;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(R.r(6)),
      ),
      child: Text(
        isPickup ? 'Jemput' : 'Antar',
        style: AppFonts.inter(
          fontSize: R.sp(11),
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
