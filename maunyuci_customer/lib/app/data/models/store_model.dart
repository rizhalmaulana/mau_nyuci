class StoreModel {
  final String? id;
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double? distanceInKm;
  final String? operatingHoursFormatted;
  final bool? isCurrentlyOpen;
  final double? averageRating;
  final int? totalReviews;
  final String? storeImageUrl;
  final double? pickupDeliveryFee;
  final String? storePhoneNumber;
  final bool? hasPickupDeliveryService;
  final double? minOrderForPickup;

  StoreModel({
    this.id,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.distanceInKm,
    this.operatingHoursFormatted,
    this.isCurrentlyOpen,
    this.averageRating,
    this.totalReviews,
    this.storeImageUrl,
    this.pickupDeliveryFee,
    this.storePhoneNumber,
    this.hasPickupDeliveryService,
    this.minOrderForPickup,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as String?,
      name: json['name'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceInKm: (json['distanceInKm'] as num?)?.toDouble(),
      operatingHoursFormatted: json['operatingHoursFormatted'] as String?,
      isCurrentlyOpen: json['isCurrentlyOpen'] as bool?,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      totalReviews: (json['totalReviews'] as num?)?.toInt(),
      storeImageUrl: json['storeImageUrl'] as String?,
      pickupDeliveryFee: (json['pickupDeliveryFee'] as num?)?.toDouble(),
      storePhoneNumber: json['storePhoneNumber'] as String?,
      hasPickupDeliveryService: json['hasPickupDeliveryService'] as bool?,
      minOrderForPickup: (json['minOrderForPickup'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'distanceInKm': distanceInKm,
      'operatingHoursFormatted': operatingHoursFormatted,
      'isCurrentlyOpen': isCurrentlyOpen,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'storeImageUrl': storeImageUrl,
      'pickupDeliveryFee': pickupDeliveryFee,
      'storePhoneNumber': storePhoneNumber,
      'hasPickupDeliveryService': hasPickupDeliveryService,
      'minOrderForPickup': minOrderForPickup,
    };
  }
}
