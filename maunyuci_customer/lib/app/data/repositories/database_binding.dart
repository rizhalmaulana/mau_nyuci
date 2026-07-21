import 'package:get/get.dart';
import 'package:maunyuci_core/database/app_database.dart';

import 'user_session_repository.dart';
import 'user_profile_repository.dart';
import 'address_repository.dart';

class DatabaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AppDatabase(), permanent: true);
    
    Get.lazyPut(() => UserSessionRepository(Get.find<AppDatabase>()), fenix: true);
    Get.lazyPut(() => UserProfileRepository(Get.find<AppDatabase>()), fenix: true);
    Get.lazyPut(() => AddressRepository(), fenix: true);
  }
}