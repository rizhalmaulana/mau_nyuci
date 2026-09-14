import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/menu_model.dart';
import '../../routes/app_routes.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/layanan/views/layanan_view.dart';
import '../../modules/layanan/views/katalog_laundry_view.dart';
import '../../modules/layanan/controllers/layanan_controller.dart';
import '../../modules/akun/views/akun_view.dart';
import '../../modules/akun/controllers/akun_controller.dart';
import '../../modules/all_orders/views/all_orders_view.dart';
import '../../modules/all_orders/controllers/all_orders_controller.dart';
import '../../modules/history_orders/views/history_orders_view.dart';
import '../../modules/history_orders/controllers/history_orders_controller.dart';
import '../../modules/analytics/views/analytics_view.dart';
import '../../modules/analytics/controllers/analytics_controller.dart';
import '../../modules/promo/views/promo_view.dart';
import '../../modules/promo/controllers/promo_controller.dart';
import '../../modules/expense/views/expense_view.dart';
import '../../modules/expense/controllers/expense_controller.dart';
import '../../modules/inventory/views/inventory_view.dart';
import '../constants/app_fonts.dart';
import '../constants/app_colors.dart';
import 'responsive_helper.dart';

class MenuMapper {
  static Widget getIcon(String iconString, {Color? color}) {
    if (iconString.startsWith('ic_')) {
      return Image.asset(
        'assets/icons/$iconString.png',
        width: 24,
        height: 24,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.layers_outlined, color: color, size: 24);
        },
      );
    }

    // Map material icons as fallback
    switch (iconString) {
      case 'home':
        return Icon(Icons.home, color: color);
      case 'receipt':
        return Icon(Icons.receipt, color: color);
      case 'receipt_long':
        return Icon(Icons.receipt_long, color: color);
      case 'person':
        return Icon(Icons.person, color: color);
      case 'people':
      case 'group':
      case 'staff':
        return Icon(Icons.people_outline, color: color);
      case 'local_laundry_service':
        return Icon(Icons.local_laundry_service, color: color);
      case 'local_offer':
        return Icon(Icons.local_offer, color: color);
      case 'pie_chart':
        return Icon(Icons.pie_chart, color: color);
      case 'inventory':
      case 'inventory_2':
      case 'stock':
      case 'box':
        return Icon(Icons.inventory_2_outlined, color: color);
      case 'payments':
      case 'payment':
      case 'wallet':
      case 'account_balance_wallet':
        return Icon(Icons.account_balance_wallet_outlined, color: color);
      case 'store':
      case 'storefront':
        return Icon(Icons.storefront_outlined, color: color);
      case 'settings':
        return Icon(Icons.settings_outlined, color: color);
      default:
        return Icon(Icons.circle, color: color); // Fallback icon
    }
  }

  static Widget getScreen(String pathString) {
    switch (pathString) {
      case '/home':
        return const HomeView();
      case '/pesanan':
      case '/riwayat':
        if (!Get.isRegistered<HistoryOrdersController>()) {
          Get.put(HistoryOrdersController());
        }
        return const HistoryOrdersView();

      case '/layanan':
        // Inject Controller dynamically here since we use bottom nav,
        // or ensure MainBinding initializes it. For now, just initialize it here:
        if (!Get.isRegistered<LayananController>()) {
          Get.put(LayananController());
        }
        return const LayananView();
      case '/layanan/katalog':
        if (!Get.isRegistered<LayananController>()) {
          Get.put(LayananController());
        }
        return const KatalogLaundryView();
      case '/layanan/stok':
        return const InventoryView();
      case '/akun':
        if (!Get.isRegistered<AkunController>()) {
          Get.put(AkunController());
        }
        return const AkunView();

      // --- PREMIUM FEATURES ---
      case '/analitik':
        if (!Get.isRegistered<AnalyticsController>()) {
          Get.put(AnalyticsController());
        }
        return const AnalyticsView();
      case '/promo':
        if (!Get.isRegistered<PromoController>()) {
          Get.put(PromoController());
        }
        return const PromoView();
      case '/pengeluaran':
        if (!Get.isRegistered<ExpenseController>()) {
          Get.put(ExpenseController());
        }
        return const ExpenseView();

      default:
        return Center(child: Text('Unknown Page: $pathString'));
    }
  }

  /// Navigasi sub-menu dinamis dari BE. Tanpa hardcode role:
  /// apa yang dikirim BE, itu yang bisa dibuka.
  /// [store] diteruskan untuk sub-menu yang butuh data toko (mis. /akun/profil).
  static void openSubMenu(MenuModel menu, {dynamic store}) {
    switch (menu.path) {
      case '/layanan/katalog':
        if (!Get.isRegistered<LayananController>()) {
          Get.put(LayananController());
        }
        Get.to(() => const KatalogLaundryView());
        break;
      case '/layanan/stok':
        Get.toNamed(Routes.INVENTORY);
        break;
      case '/akun/staff':
        Get.toNamed(Routes.STAFF);
        break;
      case '/akun/pembayaran':
        Get.toNamed(Routes.BANK_ACCOUNT);
        break;
      case '/akun/profil':
        Get.toNamed(Routes.EDIT_STORE, arguments: store);
        break;
      default:
        Get.to(() => UnknownMenuView(menu: menu));
    }
  }
}

/// Fallback bila BE mengirim sub-menu yang belum dikenal aplikasi.
/// Menampilkan info, bukan crash — forward-compatible.
class UnknownMenuView extends StatelessWidget {
  final MenuModel menu;
  const UnknownMenuView({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(menu.title.isNotEmpty ? menu.title : 'Menu')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(R.w(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction_outlined, size: R.r(64), color: AppColors.grey400),
              SizedBox(height: R.h(16)),
              Text(
                'Halaman "${menu.title}" belum tersedia di versi aplikasi ini.',
                textAlign: TextAlign.center,
                style: AppFonts.inter(fontSize: R.sp(14), color: AppColors.grey600),
              ),
              SizedBox(height: R.h(8)),
              Text(
                'Silakan perbarui aplikasi ke versi terbaru.',
                textAlign: TextAlign.center,
                style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
