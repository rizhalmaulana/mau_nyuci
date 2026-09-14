import 'package:get/get.dart';
import 'package:maunyuci_customer/app/routes/app_pages.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:maunyuci_core/maunyuci_core.dart';

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
    _initProcess();
  }

  Future<void> _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = packageInfo.version;
    } catch (e) {
      appVersion.value = 'Dev1.0.0';
    }
  }

  Future<void> _initProcess() async {
    await Future.delayed(const Duration(seconds: 2));

    String nextRoute = Routes.LOGIN;
    try {
      final String? token = await SecureStorageHelper.getToken();
      final String? role = await SecureStorageHelper.getRole();
      
      if (token != null && token.isNotEmpty) {
        if (role == 'Customer') {
          nextRoute = Routes.HOME;
        } else {
          await SecureStorageHelper.clearAll();
          nextRoute = Routes.LOGIN;
        }
      }
    } catch (e) {
      nextRoute = Routes.LOGIN;
    }

    Get.offAllNamed(nextRoute);
  }
}