import 'package:flutter/material.dart';
import '../../modules/home/views/home_view.dart'; // Just using the placeholder screen approach 
import '../../modules/order_history/views/order_history_view.dart';
import '../../modules/account/views/account_view.dart';
import '../constants/app_assets.dart';

class MenuMapper {
  static Widget getIcon(String iconString, {Color? color}) {
    if (iconString.startsWith('ic_')) {
      String assetPath = '';
      if (iconString == 'ic_home') {
        assetPath = AppAssets.iconHome;
      } else if (iconString == 'ic_riwayat') {
        assetPath = AppAssets.iconRiwayat;
      }
      else if (iconString == 'ic_akun') {
        assetPath = AppAssets.iconAkun;
      }
      else {
        assetPath = 'assets/icons/$iconString.png';

        return ImageIcon(
          AssetImage(assetPath),
          color: color,
        );
      }
    }

    // Map material icons as fallback
    switch (iconString) {
      case 'home':
        return Icon(Icons.home, color: color);
      case 'receipt':
        return Icon(Icons.receipt, color: color);
      case 'person':
        return Icon(Icons.person, color: color);
      default:
        return Icon(Icons.circle, color: color); // Fallback icon
    }
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
