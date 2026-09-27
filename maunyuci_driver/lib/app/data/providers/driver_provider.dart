import 'package:dio/dio.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import '../models/driver_task_model.dart';

class DriverProvider {
  final ApiClientNetwork _apiClient;

  DriverProvider(this._apiClient);

  Future<Map<String, dynamic>> getUnsettledCash() async {
    try {
      final response = await _apiClient.getReq<dynamic>(ApiConstants.driverUnsettledCash);
      if (!response.success) throw Exception(response.message);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<DriverTaskModel>> getTasks() async {
    try {
      final response = await _apiClient.getReq<dynamic>(ApiConstants.driverTasks);
      if (!response.success) throw Exception(response.message);
      
      final dataList = response.data is List ? response.data : response.data['data'] ?? [];
      return (dataList as List).map((e) => DriverTaskModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<DriverTaskDetailModel> getTaskDetail(String orderId) async {
    try {
      final response = await _apiClient.getReq<dynamic>(ApiConstants.driverTaskDetail(orderId));
      if (!response.success) throw Exception(response.message);
      
      final data = response.data is Map ? response.data : response.data['data'];
      return DriverTaskDetailModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendLocation(double latitude, double longitude) async {
    try {
      final response = await _apiClient.putReq<dynamic>(
        ApiConstants.driverLocation,
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      if (!response.success) throw Exception(response.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> confirmPickup(String orderId, String evidenceFilePath) async {
    try {
      FormData formData = FormData.fromMap({
        'evidenceFile': await MultipartFile.fromFile(evidenceFilePath, filename: 'pickup_evidence.jpg'),
      });
      final response = await _apiClient.putReq<dynamic>(
        ApiConstants.driverPickup(orderId),
        data: formData,
      );
      if (!response.success) throw Exception(response.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> confirmDelivery(String orderId, String evidenceFilePath) async {
    try {
      FormData formData = FormData.fromMap({
        'evidenceFile': await MultipartFile.fromFile(evidenceFilePath, filename: 'delivery_evidence.jpg'),
      });
      final response = await _apiClient.putReq<dynamic>(
        ApiConstants.driverDeliverPhoto(orderId),
        data: formData,
      );
      if (!response.success) throw Exception(response.message);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> confirmCashDelivery(String orderId) async {
    try {
      final response = await _apiClient.putReq<dynamic>(
        ApiConstants.driverDeliverCash(orderId),
      );
      if (!response.success) throw Exception(response.message);
    } catch (e) {
      rethrow;
    }
  }
}
