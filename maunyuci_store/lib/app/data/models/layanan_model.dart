class LayananModel {
  String id;
  String imageAsset;
  String name;
  String category;
  double price;
  String unit; // Kg, Pcs, Meter
  String? timeEstimate;
  String? description;

  LayananModel({
    required this.id,
    required this.imageAsset,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    this.timeEstimate,
    this.description,
  });

  // For copying with changes
  LayananModel copyWith({
    String? id,
    String? imageAsset,
    String? name,
    String? category,
    double? price,
    String? unit,
    String? timeEstimate,
    String? description,
  }) {
    return LayananModel(
      id: id ?? this.id,
      imageAsset: imageAsset ?? this.imageAsset,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      timeEstimate: timeEstimate ?? this.timeEstimate,
      description: description ?? this.description,
    );
  }

  factory LayananModel.fromJson(Map<String, dynamic> json) {
    return LayananModel(
      id: json['id']?.toString() ?? json['catalogId']?.toString() ?? json['Id']?.toString() ?? json['storeCatalogId']?.toString() ?? '',
      imageAsset: json['imageAsset']?.toString() ?? json['ImageAsset']?.toString() ?? '',
      name: json['name']?.toString() ?? json['Name']?.toString() ?? '',
      category: json['category']?.toString() ?? json['Category']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? json['Price']?.toString() ?? '0') ?? 0.0,
      unit: json['unit']?.toString() ?? json['Unit']?.toString() ?? '',
      timeEstimate: json['timeEstimate']?.toString() ?? json['TimeEstimate']?.toString(),
      description: json['description']?.toString() ?? json['Description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'catalogId': id,
      'category': category,
      'serviceType': 'Regular', // default
      'name': name,
      'description': description ?? '',
      'imageAsset': imageAsset,
      'price': price,
      'unit': unit,
      'timeEstimate': timeEstimate ?? '',
      'isAvailable': true,
    };
  }
}
