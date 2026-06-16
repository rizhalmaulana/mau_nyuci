import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../core/utils/responsive_helper.dart';
import '../controllers/account_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../routes/app_pages.dart';

class AccountView extends GetView<AccountController> {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: R.r(32)),
        child: Stack(
          children: [
            Container(
              height: R.h(250),
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: R.w(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: R.h(16)),
                    Text(
                      'Akun',
                      style: AppFonts.fInterSubheadingSemibold.copyWith(
                        color: AppColors.white,
                        fontSize: R.sp(24),
                      ),
                    ),
                    SizedBox(height: R.h(32)),
                    Container(
                      padding: EdgeInsets.all(R.r(16)),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(R.r(16)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Obx(() {
                            if (controller.isFetchingProfile.value) {
                              return Container(
                                width: R.r(64),
                                height: R.r(64),
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                                child: const CircularProgressIndicator(color: Colors.white),
                              );
                            }
                            if (controller.profilePictureUrl.value != null && controller.profilePictureUrl.value!.isNotEmpty) {
                              return ClipOval(
                                child: Image.network(
                                  controller.profilePictureUrl.value!,
                                  width: R.r(64),
                                  height: R.r(64),
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return SizedBox(
                                      width: R.r(64),
                                      height: R.r(64),
                                      child: const CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: R.r(64),
                                    height: R.r(64),
                                    color: AppColors.primary,
                                    child: Center(
                                      child: Text(
                                        controller.initials,
                                        style: AppFonts.fInterSubheadingSemibold.copyWith(
                                          color: AppColors.white,
                                          fontSize: R.sp(20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            return CircleAvatar(
                                radius: 32,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  controller.initials,
                                  style: AppFonts.fInterSubheadingSemibold.copyWith(
                                    color: AppColors.white,
                                    fontSize: R.sp(20),
                                  ),
                                ),
                            );
                          }),
                          SizedBox(width: R.w(16)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() {
                                  if (controller.isFetchingProfile.value) {
                                    return Text(
                                      'Memuat...',
                                      style: AppFonts.fInterBodyMedium.copyWith(fontWeight: FontWeight.bold),
                                    );
                                  }
                                  return Text(
                                    controller.fullName.value,
                                    style: AppFonts.fInterBodyMedium.copyWith(fontWeight: FontWeight.bold),
                                  );
                                }),
                                SizedBox(height: R.h(4)),
                                Obx(() {
                                  if (controller.isFetchingProfile.value) return const SizedBox();
                                  return Text(
                                    controller.email.value,
                                    style: AppFonts.fInterBodySmallRegular.copyWith(color: AppColors.textSecondary),
                                  );
                                }),
                                SizedBox(height: R.h(2)),
                                Obx(() {
                                  if (controller.isFetchingProfile.value) return const SizedBox();
                                  return Text(
                                    controller.phone.value,
                                    style: AppFonts.fInterBodySmallRegular.copyWith(color: AppColors.textSecondary),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: R.h(24)),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(R.r(16)),
                        border: Border.all(
                            color: AppColors.border.withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                                R.r(16), R.r(16), R.r(16), R.r(8)),
                            child: Text(
                              'Detail Informasi',
                              style: AppFonts.fInterSubheadingSemibold,
                            ),
                          ),
                          Divider(height: R.h(1)),
                          SizedBox(height: R.h(8)),
                          _buildMenuItem(
                            icon: SvgPicture.asset(
                              AppAssets.iconUserRounded,
                              width: R.r(24),
                              height: R.r(24),
                              colorFilter: const ColorFilter.mode(
                                  AppColors.textSecondary, BlendMode.srcIn),
                            ),
                            title: 'Ubah Profil',
                            onTap: () async {
                              await Get.toNamed(Routes.EDIT_PROFILE);
                              controller.fetchProfile();
                            },
                          ),
                          SizedBox(height: R.h(16)),
                          _buildMenuItem(
                            icon: SvgPicture.asset(
                              AppAssets.iconLockKey,
                              width: R.r(24),
                              height: R.r(24),
                              colorFilter: const ColorFilter.mode(
                                  AppColors.textSecondary, BlendMode.srcIn),
                            ),
                            title: 'Ubah Password',
                            onTap: () {
                              Get.toNamed(Routes.CHANGE_PASSWORD);
                            },
                          ),
                          SizedBox(height: R.h(16)),
                          _buildMenuItem(
                            icon: SvgPicture.asset(
                              AppAssets.iconDocumentText,
                              width: R.r(24),
                              height: R.r(24),
                              colorFilter: const ColorFilter.mode(
                                  AppColors.textSecondary, BlendMode.srcIn),
                            ),
                            title: 'Ketentuan Layanan',
                            onTap: () {},
                          ),
                          SizedBox(height: R.h(16)),
                          _buildMenuItem(
                            icon: SvgPicture.asset(
                              AppAssets.iconShieldStar,
                              width: R.r(24),
                              height: R.r(24),
                              colorFilter: const ColorFilter.mode(
                                  AppColors.textSecondary, BlendMode.srcIn),
                            ),
                            title: 'Kebijakan Privasi',
                            onTap: () {},
                          ),
                          SizedBox(height: R.h(16)),
                          _buildMenuItem(
                            icon: SvgPicture.asset(
                              AppAssets.iconShieldStar,
                              width: R.r(24),
                              height: R.r(24),
                              colorFilter: const ColorFilter.mode(
                                  AppColors.textSecondary, BlendMode.srcIn),
                            ),
                            title: 'Tentang Aplikasi',
                            onTap: () {},
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: R.h(14)),
                    Obx(() => InkWell(
                          onTap: controller.isLoading.value
                              ? null
                              : controller.logout,
                          borderRadius: BorderRadius.circular(R.r(16)),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: R.h(16), horizontal: R.w(16)),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(R.r(16)),
                              border: Border.all(
                                  color: AppColors.border.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                controller.isLoading.value
                                    ? SizedBox(
                                        width: R.r(24),
                                        height: R.r(24),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.red,
                                        ),
                                      )
                                    : SvgPicture.asset(
                                        AppAssets.iconLogout,
                                        width: R.r(24),
                                        height: R.r(24),
                                        colorFilter: const ColorFilter.mode(
                                            Colors.red, BlendMode.srcIn),
                                      ),
                                SizedBox(width: R.w(16)),
                                Text(
                                  controller.isLoading.value
                                      ? 'Keluar...'
                                      : 'Keluar',
                                  style: AppFonts.fInterBodyMedium.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required Widget icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: R.r(16),
          right: R.r(16),
          top: R.r(12),
          bottom: isLast ? R.r(16) : R.r(12),
        ),
        child: Row(
          children: [
            SizedBox(width: R.w(24), height: R.h(24), child: icon),
            SizedBox(width: R.w(16)),
            Expanded(
              child: Text(
                title,
                style: AppFonts.fInterBodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: R.sp(20)),
          ],
        ),
      ),
    );
  }
}
