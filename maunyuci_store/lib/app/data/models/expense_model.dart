class ExpenseModel {
  final String id;
  final String category;
  final double amount;
  final String? description;
  final DateTime expenseDate;
  final String storeId;

  ExpenseModel({
    required this.id,
    required this.category,
    required this.amount,
    this.description,
    required this.expenseDate,
    required this.storeId,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] ?? '',
      category: json['category'] ?? 'Lainnya',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'],
      expenseDate: json['expenseDate'] != null ? DateTime.parse(json['expenseDate']) : DateTime.now(),
      storeId: json['storeId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'description': description,
      'expenseDate': expenseDate.toIso8601String(),
      'storeId': storeId,
    };
  }
}
