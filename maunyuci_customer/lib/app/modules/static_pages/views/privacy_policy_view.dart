import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/responsive_helper.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Kebijakan Privasi', style: AppFonts.fInterSubheadingSemibold.copyWith(fontSize: R.sp(16), color: Colors.black)),
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
            Text('Kebijakan Privasi MauNyuci', style: AppFonts.fInterSubheadingSemibold.copyWith(fontSize: R.sp(18), color: AppColors.primary)),
            SizedBox(height: R.h(16)),
            _buildSection(
              title: '1. Pengumpulan Data',
              content: 'Kami mengumpulkan informasi identitas diri Anda seperti nama, alamat email, nomor telepon, dan alamat tempat tinggal untuk keperluan kelancaran operasional layanan penjemputan dan pengantaran laundry.',
            ),
            _buildSection(
              title: '2. Penggunaan Data',
              content: 'Informasi yang Anda berikan akan digunakan secara eksklusif untuk:\n- Memproses pesanan Anda.\n- Menghubungi Anda terkait status pesanan.\n- Meningkatkan layanan dan antarmuka aplikasi.\n- Keperluan promosi (jika Anda telah memberikan persetujuan).',
            ),
            _buildSection(
              title: '3. Keamanan Data',
              content: 'Kami berkomitmen untuk menjaga keamanan data pribadi Anda dengan menerapkan standar keamanan yang ketat guna mencegah akses, perubahan, atau pengungkapan yang tidak sah.',
            ),
            _buildSection(
              title: '4. Pembagian Data ke Pihak Ketiga',
              content: 'Kami hanya membagikan informasi dasar Anda (seperti nama, nomor telepon, dan alamat) kepada mitra laundry dan kurir terkait dengan tujuan penyelesaian pesanan Anda. Kami tidak akan menjual atau menyewakan data Anda kepada pihak lain.',
            ),
            _buildSection(
              title: '5. Penghapusan Akun',
              content: 'Anda memiliki hak untuk meminta penghapusan akun dan data pribadi Anda dengan menghubungi layanan pelanggan kami atau melalui opsi penghapusan di dalam aplikasi.',
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
