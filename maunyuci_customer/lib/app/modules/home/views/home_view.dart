import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:maunyuci_customer/app/modules/home/views/widgets/transaction_active_section.dart';
import 'package:maunyuci_customer/app/modules/home/views/widgets/history_order_section.dart';
import 'package:maunyuci_customer/app/modules/home/views/widgets/home_header_section.dart';
import 'package:maunyuci_customer/app/modules/home/views/widgets/order_now_section.dart';
import '../controllers/home_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/custom_shimmer.dart';
import '../../../core/utils/responsive_helper.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  final RxBool isScrolled = false.obs;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut(() => HomeController());
    }

    return Obx(() => Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: isScrolled.value ? AppColors.background : Colors.transparent,
        elevation: 0,
        systemOverlayStyle: isScrolled.value ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        toolbarHeight: 0,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollUpdateNotification) {
            if (scrollNotification.metrics.pixels > 50 && !isScrolled.value) {
              isScrolled.value = true;
            } else if (scrollNotification.metrics.pixels <= 50 && isScrolled.value) {
              isScrolled.value = false;
            }
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: controller.refreshData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            // + system inset agar konten terbawah tidak tertutup
            // tombol navigasi HP (mode 3 tombol).
            padding: EdgeInsets.only(
              bottom: R.h(24.0) + MediaQuery.of(context).padding.bottom,
            ),
            child: Stack(
              children: [
                Container(
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
                SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: R.h(16)),
                      controller.isLoading.value ? const HomeHeaderShimmer() : const HomeHeader(),
                      SizedBox(height: R.h(24)),
                      controller.isLoading.value ? const ActiveTransactionShimmer() : const ActiveTransactionSection(),
                      SizedBox(height: R.h(18)),
                      const OrderNowCard(),
                      SizedBox(height: R.h(18)),
                      controller.isLoading.value ? const HistoryShimmer() : const HistoryOrderSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

}