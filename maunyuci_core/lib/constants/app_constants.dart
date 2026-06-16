import 'dart:ui';

class AppConstants {
  static String appName = 'MauNyuci';

  // Pesan Error Umum
  static String defaultErrorAuth = 'No. HP atau Kata Sandi tidak sesuai.';
  static String defaultErrorMsg = 'Terjadi kesalahan. Silakan coba lagi.';
  static String noInternetMsg = 'Tidak ada koneksi internet. Periksa jaringan Anda.';
  static String timeoutMsg = 'Koneksi ke server terputus (Timeout).';

  // Format Mata Uang & Tanggal (sebagai referensi)
  static String currencySymbol = 'Rp';
  static String defaultDateFormat = 'dd MMM yyyy, HH:mm';

  // Ukuran Kompresi Gambar Maksimal (untuk flutter_image_compress)
  static int maxImageWidth = 1080;
  static int defaultImageQuality = 80;
}