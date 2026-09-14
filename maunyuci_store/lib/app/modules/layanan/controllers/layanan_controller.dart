import 'package:get/get.dart';
import '../../../data/models/layanan_model.dart';
import '../../../data/providers/layanan_provider.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../data/providers/layanan_provider.dart';

class LayananController extends GetxController {
  final layanans = <LayananModel>[].obs;
  final isLoading = false.obs;
  
  final LayananProvider _provider = LayananProvider();
  
  // Available default assets from CDN
  final RxList<String> defaultAssets = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCatalog();
    fetchAvailableIcons();
  }

  Future<void> fetchAvailableIcons() async {
    final response = await _provider.getAvailableIcons();
    if (response.success && response.data != null) {
      defaultAssets.assignAll(response.data!);
    } else {
      // Fallback if fails
      defaultAssets.assignAll([
        'img_laundry_item.png',
        'img_kaos_satuan.png',
        'img_kemeja_satuan.png',
        'img_jeans.png',
        'img_celana.png',
        'img_jas.png',
        'img_hoodie.png',
        'img_batik.png',
        'img_bedcover.png',
        'img_selimut.png',
        'img_boneka.png',
        'img_sepatu.png'
      ]);
    }
  }

  Future<void> fetchCatalog() async {
    isLoading.value = true;
    final response = await _provider.getMyCatalog();
    isLoading.value = false;
    
    if (response.success && response.data != null) {
      layanans.assignAll(response.data!);
    } else {
      final msg = (response.message == null || response.message!.isEmpty) ? 'Gagal mengambil katalog' : response.message!;
      CustomSnackbar.showWarning('Error', msg);
    }
  }

  Future<bool> addLayanan(LayananModel layanan) async {
    final response = await _provider.addLayanan(layanan);
    if (response.success) {
      if (response.data != null) {
        layanans.add(response.data!);
      } else {
        // Jika data dari response null, fetch ulang katalog agar list tetap sinkron
        await fetchCatalog();
      }
      return true;
    } else {
      final msg = (response.message == null || response.message!.isEmpty) ? 'Gagal menambah layanan' : response.message!;
      CustomSnackbar.showWarning('Error', msg);
      return false;
    }
  }

  Future<bool> updateLayanan(String id, LayananModel newLayanan) async {
    final response = await _provider.updateLayanan(id, newLayanan);
    if (response.success) {
      if (response.data != null) {
        final index = layanans.indexWhere((element) => element.id == id);
        if (index != -1) {
          layanans[index] = response.data!;
        }
      } else {
        await fetchCatalog();
      }
      return true;
    } else {
      final msg = (response.message == null || response.message!.isEmpty) ? 'Gagal memperbarui layanan' : response.message!;
      CustomSnackbar.showWarning('Error', msg);
      return false;
    }
  }

  Future<bool> deleteLayanan(String id) async {
    // Optimistic delete
    final index = layanans.indexWhere((element) => element.id == id);
    LayananModel? backup;
    if (index != -1) {
      backup = layanans[index];
      layanans.removeAt(index);
    }

    final response = await _provider.deleteLayanan(id);
    if (response.success) {
      return true;
    } else {
      // Revert if failed
      if (backup != null && index != -1) {
        layanans.insert(index, backup);
      }
      final msg = (response.message == null || response.message!.isEmpty) ? 'Gagal menghapus layanan' : response.message!;
      CustomSnackbar.showWarning('Error', msg);
      return false;
    }
  }
}
