import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/responsive_helper.dart';
import '../controllers/create_order_controller.dart';
import '../../../routes/app_pages.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_assets.dart';

class CreateOrderView extends GetView<CreateOrderController> {
  const CreateOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Toko Terdekat',
          style: AppFonts.fInterSubheadingSemibold.copyWith(
            color: AppColors.textPrimary,
            fontSize: R.sp(20)
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.nearbyStores.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppAssets.imgEmptyRiwayat,
                  width: R.r(150),
                  height: R.r(150),
                ),
                SizedBox(height: R.h(16)),
                Text(
                  'Tidak ada toko terdekat yang buka',
                  style: AppFonts.fInterBodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(R.r(16)),
          itemCount: controller.nearbyStores.length,
          separatorBuilder: (context, index) => SizedBox(height: R.h(12)),
          itemBuilder: (context, index) {
            final store = controller.nearbyStores[index];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(R.r(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(R.r(16)),
                  onTap: () {
                    if (store.id != null) {
                      Get.toNamed(Routes.STORE_DETAIL, arguments: {
                        'storeId': store.id,
                        'store': store,
                      });
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(R.r(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(R.r(12)),
                                  child: store.storeImageUrl != null && store.storeImageUrl!.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: store.storeImageUrl!,
                                          width: R.r(84),
                                          height: R.r(84),
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            width: R.r(84),
                                            height: R.r(84),
                                            color: AppColors.background,
                                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                          ),
                                          errorWidget: (context, url, error) => _buildPlaceholderIcon(),
                                        )
                                      : _buildPlaceholderIcon(),
                                ),
                                if (store.isCurrentlyOpen != null)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: R.h(4)),
                                      decoration: BoxDecoration(
                                        color: store.isCurrentlyOpen! ? AppColors.success600.withOpacity(0.9) : AppColors.danger400.withOpacity(0.9),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(R.r(12)),
                                          bottomRight: Radius.circular(R.r(12)),
                                        ),
                                      ),
                                      child: Text(
                                        store.isCurrentlyOpen! ? 'BUKA' : 'TUTUP',
                                        textAlign: TextAlign.center,
                                        style: AppFonts.fInterCaptionMedium.copyWith(
                                          color: Colors.white,
                                          fontSize: R.r(10),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(width: R.w(16)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          store.name ?? 'Nama Toko',
                                          style: AppFonts.fInterBodyMedium.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: R.r(16),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.star, size: R.r(16), color: Colors.amber),
                                          SizedBox(width: R.w(4)),
                                          Text(
                                            '${store.averageRating ?? 0.0}',
                                            style: AppFonts.fInterCaptionMedium.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: R.h(6)),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, size: R.r(14), color: AppColors.primary),
                                      SizedBox(width: R.w(4)),
                                      Text(
                                        'Berjarak ${store.distanceInKm?.toStringAsFixed(1) ?? '0.0'} km',
                                        style: AppFonts.fInterCaptionMedium.copyWith(color: AppColors.primary),
                                      ),
                                      if (store.totalReviews != null && store.totalReviews! > 0) ...[
                                        SizedBox(width: R.w(8)),
                                        Text(
                                          '•',
                                          style: AppFonts.fInterCaptionRegular.copyWith(color: AppColors.textSecondary),
                                        ),
                                        SizedBox(width: R.w(8)),
                                        Text(
                                          '${store.totalReviews} Ulasan',
                                          style: AppFonts.fInterCaptionRegular.copyWith(color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: R.h(8)),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: R.r(14), color: AppColors.textSecondary),
                                      SizedBox(width: R.w(4)),
                                      Expanded(
                                        child: Text(
                                          store.operatingHoursFormatted ?? 'Jam tidak tersedia',
                                          style: AppFonts.fInterCaptionRegular.copyWith(color: AppColors.textSecondary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (store.address != null && store.address!.isNotEmpty) ...[
                                    SizedBox(height: R.h(4)),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.map_outlined, size: R.r(14), color: AppColors.textSecondary),
                                        SizedBox(width: R.w(4)),
                                        Expanded(
                                          child: Text(
                                            store.address!,
                                            style: AppFonts.fInterCaptionRegular.copyWith(color: AppColors.textSecondary),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (store.pickupDeliveryFee != null) ...[
                          SizedBox(height: R.h(12)),
                          Divider(color: Colors.grey.shade200, height: 1, thickness: 1),
                          SizedBox(height: R.h(12)),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(R.r(4)),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(R.r(4)),
                                ),
                                child: Icon(Icons.two_wheeler, size: R.r(14), color: AppColors.primary),
                              ),
                              SizedBox(width: R.w(8)),
                              Text(
                                'Biaya Antar Jemput',
                                style: AppFonts.fInterCaptionRegular.copyWith(color: AppColors.textSecondary),
                              ),
                              const Spacer(),
                              Text(
                                store.pickupDeliveryFee! == 0 
                                    ? 'GRATIS' 
                                    : NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(store.pickupDeliveryFee),
                                style: AppFonts.fInterCaptionMedium.copyWith(
                                  color: store.pickupDeliveryFee! == 0 ? AppColors.success600 : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: R.r(84),
      height: R.r(84),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
      ),
      child: Padding(
        padding: EdgeInsets.all(R.r(16)),
        child: Image.asset(
          AppAssets.mauNyuciPng,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
