class InventoryModel {
  final String id;
  final String itemName;
  final double currentStock;
  final String unit;
  final double minStockLevel;
  final String storeId;
  final DateTime? updatedAt;

  InventoryModel({
    required this.id,
    required this.itemName,
    required this.currentStock,
    required this.unit,
    this.minStockLevel = 0,
    required this.storeId,
    this.updatedAt,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'] ?? '',
      itemName: json['itemName'] ?? json['name'] ?? '',
      // BE mengirim `stockQuantity` (lihat Swagger), alias lama dipertahankan.
      currentStock: (json['currentStock'] ?? json['stockQuantity'] ?? json['stock'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'Pcs',
      // BE mengirim `minimumStockAlert`, alias lama dipertahankan.
      minStockLevel: (json['minStockLevel'] ?? json['minimumStockAlert'] ?? json['minimumStock'] ?? 0).toDouble(),
      storeId: json['storeId'] ?? '',
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'currentStock': currentStock,
      'unit': unit,
      'minStockLevel': minStockLevel,
      'storeId': storeId,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
