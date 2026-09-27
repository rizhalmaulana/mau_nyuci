class OrderModel {
  final String id;
  final String storeName;
  final String customerName;
  final String? customerPhone;
  final String status;
  final String deliveryType;
  final String paymentMethod;
  final double totalAmount;
  final double deliveryFee;
  final double discountAmount;
  final String? appliedPromoCode;
  final String paymentStatus;
  final String? paymentProvider;
  final String? paymentReceiptUrl;
  final String? paymentRejectionReason;

  final String? selectedStoreBankAccountId;
  final String? selectedStoreBankName;
  final String? selectedStoreBankAccountNumber;
  final String? selectedStoreAccountHolderName;

  final DateTime createdAt;
  final DateTime? expectedCompletionDate;
  final bool isLate;
  
  final String? deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? logisticsNote;
  final String? pickupTimeSlot;
  final String? deliveryTimeSlot;
  final String? customerLaundryImageUrl;

  // Fitur manual POS Order
  final bool isManualOrder;
  final String? guestCustomerName;
  final String? guestCustomerPhone;

  final double? totalQuantity;

  final List<OrderItemModel>? items;
  final List<OrderItemSummaryModel>? itemsSummary;

  OrderModel({
    required this.id,
    required this.storeName,
    required this.customerName,
    this.customerPhone,
    required this.status,
    required this.deliveryType,
    required this.paymentMethod,
    required this.totalAmount,
    required this.deliveryFee,
    this.discountAmount = 0.0,
    this.appliedPromoCode,
    required this.paymentStatus,
    this.paymentProvider,
    this.paymentReceiptUrl,
    this.paymentRejectionReason,
    this.selectedStoreBankAccountId,
    this.selectedStoreBankName,
    this.selectedStoreBankAccountNumber,
    this.selectedStoreAccountHolderName,
    required this.createdAt,
    this.expectedCompletionDate,
    required this.isLate,
    this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.logisticsNote,
    this.pickupTimeSlot,
    this.deliveryTimeSlot,
    this.customerLaundryImageUrl,
    required this.isManualOrder,
    this.guestCustomerName,
    this.guestCustomerPhone,
    this.totalQuantity,
    this.items,
    this.itemsSummary,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      storeName: json['storeName'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'],
      status: json['status'] ?? 'Pending',
      deliveryType: json['deliveryType'] ?? 'SelfService',
      paymentMethod: json['paymentMethod'] ?? 'PayLater',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      appliedPromoCode: json['appliedPromoCode'],
      paymentStatus: json['paymentStatus'] ?? 'Unpaid',
      paymentProvider: json['paymentProvider'],
      paymentReceiptUrl: json['paymentReceiptUrl'],
      paymentRejectionReason: json['paymentRejectionReason'],
      selectedStoreBankAccountId: json['selectedStoreBankAccountId'],
      selectedStoreBankName: json['selectedStoreBankName'],
      selectedStoreBankAccountNumber: json['selectedStoreBankAccountNumber'],
      selectedStoreAccountHolderName: json['selectedStoreAccountHolderName'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']).toLocal() : DateTime.now(),
      expectedCompletionDate: json['expectedCompletionDate'] != null ? DateTime.parse(json['expectedCompletionDate']).toLocal() : null,
      isLate: json['isLate'] ?? false,
      deliveryAddress: json['deliveryAddress'],
      deliveryLatitude: json['deliveryLatitude'] != null ? (json['deliveryLatitude'] as num).toDouble() : null,
      deliveryLongitude: json['deliveryLongitude'] != null ? (json['deliveryLongitude'] as num).toDouble() : null,
      logisticsNote: json['logisticsNote'],
      pickupTimeSlot: json['pickupTimeSlot'],
      deliveryTimeSlot: json['deliveryTimeSlot'],
      customerLaundryImageUrl: json['customerLaundryImageUrl'],
      isManualOrder: json['isManualOrder'] ?? false,
      guestCustomerName: json['guestCustomerName'],
      guestCustomerPhone: json['guestCustomerPhone'],
      totalQuantity: json['totalQuantity'] != null ? (json['totalQuantity'] as num).toDouble() : null,
      items: json['items'] != null
          ? (json['items'] as List<dynamic>).map((item) => OrderItemModel.fromJson(item)).toList()
          : null,
      itemsSummary: json['itemsSummary'] != null
          ? (json['itemsSummary'] as List<dynamic>).map((item) => OrderItemSummaryModel.fromJson(item)).toList()
          : null,
    );
  }
}

class OrderItemSummaryModel {
  final String itemName;
  final double quantity;
  final String unit;
  final double unitPrice;
  final String? itemImageUrl;

  OrderItemSummaryModel({
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    this.itemImageUrl,
  });

  factory OrderItemSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderItemSummaryModel(
      itemName: json['itemName'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      itemImageUrl: json['itemImageUrl'],
    );
  }
}

class OrderItemModel {
  final String id;
  final String itemName;
  final double unitPrice;
  final double quantity;
  final String unit;
  final double subTotal;
  final String? itemImageUrl;

  OrderItemModel({
    required this.id,
    required this.itemName,
    required this.unitPrice,
    required this.quantity,
    required this.unit,
    required this.subTotal,
    this.itemImageUrl,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    // GET Order/{id} mengirim kunci "orderItemId" (bukan "id").
    final parsedId = (json['id'] ?? json['orderItemId'])?.toString() ?? '';
    return OrderItemModel(
      id: parsedId,
      itemName: json['itemName'] ?? '',
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? '',
      subTotal: (json['subTotal'] ?? 0).toDouble(),
      itemImageUrl: json['itemImageUrl'],
    );
  }
}
