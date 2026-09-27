import 'package:get/get.dart';
import '../../../core/widgets/custom_confirm_modal.dart';
import '../../../core/widgets/custom_success_modal.dart';
import '../../../data/models/catalog_model.dart';
import '../../../data/models/store_model.dart';
import '../../../data/models/promo_model.dart';
import '../../../data/models/store_bank_account_model.dart';
import '../../../data/providers/catalog_provider.dart';
import '../../../data/providers/store_provider.dart';
import '../../../data/providers/store_promo_provider.dart';
import '../../../data/providers/store_bank_account_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../home/controllers/home_controller.dart';
import '../../main/controllers/main_controller.dart';
import '../../../data/providers/order_provider.dart';
import '../../../data/providers/media_provider.dart';
import 'dart:io';

enum DeliveryType { dropoff, courier }

class StoreDetailController extends GetxController {
  final CatalogProvider _catalogProvider = CatalogProvider();
  final StoreProvider _storeProvider = StoreProvider();
  final StorePromoProvider _promoProvider = StorePromoProvider();
  final StoreBankAccountProvider _bankAccountProvider = StoreBankAccountProvider();
  final OrderProvider _orderProvider = OrderProvider();
  final MediaProvider _mediaProvider = MediaProvider();
  
  var isLoading = true.obs;
  var isSubmitting = false.obs;
  
  var catalogList = <CatalogModel>[].obs;
  var bankAccounts = <StoreBankAccountModel>[].obs;
  var promos = <PromoModel>[].obs;
  
  // Local Cart State
  // Map of CatalogId to Quantity
  var cart = <String, int>{}.obs;

  // Delivery State
  var selectedDeliveryType = DeliveryType.courier.obs;
  var pickupTimeSlot = RxnString();
  var deliveryTimeSlot = RxnString();
  final logisticsNoteController = TextEditingController();

  // Laundry Image for Courier
  final Rxn<File> laundryImageFile = Rxn<File>();

  // Promo State
  var selectedPromo = Rxn<PromoModel>();

  // Payment State
  var paymentStatus = 'Belum Lunas'.obs; // 'Lunas' or 'Belum Lunas'
  var selectedPaymentMethodId = RxnString(); // Bank account ID if Lunas

  late String storeId;
  StoreModel? store;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is String) {
      storeId = args;
    } else if (args is Map<String, dynamic>) {
      storeId = args['storeId'] as String;
      store = args['store'] as StoreModel?;
    } else {
      storeId = '';
    }

    if (storeId.isNotEmpty) {
      _fetchInitialData();
    }
  }

  Future<void> _fetchInitialData() async {
    try {
      isLoading.value = true;
      final responses = await Future.wait([
        _storeProvider.getStoreById(storeId),
        _catalogProvider.getStoreCatalog(storeId),
        _bankAccountProvider.getBankAccountsByStoreId(storeId),
        _promoProvider.getStorePromos(storeId),
      ]);

      // Handle Store Profile
      final storeRes = responses[0];
      if (storeRes.success && storeRes.data != null) {
        store = storeRes.data as StoreModel;
      }

      // Handle Catalogs
      final catalogRes = responses[1];
      if (catalogRes.success && catalogRes.data != null) {
        catalogList.assignAll(catalogRes.data as List<CatalogModel>);
      }

      // Handle Bank Accounts
      final bankRes = responses[2];
      if (bankRes.success && bankRes.data != null) {
        bankAccounts.assignAll(bankRes.data as List<StoreBankAccountModel>);
      }

      // Handle Promos
      final promoRes = responses[3];
      if (promoRes.success && promoRes.data != null) {
        promos.assignAll(promoRes.data as List<PromoModel>);
      }

    } catch (e) {
      CustomSnackbar.showError('Error', 'Terjadi kesalahan saat memuat detail toko: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void addToCart(String catalogId) {
    final item = catalogList.firstWhereOrNull((e) => e.id == catalogId);
    if (item != null && item.unit?.toLowerCase() == 'kg') {
      if (selectedDeliveryType.value == DeliveryType.courier) {
        cart[catalogId] = (store?.minOrderForPickup ?? 1).toInt();
      } else {
        cart[catalogId] = 1;
      }
      return;
    }

    if (cart.containsKey(catalogId)) {
      cart[catalogId] = cart[catalogId]! + 1;
    } else {
      cart[catalogId] = 1;
    }
  }

  void removeFromCart(String catalogId) {
    if (cart.containsKey(catalogId)) {
      if (cart[catalogId]! > 1) {
        cart[catalogId] = cart[catalogId]! - 1;
      } else {
        cart.remove(catalogId);
      }
    }
  }

  int getQuantity(String catalogId) {
    return cart[catalogId] ?? 0;
  }

  void onDeliveryTypeChanged(DeliveryType type) {
    selectedDeliveryType.value = type;
    
    // Update kiloan items in cart based on delivery type
    final keys = cart.keys.toList();
    for (var catalogId in keys) {
      final item = catalogList.firstWhereOrNull((e) => e.id == catalogId);
      if (item != null && item.unit?.toLowerCase() == 'kg') {
        if (type == DeliveryType.courier) {
          cart[catalogId] = (store?.minOrderForPickup ?? 1).toInt();
        } else {
          cart[catalogId] = 1;
        }
      }
    }
  }

  double get subtotal {
    double total = 0;
    cart.forEach((catalogId, quantity) {
      final item = catalogList.firstWhereOrNull((e) => e.id == catalogId);
      if (item != null && item.price != null) {
        total += item.price! * quantity;
      }
    });
    return total;
  }

  bool get hasKiloan {
    for (var catalogId in cart.keys) {
      final item = catalogList.firstWhereOrNull((e) => e.id == catalogId);
      if (item != null && item.unit?.toLowerCase() == 'kg') {
        return true;
      }
    }
    return false;
  }

  double get discountAmount {
    if (selectedPromo.value == null) return 0.0;
    if (selectedPromo.value!.discountTarget.toLowerCase() == 'ongkir') return 0.0;
    
    final promo = selectedPromo.value!;
    
    // Check min order
    if (subtotal < promo.minOrderAmount) return 0.0;

    final isPercent = promo.discountType.toLowerCase().contains('percent') || promo.discountType.toLowerCase().contains('persent');

    if (isPercent) {
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
    double fee = 0.0;
    if (selectedDeliveryType.value == DeliveryType.courier) {
      fee = store?.pickupDeliveryFee ?? 0.0;
    }

    if (selectedPromo.value != null && selectedPromo.value!.discountTarget.toLowerCase() == 'ongkir') {
      final promo = selectedPromo.value!;
      if (subtotal >= promo.minOrderAmount) {
        final isPercent = promo.discountType.toLowerCase().contains('percent') || promo.discountType.toLowerCase().contains('persent');
        double disc = 0.0;
        if (isPercent) {
          disc = fee * (promo.discountValue / 100);
          if (promo.maxDiscountAmount > 0 && disc > promo.maxDiscountAmount) {
            disc = promo.maxDiscountAmount;
          }
        } else {
          disc = promo.discountValue;
        }
        fee -= disc;
        if (fee < 0) fee = 0.0;
      }
    }
    return fee;
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
        imageQuality: 70,
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
    if (cart.isEmpty) {
      CustomSnackbar.showError('Oops', 'Keranjang masih kosong!');
      return;
    }

    if (store == null) {
      CustomSnackbar.showError('Error', 'Data toko tidak ditemukan.');
      return;
    }

    final homeCtrl = Get.find<HomeController>();

    // Validation for Delivery
    if (selectedDeliveryType.value == DeliveryType.courier) {
      if (!(store!.hasPickupDeliveryService ?? false)) {
        CustomSnackbar.showError('Oops', 'Toko ini tidak mendukung layanan Antar-Jemput.');
        return;
      }
      
      // Hitung total Kg
      double totalKg = 0;
      cart.forEach((catalogId, quantity) {
        final item = catalogList.firstWhereOrNull((e) => e.id == catalogId);
        if (item != null && item.unit?.toLowerCase() == 'kg') {
          totalKg += quantity;
        }
      });

      if (totalKg < (store!.minOrderForPickup ?? 0.0)) {
        CustomSnackbar.showInfo('Mohon Maaf', 'Minimal order untuk antar-jemput adalah ${(store!.minOrderForPickup ?? 0).toInt()} Kg (hanya layanan Kiloan yang dihitung).');
        return;
      }

      if (pickupTimeSlot.value == null || deliveryTimeSlot.value == null) {
        CustomSnackbar.showInfo('Mohon Maaf', 'Harap pilih slot waktu penjemputan dan pengantaran.');
        return;
      }
      
      if (homeCtrl.userAddress.value == 'Belum ada alamat' || homeCtrl.userAddress.value.isEmpty) {
        CustomSnackbar.showInfo('Mohon Maaf', 'Alamat belum diatur. Silakan atur lokasi di halaman utama terlebih dahulu.');
        return;
      }
      if (homeCtrl.userLatitude.value == 0.0 || homeCtrl.userLongitude.value == 0.0) {
        CustomSnackbar.showInfo('Mohon Maaf', 'Silakan pilih titik lokasi pada peta di halaman utama.');
        return;
      }
      
      if (laundryImageFile.value == null) {
        CustomSnackbar.showInfo('Oops', 'Layanan Antar-Jemput mewajibkan lampiran foto cucian Anda.');
        return;
      }

      if (logisticsNoteController.text.trim().isEmpty) {
        CustomSnackbar.showInfo('Oops', 'Mohon isi Detail Alamat & Patokan agar kurir mudah menemukan lokasi Anda.');
        return;
      }
    }

    // Validasi Payment
    if (paymentStatus.value == 'Lunas' && selectedPaymentMethodId.value == null) {
      CustomSnackbar.showInfo('Oops', 'Silakan pilih metode pembayaran/rekening bank terlebih dahulu.');
      return;
    }

    CustomConfirmModal.show(
      title: 'Konfirmasi Pesanan',
      message:
          'Apakah Anda yakin ingin membuat pesanan ini? Pastikan layanan dan opsi pengantaran sudah benar.',
      textCancel: 'Batal',
      textConfirm: 'Buat Pesanan',
      icon: Icons.receipt_long_outlined,
      onConfirm: () {
        Get.back();
        _processSubmitOrder();
      },
    );
  }

  Future<void> _processSubmitOrder() async {
    isSubmitting.value = true;
    try {
      String? customerLaundryImageUrl;

      if (selectedDeliveryType.value == DeliveryType.courier && laundryImageFile.value != null) {
        final uploadResponse = await _mediaProvider.uploadLaundryImage(laundryImageFile.value!.path);
        if (uploadResponse.success && uploadResponse.data != null) {
          customerLaundryImageUrl = uploadResponse.data;
        } else {
          CustomSnackbar.showError('Gagal', uploadResponse.message ?? 'Gagal mengunggah foto cucian');
          isSubmitting.value = false;
          return;
        }
      }

      final homeCtrl = Get.find<HomeController>();
      final items = cart.entries.map((e) => CheckoutItemPayload(
        catalogItemId: e.key,
        quantity: e.value.toDouble(),
      )).toList();

      final payload = CheckoutPayload(
        storeId: store!.id.toString(),
        deliveryType: selectedDeliveryType.value == DeliveryType.courier ? 1 : 0,
        promoId: selectedPromo.value?.id,
        paymentMethod: paymentStatus.value == 'Belum Lunas' ? 1 : 0, // 0 = PayNow, 1 = PayLater
        selectedStoreBankAccountId: paymentStatus.value == 'Lunas' ? selectedPaymentMethodId.value : null,
        deliveryAddress: selectedDeliveryType.value == DeliveryType.courier ? homeCtrl.userAddress.value : null,
        deliveryLatitude: selectedDeliveryType.value == DeliveryType.courier ? homeCtrl.userLatitude.value : null,
        deliveryLongitude: selectedDeliveryType.value == DeliveryType.courier ? homeCtrl.userLongitude.value : null,
        pickupTimeSlot: selectedDeliveryType.value == DeliveryType.courier ? pickupTimeSlot.value : null,
        deliveryTimeSlot: selectedDeliveryType.value == DeliveryType.courier ? deliveryTimeSlot.value : null,
        logisticsNotes: selectedDeliveryType.value == DeliveryType.courier ? logisticsNoteController.text : null,
        customerLaundryImageUrl: customerLaundryImageUrl,
        items: items,
      );

      final response = await _orderProvider.checkoutOrder(payload);

      if (response.success) {
        cart.clear();

        // Refresh Home agar riwayat/transaksi aktif terbaru
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().refreshData();
        }

        // Tampilkan feedback sukses dulu, navigasi jalan saat user tap tombol.
        // Sebelumnya snackbar langsung tertutup oleh Get.back() sehingga
        // user tidak melihat info berhasil/gagal dan terkesan tetap di halaman ini.
        CustomSuccessModal.show(
          title: 'Pesanan Berhasil Dibuat!',
          message: 'Pesanan Anda berhasil dibuat dan sedang diproses oleh toko.',
          buttonText: 'Lihat Pesanan',
          onPressed: () {
            Get.until((route) => route.settings.name == '/main' || route.isFirst);
            if (Get.isRegistered<MainController>()) {
              final mainCtrl = Get.find<MainController>();
              final historyIndex =
                  mainCtrl.menus.indexWhere((m) => m.path == '/history');
              mainCtrl.changeTabIndex(historyIndex != -1 ? historyIndex : 1);
            }
          },
        );
      } else {
        CustomSnackbar.showError('Gagal', response.message ?? 'Terjadi kesalahan saat memproses pesanan.');
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Terjadi kesalahan: $e');
    } finally {
      isSubmitting.value = false;
    }
  }
}
