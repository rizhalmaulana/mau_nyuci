import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../routes/app_routes.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/providers/store_provider.dart';

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  var appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _getAppVersion();
  }

  @override
  void onReady() {
    super.onReady();
    _checkLoginStatus();
  }

  Future<void> _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = packageInfo.version;
    } catch (e) {
      appVersion.value = 'Dev1.0.0';
    }
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    final storage = Get.find<StorageService>();
    final token = await storage.getToken();
    final role = await storage.read('user_role');

    if (token != null && token.isNotEmpty) {
      // Owner & StoreStaff sama-sama sesi valid. Staff tidak pernah
      // diarahkan ke Register Store (hanya Owner).
      if (role == 'Owner' || role == 'StoreStaff') {
        try {
          final storeProvider = StoreProvider();
          final storeResponse = await storeProvider.getMyStore();
          final storeData = storeResponse.data;

          String? storeId;
          bool registered = true;
          if (storeData is Map) {
            if (storeData['isStoreRegistered'] == false) registered = false;
            final inner = storeData['data'];
            storeId = ((inner is Map ? inner['id'] : null) ?? storeData['id'] ?? storeData['storeId'])?.toString();
          }
          if (storeId != null) {
            await storage.write('storeId', storeId);
          }

          if (role == 'Owner' && !registered) {
            Get.offAllNamed(Routes.REGISTER_STORE);
          } else {
            Get.offAllNamed(Routes.MAIN);
          }
        } catch (e) {
          Get.offAllNamed(Routes.MAIN); // Fallback jika tidak ada internet
        }
      } else {
        await storage.deleteAll();
        Get.offAllNamed(Routes.LOGIN);
      }
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}

