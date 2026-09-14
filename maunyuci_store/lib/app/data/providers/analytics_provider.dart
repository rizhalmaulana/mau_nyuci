import 'package:maunyuci_core/maunyuci_core.dart';

class AnalyticsProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<Map<String, dynamic>>> getSummary() async {
    return await _network.getReq<Map<String, dynamic>>(
      ApiConstants.storeAnalyticsSummary,
      fromJson: (inner) {
        if (inner is Map<String, dynamic>) {
          return inner;
        }
        return <String, dynamic>{};
      },
    );
  }
}
