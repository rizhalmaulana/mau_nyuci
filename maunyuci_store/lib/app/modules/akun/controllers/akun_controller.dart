import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/store_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/store_provider.dart';
import '../../../data/services/storage_service.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/custom_confirm_modal.dart';
import '../../../routes/app_pages.dart';
import '../../../routes/app_routes.dart';

class AkunController extends GetxController {
  final AuthProvider _authProvider = AuthProvider();
  final StoreProvider _storeProvider = StoreProvider();
  final StorageService _storageService = Get.find<StorageService>();

  final RxBool isLoading = true.obs;
  final RxBool isLoggingOut = false.obs;
  final RxBool isDeliveryEnabled = false.obs;

  final Rxn<UserModel> user = Rxn<UserModel>();
  final Rxn<StoreModel> store = Rxn<StoreModel>();

  @override
  void onInit() {
    super.onInit();
    _loadDeliverySetting();
    fetchData();
  }

  void _loadDeliverySetting() async {
    final val = await _storageService.read('isDeliveryEnabled');
    isDeliveryEnabled.value = val == 'true';
  }

  void toggleDelivery(bool value) {
    isDeliveryEnabled.value = value;
    _storageService.write('isDeliveryEnabled', value.toString());
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _authProvider.getProfile(),
        _storeProvider.getStoreProfile(),
      ]);

      final userResponse = results[0] as ApiResponse<UserModel>;
      final storeResponse = results[1] as ApiResponse<StoreModel>;

      if (userResponse.success && userResponse.data != null) {
        user.value = userResponse.data;
        await _storageService.write('membership_tier', user.value!.membershipTier);
        if (user.value!.storeRole.isNotEmpty) {
          await _storageService.write('store_role', user.value!.storeRole);
        }
      } else {
        CustomSnackbar.showError('Mohon Maaf', 'Gagal memuat profil: ${userResponse.message}');
      }

      if (storeResponse.success && storeResponse.data != null) {
        store.value = storeResponse.data;
      } else {
        CustomSnackbar.showError('Mohon Maaf', 'Gagal memuat data toko: ${storeResponse.message}');
      }
    } catch (e) {
      CustomSnackbar.showError('Mohon Maaf', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    CustomConfirmModal.show(
      title: "Konfirmasi Keluar",
      message: "Apakah Anda yakin ingin keluar dari aplikasi Toko?",
      textCancel: "Batal",
      textConfirm: "Keluar",
      onConfirm: () async {
        Get.back();
        isLoggingOut.value = true;
        try {
          await _storageService.deleteAll();
          Get.offAllNamed(Routes.LOGIN);
        } catch (e) {
          CustomSnackbar.showError('Mohon Maaf', 'Gagal Logout: $e');
        } finally {
          isLoggingOut.value = false;
        }
      },
    );
  }
}
