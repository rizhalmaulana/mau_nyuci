import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/providers/order_provider.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_confirm_modal.dart';
import '../../../core/services/printer_service.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_colors.dart';

class OrderDetailController extends GetxController {
  final OrderProvider _orderProvider = OrderProvider();
  
  var isLoading = true.obs;
  var order = Rxn<OrderModel>();

  late String orderId;

  @override
  void onInit() {
    super.onInit();
    orderId = Get.arguments as String;
    fetchOrderDetail();
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
      Container(
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
      CustomSnackbar.showError('Gagal', response.message ?? 'Terjadi kesalahan');
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
        CustomSnackbar.showError('Gagal', response.message ?? 'Terjadi kesalahan');
      }
    }
  }

  Future<void> uploadReceiptQris() async {
    final ImageSource? source = await Get.bottomSheet<ImageSource>(
      Container(
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
