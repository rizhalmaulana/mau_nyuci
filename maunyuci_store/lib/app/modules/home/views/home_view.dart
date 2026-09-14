import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_shimmer.dart';
import '../controllers/home_controller.dart';
import 'widgets/home_header_widget.dart';
import 'widgets/order_list_item_widget.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.deepPurple,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: R.h(180),
              child: Container(
                height: R.h(250),
                width: double.infinity,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage(AppAssets.headerHome),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(R.r(32)),
                    bottomRight: Radius.circular(R.r(32)),
                  ),
                ),
              ),
            ),

            // Lapis Konten Utama
            Positioned.fill(
              child: CustomScrollView(
                controller: controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: controller.scrollController,
                          builder: (context, child) {
                            double offset = 0.0;
                            if (controller.scrollController.hasClients) {
                              offset = controller.scrollController.offset;
                              if (offset < 0) offset = 0;
                            }
                            return Transform.translate(
                              offset: Offset(0, offset),
                              child: child,
                            );
                          },
                          child: Column(
                            children: [
                              const HomeHeaderWidget(),
                              SizedBox(height: R.h(10)),
                              const HomeActionWidget(),
                              SizedBox(height: R.h(24)),
                            ],
                          ),
                        ),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(R.r(24)),
                          topRight: Radius.circular(R.r(24)),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ]
                      ),
                      padding: EdgeInsets.only(left: R.w(24), right: R.w(24), top: R.h(24)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Daftar Orderan', style: TextStyle(fontSize: R.sp(18), fontWeight: FontWeight.bold)),
                                  Obx(() => Text('Total antrean: ${controller.orderList.length} pesanan', style: TextStyle(fontSize: R.sp(12), color: AppColors.grey500))),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.toNamed('/all-orders');
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text('Lihat Semua', style: TextStyle(color: AppColors.deepPurple, fontSize: R.sp(14), fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          SizedBox(height: R.h(16)),
                          
                          // List Content
                          Obx(() {
                            if (controller.isLoading.value && controller.orderList.isEmpty) {
                              return CustomShimmer.listOrder();
                            }
                            
                            return controller.orderList.isEmpty 
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: R.h(32)),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          AppAssets.imgEmptyRiwayat,
                                          height: R.h(110),
                                          fit: BoxFit.contain,
                                        ),
                                        SizedBox(height: R.h(8)),
                                        Text(
                                          'Belum ada Orderan yang Masuk',
                                          style: TextStyle(
                                            color: AppColors.grey600,
                                            fontSize: R.sp(14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: controller.orderList.length > 10 ? 10 : controller.orderList.length,
                                  itemBuilder: (context, index) {
                                    final order = controller.orderList[index];
                                    return OrderListItemWidget(order: order);
                                  },
                                );
                          }),

                          SizedBox(height: R.h(24)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
                  
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
