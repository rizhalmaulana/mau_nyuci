class TransactionResponseModel {
  final String id;
  final String storeName;
  final String status;
  final String deliveryType;
  final String paymentMethod;
  final double totalAmount;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime? expectedCompletionDate;
  final List<OrderItemResponseModel> items; // Tambahkan ini

  TransactionResponseModel({
    required this.id,
    required this.storeName,
    required this.status,
    required this.deliveryType,
    required this.paymentMethod,
    required this.totalAmount,
    required this.paymentStatus,
    required this.createdAt,
    required this.items, // Tambahkan ini
    this.expectedCompletionDate,
  });

  factory TransactionResponseModel.fromJson(Map<String, dynamic> json) {
    return TransactionResponseModel(
      id: json['id'],
      storeName: json['storeName'],
      status: json['status'],
      deliveryType: json['deliveryType'],
      paymentMethod: json['paymentMethod'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentStatus: json['paymentStatus'],
      createdAt: DateTime.parse(json['createdAt']),
      expectedCompletionDate: json['expectedCompletionDate'] != null
          ? DateTime.parse(json['expectedCompletionDate'])
          : null,
      items: (json['items'] as List?)
          ?.map((i) => OrderItemResponseModel.fromJson(i))
          .toList() ?? [],
    );
  }
}

class OrderItemResponseModel {
  final String itemName;
  final double unitPrice;
  final double quantity;
  final String unit;
  final double subTotal;

  OrderItemResponseModel({
    required this.itemName,
    required this.unitPrice,
    required this.quantity,
    required this.unit,
    required this.subTotal,
  });

  factory OrderItemResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderItemResponseModel(
      itemName: json['itemName'] ?? '',
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] ?? '',
      subTotal: (json['subTotal'] as num).toDouble(),
    );
  }
}