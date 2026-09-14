import 'package:flutter/services.dart';

/// Formatter input angka dengan pemisah ribuan titik (1.000 / 10.000 / 100.000).
/// Hanya menerima digit, kursor selalu di akhir teks.
class ThousandSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final numericOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final formatted = formatThousand(numericOnly);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// "10000" -> "10.000". Menerima String digit atau num.
String formatThousand(dynamic value) {
  final digits = value.toString().replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return '';
  final buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    buffer.write(digits[i]);
    final index = digits.length - 1 - i;
    if (index > 0 && index % 3 == 0) {
      buffer.write('.');
    }
  }
  return buffer.toString();
}

/// "10.000" -> 10000.0. Dipakai sebelum kirim payload ke BE
/// agar tipe data tetap number (tanpa pemisah ribuan / desimal).
double parseThousand(String text) {
  if (text.trim().isEmpty) return 0;
  return double.tryParse(text.replaceAll('.', '').trim()) ?? 0;
}
