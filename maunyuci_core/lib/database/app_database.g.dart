// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneNumberMeta =
      const VerificationMeta('phoneNumber');
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
      'phone_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _profilePictureUrlMeta =
      const VerificationMeta('profilePictureUrl');
  @override
  late final GeneratedColumn<String> profilePictureUrl =
      GeneratedColumn<String>('profile_picture_url', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _defaultAddressMeta =
      const VerificationMeta('defaultAddress');
  @override
  late final GeneratedColumn<String> defaultAddress = GeneratedColumn<String>(
      'default_address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _defaultLatitudeMeta =
      const VerificationMeta('defaultLatitude');
  @override
  late final GeneratedColumn<double> defaultLatitude = GeneratedColumn<double>(
      'default_latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _defaultLongitudeMeta =
      const VerificationMeta('defaultLongitude');
  @override
  late final GeneratedColumn<double> defaultLongitude = GeneratedColumn<double>(
      'default_longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authProviderMeta =
      const VerificationMeta('authProvider');
  @override
  late final GeneratedColumn<String> authProvider = GeneratedColumn<String>(
      'auth_provider', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        fullName,
        phoneNumber,
        email,
        profilePictureUrl,
        defaultAddress,
        defaultLatitude,
        defaultLongitude,
        role,
        authProvider
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<UserProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
          _phoneNumberMeta,
          phoneNumber.isAcceptableOrUnknown(
              data['phone_number']!, _phoneNumberMeta));
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('profile_picture_url')) {
      context.handle(
          _profilePictureUrlMeta,
          profilePictureUrl.isAcceptableOrUnknown(
              data['profile_picture_url']!, _profilePictureUrlMeta));
    }
    if (data.containsKey('default_address')) {
      context.handle(
          _defaultAddressMeta,
          defaultAddress.isAcceptableOrUnknown(
              data['default_address']!, _defaultAddressMeta));
    }
    if (data.containsKey('default_latitude')) {
      context.handle(
          _defaultLatitudeMeta,
          defaultLatitude.isAcceptableOrUnknown(
              data['default_latitude']!, _defaultLatitudeMeta));
    }
    if (data.containsKey('default_longitude')) {
      context.handle(
          _defaultLongitudeMeta,
          defaultLongitude.isAcceptableOrUnknown(
              data['default_longitude']!, _defaultLongitudeMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('auth_provider')) {
      context.handle(
          _authProviderMeta,
          authProvider.isAcceptableOrUnknown(
              data['auth_provider']!, _authProviderMeta));
    } else if (isInserting) {
      context.missing(_authProviderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      phoneNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_number'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      profilePictureUrl: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}profile_picture_url']),
      defaultAddress: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}default_address']),
      defaultLatitude: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}default_latitude']),
      defaultLongitude: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}default_longitude']),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      authProvider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}auth_provider'])!,
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfile extends DataClass implements Insertable<UserProfile> {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? profilePictureUrl;
  final String? defaultAddress;
  final double? defaultLatitude;
  final double? defaultLongitude;
  final String role;
  final String authProvider;
  const UserProfile(
      {required this.id,
      required this.fullName,
      required this.phoneNumber,
      this.email,
      this.profilePictureUrl,
      this.defaultAddress,
      this.defaultLatitude,
      this.defaultLongitude,
      required this.role,
      required this.authProvider});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['full_name'] = Variable<String>(fullName);
    map['phone_number'] = Variable<String>(phoneNumber);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || profilePictureUrl != null) {
      map['profile_picture_url'] = Variable<String>(profilePictureUrl);
    }
    if (!nullToAbsent || defaultAddress != null) {
      map['default_address'] = Variable<String>(defaultAddress);
    }
    if (!nullToAbsent || defaultLatitude != null) {
      map['default_latitude'] = Variable<double>(defaultLatitude);
    }
    if (!nullToAbsent || defaultLongitude != null) {
      map['default_longitude'] = Variable<double>(defaultLongitude);
    }
    map['role'] = Variable<String>(role);
    map['auth_provider'] = Variable<String>(authProvider);
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      fullName: Value(fullName),
      phoneNumber: Value(phoneNumber),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      profilePictureUrl: profilePictureUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePictureUrl),
      defaultAddress: defaultAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultAddress),
      defaultLatitude: defaultLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultLatitude),
      defaultLongitude: defaultLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultLongitude),
      role: Value(role),
      authProvider: Value(authProvider),
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfile(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      email: serializer.fromJson<String?>(json['email']),
      profilePictureUrl:
          serializer.fromJson<String?>(json['profilePictureUrl']),
      defaultAddress: serializer.fromJson<String?>(json['defaultAddress']),
      defaultLatitude: serializer.fromJson<double?>(json['defaultLatitude']),
      defaultLongitude: serializer.fromJson<double?>(json['defaultLongitude']),
      role: serializer.fromJson<String>(json['role']),
      authProvider: serializer.fromJson<String>(json['authProvider']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fullName': serializer.toJson<String>(fullName),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'email': serializer.toJson<String?>(email),
      'profilePictureUrl': serializer.toJson<String?>(profilePictureUrl),
      'defaultAddress': serializer.toJson<String?>(defaultAddress),
      'defaultLatitude': serializer.toJson<double?>(defaultLatitude),
      'defaultLongitude': serializer.toJson<double?>(defaultLongitude),
      'role': serializer.toJson<String>(role),
      'authProvider': serializer.toJson<String>(authProvider),
    };
  }

  UserProfile copyWith(
          {String? id,
          String? fullName,
          String? phoneNumber,
          Value<String?> email = const Value.absent(),
          Value<String?> profilePictureUrl = const Value.absent(),
          Value<String?> defaultAddress = const Value.absent(),
          Value<double?> defaultLatitude = const Value.absent(),
          Value<double?> defaultLongitude = const Value.absent(),
          String? role,
          String? authProvider}) =>
      UserProfile(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        email: email.present ? email.value : this.email,
        profilePictureUrl: profilePictureUrl.present
            ? profilePictureUrl.value
            : this.profilePictureUrl,
        defaultAddress:
            defaultAddress.present ? defaultAddress.value : this.defaultAddress,
        defaultLatitude: defaultLatitude.present
            ? defaultLatitude.value
            : this.defaultLatitude,
        defaultLongitude: defaultLongitude.present
            ? defaultLongitude.value
            : this.defaultLongitude,
        role: role ?? this.role,
        authProvider: authProvider ?? this.authProvider,
      );
  UserProfile copyWithCompanion(UserProfilesCompanion data) {
    return UserProfile(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      phoneNumber:
          data.phoneNumber.present ? data.phoneNumber.value : this.phoneNumber,
      email: data.email.present ? data.email.value : this.email,
      profilePictureUrl: data.profilePictureUrl.present
          ? data.profilePictureUrl.value
          : this.profilePictureUrl,
      defaultAddress: data.defaultAddress.present
          ? data.defaultAddress.value
          : this.defaultAddress,
      defaultLatitude: data.defaultLatitude.present
          ? data.defaultLatitude.value
          : this.defaultLatitude,
      defaultLongitude: data.defaultLongitude.present
          ? data.defaultLongitude.value
          : this.defaultLongitude,
      role: data.role.present ? data.role.value : this.role,
      authProvider: data.authProvider.present
          ? data.authProvider.value
          : this.authProvider,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfile(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('email: $email, ')
          ..write('profilePictureUrl: $profilePictureUrl, ')
          ..write('defaultAddress: $defaultAddress, ')
          ..write('defaultLatitude: $defaultLatitude, ')
          ..write('defaultLongitude: $defaultLongitude, ')
          ..write('role: $role, ')
          ..write('authProvider: $authProvider')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      fullName,
      phoneNumber,
      email,
      profilePictureUrl,
      defaultAddress,
      defaultLatitude,
      defaultLongitude,
      role,
      authProvider);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfile &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.phoneNumber == this.phoneNumber &&
          other.email == this.email &&
          other.profilePictureUrl == this.profilePictureUrl &&
          other.defaultAddress == this.defaultAddress &&
          other.defaultLatitude == this.defaultLatitude &&
          other.defaultLongitude == this.defaultLongitude &&
          other.role == this.role &&
          other.authProvider == this.authProvider);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfile> {
  final Value<String> id;
  final Value<String> fullName;
  final Value<String> phoneNumber;
  final Value<String?> email;
  final Value<String?> profilePictureUrl;
  final Value<String?> defaultAddress;
  final Value<double?> defaultLatitude;
  final Value<double?> defaultLongitude;
  final Value<String> role;
  final Value<String> authProvider;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.email = const Value.absent(),
    this.profilePictureUrl = const Value.absent(),
    this.defaultAddress = const Value.absent(),
    this.defaultLatitude = const Value.absent(),
    this.defaultLongitude = const Value.absent(),
    this.role = const Value.absent(),
    this.authProvider = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    required String fullName,
    required String phoneNumber,
    this.email = const Value.absent(),
    this.profilePictureUrl = const Value.absent(),
    this.defaultAddress = const Value.absent(),
    this.defaultLatitude = const Value.absent(),
    this.defaultLongitude = const Value.absent(),
    required String role,
    required String authProvider,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fullName = Value(fullName),
        phoneNumber = Value(phoneNumber),
        role = Value(role),
        authProvider = Value(authProvider);
  static Insertable<UserProfile> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<String>? phoneNumber,
    Expression<String>? email,
    Expression<String>? profilePictureUrl,
    Expression<String>? defaultAddress,
    Expression<double>? defaultLatitude,
    Expression<double>? defaultLongitude,
    Expression<String>? role,
    Expression<String>? authProvider,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (email != null) 'email': email,
      if (profilePictureUrl != null) 'profile_picture_url': profilePictureUrl,
      if (defaultAddress != null) 'default_address': defaultAddress,
      if (defaultLatitude != null) 'default_latitude': defaultLatitude,
      if (defaultLongitude != null) 'default_longitude': defaultLongitude,
      if (role != null) 'role': role,
      if (authProvider != null) 'auth_provider': authProvider,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith(
      {Value<String>? id,
      Value<String>? fullName,
      Value<String>? phoneNumber,
      Value<String?>? email,
      Value<String?>? profilePictureUrl,
      Value<String?>? defaultAddress,
      Value<double?>? defaultLatitude,
      Value<double?>? defaultLongitude,
      Value<String>? role,
      Value<String>? authProvider,
      Value<int>? rowid}) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      defaultLatitude: defaultLatitude ?? this.defaultLatitude,
      defaultLongitude: defaultLongitude ?? this.defaultLongitude,
      role: role ?? this.role,
      authProvider: authProvider ?? this.authProvider,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (profilePictureUrl.present) {
      map['profile_picture_url'] = Variable<String>(profilePictureUrl.value);
    }
    if (defaultAddress.present) {
      map['default_address'] = Variable<String>(defaultAddress.value);
    }
    if (defaultLatitude.present) {
      map['default_latitude'] = Variable<double>(defaultLatitude.value);
    }
    if (defaultLongitude.present) {
      map['default_longitude'] = Variable<double>(defaultLongitude.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (authProvider.present) {
      map['auth_provider'] = Variable<String>(authProvider.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('email: $email, ')
          ..write('profilePictureUrl: $profilePictureUrl, ')
          ..write('defaultAddress: $defaultAddress, ')
          ..write('defaultLatitude: $defaultLatitude, ')
          ..write('defaultLongitude: $defaultLongitude, ')
          ..write('role: $role, ')
          ..write('authProvider: $authProvider, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [userProfiles];
}

typedef $$UserProfilesTableCreateCompanionBuilder = UserProfilesCompanion
    Function({
  required String id,
  required String fullName,
  required String phoneNumber,
  Value<String?> email,
  Value<String?> profilePictureUrl,
  Value<String?> defaultAddress,
  Value<double?> defaultLatitude,
  Value<double?> defaultLongitude,
  required String role,
  required String authProvider,
  Value<int> rowid,
});
typedef $$UserProfilesTableUpdateCompanionBuilder = UserProfilesCompanion
    Function({
  Value<String> id,
  Value<String> fullName,
  Value<String> phoneNumber,
  Value<String?> email,
  Value<String?> profilePictureUrl,
  Value<String?> defaultAddress,
  Value<double?> defaultLatitude,
  Value<double?> defaultLongitude,
  Value<String> role,
  Value<String> authProvider,
  Value<int> rowid,
});

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get profilePictureUrl => $composableBuilder(
      column: $table.profilePictureUrl,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultAddress => $composableBuilder(
      column: $table.defaultAddress,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get defaultLatitude => $composableBuilder(
      column: $table.defaultLatitude,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get defaultLongitude => $composableBuilder(
      column: $table.defaultLongitude,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authProvider => $composableBuilder(
      column: $table.authProvider, builder: (column) => ColumnFilters(column));
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get profilePictureUrl => $composableBuilder(
      column: $table.profilePictureUrl,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultAddress => $composableBuilder(
      column: $table.defaultAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get defaultLatitude => $composableBuilder(
      column: $table.defaultLatitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get defaultLongitude => $composableBuilder(
      column: $table.defaultLongitude,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authProvider => $composableBuilder(
      column: $table.authProvider,
      builder: (column) => ColumnOrderings(column));
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get profilePictureUrl => $composableBuilder(
      column: $table.profilePictureUrl, builder: (column) => column);

  GeneratedColumn<String> get defaultAddress => $composableBuilder(
      column: $table.defaultAddress, builder: (column) => column);

  GeneratedColumn<double> get defaultLatitude => $composableBuilder(
      column: $table.defaultLatitude, builder: (column) => column);

  GeneratedColumn<double> get defaultLongitude => $composableBuilder(
      column: $table.defaultLongitude, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get authProvider => $composableBuilder(
      column: $table.authProvider, builder: (column) => column);
}

class $$UserProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserProfilesTable,
    UserProfile,
    $$UserProfilesTableFilterComposer,
    $$UserProfilesTableOrderingComposer,
    $$UserProfilesTableAnnotationComposer,
    $$UserProfilesTableCreateCompanionBuilder,
    $$UserProfilesTableUpdateCompanionBuilder,
    (
      UserProfile,
      BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>
    ),
    UserProfile,
    PrefetchHooks Function()> {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String> phoneNumber = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> profilePictureUrl = const Value.absent(),
            Value<String?> defaultAddress = const Value.absent(),
            Value<double?> defaultLatitude = const Value.absent(),
            Value<double?> defaultLongitude = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> authProvider = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserProfilesCompanion(
            id: id,
            fullName: fullName,
            phoneNumber: phoneNumber,
            email: email,
            profilePictureUrl: profilePictureUrl,
            defaultAddress: defaultAddress,
            defaultLatitude: defaultLatitude,
            defaultLongitude: defaultLongitude,
            role: role,
            authProvider: authProvider,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fullName,
            required String phoneNumber,
            Value<String?> email = const Value.absent(),
            Value<String?> profilePictureUrl = const Value.absent(),
            Value<String?> defaultAddress = const Value.absent(),
            Value<double?> defaultLatitude = const Value.absent(),
            Value<double?> defaultLongitude = const Value.absent(),
            required String role,
            required String authProvider,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserProfilesCompanion.insert(
            id: id,
            fullName: fullName,
            phoneNumber: phoneNumber,
            email: email,
            profilePictureUrl: profilePictureUrl,
            defaultAddress: defaultAddress,
            defaultLatitude: defaultLatitude,
            defaultLongitude: defaultLongitude,
            role: role,
            authProvider: authProvider,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserProfilesTable,
    UserProfile,
    $$UserProfilesTableFilterComposer,
    $$UserProfilesTableOrderingComposer,
    $$UserProfilesTableAnnotationComposer,
    $$UserProfilesTableCreateCompanionBuilder,
    $$UserProfilesTableUpdateCompanionBuilder,
    (
      UserProfile,
      BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfile>
    ),
    UserProfile,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
}
