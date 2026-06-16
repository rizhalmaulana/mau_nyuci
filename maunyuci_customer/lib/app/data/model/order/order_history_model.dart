class OrderHistoryModel {
  final String storeName;
  final String serviceType;
  final String status;
  final String date;
  final String totalPrice;

  OrderHistoryModel({
    required this.storeName,
    required this.serviceType,
    required this.status,
    required this.date,
    required this.totalPrice,
  });
}