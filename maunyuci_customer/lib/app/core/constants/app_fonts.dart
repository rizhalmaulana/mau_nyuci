import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class AppFonts {
  static const String _fontFamily = 'Inter';

  // Subheading
  static TextStyle get fInterSubheadingRegular => TextStyle(fontFamily: _fontFamily, fontSize: R.sp(18), fontWeight: FontWeight.w400);
  static TextStyle get fInterSubheadingMedium => TextStyle(fontFamily: _fontFamily, fontSize: R.sp(18), fontWeight: FontWeight.w500);
  static TextStyle get fInterSubheadingSemibold => TextStyle(fontFamily: _fontFamily, fontSize: R.sp(18), fontWeight: FontWeight.w600);

  // Body
  static TextStyle get fInterBodyRegular => TextStyle(fontFamily: _fontFamily, fontSize: R.sp(16), fontWeight: FontWeight.w400);
  static TextStyle get fInterBodyMedium => TextStyle(fontFamily: _fontFamily, fontSize: R.sp(16), fontWeight: FontWeight.w500);
  static TextStyle get fInterBodySemibold => TextStyle(fontFamily: _fontFamily, fontSize: R.sp(16), fontWeight: FontWeight.w600);

  // Body Small
  static TextStyle get fInterBodySmallRegular => TextStyle(fontFamily: _fontFamily, fontSize: R.sp(14), fontWeight: FontWeight.w400);
  static TextStyle get fInterBodySmallMedium => TextStyle(fontFamily: _fontFamily, fontSize: R.sp(14), fontWeight: FontWeight.w500);
  static TextStyle get fInterBodySmallSemibold => TextStyle(fontFamily: _fontFamily, fontSize: R.sp(14), fontWeight: FontWeight.w600);

  // Status
  static TextStyle get fInterStatusRegular => TextStyle(fontFamily: _fontFamily, fontSize: R.sp(10), fontWeight: FontWeight.w400);
  static TextStyle get fInterStatusSemibold => TextStyle(fontFamily: _fontFamily, fontSize: R.sp(10), fontWeight: FontWeight.w600);

  // Caption
  static TextStyle get fInterCaptionLight => TextStyle(fontFamily: _fontFamily, fontSize: R.sp(12), fontWeight: FontWeight.w300);
  static TextStyle get fInterCaptionRegular => TextStyle(fontFamily: _fontFamily, fontSize: R.sp(12), fontWeight: FontWeight.w400);
  static TextStyle get fInterCaptionMedium => TextStyle(fontFamily: _fontFamily, fontSize: R.sp(12), fontWeight: FontWeight.w500);
}