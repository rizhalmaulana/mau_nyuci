import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/responsive_helper.dart';

class TermsOfServiceView extends StatelessWidget {
  const TermsOfServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Ketentuan Layanan', style: AppFonts.fInterSubheadingSemibold.copyWith(fontSize: R.sp(16), color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(R.w(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ketentuan Layanan MauNyuci', style: AppFonts.fInterSubheadingSemibold.copyWith(fontSize: R.sp(18), color: AppColors.primary)),
            SizedBox(height: R.h(16)),
            _buildSection(
              title: '1. Pengantar',
              content: 'Selamat datang di MauNyuci! Ketentuan Layanan ini mengatur penggunaan Anda atas aplikasi MauNyuci. Dengan mendaftar, mengakses, atau menggunakan aplikasi kami, Anda setuju untuk terikat oleh Ketentuan ini.',
            ),
            _buildSection(
              title: '2. Layanan',
              content: 'MauNyuci menyediakan platform yang menghubungkan pelanggan dengan penyedia layanan laundry (mitra kami). Kami berkomitmen untuk memfasilitasi transaksi yang aman dan nyaman antara kedua belah pihak.',
            ),
            _buildSection(
              title: '3. Tanggung Jawab Pelanggan',
              content: 'a. Pelanggan wajib memberikan informasi yang akurat saat melakukan pendaftaran dan pemesanan.\nb. Pelanggan bertanggung jawab untuk memeriksa kembali jumlah dan kondisi pakaian sebelum diserahkan kepada kurir atau mitra laundry.\nc. Pembayaran harus diselesaikan sesuai dengan nominal yang tertera pada aplikasi.',
            ),
            _buildSection(
              title: '4. Kebijakan Ganti Rugi',
              content: 'MauNyuci dan Mitra Laundry akan berupaya memberikan layanan terbaik. Apabila terjadi kerusakan atau kehilangan pakaian, kebijakan penggantian akan disesuaikan dengan syarat dan ketentuan yang berlaku di masing-masing mitra laundry.',
            ),
            _buildSection(
              title: '5. Perubahan Ketentuan',
              content: 'Kami berhak untuk mengubah atau memperbarui Ketentuan Layanan ini sewaktu-waktu tanpa pemberitahuan sebelumnya. Penggunaan berkelanjutan atas aplikasi setelah perubahan ini merupakan bentuk persetujuan Anda terhadap ketentuan yang baru.',
            ),
            SizedBox(height: R.h(32)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppFonts.fInterBodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.black87)),
          SizedBox(height: R.h(8)),
          Text(content, style: AppFonts.fInterBodySmallRegular.copyWith(color: Colors.grey.shade700, height: 1.5)),
        ],
      ),
    );
  }
}
