class MenuModel {
  final String id;
  final String? parentId;
  final String title;
  final String path;
  final String icon;
  final int sortOrder;
  final bool isActive;
  final String? requiredRole;
  final String? requiredMembershipTier;
  final List<MenuModel> subMenus;

  MenuModel({
    required this.id,
    this.parentId,
    required this.title,
    required this.path,
    required this.icon,
    required this.sortOrder,
    this.isActive = true,
    this.requiredRole,
    this.requiredMembershipTier,
    this.subMenus = const [],
  });

  /// Top-level bila [parentId] null (sesuai kontrak BE `/api/Menu`).
  bool get isTopLevel => parentId == null || parentId!.isEmpty;

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: (json['id'] ?? '').toString(),
      parentId: json['parentId']?.toString(),
      title: json['title'] ?? '',
      path: json['path'] ?? '',
      icon: json['icon'] ?? '',
      sortOrder: json['sortOrder'] is int
          ? json['sortOrder']
          : int.tryParse(json['sortOrder']?.toString() ?? '') ?? 0,
      isActive: json['isActive'] ?? true,
      requiredRole: json['requiredRole']?.toString(),
      requiredMembershipTier: json['requiredMembershipTier']?.toString(),
      subMenus: json['subMenus'] is List
          ? (json['subMenus'] as List).map((i) => MenuModel.fromJson(i)).toList()
          : [],
    );
  }
}
