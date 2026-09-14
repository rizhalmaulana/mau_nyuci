import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/notification_model.dart';

class NotificationProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<List<NotificationModel>>> getNotifications({int page = 1, int pageSize = 20}) async {
    return await _network.getReq<List<NotificationModel>>(
      ApiConstants.getNotifications,
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
      },
      fromJson: (data) {
        if (data is List) {
          return data.map((e) => NotificationModel.fromJson(e)).toList();
        } else if (data is Map<String, dynamic> && data['items'] is List) {
          // In case of paginated response wrapping items
          return (data['items'] as List).map((e) => NotificationModel.fromJson(e)).toList();
        }
        return [];
      },
    );
  }

  Future<ApiResponse<dynamic>> readNotification(String id) async {
    return await _network.putReq<dynamic>(
      ApiConstants.readNotification(id),
    );
  }

  Future<ApiResponse<int>> getUnreadCount() async {
    return await _network.getReq<int>(
      ApiConstants.unreadNotificationCount,
      fromJson: (data) {
        if (data is int) return data;
        if (data is Map && data['count'] != null) return data['count'] as int;
        return int.tryParse(data.toString()) ?? 0;
      },
    );
  }
}
