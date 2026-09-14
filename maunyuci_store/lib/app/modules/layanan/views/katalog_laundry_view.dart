import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

import '../controllers/layanan_controller.dart';
import 'form_layanan_view.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_confirm_modal.dart';
import '../../../core/widgets/custom_snackbar.dart';
import 'package:maunyuci_core/maunyuci_core.dart';

/// Isi katalog laundry. Dibuka dari sub-menu dinamis "/layanan/katalog".
/// Tanpa hardcode role: siapa pun yang menerima sub-menu ini dari BE
/// (Owner maupun StoreStaff aktif) bisa Add/Edit/Delete di sini.
class KatalogLaundryView extends GetView<LayananController> {
  const KatalogLaundryView({super.key});

  String _formatRupiah(double number) {
    String str = number.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      buffer.write(str[i]);
      int index = str.length - 1 - i;
      if (index > 0 && index % 3 == 0) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<LayananController>()) {
      Get.put(LayananController());
    }

    // We group the layanans by category
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text(
          'Katalog Laundry',
          style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(18)),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.black87,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.layanans.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchCatalog,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height - kToolbarHeight - R.h(100),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/img_empty_transaksi.png', height: R.h(125), fit: BoxFit.contain),
                    SizedBox(height: R.h(8)),
                    Text(
                      'Belum ada Katalog Laundry',
                      style: AppFonts.inter(color: AppColors.grey500, fontSize: R.sp(16)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Group by category
        final grouped = <String, List>{};
        for (var l in controller.layanans) {
          if (!grouped.containsKey(l.category)) {
            grouped[l.category] = [];
          }
          grouped[l.category]!.add(l);
        }

        return RefreshIndicator(
          onRefresh: controller.fetchCatalog,
          color: AppColors.primary,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: R.h(100)), // Padding for FAB
            itemCount: grouped.keys.length,
          itemBuilder: (context, index) {
            String category = grouped.keys.elementAt(index);
            var items = grouped[category]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(R.w(20), R.h(24), R.w(20), R.h(12)),
                  child: Text(
                    category,
                    style: AppFonts.inter(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                ...items.map((item) {
                  return Dismissible(
                    key: Key(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: AppColors.danger,
                      child: const Icon(Icons.delete, color: AppColors.white),
                    ),
                    confirmDismiss: (direction) async {
                      final result = await CustomConfirmModal.show<bool>(
                        title: "Hapus Layanan",
                        message: "Apakah Anda yakin ingin menghapus layanan '${item.name}'? Tindakan ini tidak dapat dibatalkan.",
                        textConfirm: "Hapus",
                        textCancel: "Batal",
                        confirmColor: AppColors.danger,
                        icon: Icons.delete_outline,
                        onConfirm: () {
                          Get.back(result: true);
                        },
                        onCancel: () {
                          Get.back(result: false);
                        }
                      );
                      return result ?? false;
                    },
                    onDismissed: (direction) async {
                      final success = await controller.deleteLayanan(item.id);
                      if (success) {
                        CustomSnackbar.showSuccess('Berhasil', 'Layanan ${item.name} dihapus');
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(6)),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(R.r(16)),
                        child: Stack(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(12)),
                              leading: Container(
                                width: R.r(56),
                                height: R.r(56),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(R.r(12)),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(R.r(8)),
                                  child: item.imageAsset.isNotEmpty
                                      ? (item.imageAsset.startsWith('http')
                                          ? Image.network(item.imageAsset, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: AppColors.grey500))
                                          : Image.network('${ApiConstants.cloudflareCatalogIconUrl}${item.imageAsset}', fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: AppColors.grey500)))
                                      : const Icon(Icons.image, color: AppColors.grey500),
                                ),
                              ),
                              title: Text(
                                item.name,
                                style: AppFonts.inter(fontWeight: FontWeight.w600, fontSize: R.sp(14)),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: R.h(6)),
                                  Text(
                                    'Rp ${_formatRupiah(item.price)} / ${item.unit}',
                                    style: AppFonts.inter(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: R.sp(13),
                                    ),
                                  ),
                                  if (item.timeEstimate != null && item.timeEstimate!.isNotEmpty) ...[
                                    SizedBox(height: R.h(6)),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, size: R.r(14), color: AppColors.grey600),
                                        SizedBox(width: R.w(6)),
                                        Text(
                                          item.timeEstimate!,
                                          style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right, color: AppColors.grey500),
                              onTap: () {
                                Get.to(() => FormLayananView(layanan: item));
                              },
                            ),

                            // Badge Description
                            if (item.description != null && item.description!.isNotEmpty)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(4)),
                                  decoration: BoxDecoration(
                                    color: AppColors.orange50,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(R.r(12)),
                                    ),
                                  ),
                                  child: Text(
                                    item.description!,
                                    style: AppFonts.inter(
                                      fontSize: R.sp(10),
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.orange800,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      );
    }),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_layanan',
        onPressed: () {
          Get.to(() => const FormLayananView());
        },
        backgroundColor: AppColors.primary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(16))),
        icon: Icon(Icons.add_circle, size: R.r(20), color: AppColors.white),
        label: Text('Layanan', style: AppFonts.inter(fontWeight: FontWeight.w600, color: AppColors.white, fontSize: R.sp(14))),
      ),
    );
  }
}
