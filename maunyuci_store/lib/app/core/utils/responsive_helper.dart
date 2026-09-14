import 'package:flutter/material.dart';

class R {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double _baseWidth;
  static late double _baseHeight;

  // Base design size (desain di Figma/referensi ukuran berapa?)
  static const double designWidth = 375.0;
  static const double designHeight = 812.0;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    _baseWidth = screenWidth / designWidth;
    _baseHeight = screenHeight / designHeight;
  }

  /// Skala horizontal (untuk width, padding horizontal)
  static double w(double size) => size * _baseWidth;

  /// Skala vertikal (untuk height, padding vertical)
  static double h(double size) => size * _baseHeight;

  /// Skala font (rata-rata width & height agar tidak terlalu ekstrem)
  static double sp(double size) => size * (_baseWidth < _baseHeight ? _baseWidth : _baseHeight);

  /// Skala adaptif berdasarkan dimensi terkecil (cocok untuk radius, icon)
  static double r(double size) => size * (_baseWidth < _baseHeight ? _baseWidth : _baseHeight);
}
