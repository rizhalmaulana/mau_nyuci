class PromoModel {
  final String id;
  final String promoCode;
  final String discountType;
  final String discountTarget;
  final double discountValue;
  final double maxDiscountAmount;
  final double minOrderAmount;
  final DateTime? expiryDate;
  final bool isActive;
  final String storeId;

  PromoModel({
    required this.id,
    required this.promoCode,
    required this.discountType,
    this.discountTarget = 'All',
    required this.discountValue,
    this.maxDiscountAmount = 0,
    this.minOrderAmount = 0,
    this.expiryDate,
    this.isActive = true,
    required this.storeId,
  });

  factory PromoModel.fromJson(Map<String, dynamic> json) {
    return PromoModel(
      id: json['id'] ?? '',
      promoCode: json['promoCode'] ?? '',
      discountType: json['discountType'] ?? 'Nominal',
      discountTarget: json['discountTarget'] ?? 'All',
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      maxDiscountAmount: (json['maxDiscountAmount'] ?? 0).toDouble(),
      minOrderAmount: (json['minOrderAmount'] ?? 0).toDouble(),
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      isActive: json['isActive'] ?? true,
      storeId: json['storeId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'promoCode': promoCode,
      'discountType': discountType,
      'discountTarget': discountTarget,
      'discountValue': discountValue,
      'maxDiscountAmount': maxDiscountAmount,
      'minOrderAmount': minOrderAmount,
      'expiryDate': expiryDate?.toIso8601String(),
      'isActive': isActive,
      'storeId': storeId,
    };
  }
}
