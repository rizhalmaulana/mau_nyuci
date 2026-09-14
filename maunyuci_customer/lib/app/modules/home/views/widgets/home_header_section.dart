import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../core/widgets/custom_permission_modal.dart';
import '../../../../core/widgets/custom_location_picker.dart';
import '../../controllers/home_controller.dart';
import '../../../../core/utils/responsive_helper.dart';

class HomeHeader extends GetView<HomeController> {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(24.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: R.h(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      'Selamat Datang, ${controller.userName.value}',
                      style: AppFonts.fInterSubheadingSemibold.copyWith(
                        color: AppColors.white,
                        fontSize: R.sp(20),
                      ),
                    )),
                    SizedBox(height: R.h(4)),
                    Text(
                      'Ada yang bisa kami bantu cuci?',
                      style: AppFonts.fInterBodySmallRegular.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                          fontSize: R.sp(12)
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed('/notification');
                  // Set unread count to 0 optimistically or fetch later
                  controller.unreadNotificationCount.value = 0;
                },
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(R.r(10)),
                      decoration: BoxDecoration(
                        color: AppColors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(R.r(16)),
                      ),
                      child: SvgPicture.asset(
                        AppAssets.iconNotification,
                        width: R.r(24),
                        height: R.r(24),
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
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
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              )
            ],
          ),
          SizedBox(height: R.h(24)),
          _buildLocationSection(context),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Obx(() {
      final permissionStatus = controller.locationPermissionStatus.value;
      final isGpsEnabled = controller.isGpsEnabled.value;
      final isLocationLoading = controller.isLocationLoading.value;

      if (isLocationLoading) {
        return _buildLocationLoading();
      }

      if (permissionStatus.isDenied) {
        return _buildLocationRequest();
      }

      if (permissionStatus.isPermanentlyDenied) {
        return _buildLocationDenied();
      }

      if (!isGpsEnabled) {
        return _buildLocationGpsOff();
      }

      return _buildLocationEnabled(context);
    });
  }

  Widget _buildLocationLoading() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(8)),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(R.r(12)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: AppColors.white, size: R.r(20)),
          SizedBox(width: R.w(8)),
          Expanded(
            child: Text(
              'Memuat lokasi...',
              style: AppFonts.fInterBodySmallMedium.copyWith(color: AppColors.white, fontSize: R.sp(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRequest() {
    return GestureDetector(
      onTap: () async {
        final granted = await CustomPermissionModal.showLocationPermission();
        if (granted == true) {
          await controller.checkLocationPermissionAndFetch();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(8)),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(R.r(12)),
        ),
        child: Row(
          children: [
            Icon(Icons.location_off, color: AppColors.white, size: R.r(20)),
            SizedBox(width: R.w(8)),
            Expanded(
              child: Text(
                'Aktifkan lokasi untuk melihat alamat',
                style: AppFonts.fInterBodySmallMedium.copyWith(color: AppColors.white),
              ),
            ),
            SvgPicture.asset(
              AppAssets.iconArrowRight,
              width: R.r(20),
              height: R.r(20),
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDenied() {
    return GestureDetector(
      onTap: () async {
        final result = await Get.dialog<bool>(
          _LocationDeniedDialog(),
        );
        if (result == true) {
          await openAppSettings();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(8)),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(R.r(12)),
        ),
        child: Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange, size: R.r(20)),
            SizedBox(width: R.w(8)),
            Expanded(
              child: Text(
                'Izin lokasi ditolak. Buka pengaturan?',
                style: AppFonts.fInterBodySmallMedium.copyWith(color: AppColors.white),
              ),
            ),
            SvgPicture.asset(
              AppAssets.iconArrowRight,
              width: R.r(20),
              height: R.r(20),
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationGpsOff() {
    return GestureDetector(
      onTap: () async {
        await Geolocator.openLocationSettings();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(8)),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(R.r(12)),
        ),
        child: Row(
          children: [
            Icon(Icons.gps_off, color: Colors.orange, size: R.r(20)),
            SizedBox(width: R.w(8)),
            Expanded(
              child: Text(
                'Nyalakan GPS untuk lokasi akurat',
                style: AppFonts.fInterBodySmallMedium.copyWith(color: AppColors.white),
              ),
            ),
            SvgPicture.asset(
              AppAssets.iconArrowRight,
              width: R.r(20),
              height: R.r(20),
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationEnabled(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showLocationPicker(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(8)),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(R.r(12)),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on, color: AppColors.white, size: R.r(20)),
            SizedBox(width: R.w(8)),
            Expanded(
              child: Obx(() => Text(
                controller.userAddress.value,
                style: AppFonts.fInterBodySmallMedium.copyWith(color: AppColors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
            ),
            SvgPicture.asset(
              AppAssets.iconArrowRight,
              width: R.r(20),
              height: R.r(20),
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationPicker(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CustomLocationPicker(),
    );

    if (result != null) {
      controller.updateAddress(
        result['address'],
        result['lat'],
        result['lng'],
      );
    }
  }
}

class _LocationDeniedDialog extends StatelessWidget {
  const _LocationDeniedDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.symmetric(horizontal: R.w(32)),
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      child: Padding(
        padding: EdgeInsets.all(R.r(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(R.r(16)),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_rounded,
                color: Colors.orange,
                size: R.r(40),
              ),
            ),
            SizedBox(height: R.h(20)),
            Text(
              'Izin Lokasi Ditolak',
              style: AppFonts.fInterSubheadingSemibold.copyWith(
                color: AppColors.textPrimary,
                fontSize: R.r(18),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: R.h(12)),
            Text(
              'Izin lokasi ditolak. Mau Nyuci membutuhkan akses lokasi.',
              style: AppFonts.fInterBodySmallRegular.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: R.h(24)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: R.h(16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.r(12)),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Buka Pengaturan',
                  style: AppFonts.fInterBodyMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: R.h(12)),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(result: false),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: R.h(12)),
                ),
                child: Text(
                  'Nanti Saja',
                  style: AppFonts.fInterBodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
