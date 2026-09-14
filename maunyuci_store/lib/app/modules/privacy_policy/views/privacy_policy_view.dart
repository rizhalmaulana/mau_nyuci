import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_colors.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('Kebijakan & Privasi', style: AppFonts.inter(fontWeight: FontWeight.bold, fontSize: R.sp(16))),
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(R.w(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kebijakan Privasi MauNyuci',
              style: AppFonts.inter(fontSize: R.sp(18), fontWeight: FontWeight.bold),
            ),
            SizedBox(height: R.h(16)),
            Text(
              'Terakhir Diperbarui: 1 September 2026',
              style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey600),
            ),
            SizedBox(height: R.h(24)),
            _buildSection(
              title: '1. Pengumpulan Informasi',
              content: 'Kami mengumpulkan informasi yang Anda berikan secara langsung kepada kami, seperti saat Anda membuat atau memodifikasi akun, menghubungi dukungan pelanggan, atau berkomunikasi dengan kami. Informasi ini termasuk nama, alamat email, nomor telepon, alamat toko, dan informasi lain yang Anda pilih untuk diberikan.',
            ),
            _buildSection(
              title: '2. Penggunaan Informasi',
              content: 'Kami menggunakan informasi yang kami kumpulkan untuk:\n- Menyediakan, memelihara, dan meningkatkan layanan kami.\n- Memproses transaksi dan mengirimkan pemberitahuan terkait.\n- Mengirimkan dukungan teknis, pembaruan, dan pesan administratif.\n- Merespon komentar, pertanyaan, dan permintaan Anda.',
            ),
            _buildSection(
              title: '3. Berbagi Informasi',
              content: 'Kami tidak membagikan informasi pribadi Anda dengan pihak ketiga kecuali sebagaimana dijelaskan dalam kebijakan ini, seperti dengan penyedia layanan pihak ketiga yang membantu kami mengoperasikan platform, atau jika diwajibkan oleh hukum.',
            ),
            _buildSection(
              title: '4. Keamanan Data',
              content: 'Kami mengambil langkah-langkah yang wajar untuk membantu melindungi informasi tentang Anda dari kehilangan, pencurian, penyalahgunaan, dan akses tidak sah, pengungkapan, perubahan, dan penghancuran.',
            ),
            _buildSection(
              title: '5. Perubahan pada Kebijakan Privasi',
              content: 'Kami mungkin memperbarui kebijakan privasi ini dari waktu ke waktu. Jika kami melakukan perubahan material, kami akan memberitahu Anda dengan merevisi tanggal di atas kebijakan dan, dalam beberapa kasus, kami dapat memberikan pemberitahuan tambahan.',
            ),
            SizedBox(height: R.h(40)),
            Center(
              child: Text(
                '© 2026 MauNyuci. All rights reserved.',
                style: AppFonts.inter(fontSize: R.sp(12), color: AppColors.grey500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFonts.inter(fontSize: R.sp(14), fontWeight: FontWeight.bold, color: AppColors.black87),
          ),
          SizedBox(height: R.h(8)),
          Text(
            content,
            style: AppFonts.inter(fontSize: R.sp(14), color: AppColors.grey700, height: 1.5),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
