import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:maunyuci_customer/app/modules/home/views/widgets/transaction_active_section.dart';
import 'package:maunyuci_customer/app/modules/home/views/widgets/history_order_section.dart';
import 'package:maunyuci_customer/app/modules/home/views/widgets/home_header_section.dart';
import 'package:maunyuci_customer/app/modules/home/views/widgets/order_now_section.dart';
import 'package:maunyuci_customer/app/modules/order_history/views/order_history_view.dart';
import '../../account/views/account_view.dart';
import '../controllers/home_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/widgets/custom_shimmer.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/utils/menu_mapper.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  final RxBool isScrolled = false.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: isScrolled.value ? AppColors.background : Colors.transparent,
        elevation: 0,
        systemOverlayStyle: isScrolled.value ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        toolbarHeight: 0,
      ),
      body: Obx(() {
        if (controller.isMenuLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.menus.isEmpty) {
          return Center(
            child: Text(
              controller.menuErrorMessage.value.isNotEmpty
                  ? controller.menuErrorMessage.value
                  : 'Tidak ada menu tersedia',
            ),
          );
        }

        final homeWidget = NotificationListener<ScrollNotification>(
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
                padding: EdgeInsets.only(bottom: R.h(24.0)),
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
                          controller.isLoading.value ? const ShimmerHeader() : const HomeHeader(),
                          SizedBox(height: R.h(24)),
                          controller.isLoading.value ? _buildShimmerActiveTransaction() : const ActiveTransactionSection(),
                          SizedBox(height: R.h(18)),
                          controller.isLoading.value ? ShimmerCard(height: R.h(140)) : const OrderNowCard(),
                          SizedBox(height: R.h(18)),
                          controller.isLoading.value ? _buildShimmerHistoryOrder() : const HistoryOrderSection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

        return IndexedStack(
          index: controller.tabIndex.value,
          children: controller.menus
              .map((menu) => MenuMapper.getScreen(menu.path, homeWidget))
              .toList(),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isMenuLoading.value || controller.menus.isEmpty) {
          return const SizedBox.shrink(); // Hide navigation bar while loading
        }

        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, R.h(-4)),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: controller.tabIndex.value,
            onTap: controller.changeTabIndex,
            backgroundColor: AppColors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedLabelStyle: AppFonts.fInterStatusRegular.copyWith(fontSize: R.sp(6)),
            unselectedLabelStyle: AppFonts.fInterStatusRegular.copyWith(fontSize: R.sp(5)),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: controller.menus.map((menu) {
              return BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: MenuMapper.getIcon(menu.icon),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: MenuMapper.getIcon(menu.icon, color: AppColors.primary),
                ),
                label: menu.title,
              );
            }).toList(),
          ),
        );
      }),
    ));
  }

  Widget _buildShimmerActiveTransaction() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerCard(width: R.w(150), height: R.h(20)),
          SizedBox(height: R.h(12)),
          ShimmerCard(height: R.h(100)),
        ],
      ),
    );
  }

  Widget _buildShimmerHistoryOrder() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerCard(width: R.w(150), height: R.h(20)),
          SizedBox(height: R.h(12)),
          ShimmerListItem(height: R.h(80)),
          ShimmerListItem(height: R.h(80)),
          ShimmerListItem(height: R.h(80)),
        ],
      ),
    );
  }
}