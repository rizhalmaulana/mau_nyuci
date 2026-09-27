import 'package:flutter/material.dart';

class AppColors {
  // Base Colors (Berdasarkan panduan warna)
  static const Color primary = Color(0xFF7C3AED); // Ungu
  static const Color secondary = Color(0xFF60A5FA); // Biru Muda
  static const Color accent = Color(0xFF22D3EE); // Cyan

  // Neutral Colors (Untuk Teks, Border, dan Background)
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color textPrimary = Color(0xFF1F2937); // Abu-abu gelap (untuk judul)
  static const Color textSecondary = Color(0xFF6B7280); // Abu-abu sedang (untuk deskripsi)
  static const Color border = Color(0xFFD1D5DB); // Abu-abu terang (untuk garis input)
  static const Color background = Color(0xFFF8FAFC);

  // ==========================================
  // COLOR PRIMITIVES (Sesuai Design System)
  // ==========================================

  // --- PRIMARY (Ungu) ---
  static const Color primary50 = Color(0xFFF7F3FF);
  static const Color primary100 = Color(0xFFF1E9FE);
  static const Color primary200 = Color(0xFFE5D6FE);
  static const Color primary300 = Color(0xFFD0B5FD);
  static const Color primary400 = Color(0xFFB48BFA);
  static const Color primary500 = Color(0xFF955CF6);
  static const Color primary600 = Color(0xFF7C3AED); // Base Color
  static const Color primary700 = Color(0xFF6928D9);
  static const Color primary800 = Color(0xFF5821B6);
  static const Color primary900 = Color(0xFF491D95);
  static const Color primary950 = Color(0xFF2F1065);

  // --- SECONDARY (Biru) ---
  static const Color secondary50 = Color(0xFFEFF6FF);
  static const Color secondary100 = Color(0xFFDBEBFE);
  static const Color secondary200 = Color(0xFFBFDBFE);
  static const Color secondary300 = Color(0xFF93C2FD);
  static const Color secondary400 = Color(0xFF60A5FA); // Base Color
  static const Color secondary500 = Color(0xFF3B8FF6);
  static const Color secondary600 = Color(0xFF257EEB);
  static const Color secondary700 = Color(0xFF1D71D8);
  static const Color secondary800 = Color(0xFF1E5FAF);
  static const Color secondary900 = Color(0xFF1E4E8A);
  static const Color secondary950 = Color(0xFF173254);

  // --- ACCENT (Cyan) ---
  static const Color accent50 = Color(0xFFECFCFF);
  static const Color accent100 = Color(0xFFCFF8FE);
  static const Color accent200 = Color(0xFFA5F0FC);
  static const Color accent300 = Color(0xFF67E6F9);
  static const Color accent400 = Color(0xFF22D3EE); // Base Color
  static const Color accent500 = Color(0xFF06B9D4);
  static const Color accent600 = Color(0xFF089BB2);
  static const Color accent700 = Color(0xFF0E7F90);
  static const Color accent800 = Color(0xFF156875);
  static const Color accent900 = Color(0xFF165963);
  static const Color accent950 = Color(0xFF083C44);

  // --- ERROR/RED (Untuk status dibatalkan) ---
  static const Color error50 = Color(0xFFFEE2E2);
  static const Color error500 = Color(0xFFDC2626);
  static const Color softRed = Color(0xFFF66B6B);

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF3F4F6);

  // ==========================================
  // LEGACY MATERIAL ALIASES
  // Nilai 1:1 dari Material Colors agar migrasi
  // dari `Colors.xxx` tidak mengubah tampilan.
  // Untuk kode baru, utamakan token primer di atas.
  // `Colors.transparent` tetap boleh dipakai langsung.
  // ==========================================

  static const Color black87 = Color(0xDD000000);
  static const Color black54 = Color(0x8A000000);
  static const Color black12 = Color(0x1F000000);
  static const Color white70 = Color(0xB3FFFFFF);

  // Grey scale (Material)
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);

  // Success (Material green)
  static const Color success = Color(0xFF4CAF50);
  static const Color success50 = Color(0xFFE8F5E9);
  static const Color success100 = Color(0xFFC8E6C9);
  static const Color success200 = Color(0xFFA5D6A7);
  static const Color success600 = Color(0xFF43A047);
  static const Color success700 = Color(0xFF388E3C);
  static const Color success800 = Color(0xFF2E7D32);

  // Danger (Material red)
  static const Color danger = Color(0xFFF44336);
  static const Color danger50 = Color(0xFFFFEBEE);
  static const Color danger100 = Color(0xFFFFCDD2);
  static const Color danger200 = Color(0xFFEF9A9A);
  static const Color danger300 = Color(0xFFE57373);
  static const Color danger400 = Color(0xFFEF5350);
  static const Color danger600 = Color(0xFFE53935);
  static const Color danger700 = Color(0xFFD32F2F);
  static const Color redAccent = Color(0xFFFF5252);

  // Orange (Material)
  static const Color orange = Color(0xFFFF9800);
  static const Color orange50 = Color(0xFFFFF3E0);
  static const Color orange100 = Color(0xFFFFE0B2);
  static const Color orange200 = Color(0xFFFFCC80);
  static const Color orange600 = Color(0xFFFB8C00);
  static const Color orange700 = Color(0xFFF57C00);
  static const Color orange800 = Color(0xFFEF6C00);

  // Warning (Material amber)
  static const Color warning = Color(0xFFFFC107);
  static const Color warning50 = Color(0xFFFFF8E1);
  static const Color warning200 = Color(0xFFFFE082);
  static const Color warning500 = Color(0xFFFFC107);
  static const Color warning600 = Color(0xFFFFB300);
  static const Color warning700 = Color(0xFFFFA000);
  static const Color warning900 = Color(0xFFFF6F00);

  // Info (Material blue)
  static const Color info = Color(0xFF2196F3);
  static const Color info50 = Color(0xFFE3F2FD);
  static const Color info100 = Color(0xFFBBDEFB);
  static const Color info700 = Color(0xFF1976D2);
  static const Color info900 = Color(0xFF0D47A1);

  // Purple (Material)
  static const Color purple = Color(0xFF9C27B0);
  static const Color purple50 = Color(0xFFF3E5F5);
  static const Color purple300 = Color(0xFFBA68C8);

  // Deep purple (Material, dipakai di fitur Staff dkk)
  static const Color deepPurple = Color(0xFF673AB7);
  static const Color deepPurple50 = Color(0xFFEDE7F6);
  static const Color deepPurple100 = Color(0xFFD1C4E9);
  static const Color deepPurple300 = Color(0xFF9575CD);

  static const Color yellow = Color(0xFFFFEB3B);
  static const Color pink = Color(0xFFE91E63);

  // Input text (Tailwind gray-700 / gray-400)
  static const Color inputText = Color(0xFF374151);
  static const Color hint = Color(0xFF9CA3AF);
}