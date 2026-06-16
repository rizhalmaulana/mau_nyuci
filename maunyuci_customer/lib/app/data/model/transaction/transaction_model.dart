class TransactionModel {
  final String storeName;
  final String serviceType;
  final String status;
  final String estimatedTime;
  final String totalPrice;

  TransactionModel({
    required this.storeName,
    required this.serviceType,
    required this.status,
    required this.estimatedTime,
    required this.totalPrice,
  });
}