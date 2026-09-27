import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../data/models/store_model.dart';
import '../../../data/models/promo_model.dart';
import '../../../data/models/store_bank_account_model.dart';
import '../../../data/providers/order_provider.dart';
import '../../../data/providers/media_provider.dart';
import '../../../core/widgets/custom_snackbar.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../home/controllers/home_controller.dart';
import '../../main/controllers/main_controller.dart';
import '../../store_detail/controllers/store_detail_controller.dart';

class CheckoutController extends GetxController {
  late StoreModel store;
  late Map<String, int> cart; // Map of catalogId -> quantity
  late double subtotal;
  
  late List<PromoModel> promos;
  late List<StoreBankAccountModel> bankAccounts;

  final OrderProvider _orderProvider = OrderProvider();
  final MediaProvider _mediaProvider = MediaProvider();

  var isSubmitting = false.obs;

  // Foto Cucian
  final Rxn<File> laundryImageFile = Rxn<File>();

  // Delivery (passed from StoreDetailController)
  late DeliveryType selectedDeliveryType;
  late String? deliveryAddress;
  late double? deliveryLatitude;
  late double? deliveryLongitude;
  late String? selectedPickupTimeSlot;
  late String? selectedDeliveryTimeSlot;
  late String? logisticsNote;

  // Promo
  final Rxn<PromoModel> selectedPromo = Rxn<PromoModel>();

  // Payment
  final RxString selectedPaymentMethod = 'Tunai / Bayar Nanti'.obs; // Tunai, Transfer
  final Rxn<StoreBankAccountModel> selectedBankAccount = Rxn<StoreBankAccountModel>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      store = args['store'] as StoreModel;
      cart = args['cart'] as Map<String, int>;
      subtotal = args['subtotal'] as double;
      promos = (args['promos'] as List?)?.cast<PromoModel>() ?? [];
      bankAccounts = (args['bankAccounts'] as List?)?.cast<StoreBankAccountModel>() ?? [];
      
      selectedDeliveryType = args['deliveryType'] as DeliveryType;
      deliveryAddress = args['deliveryAddress'] as String?;
      deliveryLatitude = args['deliveryLatitude'] as double?;
      deliveryLongitude = args['deliveryLongitude'] as double?;
      selectedPickupTimeSlot = args['pickupTimeSlot'] as String?;
      selectedDeliveryTimeSlot = args['deliveryTimeSlot'] as String?;
      logisticsNote = args['logisticsNote'] as String?;
    }
  }

  double get discountAmount {
    if (selectedPromo.value == null) return 0.0;
    final promo = selectedPromo.value!;
    
    // Check min order
    if (subtotal < promo.minOrderAmount) return 0.0;

    if (promo.discountType == 'Persentase') {
      double disc = subtotal * (promo.discountValue / 100);
      if (promo.maxDiscountAmount > 0 && disc > promo.maxDiscountAmount) {
        return promo.maxDiscountAmount;
      }
      return disc;
    } else {
      // Nominal
      return promo.discountValue;
    }
  }

  double get deliveryFee {
    if (selectedDeliveryType == DeliveryType.courier) {
      return store.pickupDeliveryFee ?? 0.0;
    }
    return 0.0;
  }

  double get grandTotal {
    double total = subtotal - discountAmount + deliveryFee;
    return total < 0 ? 0 : total;
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70, // Compressing image
      );
      if (pickedFile != null) {
        laundryImageFile.value = File(pickedFile.path);
      }
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied') {
        CustomSnackbar.showInfo('Izin Ditolak', 'Silakan izinkan akses kamera di Pengaturan HP Anda.');
      } else {
        CustomSnackbar.showError('Error', 'Gagal memilih gambar: ${e.message}');
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Gagal memilih gambar: $e');
    }
  }

  Future<void> submitOrder() async {
    // Validasi Payment
    if (selectedPaymentMethod.value == 'Transfer' && selectedBankAccount.value == null) {
      CustomSnackbar.showError('Oops', 'Silakan pilih rekening bank tujuan transfer.');
      return;
    }

    if (selectedDeliveryType == DeliveryType.courier && laundryImageFile.value == null) {
      CustomSnackbar.showError('Oops', 'Layanan Antar-Jemput mewajibkan lampiran foto cucian Anda.');
      return;
    }

    isSubmitting.value = true;
    try {
      String? customerLaundryImageUrl;

      if (laundryImageFile.value != null) {
        final uploadResponse = await _mediaProvider.uploadLaundryImage(laundryImageFile.value!.path);
        if (uploadResponse.success && uploadResponse.data != null) {
          customerLaundryImageUrl = uploadResponse.data;
        } else {
          CustomSnackbar.showError('Mohon Maaf', uploadResponse.message ?? 'Gagal mengunggah foto cucian');
          isSubmitting.value = false;
          return;
        }
      }

      final items = cart.entries.map((e) => CheckoutItemPayload(
        catalogItemId: e.key,
        quantity: e.value.toDouble(),
      )).toList();

      final payload = CheckoutPayload(
        storeId: store.id.toString(),
        deliveryType: selectedDeliveryType == DeliveryType.courier ? 1 : 0,
        promoId: selectedPromo.value?.id,
        paymentMethod: selectedPaymentMethod.value == 'Transfer' ? 0 : 1, // 0 = PayNow, 1 = PayLater
        selectedStoreBankAccountId: selectedBankAccount.value?.id,
        deliveryAddress: deliveryAddress,
        deliveryLatitude: deliveryLatitude,
        deliveryLongitude: deliveryLongitude,
        pickupTimeSlot: selectedPickupTimeSlot,
        deliveryTimeSlot: selectedDeliveryTimeSlot,
        logisticsNotes: logisticsNote,
        customerLaundryImageUrl: customerLaundryImageUrl,
        items: items,
      );

      final response = await _orderProvider.checkoutOrder(payload);

      if (response.success) {
        CustomSnackbar.showSuccess('Berhasil', 'Pesanan Anda berhasil dibuat!');
        
        // Refresh Home
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().refreshData();
        }
        
        // Go back to Main and navigate to History
        Get.back(); // Close Checkout
        Get.back(); // Close Store Detail
        if (Get.isRegistered<MainController>()) {
          Get.find<MainController>().changeTabIndex(1); // Assuming index 1 is History
        }
      } else {
        CustomSnackbar.showError('Mohon Maaf', response.message ?? 'Terjadi kesalahan saat memproses pesanan.');
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Terjadi kesalahan: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
