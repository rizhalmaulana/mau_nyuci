import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/menu_model.dart';
import '../../../data/repositories/menu_repository.dart';

class MainController extends GetxController {
  final MenuRepository _menuRepository = MenuRepository();

  var tabIndex = 0.obs;
  var menus = <MenuModel>[].obs;
  var isMenuLoading = true.obs;
  var menuErrorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMenus();
  }

  Future<void> fetchMenus() async {
    try {
      isMenuLoading.value = true;
      menuErrorMessage.value = '';

      final fetchedMenus = await _menuRepository.fetchMenus();
      fetchedMenus.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      menus.assignAll(fetchedMenus);
    } catch (e) {
      menuErrorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isMenuLoading.value = false;
    }
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}
