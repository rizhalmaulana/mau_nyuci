import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

import '../controllers/layanan_controller.dart';
import 'katalog_laundry_view.dart';
import '../../main/controllers/main_controller.dart';
import '../../../core/utils/menu_mapper.dart';
import '../../../core/utils/responsive_helper.dart';

/// Tab Layanan: hub sub-menu dinamis dari BE (`parentId` -> ID menu Layanan).
/// Tanpa hardcode: StoreStaff hanya menerima "Katalog Laundry",
/// Owner menerima redundancy sesuai respons BE.
class LayananView extends GetView<LayananController> {
  const LayananView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LayananController>()) {
      Get.put(LayananController());
    }

    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text(
          'Layanan',
          style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(18)),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.black87,
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) {
          if (!Get.isRegistered<MainController>()) {
            return const KatalogLaundryView();
          }
          final mainController = Get.find<MainController>();
          return Obx(() {
            if (mainController.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }

            final subMenus = mainController.subMenusOf('/layanan');

            // Fallback: BE belum mengirim sub-menu (respons lama/gagal) —
            // tampilkan katalog langsung agar layar tidak kosong.
            if (subMenus.isEmpty) {
              return const KatalogLaundryView();
            }

            return RefreshIndicator(
              onRefresh: mainController.fetchMenus,
              color: AppColors.primary,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(R.w(16)),
                itemCount: subMenus.length,
                separatorBuilder: (_, __) => SizedBox(height: R.h(12)),
                itemBuilder: (context, index) {
                  final menu = subMenus[index];
                  return InkWell(
                    onTap: () => MenuMapper.openSubMenu(menu),
                    borderRadius: BorderRadius.circular(R.r(16)),
                    child: Container(
                      padding: EdgeInsets.all(R.w(16)),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(R.r(16)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: AppColors.grey100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: R.r(48),
                            height: R.r(48),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(R.r(12)),
                            ),
                            child: Center(child: MenuMapper.getIcon(menu.icon, color: AppColors.primary)),
                          ),
                          SizedBox(width: R.w(16)),
                          Expanded(
                            child: Text(
                              menu.title,
                              style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.grey500),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          });
        },
      ),
    );
  }
}
