import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSuccessModal {
  static void show({
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade900,
      icon: Icon(Icons.check_circle_outline_rounded, color: Colors.green.shade700, size: 28),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      duration: const Duration(seconds: 4),
      mainButton: TextButton(
        onPressed: () {
          Get.closeCurrentSnackbar();
          onPressed();
        },
        child: Text(buttonText, style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
      ),
    );
  }
}