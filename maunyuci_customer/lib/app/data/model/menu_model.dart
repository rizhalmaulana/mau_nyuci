class MenuModel {
  final String id;
  final String title;
  final String path;
  final String icon;
  final int sortOrder;
  final List<MenuModel> subMenus;

  MenuModel({
    required this.id,
    required this.title,
    required this.path,
    required this.icon,
    required this.sortOrder,
    this.subMenus = const [],
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      path: json['path'] ?? '',
      icon: json['icon'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
      subMenus: json['subMenus'] != null
          ? (json['subMenus'] as List).map((i) => MenuModel.fromJson(i)).toList()
          : [],
    );
  }
}
