import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../home/views/home_view.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/utils/menu_mapper.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isMenuLoading.value) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.menus.isEmpty) {
        return Scaffold(
          body: Center(
            child: Text(
              controller.menuErrorMessage.value.isNotEmpty
                  ? controller.menuErrorMessage.value
                  : 'Tidak ada menu tersedia',
            ),
          ),
        );
      }

      return Scaffold(
        body: IndexedStack(
          index: controller.tabIndex.value,
          children: controller.menus
              .map((menu) => MenuMapper.getScreen(menu.path, HomeView()))
              .toList(),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            margin: EdgeInsets.only(
                left: R.w(16), right: R.w(16), bottom: R.h(16), top: R.h(8)),
            padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(8)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(R.r(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(controller.menus.length, (index) {
                final menu = controller.menus[index];
                final isSelected = controller.tabIndex.value == index;

                return GestureDetector(
                  onTap: () => controller.changeTabIndex(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? R.w(16) : R.w(12),
                        vertical: R.h(10)),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(R.r(24)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MenuMapper.getIcon(
                          menu.icon,
                          color: isSelected ? AppColors.primary : Colors.grey.shade400,
                        ),
                        if (isSelected) ...[
                          SizedBox(width: R.w(8)),
                          Text(
                            menu.title,
                            style: AppFonts.fInterBodySmallMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    });
  }
}
