import 'package:drift/drift.dart';
import 'package:maunyuci_core/maunyuci_core.dart';
import 'package:maunyuci_core/database/app_database.dart';

class UserProfileRepository {
  final AppDatabase _db;

  UserProfileRepository(this._db);

  Future<Map<String, dynamic>?> getProfile(String odUserId) async {
    UserProfile? profile;
    if (odUserId.isNotEmpty) {
      profile = await _db.getUserProfile(odUserId);
    }
    
    if (profile == null) {
      // Fallback ambil profil pertama yang ada (untuk kasus offline tanpa tahu user_id)
      final allProfiles = await _db.select(_db.userProfiles).get();
      if (allProfiles.isNotEmpty) {
        profile = allProfiles.first;
      }
    }

    if (profile == null) {
      return null;
    }

    return {
      'fullName': profile.fullName,
      'phoneNumber': profile.phoneNumber,
      'email': profile.email,
      'profilePictureUrl': profile.profilePictureUrl,
      'defaultAddress': profile.defaultAddress,
      'defaultLatitude': profile.defaultLatitude,
      'defaultLongitude': profile.defaultLongitude,
      'role': profile.role,
    };
  }

  Future<void> saveProfile({
    required String odUserId,
    required String fullName,
    required String phoneNumber,
    String? email,
    String? profilePictureUrl,
    String? defaultAddress,
    double? defaultLatitude,
    double? defaultLongitude,
    String? role,
  }) async {
    await _db.insertOrUpdateUserProfile(
      UserProfilesCompanion(
        id: Value(odUserId),
        fullName: Value(fullName),
        phoneNumber: Value(phoneNumber),
        email: Value(email),
        profilePictureUrl: Value(profilePictureUrl),
        defaultAddress: Value(defaultAddress),
        defaultLatitude: Value(defaultLatitude),
        defaultLongitude: Value(defaultLongitude),
        role: Value(role ?? 'Customer'),
        authProvider: const Value('Local'),
      )
    );
  }

  Future<void> updateDefaultAddress(
    String odUserId,
    String address,
    double lat,
    double lng,
  ) async {
    final currentProfile = await _db.getUserProfile(odUserId);
    if (currentProfile != null) {
      await _db.insertOrUpdateUserProfile(
        currentProfile.toCompanion(true).copyWith(
          defaultAddress: Value(address),
          defaultLatitude: Value(lat),
          defaultLongitude: Value(lng),
        )
      );
    }
  }

  Future<void> clearProfile() async {
    await _db.clearUserProfiles();
  }
}