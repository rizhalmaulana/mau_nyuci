import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/providers/transaction_provider.dart';
import '../../../data/providers/media_provider.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../home/controllers/home_controller.dart';

class OrderDetailController extends GetxController {
  final TransactionProvider _transactionProvider = TransactionProvider();
  final MediaProvider _mediaProvider = MediaProvider();
  
  late String orderId;
  var isLoading = true.obs;
  var order = Rxn<OrderModel>();

  @override
  void onInit() {
    super.onInit();
    orderId = Get.arguments as String;
    fetchOrderDetail();
  }

  Future<void> fetchOrderDetail() async {
    isLoading.value = true;
    try {
      final response = await _transactionProvider.getOrderById(orderId);
      if (response.success && response.data != null) {
        order.value = response.data;
      } else {
        CustomSnackbar.showError('Mohon Maaf', response.message ?? 'Gagal mengambil detail pesanan');
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelOrder(String reason) async {
    isLoading.value = true;
    try {
      final response = await _transactionProvider.cancelOrder(orderId, reason);
      if (response.success) {
        CustomSnackbar.showSuccess('Berhasil', response.message ?? 'Pesanan berhasil dibatalkan.');
        await fetchOrderDetail(); // Refresh the order detail
        
        // Let's also refresh Home if it's there
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().refreshData();
        }
      } else {
        CustomSnackbar.showError('Gagal', response.message ?? 'Gagal membatalkan pesanan.');
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void showCancelOrderSheet() {
    final reasonController = TextEditingController();
    Get.bottomSheet(
      SafeArea(
        top: false,
        // Tombol "Kirim Pembatalan" tidak boleh tertutup tombol navigasi HP.
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
            Text('Batalkan Pesanan', style: AppFonts.inter(fontSize: R.sp(18), fontWeight: FontWeight.bold, color: AppColors.danger)),
            SizedBox(height: R.h(8)),
            Text('Silakan tulis alasan pembatalan. Tindakan ini tidak dapat dibatalkan.',
                style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey600)),
            SizedBox(height: R.h(16)),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: AppFonts.inter(fontSize: R.sp(13)),
              decoration: InputDecoration(
                hintText: 'Contoh: Berubah pikiran, salah pilih layanan...',
                hintStyle: AppFonts.inter(fontSize: R.sp(13), color: AppColors.grey400),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: AppColors.grey300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: AppColors.grey300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.r(12)), borderSide: const BorderSide(color: AppColors.danger)),
              ),
            ),
            SizedBox(height: R.h(24)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final reason = reasonController.text.trim();
                  if (reason.isEmpty) {
                    CustomSnackbar.showInfo('Oops', 'Alasan pembatalan harus diisi.');
                    return;
                  }
                  Get.back(); // close bottom sheet
                  cancelOrder(reason);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  padding: EdgeInsets.symmetric(vertical: R.h(16)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.r(12))),
                ),
                child: Text('Kirim Pembatalan', style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.white)),
              ),
            ),
            SizedBox(height: R.h(12)),
          ],
        ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> pickAndUploadReceipt() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      
      if (pickedFile != null) {
        isLoading.value = true;
        
        // 1. Upload media
        final uploadResponse = await _mediaProvider.uploadLaundryImage(pickedFile.path); // Use same endpoint or new one if they have upload qris
        if (uploadResponse.success && uploadResponse.data != null) {
          final imageUrl = uploadResponse.data!;
          
          // 2. Submit to backend
          final response = await _transactionProvider.uploadReceipt(orderId, imageUrl);
          if (response.success) {
            CustomSnackbar.showSuccess('Berhasil', 'Bukti transfer berhasil diunggah.');
            await fetchOrderDetail(); // Refresh the order detail
            if (Get.isRegistered<HomeController>()) {
              Get.find<HomeController>().refreshData();
            }
          } else {
            CustomSnackbar.showError('Gagal', response.message ?? 'Gagal menyimpan bukti transfer.');
          }
        } else {
          CustomSnackbar.showError('Gagal', uploadResponse.message ?? 'Gagal mengunggah foto.');
        }
      }
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied') {
        CustomSnackbar.showInfo('Izin Ditolak', 'Silakan izinkan akses galeri/kamera di Pengaturan HP Anda.');
      } else {
        CustomSnackbar.showError('Error', 'Gagal memilih gambar: ${e.message}');
      }
    } catch (e) {
      CustomSnackbar.showError('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
