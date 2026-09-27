class CatalogModel {
  final String? id;
  final String? storeId;
  final String? name;
  final String? category; // Kiloan, Satuan, etc.
  final double? price;
  final String? unit; // Kg, Pcs, etc.
  final String? description;
  final String? imageAsset;
  final String? timeEstimate;

  CatalogModel({
    this.id,
    this.storeId,
    this.name,
    this.category,
    this.price,
    this.unit,
    this.description,
    this.imageAsset,
    this.timeEstimate,
  });

  factory CatalogModel.fromJson(Map<String, dynamic> json) {
    return CatalogModel(
      id: json['id'] as String?,
      storeId: json['storeId'] as String?,
      name: json['name'] as String?,
      category: json['category'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      description: json['description'] as String?,
      imageAsset: json['imageAsset'] as String?,
      timeEstimate: json['timeEstimate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'storeId': storeId,
      'name': name,
      'category': category,
      'price': price,
      'unit': unit,
      'description': description,
      'imageAsset': imageAsset,
      'timeEstimate': timeEstimate,
    };
  }
}
