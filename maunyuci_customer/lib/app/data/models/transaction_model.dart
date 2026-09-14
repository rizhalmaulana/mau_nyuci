import 'package:maunyuci_core/maunyuci_core.dart';

class TransactionModel {
  final String id;
  final String storeId;
  final String storeName;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final String paymentMethod;
  final bool isPaid;

  TransactionModel({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.paymentMethod = 'Tunai',
    this.isPaid = false,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      storeId: json['storeId'] ?? '',
      storeName: json['storeName'] ?? 'Toko Laundry',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'Pending',
      orderDate: json['orderDate'] != null ? DateTime.parse(json['orderDate']) : DateTime.now(),
      paymentMethod: json['paymentMethod'] ?? 'Tunai',
      isPaid: json['isPaid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'storeName': storeName,
      'totalAmount': totalAmount,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
    };
  }
}
