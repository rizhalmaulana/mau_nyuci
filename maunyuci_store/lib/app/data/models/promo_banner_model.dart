class PromoBannerModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String imageUrl;
  final String ctaText;
  final String ctaType;
  final String ctaValue;
  final int sortOrder;
  final bool isActive;
  final List<String> targetRoles;
  final List<String> targetTiers;
  final String appType;

  const PromoBannerModel({
    required this.id,
    required this.title,
    required this.description,
    this.icon = '',
    this.imageUrl = '',
    this.ctaText = 'Coba 1 Bulan Gratis',
    this.ctaType = 'whatsapp',
    this.ctaValue = '',
    this.sortOrder = 0,
    this.isActive = true,
    this.targetRoles = const [],
    this.targetTiers = const [],
    this.appType = 'Store',
  });

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return const [];
  }

  factory PromoBannerModel.fromJson(Map<String, dynamic> json) {
    return PromoBannerModel(
      id: (json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      ctaText: json['ctaText'] ?? 'Coba 1 Bulan Gratis',
      ctaType: json['ctaType'] ?? 'whatsapp',
      ctaValue: json['ctaValue'] ?? '',
      sortOrder: json['sortOrder'] is int
          ? json['sortOrder']
          : int.tryParse(json['sortOrder']?.toString() ?? '') ?? 0,
      isActive: json['isActive'] ?? true,
      targetRoles: _stringList(json['targetRoles']),
      targetTiers: _stringList(json['targetTiers']),
      appType: json['appType'] ?? 'Store',
    );
  }
}
