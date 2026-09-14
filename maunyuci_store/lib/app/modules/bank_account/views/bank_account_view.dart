import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/responsive_helper.dart';
import '../controllers/bank_account_controller.dart';
import 'widgets/bank_account_form_sheet.dart';
import '../../../core/widgets/custom_confirm_modal.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

class BankAccountView extends GetView<BankAccountController> {
  const BankAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        title: Text('Metode Pembayaran', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(16), color: AppColors.black87)),
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.black87),
      ),
      body: RefreshIndicator(
        onRefresh: controller.fetchAccounts,
        child: Obx(() {
          if (controller.isLoading.value && controller.accounts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.accounts.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            padding: EdgeInsets.all(R.w(16)),
            itemCount: controller.accounts.length,
            separatorBuilder: (context, index) => SizedBox(height: R.h(12)),
            itemBuilder: (context, index) {
              final account = controller.accounts[index];
              return Container(
                padding: EdgeInsets.all(R.w(16)),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(R.r(16)),
                  border: Border.all(color: AppColors.grey200),
                  boxShadow: [
                    BoxShadow(color: AppColors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildBankIcon(account.bankName),
                            SizedBox(width: R.w(12)),
                            Text(
                              account.bankName,
                              style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(16)),
                            ),
                          ],
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              BankAccountFormSheet.show(context, account: account);
                            } else if (value == 'delete') {
                              _showDeleteConfirmation(context, account.id);
                            }
                          },
                          icon: Icon(Icons.more_vert, color: AppColors.grey600),
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'edit', child: Text('Ubah', style: AppFonts.inter())),
                            PopupMenuItem(value: 'delete', child: Text('Hapus', style: AppFonts.inter(color: AppColors.danger))),
                          ],
                        ),
                      ],
                    ),
                    if (account.accountNumber != '-') ...[
                      SizedBox(height: R.h(16)),
                      Text(
                        account.accountNumber,
                        style: AppFonts.inter(fontSize: R.sp(20), fontWeight: FontWeight.w600, letterSpacing: 1.5, color: AppColors.grey800),
                      ),
                    ],
                    if (account.accountHolderName != '-') ...[
                      SizedBox(height: R.h(8)),
                      Text(
                        'A.n. ${account.accountHolderName}',
                        style: AppFonts.inter(fontSize: R.sp(14), color: AppColors.grey600),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_bank_account',
        onPressed: () => BankAccountFormSheet.show(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text('Tambah Rekening', style: AppFonts.inter(fontWeight: FontWeight.bold, color: AppColors.white)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        alignment: Alignment.center,
        padding: EdgeInsets.all(R.w(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(R.w(24)),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.account_balance_wallet_outlined, size: R.r(64), color: AppColors.primary),
            ),
            SizedBox(height: R.h(24)),
            Text(
              'Belum Ada Rekening',
              style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(18), color: AppColors.black87),
            ),
            SizedBox(height: R.h(12)),
            Text(
              'Tambahkan metode pembayaran atau nomor rekening agar pelanggan dapat melakukan pembayaran transfer / QRIS.',
              textAlign: TextAlign.center,
              style: AppFonts.inter(fontSize: R.sp(14), color: AppColors.grey600, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankIcon(String bankName) {
    final l = bankName.toLowerCase();
    IconData icon = Icons.account_balance;
    Color color = AppColors.primary;
    
    if (l.contains('cash') || l.contains('tunai')) {
      icon = Icons.payments_outlined;
      color = AppColors.success;
    } else if (l.contains('qris')) {
      icon = Icons.qr_code_2;
      color = AppColors.pink;
    } else if (l.contains('gopay') || l.contains('ovo') || l.contains('dana') || l.contains('shopee') || l.contains('linkaja') || l.contains('e-wallet')) {
      icon = Icons.account_balance_wallet;
      color = AppColors.info;
    }

    return Container(
      padding: EdgeInsets.all(R.w(8)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(R.r(8)),
      ),
      child: Icon(icon, color: color, size: R.r(20)),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    CustomConfirmModal.show(
      title: 'Hapus Rekening?',
      message: 'Anda yakin ingin menghapus rekening ini? Rekening yang dihapus tidak akan ditampilkan lagi sebagai metode pembayaran.',
      textConfirm: 'Hapus',
      textCancel: 'Batal',
      confirmColor: AppColors.danger,
      cancelColor: AppColors.grey500,
      icon: Icons.delete_outline,
      onConfirm: () {
        Get.back();
        controller.deleteAccount(id);
      },
    );
  }
}
