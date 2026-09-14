import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../core/utils/responsive_helper.dart';
import '../controllers/account_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/helpers/api_error_helper.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../routes/app_pages.dart';

class AccountView extends GetView<AccountController> {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Akun & Pengaturan', 
          style: AppFonts.fInterSubheadingSemibold.copyWith(
            fontSize: R.sp(18), 
            color: Colors.black87
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchProfile();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(R.w(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- HEADER: USER PROFILE ---
              Container(
                padding: EdgeInsets.all(R.w(16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(R.r(16)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
                      final rawUrl = controller.profilePictureUrl.value;
                      final imgUrl = getFullImageUrl(rawUrl);

                      final hasValidUrl = imgUrl.isNotEmpty && imgUrl.startsWith('http');
                      if (hasValidUrl) {
                        return ClipOval(
                          child: Image.network(
                            imgUrl,
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
                        radius: R.r(32),
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
                                style: AppFonts.fInterBodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                              );
                            }
                            return Text(
                              controller.fullName.value,
                              style: AppFonts.fInterBodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                            );
                          }),
                          SizedBox(height: R.h(4)),
                          Obx(() {
                            if (controller.isFetchingProfile.value) return const SizedBox();
                            return Text(
                              controller.email.value,
                              style: AppFonts.fInterBodySmallRegular.copyWith(color: Colors.grey.shade600),
                            );
                          }),
                          SizedBox(height: R.h(4)),
                          Obx(() {
                            if (controller.isFetchingProfile.value) return const SizedBox();
                            return Text(
                              controller.phone.value,
                              style: AppFonts.fInterBodySmallRegular.copyWith(color: Colors.grey.shade600),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: R.h(24)),
              Text(
                'Detail Informasi',
                style: AppFonts.fInterBodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade600),
              ),
              SizedBox(height: R.h(8)),

              // --- MENUS ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(R.r(16)),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: SvgPicture.asset(
                        AppAssets.iconUserRounded,
                        width: R.r(24),
                        height: R.r(24),
                        colorFilter: ColorFilter.mode(Colors.grey.shade700, BlendMode.srcIn),
                      ),
                      title: 'Ubah Profil',
                      onTap: () async {
                        await Get.toNamed(Routes.EDIT_PROFILE);
                        controller.fetchProfile();
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      icon: SvgPicture.asset(
                        AppAssets.iconLockKey,
                        width: R.r(24),
                        height: R.r(24),
                        colorFilter: ColorFilter.mode(Colors.grey.shade700, BlendMode.srcIn),
                      ),
                      title: 'Ubah Password',
                      onTap: () {
                        Get.toNamed(Routes.CHANGE_PASSWORD);
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      icon: SvgPicture.asset(
                        AppAssets.iconDocumentText,
                        width: R.r(24),
                        height: R.r(24),
                        colorFilter: ColorFilter.mode(Colors.grey.shade700, BlendMode.srcIn),
                      ),
                      title: 'Ketentuan Layanan',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      icon: SvgPicture.asset(
                        AppAssets.iconShieldStar,
                        width: R.r(24),
                        height: R.r(24),
                        colorFilter: ColorFilter.mode(Colors.grey.shade700, BlendMode.srcIn),
                      ),
                      title: 'Kebijakan Privasi',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      icon: SvgPicture.asset(
                        AppAssets.iconShieldStar, // Can be changed to info icon later
                        width: R.r(24),
                        height: R.r(24),
                        colorFilter: ColorFilter.mode(Colors.grey.shade700, BlendMode.srcIn),
                      ),
                      title: 'Tentang Aplikasi',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              SizedBox(height: R.h(24)),
              
              // --- LOGOUT BUTTON ---
              Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: R.h(16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                ),
                child: controller.isLoading.value 
                    ? SizedBox(height: R.h(20), width: R.h(20), child: const CircularProgressIndicator(color: Colors.red, strokeWidth: 2))
                    : Text(
                        'Keluar Akun', 
                        style: AppFonts.fInterBodyMedium.copyWith(
                          fontWeight: FontWeight.bold, 
                          color: Colors.red
                        ),
                      ),
              )),
              
              SizedBox(height: R.h(32)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: icon,
      title: Text(
        title, 
        style: AppFonts.fInterBodyMedium.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        )
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: R.r(20)),
      onTap: onTap,
    );
  }
}
