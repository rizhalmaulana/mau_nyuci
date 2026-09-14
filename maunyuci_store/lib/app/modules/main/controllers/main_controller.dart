import 'package:get/get.dart';
import '../../../data/models/menu_model.dart';
import '../../../data/providers/menu_provider.dart';
import '../../../data/services/storage_service.dart';

class MainController extends GetxController {
  final MenuProvider _menuProvider = MenuProvider();
  final StorageService _storageService = Get.find<StorageService>();

  /// True hanya untuk Owner bertier Premium. Dipakai untuk menampilkan
  /// seksi "Fitur Premium" (extraMenus). Selain itu disembunyikan.
  final RxBool isOwnerPremium = false.obs;

  // Seluruh menu dari BE (top-level + sub-menu, sudah di-flatten).
  final RxList<MenuModel> allMenus = <MenuModel>[].obs;

  // Bottom nav = SEMUA top-level (parentId == null) dari BE, tanpa hardcode.
  // Staff otomatis hanya dapat subset (Beranda, Pesanan, Layanan, Akun)
  // karena BE memang hanya mengirim itu.
  final RxList<MenuModel> bottomNavMenus = <MenuModel>[].obs;

  // Menu premium tampil di seksi "Fitur Premium" halaman Akun, BUKAN di
  // bottom nav. Deteksi utama dari field BE `requiredMembershipTier`.
  // Daftar path di bawah hanya fallback bila BE tidak mengirim field itu
  // (perilaku lama) — akses tetap dikendalikan BE via respons Menu.
  static const List<String> premiumPaths = ['/analitik', '/promo', '/pengeluaran'];
  final RxList<MenuModel> extraMenus = <MenuModel>[].obs;

  bool _isPremiumMenu(MenuModel menu) {
    final tier = menu.requiredMembershipTier;
    if (tier != null && tier.isNotEmpty) {
      return tier.toLowerCase() == 'premium';
    }
    return premiumPaths.contains(menu.path);
  }

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Index untuk BottomNavigationBar
  final currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMenus();
  }

  Future<void> _loadAccess() async {
    final role = await _storageService.read('user_role');
    final tier = await _storageService.read('membership_tier');
    isOwnerPremium.value = role == 'Owner' && tier == 'Premium';
  }

  Future<void> fetchMenus() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _loadAccess();

      final fetchedMenus = await _menuProvider.fetchMenus('Store');

      // Flatten: dukung respons flat (parentId) maupun nested (subMenus).
      final flat = <MenuModel>[];
      for (final menu in fetchedMenus) {
        flat.add(menu);
        for (final sub in menu.subMenus) {
          flat.add(
            MenuModel(
              id: sub.id,
              parentId: sub.parentId ?? menu.id,
              title: sub.title,
              path: sub.path,
              icon: sub.icon,
              sortOrder: sub.sortOrder,
              isActive: sub.isActive,
              requiredRole: sub.requiredRole,
              requiredMembershipTier: sub.requiredMembershipTier,
            ),
          );
        }
      }

      final active = flat.where((m) => m.isActive).toList();
      allMenus.assignAll(active);

      final topLevel = active.where((m) => m.isTopLevel).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      // Premium -> seksi Akun HANYA bila Owner Premium; selain itu disembunyikan.
      // Sisanya -> bottom nav.
      if (isOwnerPremium.value) {
        extraMenus.assignAll(topLevel.where(_isPremiumMenu).toList());
      } else {
        extraMenus.clear();
      }
      bottomNavMenus.assignAll(topLevel.where((m) => !_isPremiumMenu(m)).toList());

      if (currentIndex.value >= bottomNavMenus.length) {
        currentIndex.value = 0;
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Sub-menu dari sebuah parent (dicari by path, mis. '/layanan' atau '/akun'),
  /// yaitu item yang `parentId`-nya merujuk ke ID parent tersebut.
  List<MenuModel> subMenusOf(String parentPath) {
    final parent = allMenus.firstWhereOrNull((m) => m.path == parentPath);
    if (parent == null) return [];
    final subs = allMenus.where((m) => m.parentId == parent.id).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return subs;
  }

  void changePage(int index) {
    if (index >= 0 && index < bottomNavMenus.length) {
      currentIndex.value = index;
    }
  }
}
