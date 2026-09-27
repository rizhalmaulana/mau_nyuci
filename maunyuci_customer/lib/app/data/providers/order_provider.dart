import 'package:maunyuci_core/maunyuci_core.dart';

class OrderProvider {
  final ApiClientNetwork _network = ApiClientNetwork();

  Future<ApiResponse<String>> checkoutOrder(CheckoutPayload payload) async {
    return await _network.postReq<String>(
      ApiConstants.checkoutOrder,
      data: payload.toJson(),
    );
  }
}
