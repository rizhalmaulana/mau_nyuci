import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/store_bank_account_model.dart';
import '../../../data/providers/store_bank_account_provider.dart';
import '../../../data/providers/media_provider.dart';
import '../../../core/widgets/custom_snackbar.dart';

class BankAccountController extends GetxController {
  final StoreBankAccountProvider _provider = StoreBankAccountProvider();
  final MediaProvider _mediaProvider = MediaProvider();

  var isLoading = false.obs;
  var isSaving = false.obs;
  var accounts = <StoreBankAccountModel>[].obs;
  var masterBankMethods = <String>[].obs;

  // Form
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final accountHolderNameController = TextEditingController();

  var selectedBankName = ''.obs;
  var qrisImageFile = Rx<File?>(null);
  var qrisImageUrl = ''.obs;

  bool get isCashSelected {
    final method = selectedBankName.value.isNotEmpty ? selectedBankName.value : bankNameController.text;
    final l = method.toLowerCase();
    return l.contains('cash') || l.contains('tunai');
  }

  bool get isEWalletSelected {
    final method = selectedBankName.value.isNotEmpty ? selectedBankName.value : bankNameController.text;
    final l = method.toLowerCase();
    return l.contains('gopay') || l.contains('ovo') || l.contains('dana') || 
           l.contains('shopee') || l.contains('linkaja') || l.contains('e-wallet');
  }

  bool get isQrisSelected {
    final method = selectedBankName.value.isNotEmpty ? selectedBankName.value : bankNameController.text;
    return method.toLowerCase().contains('qris');
  }

  @override
  void onInit() {
    super.onInit();
    fetchAccounts();
    fetchMasterMethods();
  }

  Future<void> fetchAccounts() async {
    isLoading.value = true;
    final response = await _provider.getMyAccounts();
    isLoading.value = false;

    if (response.success && response.data != null) {
      accounts.assignAll(response.data!);
    } else {
      final msg = (response.message == null || response.message!.isEmpty) ? 'Gagal memuat daftar rekening' : response.message!;
      CustomSnackbar.showWarning('Error', msg);
    }
  }

  Future<void> fetchMasterMethods() async {
    final response = await _provider.getMasterMethods();
    if (response.success && response.data != null) {
      masterBankMethods.assignAll(response.data!);
    }
  }

  void resetForm() {
    bankNameController.clear();
    accountNumberController.clear();
    accountHolderNameController.clear();
    selectedBankName.value = '';
    qrisImageFile.value = null;
    qrisImageUrl.value = '';
  }

  Future<void> pickQrisImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      qrisImageFile.value = File(image.path);
    }
  }

  Future<void> saveAccount({String? id}) async {
    final bankName = selectedBankName.value.isNotEmpty ? selectedBankName.value : bankNameController.text;
    
    if (bankName.isEmpty) {
      CustomSnackbar.showWarning('Input tidak valid', 'Nama Bank / Metode wajib diisi.');
      return;
    }

    String accNum = accountNumberController.text;
    String accName = accountHolderNameController.text;
    String? finalQrisUrl = qrisImageUrl.value.isNotEmpty ? qrisImageUrl.value : null;

    if (isCashSelected) {
      accNum = '-';
      accName = '-';
    } else if (isQrisSelected) {
      accNum = '-';
      if (accName.isEmpty) {
        CustomSnackbar.showWarning('Input tidak valid', 'Atas Nama wajib diisi.');
        return;
      }
      if (qrisImageFile.value == null && finalQrisUrl == null) {
        CustomSnackbar.showWarning('Input tidak valid', 'Gambar QRIS wajib diupload.');
        return;
      }
    } else {
      if (accNum.isEmpty) {
        CustomSnackbar.showWarning('Input tidak valid', isEWalletSelected ? 'Nomor HP wajib diisi.' : 'Nomor Rekening wajib diisi.');
        return;
      }
      if (accName.isEmpty) {
        CustomSnackbar.showWarning('Input tidak valid', 'Atas Nama wajib diisi.');
        return;
      }
    }

    isSaving.value = true;
    
    if (isQrisSelected && qrisImageFile.value != null) {
      final uploadResponse = await _mediaProvider.uploadQrisImage(qrisImageFile.value!);
      if (uploadResponse.success && uploadResponse.data != null) {
        finalQrisUrl = uploadResponse.data!;
      } else {
        isSaving.value = false;
        final msg = (uploadResponse.message == null || uploadResponse.message!.isEmpty) ? 'Gagal mengupload gambar QRIS' : uploadResponse.message!;
        CustomSnackbar.showWarning('Error Upload', msg);
        return;
      }
    }

    final response = id == null
        ? await _provider.addAccount(bankName, accNum, accName, qrisImageUrl: finalQrisUrl)
        : await _provider.updateAccount(id, bankName, accNum, accName, qrisImageUrl: finalQrisUrl);
    isSaving.value = false;

    if (response.success) {
      Get.back(); // Tutup bottom sheet
      CustomSnackbar.showSuccess('Berhasil', response.message ?? 'Rekening berhasil disimpan');
      fetchAccounts(); // Refresh data
    } else {
      final msg = (response.message == null || response.message!.isEmpty) ? 'Gagal menyimpan rekening' : response.message!;
      CustomSnackbar.showWarning('Error', msg);
    }
  }

  Future<void> deleteAccount(String id) async {
    final response = await _provider.deleteAccount(id);
    if (response.success) {
      CustomSnackbar.showSuccess('Berhasil', response.message ?? 'Rekening berhasil dihapus');
      fetchAccounts();
    } else {
      final msg = (response.message == null || response.message!.isEmpty) ? 'Gagal menghapus rekening' : response.message!;
      CustomSnackbar.showWarning('Error', msg);
    }
  }

  @override
  void onClose() {
    bankNameController.dispose();
    accountNumberController.dispose();
    accountHolderNameController.dispose();
    super.onClose();
  }
}
