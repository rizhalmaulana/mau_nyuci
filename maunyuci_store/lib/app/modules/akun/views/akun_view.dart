import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/utils/menu_mapper.dart';
import '../../../routes/app_routes.dart';
import '../controllers/akun_controller.dart';
import '../../main/controllers/main_controller.dart';
import '../../../data/models/menu_model.dart';
import '../../../core/utils/role_label.dart';
import '../../../core/widgets/premium_promo_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

class AkunView extends GetView<AkunController> {
  const AkunView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text('Akun & Pengaturan', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(18), color: AppColors.black87)),
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchData,
        child: Obx(() {
          if (controller.isLoading.value && controller.user.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = controller.user.value;
          final store = controller.store.value;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(R.w(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- HEADER: USER PROFILE ---
                if (user != null)
                  Container(
                    padding: EdgeInsets.all(R.w(16)),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(R.r(16)),
                      boxShadow: [
                        BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: R.r(64),
                              height: R.r(64),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(alpha: 0.1),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: user.profilePictureUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: user.profilePictureUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Padding(
                                        padding: EdgeInsets.all(R.r(16)),
                                        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                                      ),
                                      errorWidget: (context, url, error) => Icon(Icons.person, size: R.r(32), color: AppColors.primary),
                                    )
                                  : Icon(Icons.person, size: R.r(32), color: AppColors.primary),
                            ),
                            if (Get.isRegistered<MainController>() && Get.find<MainController>().extraMenus.isNotEmpty)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(R.w(4)),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning500,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(color: AppColors.black12, blurRadius: 4, offset: const Offset(0, 2))
                                    ],
                                  ),
                                  child: Icon(Icons.workspace_premium, color: AppColors.white, size: R.r(12)),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(width: R.w(16)),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final isStaff = user.role == 'StoreStaff';
                              final contact = isStaff
                                  ? (user.phoneNumber.isNotEmpty ? user.phoneNumber : user.email)
                                  : user.email;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user.fullName.isNotEmpty ? user.fullName : 'Mitra MauNyuci', style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold, color: AppColors.black87)),
                                  if (contact.isNotEmpty) ...[
                                    SizedBox(height: R.h(4)),
                                    Text(contact, style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey600)),
                                  ],
                                  SizedBox(height: R.h(4)),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(2)),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(R.r(4)),
                                    ),
                                    child: Text(roleLabel(user), style: AppFonts.inter(fontSize: R.sp(10), fontWeight: FontWeight.w600, color: AppColors.primary)),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: R.h(16)),

                // --- STORE PROFILE CARD ---
                if (store != null)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(R.r(16)),
                      boxShadow: [
                        BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Store Image Banner
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(16))),
                          child: store.storeImageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: store.storeImageUrl,
                                  height: R.h(120),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(height: R.h(120), color: AppColors.grey100, child: const Center(child: CircularProgressIndicator())),
                                  errorWidget: (context, url, error) => Container(height: R.h(120), color: AppColors.grey200, child: const Icon(Icons.store, color: AppColors.grey500)),
                                )
                              : Container(height: R.h(120), color: AppColors.primary.withValues(alpha: 0.1), child: Icon(Icons.storefront, size: R.r(48), color: AppColors.primary)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(R.w(16)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(store.name, style: AppFonts.inter(fontSize: R.sp(16), fontWeight: FontWeight.bold))),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: R.w(8), vertical: R.h(4)),
                                    decoration: BoxDecoration(
                                      color: store.isCurrentlyOpen ? AppColors.success50 : AppColors.danger50,
                                      borderRadius: BorderRadius.circular(R.r(12)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.circle, size: R.r(8), color: store.isCurrentlyOpen ? AppColors.success : AppColors.danger),
                                        SizedBox(width: R.w(4)),
                                        Text(store.isCurrentlyOpen ? 'Buka' : 'Tutup', style: AppFonts.inter(fontSize: R.sp(12), fontWeight: FontWeight.bold, color: store.isCurrentlyOpen ? AppColors.success : AppColors.danger)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: R.h(8)),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: R.r(14), color: AppColors.grey600),
                                  SizedBox(width: R.w(4)),
                                  Text(store.operatingHoursFormatted.isNotEmpty ? store.operatingHoursFormatted : '-', style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey600)),
                                ],
                              ),
                              SizedBox(height: R.h(8)),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on_outlined, size: R.r(14), color: AppColors.grey600),
                                  SizedBox(width: R.w(4)),
                                  Expanded(child: Text(store.address, style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey600), maxLines: 2, overflow: TextOverflow.ellipsis)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // --- BANNER PROMOSI PREMIUM (Server-Driven UI) ---
                // Widget mengambil GET /api/PromoBanners?appType=Store dan
                // memfilter via targetRoles/targetTiers; fallback lokal hanya
                // untuk Owner non-Premium. Selain itu widget menyembunyikan diri.
                if (user != null) ...[
                  SizedBox(height: R.h(16)),
                  PremiumPromoSlider(
                    role: user.role,
                    membershipTier: user.membershipTier,
                  ),
                ],

                SizedBox(height: R.h(24)),

                // --- FITUR PREMIUM ---
                if (Get.isRegistered<MainController>() && Get.find<MainController>().extraMenus.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.workspace_premium, color: AppColors.warning600, size: R.r(20)),
                      SizedBox(width: R.w(8)),
                      Text('Fitur Premium', style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.bold, color: AppColors.warning700)),
                    ],
                  ),
                  SizedBox(height: R.h(8)),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(R.r(16)),
                      border: Border.all(color: AppColors.warning200),
                      boxShadow: [
                        BoxShadow(color: AppColors.warning.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      children: Get.find<MainController>().extraMenus.map((menu) {
                        return Column(
                          children: [
                            ListTile(
                              leading: MenuMapper.getIcon(menu.icon, color: AppColors.warning600),
                              title: Text(menu.title, style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w600, color: AppColors.black87)),
                              trailing: Icon(Icons.chevron_right, color: AppColors.grey400, size: R.r(20)),
                              onTap: () {
                                Get.to(() => MenuMapper.getScreen(menu.path));
                              },
                            ),
                            if (menu != Get.find<MainController>().extraMenus.last)
                              const Divider(height: 1),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: R.h(24)),
                ],

                // --- SUB-MENU DINAMIS DARI BE (parentId -> menu Akun) ---
                // Tanpa hardcode: StoreStaff tidak menerima "Katalog Stok",
                // "Ubah Profil", dll sehingga otomatis tidak tampil di sini.
                if (Get.isRegistered<MainController>())
                  Obx(() {
                    final subMenus = Get.find<MainController>().subMenusOf('/akun');
                    if (subMenus.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Kelola', style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.bold, color: AppColors.grey600)),
                        SizedBox(height: R.h(8)),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(R.r(16)),
                            border: Border.all(color: AppColors.grey200),
                          ),
                          child: Column(
                            children: [
                              for (int i = 0; i < subMenus.length; i++) ...[
                                _buildDynamicMenuTile(
                                  menu: subMenus[i],
                                  onTap: () => MenuMapper.openSubMenu(
                                    subMenus[i],
                                    store: controller.store.value,
                                  ),
                                ),
                                if (i != subMenus.length - 1) const Divider(height: 1),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: R.h(24)),
                      ],
                    );
                  }),

                Text('Pengaturan Akun', style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.bold, color: AppColors.grey600)),
                SizedBox(height: R.h(8)),

                // --- MENU LOKAL (perangkat/akun, bukan fitur akses BE) ---
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(R.r(16)),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: Column(
                    children: [
                      _buildMenuTile(
                        icon: Icons.person_outline,
                        title: 'Ubah Profil Akun',
                        onTap: () async {
                          final result = await Get.toNamed(Routes.EDIT_PROFILE, arguments: controller.user.value);
                          if (result == true) {
                            controller.fetchData();
                          }
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
                      const Divider(height: 1),
                      _buildMenuTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Kebijakan & Privasi',
                        onTap: () {
                          Get.toNamed(Routes.PRIVACY_POLICY);
                        },
                      ),
                      const Divider(height: 1),
                      _buildMenuTile(
                        icon: Icons.print_outlined,
                        title: 'Pengaturan Printer Thermal',
                        onTap: () {
                          Get.toNamed(Routes.PRINTER_SETTINGS);
                        },
                      ),
                      const Divider(height: 1),
                      Obx(() => SwitchListTile(
                            value: controller.isDeliveryEnabled.value,
                            onChanged: controller.toggleDelivery,
                            title: Text('Layanan Pengantaran (Driver)',
                                style: AppFonts.inter(
                                    fontSize: R.sp(14),
                                    fontWeight: FontWeight.w500)),
                            activeColor: AppColors.primary,
                            secondary: Icon(Icons.delivery_dining_outlined,
                                color: AppColors.grey700, size: R.r(24)),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: R.w(16)),
                          )),
                    ],
                  ),
                ),

                SizedBox(height: R.h(24)),
                
                // --- LOGOUT BUTTON ---
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoggingOut.value ? null : controller.logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger50,
                    foregroundColor: AppColors.danger,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: R.h(16)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                  ),
                  child: controller.isLoggingOut.value 
                      ? SizedBox(height: R.h(20), width: R.h(20), child: const CircularProgressIndicator(color: AppColors.danger, strokeWidth: 2))
                      : Text('Keluar Akun', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(14))),
                )),
                
                SizedBox(height: R.h(32)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMenuTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grey700, size: R.r(24)),
      title: Text(title, style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: AppColors.grey400, size: R.r(20)),
      onTap: onTap,
    );
  }

  Widget _buildDynamicMenuTile({required MenuModel menu, required VoidCallback onTap}) {
    return ListTile(
      leading: MenuMapper.getIcon(menu.icon, color: AppColors.grey700),
      title: Text(menu.title, style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: AppColors.grey400, size: R.r(20)),
      onTap: onTap,
    );
  }
}
