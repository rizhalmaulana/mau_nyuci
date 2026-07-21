import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'custom_error_modal.dart';

class CustomSnackbar {
  static void show({
    required String title,
    required String message,
    required String type,
  }) {
    Color backgroundColor;
    Color textColor = Colors.white;
    IconData icon;

    switch (type.toLowerCase()) {
      case 'error':
        // Redirect generic error calls to the CustomErrorModal
        CustomErrorModal.show(title: title, message: message);
        return;
      case 'warning':
        backgroundColor = Colors.orange.shade700;
        icon = Icons.warning_amber_rounded;
        break;
      case 'success':
        backgroundColor = Colors.green.shade600;
        icon = Icons.check_circle_outline;
        break;
      case 'info':
      default:
        backgroundColor = Colors.blue.shade600;
        icon = Icons.info_outline;
        break;
    }

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: textColor,
      icon: Icon(icon, color: textColor),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 300),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        )
      ],
    );
  }

  static void showSuccess(String title, String message) {
    show(title: title, message: message, type: 'success');
  }

  static void showError(String title, String message) {
    CustomErrorModal.show(title: title, message: message);
  }

  static void showWarning(String title, String message) {
    show(title: title, message: message, type: 'warning');
  }

  static void showInfo(String title, String message) {
    show(title: title, message: message, type: 'info');
  }
}
