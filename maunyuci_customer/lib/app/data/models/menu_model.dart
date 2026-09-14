class MenuModel {
  final String id;
  final String title;
  final String path;
  final String icon;
  final int sortOrder;
  final String storeId;
  final String name;
  final double price;
  final String type;
  final String? description;
  final bool isAvailable;
  
  MenuModel({
    required this.id,
    required this.title,
    required this.path,
    required this.icon,
    this.sortOrder = 0,
    required this.storeId,
    required this.name,
    required this.price,
    required this.type,
    this.description,
    this.isAvailable = true,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      path: json['path'] ?? '',
      icon: json['icon'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
      storeId: json['storeId'] ?? '',
      name: json['name'] ?? json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      type: json['type'] ?? 'Satuan',
      description: json['description'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'path': path,
      'icon': icon,
      'sortOrder': sortOrder,
      'storeId': storeId,
      'name': name,
      'price': price,
      'type': type,
      'description': description,
      'isAvailable': isAvailable,
    };
  }
}
