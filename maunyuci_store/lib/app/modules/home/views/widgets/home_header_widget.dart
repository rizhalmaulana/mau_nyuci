import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../controllers/home_controller.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/custom_shimmer.dart';
import '../../../../core/constants/app_colors.dart';

class HomeHeaderWidget extends GetView<HomeController> {
  const HomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Header gradient (ungu - biru)
    return Container(
      padding: EdgeInsets.only(top: R.h(50), left: R.w(20), right: R.w(20), bottom: R.h(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Obx(() => Container(
                width: R.r(48),
                height: R.r(48),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                ),
                clipBehavior: Clip.antiAlias,
                child: controller.storeImageUrl.value.isNotEmpty
                    ? Image.network(
                        controller.storeImageUrl.value,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.store, color: AppColors.purple, size: R.sp(24)),
                      )
                    : Icon(Icons.store, color: AppColors.purple, size: R.sp(24)),
              )),
              SizedBox(width: R.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          controller.storeName.value,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: R.sp(18),
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    Text(
                      'Jangan ragu untuk memulai !',
                      style: TextStyle(color: AppColors.white70, fontSize: R.sp(12)),
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.toNamed('/notification');
                      controller.unreadNotificationCount.value = 0;
                    },
                    icon: Icon(Icons.notifications, color: AppColors.white, size: R.sp(24)),
                  ),
                  Obx(() {
                    if (controller.unreadNotificationCount.value > 0) {
                      return Positioned(
                        top: R.h(8),
                        right: R.w(10),
                        child: Container(
                          width: R.r(8),
                          height: R.r(8),
                          decoration: const BoxDecoration(
                            color: AppColors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              )
            ],
          ),
          SizedBox(height: R.h(24)),

          // Unified Card: Info Transaksi & Status Pesanan
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(R.r(16)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: R.r(10),
                  offset: Offset(0, R.h(4)),
                )
              ],
            ),
            child: Column(
              children: [
                // Bagian Atas: Putih (Transaksi & Omset)
                Container(
                  padding: EdgeInsets.all(R.w(16)),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(16))),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Transaksi Hari ini', style: TextStyle(color: AppColors.grey500, fontSize: R.sp(12))),
                                SizedBox(height: R.h(4)),
                                Obx(() {
                                  if (controller.isLoading.value && controller.dashboardStats.value == null) {
                                    return CustomShimmer.box(width: R.w(40), height: R.h(20));
                                  }
                                  return Text(
                                    (controller.dashboardStats.value?.totalOrders ?? 0).toString(),
                                    style: TextStyle(fontSize: R.sp(18), fontWeight: FontWeight.bold),
                                  );
                                }),
                              ],
                            ),
                          ),
                          Container(width: R.w(1), height: R.h(40), color: AppColors.grey300),
                          SizedBox(width: R.w(16)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Omset Hari ini', style: TextStyle(color: AppColors.grey500, fontSize: R.sp(12))),
                                SizedBox(height: R.h(4)),
                                Obx(() {
                                  if (controller.isLoading.value && controller.dashboardStats.value == null) {
                                    return CustomShimmer.box(width: R.w(80), height: R.h(20));
                                  }
                                  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
                                  return Text(
                                    currencyFormatter.format(controller.dashboardStats.value?.totalRevenue ?? 0),
                                    style: TextStyle(fontSize: R.sp(18), fontWeight: FontWeight.bold),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: R.h(16)),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: R.h(8)),
                        decoration: BoxDecoration(
                          color: AppColors.info50,
                          borderRadius: BorderRadius.circular(R.r(8)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Obx(() => Text(
                                  'Terakhir di-update ${controller.lastUpdated.value}',
                                  style: TextStyle(color: AppColors.info700, fontSize: R.sp(12)),
                                )),
                            SizedBox(width: R.w(8)),
                            InkWell(
                              onTap: controller.refreshData,
                              child: Icon(Icons.refresh, size: R.sp(16), color: AppColors.info700),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                // Bagian Bawah: Ungu (Status Pesanan)
                Container(
                  padding: EdgeInsets.symmetric(vertical: R.h(16), horizontal: R.w(12)),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6D28D9), // Ungu sesuai desain
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(R.r(16))),
                  ),
                  child: Obx(() {
                    final stats = controller.dashboardStats.value;
                    final isLoading = controller.isLoading.value && stats == null;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatusItem(Icons.schedule, 'Tunggu', stats?.pendingOrders ?? 0, AppColors.orange, isLoading),
                        _buildStatusItem(Icons.local_laundry_service, 'Dicuci', stats?.washingOrders ?? 0, AppColors.info, isLoading),
                        _buildStatusItem(Icons.shopping_bag, 'Siap', stats?.readyForPickupOrders ?? 0, AppColors.yellow, isLoading),
                        _buildStatusItem(Icons.check_circle, 'Selesai', stats?.completedOrders ?? 0, AppColors.success, isLoading),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String label, int count, Color iconColor, bool isLoading) {
    // Mapping label ke status riil
    String targetStatus = 'Pending';
    if (label == 'Dicuci') targetStatus = 'Washing';
    if (label == 'Siap') targetStatus = 'Ready';
    if (label == 'Selesai') targetStatus = 'Completed';
    
    return Expanded(
      child: InkWell(
        onTap: () => Get.toNamed('/all-orders', arguments: {'initialStatus': targetStatus}),
        borderRadius: BorderRadius.circular(R.r(12)),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: R.w(4)),
          padding: EdgeInsets.symmetric(vertical: R.h(8), horizontal: R.w(4)),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(R.r(12)),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: R.sp(14), color: iconColor),
                  SizedBox(width: R.w(4)),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(color: AppColors.white, fontSize: R.sp(12), fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: R.h(6)),
              if (isLoading)
                CustomShimmer.box(
                  width: R.w(20), 
                  height: R.h(18), 
                  baseColor: AppColors.white.withValues(alpha: 0.4), 
                  highlightColor: AppColors.white.withValues(alpha: 0.8)
                )
              else
                Text(
                  count.toString(),
                  style: TextStyle(color: AppColors.white, fontSize: R.sp(16), fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeActionWidget extends StatelessWidget {
  const HomeActionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/pos'),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(12)),
        margin: EdgeInsets.symmetric(horizontal: R.w(20)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B21B6), Color(0xFF3B82F6)], // Gradient Card Button
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(R.r(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: R.r(8),
            offset: Offset(0, R.h(4)),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(R.w(8)),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: AppColors.white, size: R.sp(24)),
          ),
          SizedBox(width: R.w(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Buat Order Sekarang', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: R.sp(16))),
                Text('Ayo buat pesanan untuk kostumer kamu!', style: TextStyle(color: AppColors.white70, fontSize: R.sp(12))),
              ],
            ),
          )
        ],
      ),
    ));
  }
}

