import 'package:maunyuci_core/database/app_database.dart';

class UserSessionRepository {
  final AppDatabase _db;

  UserSessionRepository(this._db);

  Future<UserSession?> getCurrentSession() async {
    final sessions = await _db.getUserSessions(limit: 1);
    return sessions.isEmpty ? null : sessions.first;
  }

  Future<void> saveSession({
    required String userId,
    required String token,
    required String role,
  }) async {
    await _db.deleteAllUserSessions();
    await _db.insertUserSession(UserSessionsCompanion.insert(
      userId: userId,
      token: token,
      role: role,
    ));
  }

  Future<void> clearSession() async {
    await _db.deleteAllUserSessions();
  }

  Future<String?> getToken() async {
    final session = await getCurrentSession();
    return session?.token;
  }

  Future<String?> getRole() async {
    final session = await getCurrentSession();
    return session?.role;
  }

  Future<String?> getUserId() async {
    final session = await getCurrentSession();
    return session?.userId;
  }
}