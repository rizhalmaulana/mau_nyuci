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
  final List<OrderItemResponseModel> items;
  final double? totalQuantity;

  TransactionResponseModel({
    required this.id,
    required this.storeName,
    required this.status,
    required this.deliveryType,
    required this.paymentMethod,
    required this.totalAmount,
    required this.paymentStatus,
    required this.createdAt,
    required this.items,
    this.expectedCompletionDate,
    this.totalQuantity,
  });

  factory TransactionResponseModel.fromJson(Map<String, dynamic> json) {
    // API /api/Order/customer mengirim `itemsSummary` (bukan `items`)
    // dan `totalQuantity`. Dua-duanya didukung agar berat tidak selalu '-'.
    final rawItems = (json['items'] as List?) ?? (json['itemsSummary'] as List?);
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
      items: rawItems
          ?.map((i) => OrderItemResponseModel.fromJson(i as Map<String, dynamic>))
          .toList() ?? [],
      totalQuantity: (json['totalQuantity'] as num?)?.toDouble(),
    );
  }
}

class OrderItemResponseModel {
  final String itemName;
  final double unitPrice;
  final double quantity;
  final String unit;
  final double subTotal;
  final String? itemImageUrl;

  OrderItemResponseModel({
    required this.itemName,
    required this.unitPrice,
    required this.quantity,
    required this.unit,
    required this.subTotal,
    this.itemImageUrl,
  });

  factory OrderItemResponseModel.fromJson(Map<String, dynamic> json) {
    final quantity = ((json['quantity'] as num?) ?? 0).toDouble();
    final unitPrice = ((json['unitPrice'] as num?) ?? 0).toDouble();
    return OrderItemResponseModel(
      itemName: json['itemName'] ?? '',
      unitPrice: unitPrice,
      quantity: quantity,
      unit: json['unit'] ?? '',
      // `itemsSummary` tidak mengirim subTotal -> hitung dari qty x harga.
      subTotal: ((json['subTotal'] as num?) ?? (json['subtotal'] as num?) ?? quantity * unitPrice).toDouble(),
      itemImageUrl: json['itemImageUrl'] as String?,
    );
  }
}