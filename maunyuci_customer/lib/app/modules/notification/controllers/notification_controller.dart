import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/providers/notification_provider.dart';
import '../../../core/helpers/api_error_helper.dart';
import '../../../core/widgets/custom_snackbar.dart';

class NotificationController extends GetxController {
  final NotificationProvider _provider = NotificationProvider();
  
  var notifications = <NotificationModel>[].obs;
  var isLoading = true.obs;
  var isLoadingMore = false.obs;
  
  int _currentPage = 1;
  final int _pageSize = 20;
  var hasMoreData = true.obs;
  
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fetchNotifications();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && hasMoreData.value) {
        loadMore();
      }
    }
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      _currentPage = 1;
      
      final response = await _provider.getNotifications(page: _currentPage, pageSize: _pageSize);
      if (response.success && response.data != null) {
        final data = response.data!;
        notifications.assignAll(data);
        hasMoreData.value = data.length == _pageSize;
      } else {
        CustomSnackbar.showError('Gagal Memuat', response.message ?? 'Terjadi kesalahan');
      }
    } catch (e) {
      CustomSnackbar.showError('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    try {
      isLoadingMore.value = true;
      _currentPage++;
      
      final response = await _provider.getNotifications(page: _currentPage, pageSize: _pageSize);
      if (response.success && response.data != null) {
        final data = response.data!;
        notifications.addAll(data);
        hasMoreData.value = data.length == _pageSize;
      } else {
        _currentPage--;
      }
    } catch (e) {
      _currentPage--;
      debugPrint("Load more error: $e");
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;
    
    try {
      final response = await _provider.readNotification(notification.id);
      
      if (response.success) {
        // Update local state
        final index = notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          final updated = NotificationModel(
            id: notification.id,
            title: notification.title,
            message: notification.message,
            isRead: true,
            createdAt: notification.createdAt,
            type: notification.type,
            referenceId: notification.referenceId,
          );
          notifications[index] = updated;
        }
      }
      
      // Optionally trigger something to update the home unread badge
      // e.g. Get.find<HomeController>().updateUnreadCount();
      
    } catch (e) {
      debugPrint("Error marking as read: $e");
    }
  }
}
