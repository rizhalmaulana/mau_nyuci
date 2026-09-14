import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

import '../controllers/main_controller.dart';
import '../../../core/utils/menu_mapper.dart';
import '../../../core/utils/responsive_helper.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.bottomNavMenus.isEmpty) {
          return Center(
            child: Text(
              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : 'Tidak ada menu tersedia',
            ),
          );
        }

        return IndexedStack(
          index: controller.currentIndex.value,
          children: controller.bottomNavMenus
              .map((menu) => MenuMapper.getScreen(menu.path))
              .toList(),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value || controller.bottomNavMenus.isEmpty) {
          return const SizedBox.shrink(); // Hide navigation bar while loading
        }

        return SafeArea(
          child: Container(
            margin: EdgeInsets.only(
                left: R.w(16), right: R.w(16), bottom: R.h(16), top: R.h(8)),
            padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(8)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(R.r(32)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(controller.bottomNavMenus.length, (index) {
                final menu = controller.bottomNavMenus[index];
                final isSelected = controller.currentIndex.value == index;

                return GestureDetector(
                  onTap: () => controller.changePage(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? R.w(16) : R.w(12),
                        vertical: R.h(10)),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(R.r(24)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MenuMapper.getIcon(
                          menu.icon,
                          color: isSelected ? AppColors.primary : AppColors.grey400,
                        ),
                        if (isSelected) ...[
                          SizedBox(width: R.w(8)),
                          Text(
                            menu.title,
                            style: AppFonts.inter(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: R.sp(13),
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
        );
      }),
    );
  }
}
