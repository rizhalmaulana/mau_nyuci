class PosCheckoutPayload {
  final String guestCustomerName;
  final String? guestCustomerPhone;
  final int deliveryType;
  final int paymentMethod;
  final String? deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? selectedStoreBankAccountId;
  final List<CheckoutItemPayload> items;

  PosCheckoutPayload({
    required this.guestCustomerName,
    this.guestCustomerPhone,
    required this.deliveryType,
    required this.paymentMethod,
    this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.selectedStoreBankAccountId,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'guestCustomerName': guestCustomerName,
      'deliveryType': deliveryType,
      'paymentMethod': paymentMethod,
      'items': items.map((e) => e.toJson()).toList(),
    };

    if (guestCustomerPhone != null) data['guestCustomerPhone'] = guestCustomerPhone;
    if (deliveryAddress != null) data['deliveryAddress'] = deliveryAddress;
    if (deliveryLatitude != null) data['deliveryLatitude'] = deliveryLatitude;
    if (deliveryLongitude != null) data['deliveryLongitude'] = deliveryLongitude;
    if (selectedStoreBankAccountId != null) data['selectedStoreBankAccountId'] = selectedStoreBankAccountId;

    return data;
  }
}

class CheckoutItemPayload {
  final String catalogItemId;
  final double quantity;

  CheckoutItemPayload({
    required this.catalogItemId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'catalogItemId': catalogItemId,
      'quantity': quantity,
    };
  }
}
