import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/models/layanan_model.dart';
import '../../../data/providers/layanan_provider.dart';
import '../../../data/models/store_bank_account_model.dart';
import '../../../data/providers/store_bank_account_provider.dart';
import '../../../data/providers/order_provider.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/widgets/custom_snackbar.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../home/controllers/home_controller.dart';
import '../../all_orders/controllers/all_orders_controller.dart';
class PosCartItem {
  final String id;
  final String name;
  final String unit; // 'Kg' atau 'Pcs'
  final double price;
  final double quantity;

  PosCartItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;
}

class PosController extends GetxController {
  final StorageService _storageService = Get.find();
  final LayananProvider _layananProvider = LayananProvider();
  final StoreBankAccountProvider _bankAccountProvider = StoreBankAccountProvider();
  final OrderProvider _orderProvider = OrderProvider();

  var isSubmitting = false.obs;

  // Form
  final customerNameController = TextEditingController();
  final customerWaController = TextEditingController();

  // State
  var cartItems = <PosCartItem>[].obs;
  var paymentMethodId = ''.obs; 
  var paymentStatus = 'Lunas'.obs; // Lunas, Belum Lunas
  var isDeliverySelected = false.obs;
  
  // Settings
  var isDeliveryFeatureEnabled = false.obs;

  // Catalog
  var catalogs = <LayananModel>[].obs;
  var isLoadingCatalog = false.obs;

  // Bank Accounts
  var bankAccounts = <StoreBankAccountModel>[].obs;
  var isLoadingBankAccounts = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDeliverySettings();
    _fetchCatalogs();
    fetchBankAccounts();
  }

  void _loadDeliverySettings() async {
    final val = await _storageService.read('isDeliveryEnabled');
    isDeliveryFeatureEnabled.value = val == 'true';
    if (!isDeliveryFeatureEnabled.value) {
      isDeliverySelected.value = false;
    }
  }

  Future<void> _fetchCatalogs() async {
    isLoadingCatalog.value = true;
    final response = await _layananProvider.getMyCatalog();
    isLoadingCatalog.value = false;
    
    if (response.success && response.data != null) {
      catalogs.assignAll(response.data!);
    } else {
      final msg = (response.message == null || response.message!.isEmpty) ? 'Gagal mengambil katalog' : response.message!;
      CustomSnackbar.showWarning('Error', msg);
    }
  }

  Future<void> fetchBankAccounts() async {
    isLoadingBankAccounts.value = true;
    final response = await _bankAccountProvider.getMyAccounts();
    isLoadingBankAccounts.value = false;
    
    if (response.success && response.data != null) {
      bankAccounts.assignAll(response.data!);
      if (bankAccounts.isNotEmpty && !bankAccounts.any((b) => b.id == paymentMethodId.value)) {
        // Do not default to first account, let user select
        paymentMethodId.value = '';
      }
    } else {
      final msg = (response.message == null || response.message!.isEmpty) ? 'Gagal mengambil metode pembayaran' : response.message!;
      CustomSnackbar.showWarning('Error', msg);
    }
  }

  double get grandTotal => cartItems.fold(0, (sum, item) => sum + item.subtotal);

  void addToCart(LayananModel catalog, double qty) {
    if (qty <= 0) return;
    // Tambahkan sebagai entri baru di keranjang, jangan digabung
    // agar bisa dihitung sebagai 'berapa kali layanan ini dipilih'
    cartItems.add(PosCartItem(
      id: catalog.id,
      name: catalog.name,
      unit: catalog.unit,
      price: catalog.price,
      quantity: qty,
    ));
  }

  void reduceFromCart(String id, double qty) {
    // Hapus entri terakhir dari layanan ini yang dimasukkan ke keranjang
    int lastIndex = cartItems.lastIndexWhere((item) => item.id == id);
    if (lastIndex != -1) {
      cartItems.removeAt(lastIndex);
    }
  }

  void removeFromCart(String id) {
    // Hapus semua entri dengan id ini
    cartItems.removeWhere((item) => item.id == id);
  }

  Future<void> submitOrder() async {
    if (cartItems.isEmpty) {
      CustomSnackbar.showWarning('Keranjang Kosong', 'Silakan pilih layanan terlebih dahulu.');
      return;
    }
    if (customerNameController.text.isEmpty) {
      CustomSnackbar.showWarning('Input tidak valid', 'Nama pelanggan wajib diisi.');
      return;
    }
    if (paymentStatus.value == 'Lunas' && paymentMethodId.value.isEmpty) {
      CustomSnackbar.showWarning('Metode Pembayaran', 'Silakan pilih metode pembayaran.');
      return;
    }

    isSubmitting.value = true;
    
    final payload = PosCheckoutPayload(
      guestCustomerName: customerNameController.text,
      guestCustomerPhone: customerWaController.text.isNotEmpty ? customerWaController.text : null,
      deliveryType: isDeliverySelected.value ? 1 : 0,
      paymentMethod: paymentStatus.value == 'Lunas' ? 0 : 1,
      selectedStoreBankAccountId: paymentMethodId.value.isNotEmpty ? paymentMethodId.value : null,
      items: cartItems.map((item) => CheckoutItemPayload(
        catalogItemId: item.id,
        quantity: item.quantity,
      )).toList(),
    );

    final response = await _orderProvider.posCheckoutOrder(payload);
    isSubmitting.value = false;

    if (response.success) {
      Get.back(); // Kembali ke halaman sebelumnya (Beranda) terlebih dahulu
      CustomSnackbar.showSuccess('Berhasil', 'Order manual berhasil dibuat!');
      _resetForm();
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().refreshData(silent: true);
      }
      if (Get.isRegistered<AllOrdersController>()) {
        Get.find<AllOrdersController>().refreshOrders();
      }
    } else {
      CustomSnackbar.showError('Gagal', response.message ?? 'Terjadi kesalahan saat memproses pesanan.');
    }
  }

  void _resetForm() {
    customerNameController.clear();
    customerWaController.clear();
    cartItems.clear();
    paymentMethodId.value = '';
    paymentStatus.value = 'Lunas';
    isDeliverySelected.value = false;
  }

  @override
  void onClose() {
    customerNameController.dispose();
    customerWaController.dispose();
    super.onClose();
  }
}
