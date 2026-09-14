class DashboardTransactionModel {
  final int totalOrders;
  final double totalRevenue;
  final int pendingOrders;
  final int washingOrders;
  final int readyForPickupOrders;
  final int completedOrders;
  final int cancelledOrders;

  DashboardTransactionModel({
    required this.totalOrders,
    required this.totalRevenue,
    required this.pendingOrders,
    required this.washingOrders,
    required this.readyForPickupOrders,
    required this.completedOrders,
    required this.cancelledOrders,
  });

  factory DashboardTransactionModel.fromJson(Map<String, dynamic> json) {
    return DashboardTransactionModel(
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      pendingOrders: json['pendingOrders'] ?? 0,
      washingOrders: json['washingOrders'] ?? 0,
      readyForPickupOrders: json['readyForPickupOrders'] ?? 0,
      completedOrders: json['completedOrders'] ?? 0,
      cancelledOrders: json['cancelledOrders'] ?? 0,
    );
  }
}
