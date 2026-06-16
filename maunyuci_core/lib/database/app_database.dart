import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class UserSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get token => text()();
  TextColumn get role => text()();
}

@DriftDatabase(tables: [UserSessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // UserSessions queries - uses generated types
  Future<List<UserSession>> getUserSessions({int limit = 1}) =>
    (select(userSessions)..limit(limit)).get();

  Future<int> insertUserSession(UserSessionsCompanion session) =>
    into(userSessions).insert(session);

  Future<int> deleteAllUserSessions() => delete(userSessions).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'maunyuci.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}