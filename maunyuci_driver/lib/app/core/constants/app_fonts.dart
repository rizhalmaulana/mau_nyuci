import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  /// Satu-satunya pintu pemakaian font Inter di modul ini.
  /// Bungkus [GoogleFonts.inter] agar ukuran responsif (`R.sp`) dan warna
  /// token tetap lewat sini. Jangan panggil `GoogleFonts` langsung di view.
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
      );

  /// Untuk `ThemeData.textTheme`. Satu-satunya pemakaian
  /// `GoogleFonts.interTextTheme` yang diizinkan (di `main.dart`).
  static TextTheme interTextTheme([TextTheme? textTheme]) =>
      GoogleFonts.interTextTheme(textTheme);

  // Headings
  static TextStyle get fInterHeading6Semibold => GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600);

  // Subheading
  static TextStyle get fInterSubheadingRegular => GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w400);
  static TextStyle get fInterSubheadingMedium => GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500);
  static TextStyle get fInterSubheadingSemibold => GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600);

  // Body
  static TextStyle get fInterBodyRegular => GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400);
  static TextStyle get fInterBodyMedium => GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500);
  static TextStyle get fInterBodySemibold => GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600);

  // Body Small
  static TextStyle get fInterBodySmallRegular => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400);
  static TextStyle get fInterBodySmallMedium => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500);
  static TextStyle get fInterBodySmallSemibold => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600);

  // Status
  static TextStyle get fInterStatusRegular => GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w400);
  static TextStyle get fInterStatusSemibold => GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600);

  // Caption
  static TextStyle get fInterCaptionLight => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w300);
  static TextStyle get fInterCaptionRegular => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400);
  static TextStyle get fInterCaptionMedium => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500);
}
