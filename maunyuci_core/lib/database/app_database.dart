import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';


class UserProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text()();
  TextColumn get phoneNumber => text()();
  TextColumn get email => text().nullable()();
  TextColumn get profilePictureUrl => text().nullable()();
  TextColumn get defaultAddress => text().nullable()();
  RealColumn get defaultLatitude => real().nullable()();
  RealColumn get defaultLongitude => real().nullable()();
  TextColumn get role => text()();
  TextColumn get authProvider => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [UserProfiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from == 1) {
          await m.createTable(userProfiles);
        }
        if (from < 3) {
          await customStatement('DROP TABLE IF EXISTS user_sessions;');
        }
      },
    );
  }


  // UserProfiles queries
  Future<UserProfile?> getUserProfile(String id) =>
    (select(userProfiles)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<int> insertOrUpdateUserProfile(UserProfilesCompanion profile) =>
    into(userProfiles).insertOnConflictUpdate(profile);

  Future<int> clearUserProfiles() => delete(userProfiles).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'maunyuci.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}