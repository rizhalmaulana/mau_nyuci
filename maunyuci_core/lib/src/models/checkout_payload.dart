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

class CheckoutPayload {
  final String storeId;
  final List<CheckoutItemPayload> items;
  final int deliveryType;
  final String? promoId;
  final int? paymentMethod;
  final String? selectedStoreBankAccountId;
  final String? deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? logisticsNotes;
  final String? pickupTimeSlot;
  final String? deliveryTimeSlot;
  final String? customerLaundryImageUrl;

  CheckoutPayload({
    required this.storeId,
    required this.items,
    required this.deliveryType,
    this.promoId,
    this.paymentMethod,
    this.selectedStoreBankAccountId,
    this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.logisticsNotes,
    this.pickupTimeSlot,
    this.deliveryTimeSlot,
    this.customerLaundryImageUrl,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'storeId': storeId,
      'deliveryType': deliveryType,
      'items': items.map((e) => e.toJson()).toList(),
    };

    if (paymentMethod != null) data['paymentMethod'] = paymentMethod;
    if (promoId != null) data['promoId'] = promoId;
    if (selectedStoreBankAccountId != null) data['selectedStoreBankAccountId'] = selectedStoreBankAccountId;
    if (deliveryAddress != null) data['deliveryAddress'] = deliveryAddress;
    if (deliveryLatitude != null) data['deliveryLatitude'] = deliveryLatitude;
    if (deliveryLongitude != null) data['deliveryLongitude'] = deliveryLongitude;
    if (logisticsNotes != null) data['logisticsNotes'] = logisticsNotes;
    if (pickupTimeSlot != null) data['pickupTimeSlot'] = pickupTimeSlot;
    if (deliveryTimeSlot != null) data['deliveryTimeSlot'] = deliveryTimeSlot;
    if (customerLaundryImageUrl != null) data['customerLaundryImageUrl'] = customerLaundryImageUrl;

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
