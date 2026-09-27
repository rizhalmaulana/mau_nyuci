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
            color: Colors.black87,
            fontSize: R.sp(20)
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchProfile();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            left: R.w(16),
            right: R.w(16),
            top: R.w(16),
            bottom: R.w(16) + MediaQuery.of(context).padding.bottom,
          ),
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
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const CircularProgressIndicator(),
                        );
                      }
                      final rawUrl = controller.profilePictureUrl.value;
                      final imgUrl = getFullImageUrl(rawUrl);

                      final hasValidUrl = imgUrl.isNotEmpty && imgUrl.startsWith('http');
                      return Container(
                        width: R.r(64),
                        height: R.r(64),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: hasValidUrl
                            ? CachedNetworkImage(
                                imageUrl: imgUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Padding(
                                  padding: EdgeInsets.all(R.r(16)),
                                  child: const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                                ),
                                errorWidget: (context, url, error) => Icon(Icons.person, size: R.r(32), color: AppColors.primary),
                              )
                            : Center(
                                child: Text(
                                  controller.initials,
                                  style: AppFonts.fInterSubheadingSemibold.copyWith(
                                    color: AppColors.primary,
                                    fontSize: R.sp(20),
                                  ),
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
                              controller.phone.value.isNotEmpty ? controller.phone.value : controller.email.value,
                              style: AppFonts.fInterBodySmallRegular.copyWith(color: Colors.grey.shade600),
                            );
                          }),
                          SizedBox(height: R.h(4)),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(2)),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(R.r(4)),
                            ),
                            child: Text(
                              'Pelanggan', 
                              style: AppFonts.fInterStatusSemibold.copyWith(color: AppColors.primary)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: R.h(24)),
              Text('Pengaturan Akun', style: AppFonts.fInterBodySmallMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
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
                    _buildMenuTile(
                      icon: Icons.person_outline,
                      title: 'Ubah Profil',
                      onTap: () async {
                        await Get.toNamed(Routes.EDIT_PROFILE);
                        controller.fetchProfile();
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuTile(
                      icon: Icons.lock_outline,
                      title: 'Ubah Password',
                      onTap: () {
                        Get.toNamed(Routes.CHANGE_PASSWORD);
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: R.h(24)),
              Text('Pusat Bantuan & Kebijakan', style: AppFonts.fInterBodySmallMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
              SizedBox(height: R.h(8)),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(R.r(16)),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildMenuTile(
                      icon: Icons.description_outlined,
                      title: 'Ketentuan Layanan',
                      onTap: () {
                        Get.toNamed(Routes.TERMS_OF_SERVICE);
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Kebijakan Privasi',
                      onTap: () {
                        Get.toNamed(Routes.PRIVACY_POLICY);
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuTile(
                      icon: Icons.info_outline,
                      title: 'Tentang Aplikasi',
                      onTap: () {
                        Get.toNamed(Routes.ABOUT_APP);
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: R.h(32)),
              
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
                        style: AppFonts.fInterBodySmallMedium.copyWith(
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

  Widget _buildMenuTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700, size: R.r(24)),
      title: Text(title, style: AppFonts.fInterBodySmallMedium.copyWith(fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400, size: R.r(20)),
      onTap: onTap,
    );
  }
}
