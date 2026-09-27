import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/providers/order_provider.dart';
import '../../../data/providers/driver_provider.dart';
import '../../../data/models/driver_model.dart';
import '../../../data/services/storage_service.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_confirm_modal.dart';
import '../../../core/services/printer_service.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';

class OrderDetailController extends GetxController {
  final OrderProvider _orderProvider = OrderProvider();
  final DriverProvider _driverProvider = DriverProvider();

  var isLoading = true.obs;
  var order = Rxn<OrderModel>();

  // Daftar kurir toko untuk flow Courier confirm-pickup.
  var drivers = <StoreDriverModel>[].obs;
  var isDriversLoading = false.obs;

  // Nama kurir yang berhasil di-assign (ditampilkan setelah OnPickup).
  // GET detail belum tentu mengembalikan nama driver, jadi simpan lokal.
  var assignedDriverName = RxnString();

  late String orderId;

  @override
  void onInit() {
    super.onInit();
    orderId = Get.arguments as String;
    fetchOrderDetail().then((_) => _preloadDrivers());
  }

  bool get isPendingCourier {
    final o = order.value;
    if (o == null) return false;
    return o.status.toLowerCase() == 'pending' &&
        o.deliveryType.toLowerCase() == 'courier';
  }

  /// Preload daftar kurir saat halaman dibuka (hanya Pending + Courier).
  /// Silent: gagal preload tidak mengganggu halaman, akan di-retry saat tombol diklik.
  Future<void> _preloadDrivers() async {
    if (!isPendingCourier) return;
    await fetchDrivers(silent: true);
  }

  Future<bool> fetchDrivers({bool silent = false}) async {
    try {
      isDriversLoading.value = true;
      final storeId = await _resolveStoreId();
      if (storeId == null) {
        if (!silent) {
          CustomSnackbar.showError('Mohon Maaf', 'storeId tidak ditemukan. Silakan login ulang.');
        }
        return false;
      }
      final response = await _driverProvider.getStoreDrivers(storeId);
      if (response.success && response.data != null) {
        drivers.assignAll(response.data!);
        return true;
      }
      if (!silent) {
        CustomSnackbar.showError('Gagal', response.message ?? 'Gagal mengambil daftar kurir');
      }
      return false;
    } catch (e) {
      if (!silent) {
        CustomSnackbar.showError('Error', 'Terjadi kesalahan: $e');
      }
      return false;
    } finally {
      isDriversLoading.value = false;
    }
  }

  Future<String?> _resolveStoreId() async {
    if (Get.isRegistered<StorageService>()) {
      return await Get.find<StorageService>().read('storeId');
    }
    return null;
  }

  Future<void> fetchOrderDetail() async {
    isLoading.value = true;
    final response = await _orderProvider.getOrderById(orderId);
    if (response.success && response.data != null) {
      order.value = response.data;
    } else {
      CustomSnackbar.showError('Mohon Maaf', response.message ?? 'Gagal mengambil detail pesanan');
    }
    isLoading.value = false;
  }

  Future<void> updateStatus(String statusAction) async {
    String endpoint = '';
    String title = '';
    String message = '';
    
    switch (statusAction) {
      case 'accept':
        endpoint = ApiConstants.acceptOrder(orderId);
        title = 'Terima Pesanan?';
        message = 'Apakah Anda yakin ingin menerima pesanan ini?';
        break;
      case 'finish-washing':
        endpoint = ApiConstants.finishWashing(orderId);
        title = 'Selesai Dicuci?';
        message = 'Apakah Anda yakin pesanan ini sudah selesai dicuci, disetrika, dan dipacking dengan rapi?';
        break;
      case 'cancel':
        endpoint = ApiConstants.cancelOrder(orderId);
        title = 'Tolak Pesanan?';
        message = 'Apakah Anda yakin ingin menolak atau membatalkan pesanan ini?';
        break;
    }

    if (endpoint.isEmpty) return;

    final confirmed = await CustomConfirmModal.show<bool>(
      title: title,
      message: message,
      textConfirm: 'Ya, Lanjutkan',
      confirmColor: statusAction == 'cancel' ? AppColors.danger : AppColors.primary,
      icon: statusAction == 'cancel' ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
      onConfirm: () => Get.back(result: true),
    );

    if (confirmed != true) return;

    isLoading.value = true;
    final response = await _orderProvider.updateOrderStatus(orderId, endpoint);
    if (response.success) {
      CustomSnackbar.showSuccess('Berhasil', response.message ?? 'Status pesanan diperbarui');
      await fetchOrderDetail(); // Refresh data
    } else {
      isLoading.value = false;
      CustomSnackbar.showError('Gagal', response.message ?? 'Terjadi kesalahan');
    }
  }

  // ============ FLOW COURIER: Terima & Tugaskan Kurir Jemput ============
  // PUT /confirm-pickup = Terima + Assign Driver sekaligus (tidak ada Accept terpisah).
  Future<void> acceptCourierWithDriver() async {
    final orderModel = order.value;
    if (orderModel == null) return;

    // Guard FE (validasi final tetap di backend, jangan di-bypass).
    if (orderModel.status.toLowerCase() != 'pending') {
      CustomSnackbar.showError('Mohon Maaf', 'Hanya pesanan Pending yang bisa diproses.');
      await fetchOrderDetail();
      return;
    }
    if (orderModel.deliveryType.toLowerCase() != 'courier') {
      CustomSnackbar.showError('Mohon Maaf', 'Hanya pesanan Antar-Jemput (Courier) yang bisa menugaskan kurir.');
      await fetchOrderDetail();
      return;
    }

    // Refresh daftar kurir setiap tombol diklik agar tidak basi.
    isLoading.value = true;
    final ok = await fetchDrivers();
    isLoading.value = false;
    if (!ok) return;

    if (drivers.isEmpty) {
      CustomSnackbar.showError('Mohon Maaf', 'Belum ada kurir terdaftar di toko ini.');
      return;
    }

    final selected = await _showDriverPickerSheet();
    if (selected == null) return; // Batal memilih

    await _submitConfirmPickup(selected);
  }

  // ============ FLOW COURIER: Tugaskan Kurir Antar ============
  Future<void> readyForDeliveryWithDriver() async {
    final orderModel = order.value;
    if (orderModel == null) return;

    if (orderModel.deliveryType.toLowerCase() != 'courier') {
      CustomSnackbar.showError('Mohon Maaf', 'Hanya pesanan Antar-Jemput (Courier) yang bisa menugaskan kurir.');
      return;
    }

    isLoading.value = true;
    final ok = await fetchDrivers();
    isLoading.value = false;
    if (!ok) return;

    if (drivers.isEmpty) {
      CustomSnackbar.showError('Mohon Maaf', 'Belum ada kurir terdaftar di toko ini.');
      return;
    }

    final selected = await _showDriverPickerSheet();
    if (selected == null) return; // Batal memilih

    isLoading.value = true;
    final response = await _orderProvider.readyForDelivery(orderId, selected.driverId);
    if (response.success) {
      CustomSnackbar.showSuccess('Berhasil', response.message ?? 'Kurir ${selected.fullName} ditugaskan mengantar.');
      await fetchOrderDetail();
    } else {
      isLoading.value = false;
      CustomSnackbar.showError('Gagal', response.message ?? 'Terjadi kesalahan');
    }
  }

  /// Bottom-sheet pilih kurir: search nama, disable nonaktif/sibuk, badge Sibuk.
  Future<StoreDriverModel?> _showDriverPickerSheet() {
    String query = '';
    StoreDriverModel? picked;

    return Get.bottomSheet<StoreDriverModel>(
      StatefulBuilder(
        builder: (context, setSheetState) {
          return Obx(() {
            final filtered = drivers.where((d) {
              if (query.trim().isEmpty) return true;
              return d.fullName.toLowerCase().contains(query.trim().toLowerCase());
            }).toList();

            // SafeArea: tombol "Terima & Tugaskan Kurir" tidak boleh
            // tertutup tombol navigasi HP (mode 3 tombol).
            return SafeArea(
              top: false,
              child: Container(
                padding: EdgeInsets.all(R.w(24)),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(24))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.grey300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(height: R.h(20)),
                  Text('Tugaskan Kurir',
                      style: AppFonts.inter(fontWeight: FontWeight.bold)),
                  SizedBox(height: R.h(8)),
                  Text('Pilih kurir untuk menjemput cucian customer. Menerima = pesanan langsung jadi OnPickup.',
                      style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey600)),
                  SizedBox(height: R.h(20)),
                  TextField(
                    onChanged: (v) => setSheetState(() => query = v),
                    style: AppFonts.inter(fontSize: R.sp(14)),
                    decoration: InputDecoration(
                      hintText: 'Cari nama kurir...',
                      hintStyle: AppFonts.inter(fontSize: R.sp(13), color: AppColors.grey500),
                      prefixIcon: Icon(Icons.search, size: R.r(20)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12))),
                      contentPadding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(10)),
                    ),
                  ),
                  SizedBox(height: R.h(16)),
                  if (isDriversLoading.value)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (filtered.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: R.h(24)),
                      child: Center(
                        child: Text('Kurir tidak ditemukan.',
                            style: AppFonts.inter(fontSize: R.sp(13), color: AppColors.grey600)),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => SizedBox(height: R.h(12)),
                        itemBuilder: (context, index) {
                          final driver = filtered[index];
                          final isPicked = picked?.driverId == driver.driverId;
                          return InkWell(
                            onTap: driver.isSelectable
                                ? () => setSheetState(() => picked = driver)
                                : null,
                            borderRadius: BorderRadius.circular(R.r(12)),
                            child: Container(
                              padding: EdgeInsets.all(R.w(16)),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isPicked ? AppColors.primary : AppColors.grey200,
                                  width: isPicked ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(R.r(12)),
                                color: driver.isSelectable
                                    ? (isPicked
                                        ? AppColors.primary.withValues(alpha: 0.05)
                                        : AppColors.white)
                                    : AppColors.grey100,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: driver.isSelectable
                                        ? AppColors.primary.withValues(alpha: 0.1)
                                        : AppColors.grey200,
                                    child: Icon(Icons.delivery_dining,
                                        color: driver.isSelectable
                                            ? AppColors.primary
                                            : AppColors.grey500),
                                  ),
                                  SizedBox(width: R.w(12)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(driver.displayLabel,
                                            style: AppFonts.inter(
                                                fontWeight: FontWeight.w600,
                                                fontSize: R.sp(13),
                                                color: driver.isSelectable
                                                    ? AppColors.black
                                                    : AppColors.grey500)),
                                        SizedBox(height: R.h(4)),
                                        Row(
                                          children: [
                                            if (!driver.isAvailable)
                                              _driverChip('Nonaktif', AppColors.danger)
                                            else if (driver.isBusy) ...[
                                              _driverChip('Sibuk', AppColors.orange700),
                                              SizedBox(width: R.w(6)),
                                              Text('Terlalu banyak tugas aktif',
                                                  style: AppFonts.inter(
                                                      fontSize: R.sp(10),
                                                      color: AppColors.grey500)),
                                            ] else
                                              Text(driver.vehicleType.isNotEmpty
                                                  ? driver.vehicleType
                                                  : driver.phoneNumber,
                                                  style: AppFonts.inter(
                                                      fontSize: R.sp(11),
                                                      color: AppColors.grey600)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isPicked)
                                    const Icon(Icons.check_circle, color: AppColors.primary),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  SizedBox(height: R.h(20)),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: picked == null
                          ? null
                          : () => Get.back(result: picked),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: R.h(16)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(R.r(12))),
                      ),
                      child: Text('Tugaskan Kurir',
                          style: AppFonts.inter(
                              fontWeight: FontWeight.bold, color: AppColors.white)),
                    ),
                  ),
                  SizedBox(height: R.h(12)),
                ],
              ),
              ),
            );
          });
        },
      ),
      isScrollControlled: true,
    );
  }

  Widget _driverChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: AppFonts.inter(
              fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Future<void> _submitConfirmPickup(StoreDriverModel driver) async {
    // Kirim DriverProfiles.Id — BUKAN userId. Tidak ada hardcode GUID.
    isLoading.value = true;
    final response = await _orderProvider.confirmPickup(orderId, driver.driverId);
    if (response.success) {
      assignedDriverName.value = driver.fullName;
      CustomSnackbar.showSuccess(
          'Berhasil', response.message ?? 'Kurir ${driver.fullName} ditugaskan menjemput.');
      await fetchOrderDetail(); // Status -> OnPickup + refresh
    } else {
      isLoading.value = false;
      await _handleConfirmPickupError(response.message ?? 'Terjadi kesalahan');
    }
  }

  /// Error mapping sesuai spek — message backend ditampilkan apa adanya.
  Future<void> _handleConfirmPickupError(String backendMessage) async {
    final msg = backendMessage.toLowerCase();
    if (msg.contains('pending')) {
      // Order sudah diambil / berubah status: refresh agar tombol ikut hilang.
      CustomSnackbar.showError('Mohon Maaf', backendMessage);
      await fetchOrderDetail();
    } else if (msg.contains('antar-jemput') || msg.contains('antar jemput')) {
      // Bukan Courier: refresh, tombol otomatis disembunyikan untuk SelfService.
      CustomSnackbar.showError('Mohon Maaf', backendMessage);
      await fetchOrderDetail();
    } else if (msg.contains('terdaftar') ||
        msg.contains('ditemukan') ||
        msg.contains('nonaktif') ||
        msg.contains('tugas')) {
      // Masalah driver: tampilkan pesan backend + reload daftar driver.
      CustomSnackbar.showError('Gagal', backendMessage);
      await fetchDrivers(silent: true);
    } else {
      CustomSnackbar.showError('Gagal', backendMessage);
    }
  }

  Future<void> handleCompleteOrder() async {
    final orderModel = order.value;
    if (orderModel == null) return;

    bool isPayNow = orderModel.paymentMethod.toLowerCase() == 'paynow' || 
                    (orderModel.selectedStoreBankName != null && orderModel.selectedStoreBankName!.trim().isNotEmpty && orderModel.selectedStoreBankName != '-') || 
                    (orderModel.paymentProvider != null && orderModel.paymentProvider!.toLowerCase().contains('qris'));

    if (isPayNow) {
      // PayNow langsung menggunakan provider sebelumnya (tanpa harus memilih tunai/non-tunai lagi)
      final confirmed = await CustomConfirmModal.show<bool>(
        title: 'Selesaikan Pesanan?',
        message: 'Apakah baju sudah diserahkan kepada pelanggan dan pembayaran dipastikan lunas? Transaksi ini akan ditutup.',
        textConfirm: 'Ya, Lanjutkan',
        confirmColor: AppColors.primary,
        icon: Icons.info_outline_rounded,
        onConfirm: () => Get.back(result: true),
      );

      if (confirmed == true) {
        await _executeCompleteOrder(orderModel.paymentProvider ?? 'Transfer');
      }
      return;
    }

    // Modal khusus PayLater (memilih Tunai/Non-Tunai di akhir)
    final provider = await Get.bottomSheet<String>(
      SafeArea(
        top: false,
        // Opsi terbawah tidak boleh tertutup tombol navigasi HP.
        child: Container(
          padding: EdgeInsets.all(R.w(24)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(24))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Metode Pembayaran Akhir', style: TextStyle(fontSize: R.sp(16), fontWeight: FontWeight.bold)),
            SizedBox(height: R.h(8)),
            Text('Pilih metode pembayaran yang digunakan oleh pelanggan saat mengambil cucian.', style: TextStyle(fontSize: R.sp(12), color: AppColors.grey600)),
            SizedBox(height: R.h(24)),
            ListTile(
              leading: const Icon(Icons.money, color: AppColors.success),
              title: const Text('Tunai (Cash)'),
              subtitle: Text('Pembayaran diterima secara tunai', style: TextStyle(fontSize: R.sp(10))),
              onTap: () => Get.back(result: 'Tunai'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.grey200)),
            ),
            SizedBox(height: R.h(12)),
            ListTile(
              leading: const Icon(Icons.qr_code, color: AppColors.info),
              title: const Text('Non-Tunai (QRIS/Transfer)'),
              subtitle: Text('Pelanggan membayar via transfer bank atau QRIS', style: TextStyle(fontSize: R.sp(10))),
              onTap: () => Get.back(result: 'QRIS'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.grey200)),
            ),
            SizedBox(height: R.h(24)),
            ],
          ),
        ),
      ),
    );

    if (provider == null) return; // Batal memilih

    if (provider == 'Tunai') {
      await _executeCompleteOrder('Tunai');
    } else {
      // Validasi struk untuk Non-Tunai
      if (orderModel.paymentReceiptUrl == null || orderModel.paymentReceiptUrl!.isEmpty) {
        CustomSnackbar.showError('Bukti Bayar Kosong', 'Harap upload bukti bayar (struk transfer/QRIS) terlebih dahulu sebelum menyelesaikan pesanan Non-Tunai.');
        await uploadReceiptQris();
      } else {
        await _executeCompleteOrder('QRIS');
      }
    }
  }

  Future<void> _executeCompleteOrder(String finalPaymentProvider) async {
    isLoading.value = true;
    final response = await _orderProvider.completeOrderWithPayment(orderId, finalPaymentProvider);
    if (response.success) {
      CustomSnackbar.showSuccess('Berhasil', response.message ?? 'Pesanan berhasil diselesaikan');
      await fetchOrderDetail();
    } else {
      isLoading.value = false;
      CustomSnackbar.showError('Mohon Maaf', response.message ?? 'Terjadi kesalahan');
    }
  }

  Future<void> verifyPaymentAction(bool isApproved) async {
    final actionText = isApproved ? 'memvalidasi' : 'menolak';
    final confirmed = await CustomConfirmModal.show<bool>(
      title: 'Konfirmasi Pembayaran',
      message: 'Apakah Anda yakin ingin $actionText pembayaran ini?',
      textConfirm: 'Ya, $actionText',
      confirmColor: isApproved ? AppColors.success : AppColors.danger,
      icon: isApproved ? Icons.check_circle_outline : Icons.cancel_outlined,
      onConfirm: () => Get.back(result: true),
    );

    if (confirmed == true) {
      isLoading.value = true;
      final response = await _orderProvider.verifyPayment(orderId, isApproved);
      if (response.success) {
        CustomSnackbar.showSuccess('Berhasil', response.message ?? 'Verifikasi berhasil dikirim');
        await fetchOrderDetail();
      } else {
        isLoading.value = false;
        CustomSnackbar.showError('Mohon Maaf', response.message ?? 'Terjadi kesalahan');
      }
    }
  }

  Future<void> uploadReceiptQris() async {
    final ImageSource? source = await Get.bottomSheet<ImageSource>(
      SafeArea(
        top: false,
        // Opsi "Galeri" tidak boleh tertutup tombol navigasi HP.
        child: Container(
          padding: EdgeInsets.all(R.w(16)),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(R.r(16))),
          ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pilih Sumber Gambar', style: TextStyle(fontSize: R.sp(16), fontWeight: FontWeight.bold)),
            SizedBox(height: R.h(16)),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
            SizedBox(height: R.h(16)),
          ],
        ),
        ),
      ),
    );

    if (source != null) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        isLoading.value = true;
        final response = await _orderProvider.uploadStoreReceipt(orderId, image.path);
        if (response.success) {
          CustomSnackbar.showSuccess('Berhasil', response.message ?? 'Bukti pembayaran berhasil diupload');
          await fetchOrderDetail();
        } else {
          isLoading.value = false;
          CustomSnackbar.showError('Gagal', response.message ?? 'Terjadi kesalahan');
        }
      }
    }
  }

  void printReceipt() {
    if (order.value == null) return;
    
    // Check if printer is connected
    final printerService = Get.find<PrinterService>();
    if (!printerService.isConnected.value) {
      // Navigate to printer settings
      Get.toNamed(Routes.PRINTER_SETTINGS);
      CustomSnackbar.showError('Printer Belum Terhubung', 'Silakan hubungkan printer thermal Anda terlebih dahulu.');
      return;
    }

    // Try to get store info from local storage or controller if available
    // For now we just pass order, PrinterService will handle default store name if not provided
    printerService.printReceipt(order.value!);
  }
}
