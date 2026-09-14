import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../core/utils/thousand_separator_input_formatter.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/providers/promo_provider.dart';
import '../../../data/models/promo_model.dart';

class PromoController extends GetxController {
  final PromoProvider _promoProvider = PromoProvider();
  final StorageService _storageService = Get.find<StorageService>();
  
  final isLoading = true.obs;
  final isPremium = true.obs;
  final promos = <PromoModel>[].obs;

  // Form Variables
  final formKey = GlobalKey<FormState>();
  final promoCodeController = TextEditingController();
  final discountValueController = TextEditingController();
  final maxDiscountController = TextEditingController();
  final minOrderController = TextEditingController();
  
  final discountType = 'Nominal'.obs;
  final discountTarget = 'All'.obs;
  final List<String> discountTargetOptions = ['All', 'Order', 'DeliveryFee'];
  final expiryDate = Rxn<DateTime>();
  final isActive = true.obs;
  
  final isSubmitting = false.obs;
  String? currentEditId;

  @override
  void onInit() {
    super.onInit();
    _checkMembershipAndFetch();
    fetchPromos();
  }

  Future<void> _checkMembershipAndFetch() async {
    final tier = await _storageService.read('membership_tier');
    if (tier != 'Premium') {
      isPremium.value = false;
      isLoading.value = false;
      return;
    }
    isPremium.value = true;
  }

  Future<void> fetchPromos() async {
    if (!isPremium.value) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    final response = await _promoProvider.getPromos();
    
    if (response.success && response.data != null) {
      promos.value = response.data!;
    } else {
      if (response.errorDetails != null && response.errorDetails!['statusCode'] == 403) {
         isPremium.value = false;
      } else {
         CustomSnackbar.showError('Error', response.message ?? 'Gagal mengambil data promo');
      }
    }
    isLoading.value = false;
  }

  void setupForm({PromoModel? existingData}) {
    if (existingData != null) {
      currentEditId = existingData.id;
      promoCodeController.text = existingData.promoCode;
      discountType.value = existingData.discountType;
      discountTarget.value = existingData.discountTarget;
      discountValueController.text = formatThousand(existingData.discountValue.toInt().toString());
      maxDiscountController.text = formatThousand(existingData.maxDiscountAmount.toInt().toString());
      minOrderController.text = formatThousand(existingData.minOrderAmount.toInt().toString());
      expiryDate.value = existingData.expiryDate;
      isActive.value = existingData.isActive;
    } else {
      currentEditId = null;
      promoCodeController.clear();
      discountType.value = 'Nominal';
      discountTarget.value = 'All';
      discountValueController.clear();
      maxDiscountController.clear();
      minOrderController.clear();
      expiryDate.value = DateTime.now().add(const Duration(days: 1));
      isActive.value = true;
    }
  }

  Future<void> savePromo() async {
    if (!formKey.currentState!.validate()) return;

    isSubmitting.value = true;
    
    final payload = {
      "promoCode": promoCodeController.text.trim(),
      "discountType": discountType.value,
      "discountTarget": discountTarget.value,
      "discountValue": parseThousand(discountValueController.text),
      "maxDiscountAmount": discountType.value == 'Percentage'
          ? parseThousand(maxDiscountController.text)
          : 0,
      "minOrderAmount": parseThousand(minOrderController.text),
      "expiryDate": expiryDate.value?.toIso8601String(),
      "isActive": isActive.value
    };

    ApiResponse<PromoModel> response;
    if (currentEditId == null) {
      response = await _promoProvider.addPromo(payload);
    } else {
      response = await _promoProvider.updatePromo(currentEditId!, payload);
    }

    if (response.success) {
      final isNew = currentEditId == null;
      Get.back(); // tutup bottom sheet dulu, snackbar setelahnya
      fetchPromos();
      Future.delayed(const Duration(milliseconds: 300), () {
        CustomSnackbar.showSuccess('Berhasil', isNew ? 'Promo berhasil ditambahkan' : 'Promo berhasil diupdate');
      });
    } else {
      CustomSnackbar.showError('Gagal', response.message ?? 'Terjadi kesalahan');
    }
    
    isSubmitting.value = false;
  }

  Future<void> deletePromo(String id) async {
    final response = await _promoProvider.deletePromo(id);
    if (response.success) {
      CustomSnackbar.showSuccess('Berhasil', 'Promo berhasil dihapus');
      fetchPromos();
    } else {
      CustomSnackbar.showError('Gagal Menghapus', response.message ?? 'Terjadi kesalahan');
    }
  }

  @override
  void onClose() {
    promoCodeController.dispose();
    discountValueController.dispose();
    maxDiscountController.dispose();
    minOrderController.dispose();
    super.onClose();
  }
}
