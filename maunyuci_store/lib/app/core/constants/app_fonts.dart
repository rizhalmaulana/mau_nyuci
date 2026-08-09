import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
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
