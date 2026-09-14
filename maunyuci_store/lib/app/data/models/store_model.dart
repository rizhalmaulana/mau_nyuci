class StoreModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double? distanceInKm;
  final String operatingHoursFormatted;
  final bool isCurrentlyOpen;
  final double averageRating;
  final int totalReviews;
  final String storeImageUrl;
  final String? phoneNumber;

  StoreModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distanceInKm,
    required this.operatingHoursFormatted,
    required this.isCurrentlyOpen,
    required this.averageRating,
    required this.totalReviews,
    required this.storeImageUrl,
    this.phoneNumber,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distanceInKm: (json['distanceInKm'] as num?)?.toDouble(),
      operatingHoursFormatted: json['operatingHoursFormatted'] ?? '',
      isCurrentlyOpen: json['isCurrentlyOpen'] ?? false,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] ?? 0,
      storeImageUrl: json['storeImageUrl'] ?? '',
      phoneNumber: json['phoneNumber'] ?? json['storePhoneNumber'],
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
      'phoneNumber': phoneNumber,
    };
  }
}

