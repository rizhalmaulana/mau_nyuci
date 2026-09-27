import 'package:flutter/material.dart';
import '../../modules/home/views/home_view.dart'; // Just using the placeholder screen approach 
import '../../modules/order_history/views/order_history_view.dart';
import '../../modules/account/views/account_view.dart';
import '../constants/app_assets.dart';

class MenuMapper {
  static Widget getIcon(String iconString, {Color? color}) {
    final String assetPath = 'assets/icons/$iconString.png';
    return Image.asset(
      assetPath,
      width: 24,
      height: 24,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.circle, color: color, size: 24);
      },
    );
  }

  static Widget getScreen(String pathString, Widget defaultHomeScrollableBody) {
    switch (pathString) {
      case '/home':
        return defaultHomeScrollableBody;
      case '/history':
        return const OrderHistoryView();
      case '/account':
        return const AccountView();
      default:
        return Center(child: Text('Unknown Page: $pathString'));
    }
  }
}
