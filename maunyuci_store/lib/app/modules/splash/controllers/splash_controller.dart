import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../routes/app_routes.dart';

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

    final token = await SecureStorageHelper.getToken();
    final role = await SecureStorageHelper.read('role');

    if (token != null && token.isNotEmpty && role == 'Owner') {
      Get.offAllNamed(Routes.HOME);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
