// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activityLevelMeta = const VerificationMeta(
    'activityLevel',
  );
  @override
  late final GeneratedColumn<String> activityLevel = GeneratedColumn<String>(
    'activity_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _workloadMeta = const VerificationMeta(
    'workload',
  );
  @override
  late final GeneratedColumn<String> workload = GeneratedColumn<String>(
    'workload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    name,
    locale,
    sex,
    birthDate,
    timezone,
    city,
    heightCm,
    activityLevel,
    workload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('sex')) {
      context.handle(
        _sexMeta,
        sex.isAcceptableOrUnknown(data['sex']!, _sexMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('activity_level')) {
      context.handle(
        _activityLevelMeta,
        activityLevel.isAcceptableOrUnknown(
          data['activity_level']!,
          _activityLevelMeta,
        ),
      );
    }
    if (data.containsKey('workload')) {
      context.handle(
        _workloadMeta,
        workload.isAcceptableOrUnknown(data['workload']!, _workloadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      ),
      sex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sex'],
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      ),
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      activityLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_level'],
      ),
      workload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workload'],
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final String name;
  final String? locale;
  final String? sex;
  final DateTime? birthDate;
  final String? timezone;
  final String? city;
  final double? heightCm;
  final String? activityLevel;
  final String? workload;
  const ProfileRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.name,
    this.locale,
    this.sex,
    this.birthDate,
    this.timezone,
    this.city,
    this.heightCm,
    this.activityLevel,
    this.workload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || locale != null) {
      map['locale'] = Variable<String>(locale);
    }
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>(sex);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || timezone != null) {
      map['timezone'] = Variable<String>(timezone);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || activityLevel != null) {
      map['activity_level'] = Variable<String>(activityLevel);
    }
    if (!nullToAbsent || workload != null) {
      map['workload'] = Variable<String>(workload);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      name: Value(name),
      locale: locale == null && nullToAbsent
          ? const Value.absent()
          : Value(locale),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      timezone: timezone == null && nullToAbsent
          ? const Value.absent()
          : Value(timezone),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      activityLevel: activityLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(activityLevel),
      workload: workload == null && nullToAbsent
          ? const Value.absent()
          : Value(workload),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      name: serializer.fromJson<String>(json['name']),
      locale: serializer.fromJson<String?>(json['locale']),
      sex: serializer.fromJson<String?>(json['sex']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      timezone: serializer.fromJson<String?>(json['timezone']),
      city: serializer.fromJson<String?>(json['city']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      activityLevel: serializer.fromJson<String?>(json['activityLevel']),
      workload: serializer.fromJson<String?>(json['workload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'name': serializer.toJson<String>(name),
      'locale': serializer.toJson<String?>(locale),
      'sex': serializer.toJson<String?>(sex),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'timezone': serializer.toJson<String?>(timezone),
      'city': serializer.toJson<String?>(city),
      'heightCm': serializer.toJson<double?>(heightCm),
      'activityLevel': serializer.toJson<String?>(activityLevel),
      'workload': serializer.toJson<String?>(workload),
    };
  }

  ProfileRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    String? name,
    Value<String?> locale = const Value.absent(),
    Value<String?> sex = const Value.absent(),
    Value<DateTime?> birthDate = const Value.absent(),
    Value<String?> timezone = const Value.absent(),
    Value<String?> city = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    Value<String?> activityLevel = const Value.absent(),
    Value<String?> workload = const Value.absent(),
  }) => ProfileRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    name: name ?? this.name,
    locale: locale.present ? locale.value : this.locale,
    sex: sex.present ? sex.value : this.sex,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    timezone: timezone.present ? timezone.value : this.timezone,
    city: city.present ? city.value : this.city,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    activityLevel: activityLevel.present
        ? activityLevel.value
        : this.activityLevel,
    workload: workload.present ? workload.value : this.workload,
  );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      name: data.name.present ? data.name.value : this.name,
      locale: data.locale.present ? data.locale.value : this.locale,
      sex: data.sex.present ? data.sex.value : this.sex,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      city: data.city.present ? data.city.value : this.city,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
      workload: data.workload.present ? data.workload.value : this.workload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('name: $name, ')
          ..write('locale: $locale, ')
          ..write('sex: $sex, ')
          ..write('birthDate: $birthDate, ')
          ..write('timezone: $timezone, ')
          ..write('city: $city, ')
          ..write('heightCm: $heightCm, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('workload: $workload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    name,
    locale,
    sex,
    birthDate,
    timezone,
    city,
    heightCm,
    activityLevel,
    workload,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.name == this.name &&
          other.locale == this.locale &&
          other.sex == this.sex &&
          other.birthDate == this.birthDate &&
          other.timezone == this.timezone &&
          other.city == this.city &&
          other.heightCm == this.heightCm &&
          other.activityLevel == this.activityLevel &&
          other.workload == this.workload);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<String> name;
  final Value<String?> locale;
  final Value<String?> sex;
  final Value<DateTime?> birthDate;
  final Value<String?> timezone;
  final Value<String?> city;
  final Value<double?> heightCm;
  final Value<String?> activityLevel;
  final Value<String?> workload;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.name = const Value.absent(),
    this.locale = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.timezone = const Value.absent(),
    this.city = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.workload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    this.name = const Value.absent(),
    this.locale = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.timezone = const Value.absent(),
    this.city = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.workload = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId);
  static Insertable<ProfileRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<String>? name,
    Expression<String>? locale,
    Expression<String>? sex,
    Expression<DateTime>? birthDate,
    Expression<String>? timezone,
    Expression<String>? city,
    Expression<double>? heightCm,
    Expression<String>? activityLevel,
    Expression<String>? workload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (name != null) 'name': name,
      if (locale != null) 'locale': locale,
      if (sex != null) 'sex': sex,
      if (birthDate != null) 'birth_date': birthDate,
      if (timezone != null) 'timezone': timezone,
      if (city != null) 'city': city,
      if (heightCm != null) 'height_cm': heightCm,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (workload != null) 'workload': workload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<String>? name,
    Value<String?>? locale,
    Value<String?>? sex,
    Value<DateTime?>? birthDate,
    Value<String?>? timezone,
    Value<String?>? city,
    Value<double?>? heightCm,
    Value<String?>? activityLevel,
    Value<String?>? workload,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      name: name ?? this.name,
      locale: locale ?? this.locale,
      sex: sex ?? this.sex,
      birthDate: birthDate ?? this.birthDate,
      timezone: timezone ?? this.timezone,
      city: city ?? this.city,
      heightCm: heightCm ?? this.heightCm,
      activityLevel: activityLevel ?? this.activityLevel,
      workload: workload ?? this.workload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(activityLevel.value);
    }
    if (workload.present) {
      map['workload'] = Variable<String>(workload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('name: $name, ')
          ..write('locale: $locale, ')
          ..write('sex: $sex, ')
          ..write('birthDate: $birthDate, ')
          ..write('timezone: $timezone, ')
          ..write('city: $city, ')
          ..write('heightCm: $heightCm, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('workload: $workload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BodyMeasurementsTable extends BodyMeasurements
    with TableInfo<$BodyMeasurementsTable, BodyMeasurementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyMeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _measuredAtMeta = const VerificationMeta(
    'measuredAt',
  );
  @override
  late final GeneratedColumn<DateTime> measuredAt = GeneratedColumn<DateTime>(
    'measured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waistCmMeta = const VerificationMeta(
    'waistCm',
  );
  @override
  late final GeneratedColumn<double> waistCm = GeneratedColumn<double>(
    'waist_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hipsCmMeta = const VerificationMeta('hipsCm');
  @override
  late final GeneratedColumn<double> hipsCm = GeneratedColumn<double>(
    'hips_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chestCmMeta = const VerificationMeta(
    'chestCm',
  );
  @override
  late final GeneratedColumn<double> chestCm = GeneratedColumn<double>(
    'chest_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _neckCmMeta = const VerificationMeta('neckCm');
  @override
  late final GeneratedColumn<double> neckCm = GeneratedColumn<double>(
    'neck_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _armCmMeta = const VerificationMeta('armCm');
  @override
  late final GeneratedColumn<double> armCm = GeneratedColumn<double>(
    'arm_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyFatPctMeta = const VerificationMeta(
    'bodyFatPct',
  );
  @override
  late final GeneratedColumn<double> bodyFatPct = GeneratedColumn<double>(
    'body_fat_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muscleMassKgMeta = const VerificationMeta(
    'muscleMassKg',
  );
  @override
  late final GeneratedColumn<double> muscleMassKg = GeneratedColumn<double>(
    'muscle_mass_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    measuredAt,
    weightKg,
    waistCm,
    hipsCm,
    chestCm,
    neckCm,
    armCm,
    bodyFatPct,
    muscleMassKg,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_measurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<BodyMeasurementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('measured_at')) {
      context.handle(
        _measuredAtMeta,
        measuredAt.isAcceptableOrUnknown(data['measured_at']!, _measuredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('waist_cm')) {
      context.handle(
        _waistCmMeta,
        waistCm.isAcceptableOrUnknown(data['waist_cm']!, _waistCmMeta),
      );
    }
    if (data.containsKey('hips_cm')) {
      context.handle(
        _hipsCmMeta,
        hipsCm.isAcceptableOrUnknown(data['hips_cm']!, _hipsCmMeta),
      );
    }
    if (data.containsKey('chest_cm')) {
      context.handle(
        _chestCmMeta,
        chestCm.isAcceptableOrUnknown(data['chest_cm']!, _chestCmMeta),
      );
    }
    if (data.containsKey('neck_cm')) {
      context.handle(
        _neckCmMeta,
        neckCm.isAcceptableOrUnknown(data['neck_cm']!, _neckCmMeta),
      );
    }
    if (data.containsKey('arm_cm')) {
      context.handle(
        _armCmMeta,
        armCm.isAcceptableOrUnknown(data['arm_cm']!, _armCmMeta),
      );
    }
    if (data.containsKey('body_fat_pct')) {
      context.handle(
        _bodyFatPctMeta,
        bodyFatPct.isAcceptableOrUnknown(
          data['body_fat_pct']!,
          _bodyFatPctMeta,
        ),
      );
    }
    if (data.containsKey('muscle_mass_kg')) {
      context.handle(
        _muscleMassKgMeta,
        muscleMassKg.isAcceptableOrUnknown(
          data['muscle_mass_kg']!,
          _muscleMassKgMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BodyMeasurementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyMeasurementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      measuredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}measured_at'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      waistCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}waist_cm'],
      ),
      hipsCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hips_cm'],
      ),
      chestCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}chest_cm'],
      ),
      neckCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}neck_cm'],
      ),
      armCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}arm_cm'],
      ),
      bodyFatPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}body_fat_pct'],
      ),
      muscleMassKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}muscle_mass_kg'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $BodyMeasurementsTable createAlias(String alias) {
    return $BodyMeasurementsTable(attachedDatabase, alias);
  }
}

class BodyMeasurementRow extends DataClass
    implements Insertable<BodyMeasurementRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final DateTime measuredAt;
  final double? weightKg;
  final double? waistCm;
  final double? hipsCm;
  final double? chestCm;
  final double? neckCm;
  final double? armCm;
  final double? bodyFatPct;
  final double? muscleMassKg;
  final String source;
  const BodyMeasurementRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.measuredAt,
    this.weightKg,
    this.waistCm,
    this.hipsCm,
    this.chestCm,
    this.neckCm,
    this.armCm,
    this.bodyFatPct,
    this.muscleMassKg,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['measured_at'] = Variable<DateTime>(measuredAt);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || waistCm != null) {
      map['waist_cm'] = Variable<double>(waistCm);
    }
    if (!nullToAbsent || hipsCm != null) {
      map['hips_cm'] = Variable<double>(hipsCm);
    }
    if (!nullToAbsent || chestCm != null) {
      map['chest_cm'] = Variable<double>(chestCm);
    }
    if (!nullToAbsent || neckCm != null) {
      map['neck_cm'] = Variable<double>(neckCm);
    }
    if (!nullToAbsent || armCm != null) {
      map['arm_cm'] = Variable<double>(armCm);
    }
    if (!nullToAbsent || bodyFatPct != null) {
      map['body_fat_pct'] = Variable<double>(bodyFatPct);
    }
    if (!nullToAbsent || muscleMassKg != null) {
      map['muscle_mass_kg'] = Variable<double>(muscleMassKg);
    }
    map['source'] = Variable<String>(source);
    return map;
  }

  BodyMeasurementsCompanion toCompanion(bool nullToAbsent) {
    return BodyMeasurementsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      measuredAt: Value(measuredAt),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      waistCm: waistCm == null && nullToAbsent
          ? const Value.absent()
          : Value(waistCm),
      hipsCm: hipsCm == null && nullToAbsent
          ? const Value.absent()
          : Value(hipsCm),
      chestCm: chestCm == null && nullToAbsent
          ? const Value.absent()
          : Value(chestCm),
      neckCm: neckCm == null && nullToAbsent
          ? const Value.absent()
          : Value(neckCm),
      armCm: armCm == null && nullToAbsent
          ? const Value.absent()
          : Value(armCm),
      bodyFatPct: bodyFatPct == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyFatPct),
      muscleMassKg: muscleMassKg == null && nullToAbsent
          ? const Value.absent()
          : Value(muscleMassKg),
      source: Value(source),
    );
  }

  factory BodyMeasurementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyMeasurementRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      measuredAt: serializer.fromJson<DateTime>(json['measuredAt']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      waistCm: serializer.fromJson<double?>(json['waistCm']),
      hipsCm: serializer.fromJson<double?>(json['hipsCm']),
      chestCm: serializer.fromJson<double?>(json['chestCm']),
      neckCm: serializer.fromJson<double?>(json['neckCm']),
      armCm: serializer.fromJson<double?>(json['armCm']),
      bodyFatPct: serializer.fromJson<double?>(json['bodyFatPct']),
      muscleMassKg: serializer.fromJson<double?>(json['muscleMassKg']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'measuredAt': serializer.toJson<DateTime>(measuredAt),
      'weightKg': serializer.toJson<double?>(weightKg),
      'waistCm': serializer.toJson<double?>(waistCm),
      'hipsCm': serializer.toJson<double?>(hipsCm),
      'chestCm': serializer.toJson<double?>(chestCm),
      'neckCm': serializer.toJson<double?>(neckCm),
      'armCm': serializer.toJson<double?>(armCm),
      'bodyFatPct': serializer.toJson<double?>(bodyFatPct),
      'muscleMassKg': serializer.toJson<double?>(muscleMassKg),
      'source': serializer.toJson<String>(source),
    };
  }

  BodyMeasurementRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    DateTime? measuredAt,
    Value<double?> weightKg = const Value.absent(),
    Value<double?> waistCm = const Value.absent(),
    Value<double?> hipsCm = const Value.absent(),
    Value<double?> chestCm = const Value.absent(),
    Value<double?> neckCm = const Value.absent(),
    Value<double?> armCm = const Value.absent(),
    Value<double?> bodyFatPct = const Value.absent(),
    Value<double?> muscleMassKg = const Value.absent(),
    String? source,
  }) => BodyMeasurementRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    measuredAt: measuredAt ?? this.measuredAt,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    waistCm: waistCm.present ? waistCm.value : this.waistCm,
    hipsCm: hipsCm.present ? hipsCm.value : this.hipsCm,
    chestCm: chestCm.present ? chestCm.value : this.chestCm,
    neckCm: neckCm.present ? neckCm.value : this.neckCm,
    armCm: armCm.present ? armCm.value : this.armCm,
    bodyFatPct: bodyFatPct.present ? bodyFatPct.value : this.bodyFatPct,
    muscleMassKg: muscleMassKg.present ? muscleMassKg.value : this.muscleMassKg,
    source: source ?? this.source,
  );
  BodyMeasurementRow copyWithCompanion(BodyMeasurementsCompanion data) {
    return BodyMeasurementRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      measuredAt: data.measuredAt.present
          ? data.measuredAt.value
          : this.measuredAt,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      waistCm: data.waistCm.present ? data.waistCm.value : this.waistCm,
      hipsCm: data.hipsCm.present ? data.hipsCm.value : this.hipsCm,
      chestCm: data.chestCm.present ? data.chestCm.value : this.chestCm,
      neckCm: data.neckCm.present ? data.neckCm.value : this.neckCm,
      armCm: data.armCm.present ? data.armCm.value : this.armCm,
      bodyFatPct: data.bodyFatPct.present
          ? data.bodyFatPct.value
          : this.bodyFatPct,
      muscleMassKg: data.muscleMassKg.present
          ? data.muscleMassKg.value
          : this.muscleMassKg,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('waistCm: $waistCm, ')
          ..write('hipsCm: $hipsCm, ')
          ..write('chestCm: $chestCm, ')
          ..write('neckCm: $neckCm, ')
          ..write('armCm: $armCm, ')
          ..write('bodyFatPct: $bodyFatPct, ')
          ..write('muscleMassKg: $muscleMassKg, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    measuredAt,
    weightKg,
    waistCm,
    hipsCm,
    chestCm,
    neckCm,
    armCm,
    bodyFatPct,
    muscleMassKg,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyMeasurementRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.measuredAt == this.measuredAt &&
          other.weightKg == this.weightKg &&
          other.waistCm == this.waistCm &&
          other.hipsCm == this.hipsCm &&
          other.chestCm == this.chestCm &&
          other.neckCm == this.neckCm &&
          other.armCm == this.armCm &&
          other.bodyFatPct == this.bodyFatPct &&
          other.muscleMassKg == this.muscleMassKg &&
          other.source == this.source);
}

class BodyMeasurementsCompanion extends UpdateCompanion<BodyMeasurementRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<DateTime> measuredAt;
  final Value<double?> weightKg;
  final Value<double?> waistCm;
  final Value<double?> hipsCm;
  final Value<double?> chestCm;
  final Value<double?> neckCm;
  final Value<double?> armCm;
  final Value<double?> bodyFatPct;
  final Value<double?> muscleMassKg;
  final Value<String> source;
  final Value<int> rowid;
  const BodyMeasurementsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.hipsCm = const Value.absent(),
    this.chestCm = const Value.absent(),
    this.neckCm = const Value.absent(),
    this.armCm = const Value.absent(),
    this.bodyFatPct = const Value.absent(),
    this.muscleMassKg = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BodyMeasurementsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required DateTime measuredAt,
    this.weightKg = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.hipsCm = const Value.absent(),
    this.chestCm = const Value.absent(),
    this.neckCm = const Value.absent(),
    this.armCm = const Value.absent(),
    this.bodyFatPct = const Value.absent(),
    this.muscleMassKg = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       measuredAt = Value(measuredAt);
  static Insertable<BodyMeasurementRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<DateTime>? measuredAt,
    Expression<double>? weightKg,
    Expression<double>? waistCm,
    Expression<double>? hipsCm,
    Expression<double>? chestCm,
    Expression<double>? neckCm,
    Expression<double>? armCm,
    Expression<double>? bodyFatPct,
    Expression<double>? muscleMassKg,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (weightKg != null) 'weight_kg': weightKg,
      if (waistCm != null) 'waist_cm': waistCm,
      if (hipsCm != null) 'hips_cm': hipsCm,
      if (chestCm != null) 'chest_cm': chestCm,
      if (neckCm != null) 'neck_cm': neckCm,
      if (armCm != null) 'arm_cm': armCm,
      if (bodyFatPct != null) 'body_fat_pct': bodyFatPct,
      if (muscleMassKg != null) 'muscle_mass_kg': muscleMassKg,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BodyMeasurementsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<DateTime>? measuredAt,
    Value<double?>? weightKg,
    Value<double?>? waistCm,
    Value<double?>? hipsCm,
    Value<double?>? chestCm,
    Value<double?>? neckCm,
    Value<double?>? armCm,
    Value<double?>? bodyFatPct,
    Value<double?>? muscleMassKg,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return BodyMeasurementsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      measuredAt: measuredAt ?? this.measuredAt,
      weightKg: weightKg ?? this.weightKg,
      waistCm: waistCm ?? this.waistCm,
      hipsCm: hipsCm ?? this.hipsCm,
      chestCm: chestCm ?? this.chestCm,
      neckCm: neckCm ?? this.neckCm,
      armCm: armCm ?? this.armCm,
      bodyFatPct: bodyFatPct ?? this.bodyFatPct,
      muscleMassKg: muscleMassKg ?? this.muscleMassKg,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<DateTime>(measuredAt.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (waistCm.present) {
      map['waist_cm'] = Variable<double>(waistCm.value);
    }
    if (hipsCm.present) {
      map['hips_cm'] = Variable<double>(hipsCm.value);
    }
    if (chestCm.present) {
      map['chest_cm'] = Variable<double>(chestCm.value);
    }
    if (neckCm.present) {
      map['neck_cm'] = Variable<double>(neckCm.value);
    }
    if (armCm.present) {
      map['arm_cm'] = Variable<double>(armCm.value);
    }
    if (bodyFatPct.present) {
      map['body_fat_pct'] = Variable<double>(bodyFatPct.value);
    }
    if (muscleMassKg.present) {
      map['muscle_mass_kg'] = Variable<double>(muscleMassKg.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyMeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('waistCm: $waistCm, ')
          ..write('hipsCm: $hipsCm, ')
          ..write('chestCm: $chestCm, ')
          ..write('neckCm: $neckCm, ')
          ..write('armCm: $armCm, ')
          ..write('bodyFatPct: $bodyFatPct, ')
          ..write('muscleMassKg: $muscleMassKg, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, PhotoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _poseMeta = const VerificationMeta('pose');
  @override
  late final GeneratedColumn<String> pose = GeneratedColumn<String>(
    'pose',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remotePathMeta = const VerificationMeta(
    'remotePath',
  );
  @override
  late final GeneratedColumn<String> remotePath = GeneratedColumn<String>(
    'remote_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    kind,
    pose,
    localPath,
    takenAt,
    sessionId,
    remotePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhotoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('pose')) {
      context.handle(
        _poseMeta,
        pose.isAcceptableOrUnknown(data['pose']!, _poseMeta),
      );
    } else if (isInserting) {
      context.missing(_poseMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('remote_path')) {
      context.handle(
        _remotePathMeta,
        remotePath.isAcceptableOrUnknown(data['remote_path']!, _remotePathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhotoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      pose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pose'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
      remotePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_path'],
      ),
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }
}

class PhotoRow extends DataClass implements Insertable<PhotoRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final String kind;
  final String pose;
  final String localPath;
  final DateTime takenAt;
  final String? sessionId;
  final String? remotePath;
  const PhotoRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.kind,
    required this.pose,
    required this.localPath,
    required this.takenAt,
    this.sessionId,
    this.remotePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['kind'] = Variable<String>(kind);
    map['pose'] = Variable<String>(pose);
    map['local_path'] = Variable<String>(localPath);
    map['taken_at'] = Variable<DateTime>(takenAt);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    if (!nullToAbsent || remotePath != null) {
      map['remote_path'] = Variable<String>(remotePath);
    }
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      kind: Value(kind),
      pose: Value(pose),
      localPath: Value(localPath),
      takenAt: Value(takenAt),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      remotePath: remotePath == null && nullToAbsent
          ? const Value.absent()
          : Value(remotePath),
    );
  }

  factory PhotoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      kind: serializer.fromJson<String>(json['kind']),
      pose: serializer.fromJson<String>(json['pose']),
      localPath: serializer.fromJson<String>(json['localPath']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      remotePath: serializer.fromJson<String?>(json['remotePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'kind': serializer.toJson<String>(kind),
      'pose': serializer.toJson<String>(pose),
      'localPath': serializer.toJson<String>(localPath),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'sessionId': serializer.toJson<String?>(sessionId),
      'remotePath': serializer.toJson<String?>(remotePath),
    };
  }

  PhotoRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    String? kind,
    String? pose,
    String? localPath,
    DateTime? takenAt,
    Value<String?> sessionId = const Value.absent(),
    Value<String?> remotePath = const Value.absent(),
  }) => PhotoRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    kind: kind ?? this.kind,
    pose: pose ?? this.pose,
    localPath: localPath ?? this.localPath,
    takenAt: takenAt ?? this.takenAt,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    remotePath: remotePath.present ? remotePath.value : this.remotePath,
  );
  PhotoRow copyWithCompanion(PhotosCompanion data) {
    return PhotoRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      kind: data.kind.present ? data.kind.value : this.kind,
      pose: data.pose.present ? data.pose.value : this.pose,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      remotePath: data.remotePath.present
          ? data.remotePath.value
          : this.remotePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhotoRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('kind: $kind, ')
          ..write('pose: $pose, ')
          ..write('localPath: $localPath, ')
          ..write('takenAt: $takenAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('remotePath: $remotePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    kind,
    pose,
    localPath,
    takenAt,
    sessionId,
    remotePath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhotoRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.kind == this.kind &&
          other.pose == this.pose &&
          other.localPath == this.localPath &&
          other.takenAt == this.takenAt &&
          other.sessionId == this.sessionId &&
          other.remotePath == this.remotePath);
}

class PhotosCompanion extends UpdateCompanion<PhotoRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<String> kind;
  final Value<String> pose;
  final Value<String> localPath;
  final Value<DateTime> takenAt;
  final Value<String?> sessionId;
  final Value<String?> remotePath;
  final Value<int> rowid;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.kind = const Value.absent(),
    this.pose = const Value.absent(),
    this.localPath = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.remotePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required String kind,
    required String pose,
    required String localPath,
    required DateTime takenAt,
    this.sessionId = const Value.absent(),
    this.remotePath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       kind = Value(kind),
       pose = Value(pose),
       localPath = Value(localPath),
       takenAt = Value(takenAt);
  static Insertable<PhotoRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<String>? kind,
    Expression<String>? pose,
    Expression<String>? localPath,
    Expression<DateTime>? takenAt,
    Expression<String>? sessionId,
    Expression<String>? remotePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (kind != null) 'kind': kind,
      if (pose != null) 'pose': pose,
      if (localPath != null) 'local_path': localPath,
      if (takenAt != null) 'taken_at': takenAt,
      if (sessionId != null) 'session_id': sessionId,
      if (remotePath != null) 'remote_path': remotePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<String>? kind,
    Value<String>? pose,
    Value<String>? localPath,
    Value<DateTime>? takenAt,
    Value<String?>? sessionId,
    Value<String?>? remotePath,
    Value<int>? rowid,
  }) {
    return PhotosCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      kind: kind ?? this.kind,
      pose: pose ?? this.pose,
      localPath: localPath ?? this.localPath,
      takenAt: takenAt ?? this.takenAt,
      sessionId: sessionId ?? this.sessionId,
      remotePath: remotePath ?? this.remotePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (pose.present) {
      map['pose'] = Variable<String>(pose.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (remotePath.present) {
      map['remote_path'] = Variable<String>(remotePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('kind: $kind, ')
          ..write('pose: $pose, ')
          ..write('localPath: $localPath, ')
          ..write('takenAt: $takenAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('remotePath: $remotePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, GoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    kind,
    title,
    priority,
    deadline,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class GoalRow extends DataClass implements Insertable<GoalRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final String kind;
  final String? title;
  final int priority;
  final DateTime? deadline;
  final int sortOrder;
  const GoalRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.kind,
    this.title,
    required this.priority,
    this.deadline,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      kind: Value(kind),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      priority: Value(priority),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      sortOrder: Value(sortOrder),
    );
  }

  factory GoalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String?>(json['title']),
      priority: serializer.fromJson<int>(json['priority']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String?>(title),
      'priority': serializer.toJson<int>(priority),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  GoalRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    String? kind,
    Value<String?> title = const Value.absent(),
    int? priority,
    Value<DateTime?> deadline = const Value.absent(),
    int? sortOrder,
  }) => GoalRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    kind: kind ?? this.kind,
    title: title.present ? title.value : this.title,
    priority: priority ?? this.priority,
    deadline: deadline.present ? deadline.value : this.deadline,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  GoalRow copyWithCompanion(GoalsCompanion data) {
    return GoalRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      priority: data.priority.present ? data.priority.value : this.priority,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('priority: $priority, ')
          ..write('deadline: $deadline, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    kind,
    title,
    priority,
    deadline,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.priority == this.priority &&
          other.deadline == this.deadline &&
          other.sortOrder == this.sortOrder);
}

class GoalsCompanion extends UpdateCompanion<GoalRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<String> kind;
  final Value<String?> title;
  final Value<int> priority;
  final Value<DateTime?> deadline;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.priority = const Value.absent(),
    this.deadline = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required String kind,
    this.title = const Value.absent(),
    this.priority = const Value.absent(),
    this.deadline = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       kind = Value(kind);
  static Insertable<GoalRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<int>? priority,
    Expression<DateTime>? deadline,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (priority != null) 'priority': priority,
      if (deadline != null) 'deadline': deadline,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<String>? kind,
    Value<String?>? title,
    Value<int>? priority,
    Value<DateTime?>? deadline,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('priority: $priority, ')
          ..write('deadline: $deadline, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduleSettingsTable extends ScheduleSettings
    with TableInfo<$ScheduleSettingsTable, ScheduleSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _institutionTypeMeta = const VerificationMeta(
    'institutionType',
  );
  @override
  late final GeneratedColumn<String> institutionType = GeneratedColumn<String>(
    'institution_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _institutionNameMeta = const VerificationMeta(
    'institutionName',
  );
  @override
  late final GeneratedColumn<String> institutionName = GeneratedColumn<String>(
    'institution_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alternationEnabledMeta =
      const VerificationMeta('alternationEnabled');
  @override
  late final GeneratedColumn<bool> alternationEnabled = GeneratedColumn<bool>(
    'alternation_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("alternation_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _week1AnchorMeta = const VerificationMeta(
    'week1Anchor',
  );
  @override
  late final GeneratedColumn<DateTime> week1Anchor = GeneratedColumn<DateTime>(
    'week1_anchor',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wakeMinuteMeta = const VerificationMeta(
    'wakeMinute',
  );
  @override
  late final GeneratedColumn<int> wakeMinute = GeneratedColumn<int>(
    'wake_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7 * 60),
  );
  static const VerificationMeta _bedMinuteMeta = const VerificationMeta(
    'bedMinute',
  );
  @override
  late final GeneratedColumn<int> bedMinute = GeneratedColumn<int>(
    'bed_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(23 * 60),
  );
  static const VerificationMeta _commuteMinutesMeta = const VerificationMeta(
    'commuteMinutes',
  );
  @override
  late final GeneratedColumn<int> commuteMinutes = GeneratedColumn<int>(
    'commute_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _weekendDaysMeta = const VerificationMeta(
    'weekendDays',
  );
  @override
  late final GeneratedColumn<String> weekendDays = GeneratedColumn<String>(
    'weekend_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('6,7'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    institutionType,
    institutionName,
    alternationEnabled,
    week1Anchor,
    wakeMinute,
    bedMinute,
    commuteMinutes,
    weekendDays,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('institution_type')) {
      context.handle(
        _institutionTypeMeta,
        institutionType.isAcceptableOrUnknown(
          data['institution_type']!,
          _institutionTypeMeta,
        ),
      );
    }
    if (data.containsKey('institution_name')) {
      context.handle(
        _institutionNameMeta,
        institutionName.isAcceptableOrUnknown(
          data['institution_name']!,
          _institutionNameMeta,
        ),
      );
    }
    if (data.containsKey('alternation_enabled')) {
      context.handle(
        _alternationEnabledMeta,
        alternationEnabled.isAcceptableOrUnknown(
          data['alternation_enabled']!,
          _alternationEnabledMeta,
        ),
      );
    }
    if (data.containsKey('week1_anchor')) {
      context.handle(
        _week1AnchorMeta,
        week1Anchor.isAcceptableOrUnknown(
          data['week1_anchor']!,
          _week1AnchorMeta,
        ),
      );
    }
    if (data.containsKey('wake_minute')) {
      context.handle(
        _wakeMinuteMeta,
        wakeMinute.isAcceptableOrUnknown(data['wake_minute']!, _wakeMinuteMeta),
      );
    }
    if (data.containsKey('bed_minute')) {
      context.handle(
        _bedMinuteMeta,
        bedMinute.isAcceptableOrUnknown(data['bed_minute']!, _bedMinuteMeta),
      );
    }
    if (data.containsKey('commute_minutes')) {
      context.handle(
        _commuteMinutesMeta,
        commuteMinutes.isAcceptableOrUnknown(
          data['commute_minutes']!,
          _commuteMinutesMeta,
        ),
      );
    }
    if (data.containsKey('weekend_days')) {
      context.handle(
        _weekendDaysMeta,
        weekendDays.isAcceptableOrUnknown(
          data['weekend_days']!,
          _weekendDaysMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      institutionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution_type'],
      ),
      institutionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution_name'],
      ),
      alternationEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}alternation_enabled'],
      )!,
      week1Anchor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}week1_anchor'],
      ),
      wakeMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wake_minute'],
      )!,
      bedMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bed_minute'],
      )!,
      commuteMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}commute_minutes'],
      )!,
      weekendDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weekend_days'],
      )!,
    );
  }

  @override
  $ScheduleSettingsTable createAlias(String alias) {
    return $ScheduleSettingsTable(attachedDatabase, alias);
  }
}

class ScheduleSettingsRow extends DataClass
    implements Insertable<ScheduleSettingsRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final String? institutionType;
  final String? institutionName;
  final bool alternationEnabled;

  /// Понедельник недели, которая считается «неделей 1». Ручное переключение сдвигает якорь на 7 дней.
  final DateTime? week1Anchor;
  final int wakeMinute;
  final int bedMinute;
  final int commuteMinutes;
  final String weekendDays;
  const ScheduleSettingsRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    this.institutionType,
    this.institutionName,
    required this.alternationEnabled,
    this.week1Anchor,
    required this.wakeMinute,
    required this.bedMinute,
    required this.commuteMinutes,
    required this.weekendDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || institutionType != null) {
      map['institution_type'] = Variable<String>(institutionType);
    }
    if (!nullToAbsent || institutionName != null) {
      map['institution_name'] = Variable<String>(institutionName);
    }
    map['alternation_enabled'] = Variable<bool>(alternationEnabled);
    if (!nullToAbsent || week1Anchor != null) {
      map['week1_anchor'] = Variable<DateTime>(week1Anchor);
    }
    map['wake_minute'] = Variable<int>(wakeMinute);
    map['bed_minute'] = Variable<int>(bedMinute);
    map['commute_minutes'] = Variable<int>(commuteMinutes);
    map['weekend_days'] = Variable<String>(weekendDays);
    return map;
  }

  ScheduleSettingsCompanion toCompanion(bool nullToAbsent) {
    return ScheduleSettingsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      institutionType: institutionType == null && nullToAbsent
          ? const Value.absent()
          : Value(institutionType),
      institutionName: institutionName == null && nullToAbsent
          ? const Value.absent()
          : Value(institutionName),
      alternationEnabled: Value(alternationEnabled),
      week1Anchor: week1Anchor == null && nullToAbsent
          ? const Value.absent()
          : Value(week1Anchor),
      wakeMinute: Value(wakeMinute),
      bedMinute: Value(bedMinute),
      commuteMinutes: Value(commuteMinutes),
      weekendDays: Value(weekendDays),
    );
  }

  factory ScheduleSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleSettingsRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      institutionType: serializer.fromJson<String?>(json['institutionType']),
      institutionName: serializer.fromJson<String?>(json['institutionName']),
      alternationEnabled: serializer.fromJson<bool>(json['alternationEnabled']),
      week1Anchor: serializer.fromJson<DateTime?>(json['week1Anchor']),
      wakeMinute: serializer.fromJson<int>(json['wakeMinute']),
      bedMinute: serializer.fromJson<int>(json['bedMinute']),
      commuteMinutes: serializer.fromJson<int>(json['commuteMinutes']),
      weekendDays: serializer.fromJson<String>(json['weekendDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'institutionType': serializer.toJson<String?>(institutionType),
      'institutionName': serializer.toJson<String?>(institutionName),
      'alternationEnabled': serializer.toJson<bool>(alternationEnabled),
      'week1Anchor': serializer.toJson<DateTime?>(week1Anchor),
      'wakeMinute': serializer.toJson<int>(wakeMinute),
      'bedMinute': serializer.toJson<int>(bedMinute),
      'commuteMinutes': serializer.toJson<int>(commuteMinutes),
      'weekendDays': serializer.toJson<String>(weekendDays),
    };
  }

  ScheduleSettingsRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    Value<String?> institutionType = const Value.absent(),
    Value<String?> institutionName = const Value.absent(),
    bool? alternationEnabled,
    Value<DateTime?> week1Anchor = const Value.absent(),
    int? wakeMinute,
    int? bedMinute,
    int? commuteMinutes,
    String? weekendDays,
  }) => ScheduleSettingsRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    institutionType: institutionType.present
        ? institutionType.value
        : this.institutionType,
    institutionName: institutionName.present
        ? institutionName.value
        : this.institutionName,
    alternationEnabled: alternationEnabled ?? this.alternationEnabled,
    week1Anchor: week1Anchor.present ? week1Anchor.value : this.week1Anchor,
    wakeMinute: wakeMinute ?? this.wakeMinute,
    bedMinute: bedMinute ?? this.bedMinute,
    commuteMinutes: commuteMinutes ?? this.commuteMinutes,
    weekendDays: weekendDays ?? this.weekendDays,
  );
  ScheduleSettingsRow copyWithCompanion(ScheduleSettingsCompanion data) {
    return ScheduleSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      institutionType: data.institutionType.present
          ? data.institutionType.value
          : this.institutionType,
      institutionName: data.institutionName.present
          ? data.institutionName.value
          : this.institutionName,
      alternationEnabled: data.alternationEnabled.present
          ? data.alternationEnabled.value
          : this.alternationEnabled,
      week1Anchor: data.week1Anchor.present
          ? data.week1Anchor.value
          : this.week1Anchor,
      wakeMinute: data.wakeMinute.present
          ? data.wakeMinute.value
          : this.wakeMinute,
      bedMinute: data.bedMinute.present ? data.bedMinute.value : this.bedMinute,
      commuteMinutes: data.commuteMinutes.present
          ? data.commuteMinutes.value
          : this.commuteMinutes,
      weekendDays: data.weekendDays.present
          ? data.weekendDays.value
          : this.weekendDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleSettingsRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('institutionType: $institutionType, ')
          ..write('institutionName: $institutionName, ')
          ..write('alternationEnabled: $alternationEnabled, ')
          ..write('week1Anchor: $week1Anchor, ')
          ..write('wakeMinute: $wakeMinute, ')
          ..write('bedMinute: $bedMinute, ')
          ..write('commuteMinutes: $commuteMinutes, ')
          ..write('weekendDays: $weekendDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    institutionType,
    institutionName,
    alternationEnabled,
    week1Anchor,
    wakeMinute,
    bedMinute,
    commuteMinutes,
    weekendDays,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleSettingsRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.institutionType == this.institutionType &&
          other.institutionName == this.institutionName &&
          other.alternationEnabled == this.alternationEnabled &&
          other.week1Anchor == this.week1Anchor &&
          other.wakeMinute == this.wakeMinute &&
          other.bedMinute == this.bedMinute &&
          other.commuteMinutes == this.commuteMinutes &&
          other.weekendDays == this.weekendDays);
}

class ScheduleSettingsCompanion extends UpdateCompanion<ScheduleSettingsRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<String?> institutionType;
  final Value<String?> institutionName;
  final Value<bool> alternationEnabled;
  final Value<DateTime?> week1Anchor;
  final Value<int> wakeMinute;
  final Value<int> bedMinute;
  final Value<int> commuteMinutes;
  final Value<String> weekendDays;
  final Value<int> rowid;
  const ScheduleSettingsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.institutionType = const Value.absent(),
    this.institutionName = const Value.absent(),
    this.alternationEnabled = const Value.absent(),
    this.week1Anchor = const Value.absent(),
    this.wakeMinute = const Value.absent(),
    this.bedMinute = const Value.absent(),
    this.commuteMinutes = const Value.absent(),
    this.weekendDays = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduleSettingsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    this.institutionType = const Value.absent(),
    this.institutionName = const Value.absent(),
    this.alternationEnabled = const Value.absent(),
    this.week1Anchor = const Value.absent(),
    this.wakeMinute = const Value.absent(),
    this.bedMinute = const Value.absent(),
    this.commuteMinutes = const Value.absent(),
    this.weekendDays = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId);
  static Insertable<ScheduleSettingsRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<String>? institutionType,
    Expression<String>? institutionName,
    Expression<bool>? alternationEnabled,
    Expression<DateTime>? week1Anchor,
    Expression<int>? wakeMinute,
    Expression<int>? bedMinute,
    Expression<int>? commuteMinutes,
    Expression<String>? weekendDays,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (institutionType != null) 'institution_type': institutionType,
      if (institutionName != null) 'institution_name': institutionName,
      if (alternationEnabled != null) 'alternation_enabled': alternationEnabled,
      if (week1Anchor != null) 'week1_anchor': week1Anchor,
      if (wakeMinute != null) 'wake_minute': wakeMinute,
      if (bedMinute != null) 'bed_minute': bedMinute,
      if (commuteMinutes != null) 'commute_minutes': commuteMinutes,
      if (weekendDays != null) 'weekend_days': weekendDays,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduleSettingsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<String?>? institutionType,
    Value<String?>? institutionName,
    Value<bool>? alternationEnabled,
    Value<DateTime?>? week1Anchor,
    Value<int>? wakeMinute,
    Value<int>? bedMinute,
    Value<int>? commuteMinutes,
    Value<String>? weekendDays,
    Value<int>? rowid,
  }) {
    return ScheduleSettingsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      institutionType: institutionType ?? this.institutionType,
      institutionName: institutionName ?? this.institutionName,
      alternationEnabled: alternationEnabled ?? this.alternationEnabled,
      week1Anchor: week1Anchor ?? this.week1Anchor,
      wakeMinute: wakeMinute ?? this.wakeMinute,
      bedMinute: bedMinute ?? this.bedMinute,
      commuteMinutes: commuteMinutes ?? this.commuteMinutes,
      weekendDays: weekendDays ?? this.weekendDays,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (institutionType.present) {
      map['institution_type'] = Variable<String>(institutionType.value);
    }
    if (institutionName.present) {
      map['institution_name'] = Variable<String>(institutionName.value);
    }
    if (alternationEnabled.present) {
      map['alternation_enabled'] = Variable<bool>(alternationEnabled.value);
    }
    if (week1Anchor.present) {
      map['week1_anchor'] = Variable<DateTime>(week1Anchor.value);
    }
    if (wakeMinute.present) {
      map['wake_minute'] = Variable<int>(wakeMinute.value);
    }
    if (bedMinute.present) {
      map['bed_minute'] = Variable<int>(bedMinute.value);
    }
    if (commuteMinutes.present) {
      map['commute_minutes'] = Variable<int>(commuteMinutes.value);
    }
    if (weekendDays.present) {
      map['weekend_days'] = Variable<String>(weekendDays.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleSettingsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('institutionType: $institutionType, ')
          ..write('institutionName: $institutionName, ')
          ..write('alternationEnabled: $alternationEnabled, ')
          ..write('week1Anchor: $week1Anchor, ')
          ..write('wakeMinute: $wakeMinute, ')
          ..write('bedMinute: $bedMinute, ')
          ..write('commuteMinutes: $commuteMinutes, ')
          ..write('weekendDays: $weekendDays, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduleItemsTable extends ScheduleItems
    with TableInfo<$ScheduleItemsTable, ScheduleItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMinuteMeta = const VerificationMeta(
    'startMinute',
  );
  @override
  late final GeneratedColumn<int> startMinute = GeneratedColumn<int>(
    'start_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMinutesMeta = const VerificationMeta(
    'durationMinutes',
  );
  @override
  late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>(
    'duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekParityMeta = const VerificationMeta(
    'weekParity',
  );
  @override
  late final GeneratedColumn<int> weekParity = GeneratedColumn<int>(
    'week_parity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requiresCommuteMeta = const VerificationMeta(
    'requiresCommute',
  );
  @override
  late final GeneratedColumn<bool> requiresCommute = GeneratedColumn<bool>(
    'requires_commute',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("requires_commute" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    kind,
    title,
    weekday,
    startMinute,
    durationMinutes,
    weekParity,
    location,
    requiresCommute,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('start_minute')) {
      context.handle(
        _startMinuteMeta,
        startMinute.isAcceptableOrUnknown(
          data['start_minute']!,
          _startMinuteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startMinuteMeta);
    }
    if (data.containsKey('duration_minutes')) {
      context.handle(
        _durationMinutesMeta,
        durationMinutes.isAcceptableOrUnknown(
          data['duration_minutes']!,
          _durationMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationMinutesMeta);
    }
    if (data.containsKey('week_parity')) {
      context.handle(
        _weekParityMeta,
        weekParity.isAcceptableOrUnknown(data['week_parity']!, _weekParityMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('requires_commute')) {
      context.handle(
        _requiresCommuteMeta,
        requiresCommute.isAcceptableOrUnknown(
          data['requires_commute']!,
          _requiresCommuteMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      )!,
      startMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minute'],
      )!,
      durationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_minutes'],
      )!,
      weekParity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_parity'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      requiresCommute: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}requires_commute'],
      )!,
    );
  }

  @override
  $ScheduleItemsTable createAlias(String alias) {
    return $ScheduleItemsTable(attachedDatabase, alias);
  }
}

class ScheduleItemRow extends DataClass implements Insertable<ScheduleItemRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final String kind;
  final String title;
  final int weekday;
  final int startMinute;
  final int durationMinutes;
  final int weekParity;
  final String? location;
  final bool requiresCommute;
  const ScheduleItemRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.kind,
    required this.title,
    required this.weekday,
    required this.startMinute,
    required this.durationMinutes,
    required this.weekParity,
    this.location,
    required this.requiresCommute,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['weekday'] = Variable<int>(weekday);
    map['start_minute'] = Variable<int>(startMinute);
    map['duration_minutes'] = Variable<int>(durationMinutes);
    map['week_parity'] = Variable<int>(weekParity);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['requires_commute'] = Variable<bool>(requiresCommute);
    return map;
  }

  ScheduleItemsCompanion toCompanion(bool nullToAbsent) {
    return ScheduleItemsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      kind: Value(kind),
      title: Value(title),
      weekday: Value(weekday),
      startMinute: Value(startMinute),
      durationMinutes: Value(durationMinutes),
      weekParity: Value(weekParity),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      requiresCommute: Value(requiresCommute),
    );
  }

  factory ScheduleItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleItemRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      weekday: serializer.fromJson<int>(json['weekday']),
      startMinute: serializer.fromJson<int>(json['startMinute']),
      durationMinutes: serializer.fromJson<int>(json['durationMinutes']),
      weekParity: serializer.fromJson<int>(json['weekParity']),
      location: serializer.fromJson<String?>(json['location']),
      requiresCommute: serializer.fromJson<bool>(json['requiresCommute']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'weekday': serializer.toJson<int>(weekday),
      'startMinute': serializer.toJson<int>(startMinute),
      'durationMinutes': serializer.toJson<int>(durationMinutes),
      'weekParity': serializer.toJson<int>(weekParity),
      'location': serializer.toJson<String?>(location),
      'requiresCommute': serializer.toJson<bool>(requiresCommute),
    };
  }

  ScheduleItemRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    String? kind,
    String? title,
    int? weekday,
    int? startMinute,
    int? durationMinutes,
    int? weekParity,
    Value<String?> location = const Value.absent(),
    bool? requiresCommute,
  }) => ScheduleItemRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    weekday: weekday ?? this.weekday,
    startMinute: startMinute ?? this.startMinute,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    weekParity: weekParity ?? this.weekParity,
    location: location.present ? location.value : this.location,
    requiresCommute: requiresCommute ?? this.requiresCommute,
  );
  ScheduleItemRow copyWithCompanion(ScheduleItemsCompanion data) {
    return ScheduleItemRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      startMinute: data.startMinute.present
          ? data.startMinute.value
          : this.startMinute,
      durationMinutes: data.durationMinutes.present
          ? data.durationMinutes.value
          : this.durationMinutes,
      weekParity: data.weekParity.present
          ? data.weekParity.value
          : this.weekParity,
      location: data.location.present ? data.location.value : this.location,
      requiresCommute: data.requiresCommute.present
          ? data.requiresCommute.value
          : this.requiresCommute,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleItemRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('weekday: $weekday, ')
          ..write('startMinute: $startMinute, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('weekParity: $weekParity, ')
          ..write('location: $location, ')
          ..write('requiresCommute: $requiresCommute')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    kind,
    title,
    weekday,
    startMinute,
    durationMinutes,
    weekParity,
    location,
    requiresCommute,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleItemRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.weekday == this.weekday &&
          other.startMinute == this.startMinute &&
          other.durationMinutes == this.durationMinutes &&
          other.weekParity == this.weekParity &&
          other.location == this.location &&
          other.requiresCommute == this.requiresCommute);
}

class ScheduleItemsCompanion extends UpdateCompanion<ScheduleItemRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<String> kind;
  final Value<String> title;
  final Value<int> weekday;
  final Value<int> startMinute;
  final Value<int> durationMinutes;
  final Value<int> weekParity;
  final Value<String?> location;
  final Value<bool> requiresCommute;
  final Value<int> rowid;
  const ScheduleItemsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.weekday = const Value.absent(),
    this.startMinute = const Value.absent(),
    this.durationMinutes = const Value.absent(),
    this.weekParity = const Value.absent(),
    this.location = const Value.absent(),
    this.requiresCommute = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScheduleItemsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required String kind,
    required String title,
    required int weekday,
    required int startMinute,
    required int durationMinutes,
    this.weekParity = const Value.absent(),
    this.location = const Value.absent(),
    this.requiresCommute = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       kind = Value(kind),
       title = Value(title),
       weekday = Value(weekday),
       startMinute = Value(startMinute),
       durationMinutes = Value(durationMinutes);
  static Insertable<ScheduleItemRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<int>? weekday,
    Expression<int>? startMinute,
    Expression<int>? durationMinutes,
    Expression<int>? weekParity,
    Expression<String>? location,
    Expression<bool>? requiresCommute,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (weekday != null) 'weekday': weekday,
      if (startMinute != null) 'start_minute': startMinute,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (weekParity != null) 'week_parity': weekParity,
      if (location != null) 'location': location,
      if (requiresCommute != null) 'requires_commute': requiresCommute,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScheduleItemsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<String>? kind,
    Value<String>? title,
    Value<int>? weekday,
    Value<int>? startMinute,
    Value<int>? durationMinutes,
    Value<int>? weekParity,
    Value<String?>? location,
    Value<bool>? requiresCommute,
    Value<int>? rowid,
  }) {
    return ScheduleItemsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      weekday: weekday ?? this.weekday,
      startMinute: startMinute ?? this.startMinute,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      weekParity: weekParity ?? this.weekParity,
      location: location ?? this.location,
      requiresCommute: requiresCommute ?? this.requiresCommute,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (startMinute.present) {
      map['start_minute'] = Variable<int>(startMinute.value);
    }
    if (durationMinutes.present) {
      map['duration_minutes'] = Variable<int>(durationMinutes.value);
    }
    if (weekParity.present) {
      map['week_parity'] = Variable<int>(weekParity.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (requiresCommute.present) {
      map['requires_commute'] = Variable<bool>(requiresCommute.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleItemsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('weekday: $weekday, ')
          ..write('startMinute: $startMinute, ')
          ..write('durationMinutes: $durationMinutes, ')
          ..write('weekParity: $weekParity, ')
          ..write('location: $location, ')
          ..write('requiresCommute: $requiresCommute, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlansTable extends Plans with TableInfo<$PlansTable, PlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acceptedAtMeta = const VerificationMeta(
    'acceptedAt',
  );
  @override
  late final GeneratedColumn<DateTime> acceptedAt = GeneratedColumn<DateTime>(
    'accepted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    createdAt,
    acceptedAt,
    source,
    payload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('accepted_at')) {
      context.handle(
        _acceptedAtMeta,
        acceptedAt.isAcceptableOrUnknown(data['accepted_at']!, _acceptedAtMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      acceptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}accepted_at'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $PlansTable createAlias(String alias) {
    return $PlansTable(attachedDatabase, alias);
  }
}

class PlanRow extends DataClass implements Insertable<PlanRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final String source;
  final String payload;
  const PlanRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.createdAt,
    this.acceptedAt,
    required this.source,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || acceptedAt != null) {
      map['accepted_at'] = Variable<DateTime>(acceptedAt);
    }
    map['source'] = Variable<String>(source);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  PlansCompanion toCompanion(bool nullToAbsent) {
    return PlansCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      createdAt: Value(createdAt),
      acceptedAt: acceptedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acceptedAt),
      source: Value(source),
      payload: Value(payload),
    );
  }

  factory PlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      acceptedAt: serializer.fromJson<DateTime?>(json['acceptedAt']),
      source: serializer.fromJson<String>(json['source']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'acceptedAt': serializer.toJson<DateTime?>(acceptedAt),
      'source': serializer.toJson<String>(source),
      'payload': serializer.toJson<String>(payload),
    };
  }

  PlanRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    DateTime? createdAt,
    Value<DateTime?> acceptedAt = const Value.absent(),
    String? source,
    String? payload,
  }) => PlanRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    createdAt: createdAt ?? this.createdAt,
    acceptedAt: acceptedAt.present ? acceptedAt.value : this.acceptedAt,
    source: source ?? this.source,
    payload: payload ?? this.payload,
  );
  PlanRow copyWithCompanion(PlansCompanion data) {
    return PlanRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      acceptedAt: data.acceptedAt.present
          ? data.acceptedAt.value
          : this.acceptedAt,
      source: data.source.present ? data.source.value : this.source,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('acceptedAt: $acceptedAt, ')
          ..write('source: $source, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    createdAt,
    acceptedAt,
    source,
    payload,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.acceptedAt == this.acceptedAt &&
          other.source == this.source &&
          other.payload == this.payload);
}

class PlansCompanion extends UpdateCompanion<PlanRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<DateTime?> acceptedAt;
  final Value<String> source;
  final Value<String> payload;
  final Value<int> rowid;
  const PlansCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.acceptedAt = const Value.absent(),
    this.source = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlansCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required DateTime createdAt,
    this.acceptedAt = const Value.absent(),
    this.source = const Value.absent(),
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       createdAt = Value(createdAt),
       payload = Value(payload);
  static Insertable<PlanRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? acceptedAt,
    Expression<String>? source,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (acceptedAt != null) 'accepted_at': acceptedAt,
      if (source != null) 'source': source,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlansCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<DateTime>? createdAt,
    Value<DateTime?>? acceptedAt,
    Value<String>? source,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return PlansCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      source: source ?? this.source,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (acceptedAt.present) {
      map['accepted_at'] = Variable<DateTime>(acceptedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlansCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('acceptedAt: $acceptedAt, ')
          ..write('source: $source, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestionnaireSectionsTable extends QuestionnaireSections
    with TableInfo<$QuestionnaireSectionsTable, QuestionnaireSectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionnaireSectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    payload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'questionnaire_sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestionnaireSectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestionnaireSectionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionnaireSectionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $QuestionnaireSectionsTable createAlias(String alias) {
    return $QuestionnaireSectionsTable(attachedDatabase, alias);
  }
}

class QuestionnaireSectionRow extends DataClass
    implements Insertable<QuestionnaireSectionRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final String payload;
  const QuestionnaireSectionRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  QuestionnaireSectionsCompanion toCompanion(bool nullToAbsent) {
    return QuestionnaireSectionsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      payload: Value(payload),
    );
  }

  factory QuestionnaireSectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionnaireSectionRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'payload': serializer.toJson<String>(payload),
    };
  }

  QuestionnaireSectionRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    String? payload,
  }) => QuestionnaireSectionRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    payload: payload ?? this.payload,
  );
  QuestionnaireSectionRow copyWithCompanion(
    QuestionnaireSectionsCompanion data,
  ) {
    return QuestionnaireSectionRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionnaireSectionRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, deletedAt, deviceId, version, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionnaireSectionRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.payload == this.payload);
}

class QuestionnaireSectionsCompanion
    extends UpdateCompanion<QuestionnaireSectionRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<String> payload;
  final Value<int> rowid;
  const QuestionnaireSectionsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionnaireSectionsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       payload = Value(payload);
  static Insertable<QuestionnaireSectionRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionnaireSectionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return QuestionnaireSectionsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionnaireSectionsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestsTable extends Quests with TableInfo<$QuestsTable, QuestRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statMeta = const VerificationMeta('stat');
  @override
  late final GeneratedColumn<String> stat = GeneratedColumn<String>(
    'stat',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleKeyMeta = const VerificationMeta(
    'titleKey',
  );
  @override
  late final GeneratedColumn<String> titleKey = GeneratedColumn<String>(
    'title_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paramsMeta = const VerificationMeta('params');
  @override
  late final GeneratedColumn<String> params = GeneratedColumn<String>(
    'params',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _subtasksMeta = const VerificationMeta(
    'subtasks',
  );
  @override
  late final GeneratedColumn<String> subtasks = GeneratedColumn<String>(
    'subtasks',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _minuteMeta = const VerificationMeta('minute');
  @override
  late final GeneratedColumn<int> minute = GeneratedColumn<int>(
    'minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _windowMinutesMeta = const VerificationMeta(
    'windowMinutes',
  );
  @override
  late final GeneratedColumn<int> windowMinutes = GeneratedColumn<int>(
    'window_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(60),
  );
  static const VerificationMeta _weekdaysMeta = const VerificationMeta(
    'weekdays',
  );
  @override
  late final GeneratedColumn<String> weekdays = GeneratedColumn<String>(
    'weekdays',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _weekParityMeta = const VerificationMeta(
    'weekParity',
  );
  @override
  late final GeneratedColumn<int> weekParity = GeneratedColumn<int>(
    'week_parity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _activeFromMeta = const VerificationMeta(
    'activeFrom',
  );
  @override
  late final GeneratedColumn<DateTime> activeFrom = GeneratedColumn<DateTime>(
    'active_from',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeUntilMeta = const VerificationMeta(
    'activeUntil',
  );
  @override
  late final GeneratedColumn<DateTime> activeUntil = GeneratedColumn<DateTime>(
    'active_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rewardDiamondsMeta = const VerificationMeta(
    'rewardDiamonds',
  );
  @override
  late final GeneratedColumn<int> rewardDiamonds = GeneratedColumn<int>(
    'reward_diamonds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rewardXpMeta = const VerificationMeta(
    'rewardXp',
  );
  @override
  late final GeneratedColumn<int> rewardXp = GeneratedColumn<int>(
    'reward_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rewardStatsMeta = const VerificationMeta(
    'rewardStats',
  );
  @override
  late final GeneratedColumn<String> rewardStats = GeneratedColumn<String>(
    'reward_stats',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _penaltyDiamondsMeta = const VerificationMeta(
    'penaltyDiamonds',
  );
  @override
  late final GeneratedColumn<int> penaltyDiamonds = GeneratedColumn<int>(
    'penalty_diamonds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _refusePenaltyDiamondsMeta =
      const VerificationMeta('refusePenaltyDiamonds');
  @override
  late final GeneratedColumn<int> refusePenaltyDiamonds = GeneratedColumn<int>(
    'refuse_penalty_diamonds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confirmMeta = const VerificationMeta(
    'confirm',
  );
  @override
  late final GeneratedColumn<String> confirm = GeneratedColumn<String>(
    'confirm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('button'),
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<int> target = GeneratedColumn<int>(
    'target',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nagMeta = const VerificationMeta('nag');
  @override
  late final GeneratedColumn<bool> nag = GeneratedColumn<bool>(
    'nag',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("nag" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _cancellableMeta = const VerificationMeta(
    'cancellable',
  );
  @override
  late final GeneratedColumn<bool> cancellable = GeneratedColumn<bool>(
    'cancellable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cancellable" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('user'),
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    kind,
    stat,
    titleKey,
    title,
    params,
    subtasks,
    minute,
    windowMinutes,
    weekdays,
    weekParity,
    activeFrom,
    activeUntil,
    rewardDiamonds,
    rewardXp,
    rewardStats,
    penaltyDiamonds,
    refusePenaltyDiamonds,
    confirm,
    target,
    nag,
    cancellable,
    source,
    planId,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quests';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('stat')) {
      context.handle(
        _statMeta,
        stat.isAcceptableOrUnknown(data['stat']!, _statMeta),
      );
    }
    if (data.containsKey('title_key')) {
      context.handle(
        _titleKeyMeta,
        titleKey.isAcceptableOrUnknown(data['title_key']!, _titleKeyMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('params')) {
      context.handle(
        _paramsMeta,
        params.isAcceptableOrUnknown(data['params']!, _paramsMeta),
      );
    }
    if (data.containsKey('subtasks')) {
      context.handle(
        _subtasksMeta,
        subtasks.isAcceptableOrUnknown(data['subtasks']!, _subtasksMeta),
      );
    }
    if (data.containsKey('minute')) {
      context.handle(
        _minuteMeta,
        minute.isAcceptableOrUnknown(data['minute']!, _minuteMeta),
      );
    }
    if (data.containsKey('window_minutes')) {
      context.handle(
        _windowMinutesMeta,
        windowMinutes.isAcceptableOrUnknown(
          data['window_minutes']!,
          _windowMinutesMeta,
        ),
      );
    }
    if (data.containsKey('weekdays')) {
      context.handle(
        _weekdaysMeta,
        weekdays.isAcceptableOrUnknown(data['weekdays']!, _weekdaysMeta),
      );
    }
    if (data.containsKey('week_parity')) {
      context.handle(
        _weekParityMeta,
        weekParity.isAcceptableOrUnknown(data['week_parity']!, _weekParityMeta),
      );
    }
    if (data.containsKey('active_from')) {
      context.handle(
        _activeFromMeta,
        activeFrom.isAcceptableOrUnknown(data['active_from']!, _activeFromMeta),
      );
    }
    if (data.containsKey('active_until')) {
      context.handle(
        _activeUntilMeta,
        activeUntil.isAcceptableOrUnknown(
          data['active_until']!,
          _activeUntilMeta,
        ),
      );
    }
    if (data.containsKey('reward_diamonds')) {
      context.handle(
        _rewardDiamondsMeta,
        rewardDiamonds.isAcceptableOrUnknown(
          data['reward_diamonds']!,
          _rewardDiamondsMeta,
        ),
      );
    }
    if (data.containsKey('reward_xp')) {
      context.handle(
        _rewardXpMeta,
        rewardXp.isAcceptableOrUnknown(data['reward_xp']!, _rewardXpMeta),
      );
    }
    if (data.containsKey('reward_stats')) {
      context.handle(
        _rewardStatsMeta,
        rewardStats.isAcceptableOrUnknown(
          data['reward_stats']!,
          _rewardStatsMeta,
        ),
      );
    }
    if (data.containsKey('penalty_diamonds')) {
      context.handle(
        _penaltyDiamondsMeta,
        penaltyDiamonds.isAcceptableOrUnknown(
          data['penalty_diamonds']!,
          _penaltyDiamondsMeta,
        ),
      );
    }
    if (data.containsKey('refuse_penalty_diamonds')) {
      context.handle(
        _refusePenaltyDiamondsMeta,
        refusePenaltyDiamonds.isAcceptableOrUnknown(
          data['refuse_penalty_diamonds']!,
          _refusePenaltyDiamondsMeta,
        ),
      );
    }
    if (data.containsKey('confirm')) {
      context.handle(
        _confirmMeta,
        confirm.isAcceptableOrUnknown(data['confirm']!, _confirmMeta),
      );
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    }
    if (data.containsKey('nag')) {
      context.handle(
        _nagMeta,
        nag.isAcceptableOrUnknown(data['nag']!, _nagMeta),
      );
    }
    if (data.containsKey('cancellable')) {
      context.handle(
        _cancellableMeta,
        cancellable.isAcceptableOrUnknown(
          data['cancellable']!,
          _cancellableMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      stat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stat'],
      ),
      titleKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_key'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      params: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}params'],
      )!,
      subtasks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtasks'],
      )!,
      minute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute'],
      ),
      windowMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}window_minutes'],
      )!,
      weekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weekdays'],
      )!,
      weekParity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}week_parity'],
      )!,
      activeFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}active_from'],
      ),
      activeUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}active_until'],
      ),
      rewardDiamonds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reward_diamonds'],
      )!,
      rewardXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reward_xp'],
      )!,
      rewardStats: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reward_stats'],
      )!,
      penaltyDiamonds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}penalty_diamonds'],
      )!,
      refusePenaltyDiamonds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refuse_penalty_diamonds'],
      ),
      confirm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confirm'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target'],
      ),
      nag: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}nag'],
      )!,
      cancellable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cancellable'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $QuestsTable createAlias(String alias) {
    return $QuestsTable(attachedDatabase, alias);
  }
}

class QuestRow extends DataClass implements Insertable<QuestRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final String kind;
  final String? stat;
  final String? titleKey;
  final String? title;
  final String params;
  final String subtasks;
  final int? minute;
  final int windowMinutes;
  final String weekdays;
  final int weekParity;
  final DateTime? activeFrom;
  final DateTime? activeUntil;
  final int rewardDiamonds;
  final int rewardXp;
  final String rewardStats;
  final int penaltyDiamonds;
  final int? refusePenaltyDiamonds;
  final String confirm;
  final int? target;
  final bool nag;
  final bool cancellable;
  final String source;
  final String? planId;
  final bool active;
  const QuestRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.kind,
    this.stat,
    this.titleKey,
    this.title,
    required this.params,
    required this.subtasks,
    this.minute,
    required this.windowMinutes,
    required this.weekdays,
    required this.weekParity,
    this.activeFrom,
    this.activeUntil,
    required this.rewardDiamonds,
    required this.rewardXp,
    required this.rewardStats,
    required this.penaltyDiamonds,
    this.refusePenaltyDiamonds,
    required this.confirm,
    this.target,
    required this.nag,
    required this.cancellable,
    required this.source,
    this.planId,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || stat != null) {
      map['stat'] = Variable<String>(stat);
    }
    if (!nullToAbsent || titleKey != null) {
      map['title_key'] = Variable<String>(titleKey);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['params'] = Variable<String>(params);
    map['subtasks'] = Variable<String>(subtasks);
    if (!nullToAbsent || minute != null) {
      map['minute'] = Variable<int>(minute);
    }
    map['window_minutes'] = Variable<int>(windowMinutes);
    map['weekdays'] = Variable<String>(weekdays);
    map['week_parity'] = Variable<int>(weekParity);
    if (!nullToAbsent || activeFrom != null) {
      map['active_from'] = Variable<DateTime>(activeFrom);
    }
    if (!nullToAbsent || activeUntil != null) {
      map['active_until'] = Variable<DateTime>(activeUntil);
    }
    map['reward_diamonds'] = Variable<int>(rewardDiamonds);
    map['reward_xp'] = Variable<int>(rewardXp);
    map['reward_stats'] = Variable<String>(rewardStats);
    map['penalty_diamonds'] = Variable<int>(penaltyDiamonds);
    if (!nullToAbsent || refusePenaltyDiamonds != null) {
      map['refuse_penalty_diamonds'] = Variable<int>(refusePenaltyDiamonds);
    }
    map['confirm'] = Variable<String>(confirm);
    if (!nullToAbsent || target != null) {
      map['target'] = Variable<int>(target);
    }
    map['nag'] = Variable<bool>(nag);
    map['cancellable'] = Variable<bool>(cancellable);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || planId != null) {
      map['plan_id'] = Variable<String>(planId);
    }
    map['active'] = Variable<bool>(active);
    return map;
  }

  QuestsCompanion toCompanion(bool nullToAbsent) {
    return QuestsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      kind: Value(kind),
      stat: stat == null && nullToAbsent ? const Value.absent() : Value(stat),
      titleKey: titleKey == null && nullToAbsent
          ? const Value.absent()
          : Value(titleKey),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      params: Value(params),
      subtasks: Value(subtasks),
      minute: minute == null && nullToAbsent
          ? const Value.absent()
          : Value(minute),
      windowMinutes: Value(windowMinutes),
      weekdays: Value(weekdays),
      weekParity: Value(weekParity),
      activeFrom: activeFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(activeFrom),
      activeUntil: activeUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(activeUntil),
      rewardDiamonds: Value(rewardDiamonds),
      rewardXp: Value(rewardXp),
      rewardStats: Value(rewardStats),
      penaltyDiamonds: Value(penaltyDiamonds),
      refusePenaltyDiamonds: refusePenaltyDiamonds == null && nullToAbsent
          ? const Value.absent()
          : Value(refusePenaltyDiamonds),
      confirm: Value(confirm),
      target: target == null && nullToAbsent
          ? const Value.absent()
          : Value(target),
      nag: Value(nag),
      cancellable: Value(cancellable),
      source: Value(source),
      planId: planId == null && nullToAbsent
          ? const Value.absent()
          : Value(planId),
      active: Value(active),
    );
  }

  factory QuestRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      kind: serializer.fromJson<String>(json['kind']),
      stat: serializer.fromJson<String?>(json['stat']),
      titleKey: serializer.fromJson<String?>(json['titleKey']),
      title: serializer.fromJson<String?>(json['title']),
      params: serializer.fromJson<String>(json['params']),
      subtasks: serializer.fromJson<String>(json['subtasks']),
      minute: serializer.fromJson<int?>(json['minute']),
      windowMinutes: serializer.fromJson<int>(json['windowMinutes']),
      weekdays: serializer.fromJson<String>(json['weekdays']),
      weekParity: serializer.fromJson<int>(json['weekParity']),
      activeFrom: serializer.fromJson<DateTime?>(json['activeFrom']),
      activeUntil: serializer.fromJson<DateTime?>(json['activeUntil']),
      rewardDiamonds: serializer.fromJson<int>(json['rewardDiamonds']),
      rewardXp: serializer.fromJson<int>(json['rewardXp']),
      rewardStats: serializer.fromJson<String>(json['rewardStats']),
      penaltyDiamonds: serializer.fromJson<int>(json['penaltyDiamonds']),
      refusePenaltyDiamonds: serializer.fromJson<int?>(
        json['refusePenaltyDiamonds'],
      ),
      confirm: serializer.fromJson<String>(json['confirm']),
      target: serializer.fromJson<int?>(json['target']),
      nag: serializer.fromJson<bool>(json['nag']),
      cancellable: serializer.fromJson<bool>(json['cancellable']),
      source: serializer.fromJson<String>(json['source']),
      planId: serializer.fromJson<String?>(json['planId']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'kind': serializer.toJson<String>(kind),
      'stat': serializer.toJson<String?>(stat),
      'titleKey': serializer.toJson<String?>(titleKey),
      'title': serializer.toJson<String?>(title),
      'params': serializer.toJson<String>(params),
      'subtasks': serializer.toJson<String>(subtasks),
      'minute': serializer.toJson<int?>(minute),
      'windowMinutes': serializer.toJson<int>(windowMinutes),
      'weekdays': serializer.toJson<String>(weekdays),
      'weekParity': serializer.toJson<int>(weekParity),
      'activeFrom': serializer.toJson<DateTime?>(activeFrom),
      'activeUntil': serializer.toJson<DateTime?>(activeUntil),
      'rewardDiamonds': serializer.toJson<int>(rewardDiamonds),
      'rewardXp': serializer.toJson<int>(rewardXp),
      'rewardStats': serializer.toJson<String>(rewardStats),
      'penaltyDiamonds': serializer.toJson<int>(penaltyDiamonds),
      'refusePenaltyDiamonds': serializer.toJson<int?>(refusePenaltyDiamonds),
      'confirm': serializer.toJson<String>(confirm),
      'target': serializer.toJson<int?>(target),
      'nag': serializer.toJson<bool>(nag),
      'cancellable': serializer.toJson<bool>(cancellable),
      'source': serializer.toJson<String>(source),
      'planId': serializer.toJson<String?>(planId),
      'active': serializer.toJson<bool>(active),
    };
  }

  QuestRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    String? kind,
    Value<String?> stat = const Value.absent(),
    Value<String?> titleKey = const Value.absent(),
    Value<String?> title = const Value.absent(),
    String? params,
    String? subtasks,
    Value<int?> minute = const Value.absent(),
    int? windowMinutes,
    String? weekdays,
    int? weekParity,
    Value<DateTime?> activeFrom = const Value.absent(),
    Value<DateTime?> activeUntil = const Value.absent(),
    int? rewardDiamonds,
    int? rewardXp,
    String? rewardStats,
    int? penaltyDiamonds,
    Value<int?> refusePenaltyDiamonds = const Value.absent(),
    String? confirm,
    Value<int?> target = const Value.absent(),
    bool? nag,
    bool? cancellable,
    String? source,
    Value<String?> planId = const Value.absent(),
    bool? active,
  }) => QuestRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    kind: kind ?? this.kind,
    stat: stat.present ? stat.value : this.stat,
    titleKey: titleKey.present ? titleKey.value : this.titleKey,
    title: title.present ? title.value : this.title,
    params: params ?? this.params,
    subtasks: subtasks ?? this.subtasks,
    minute: minute.present ? minute.value : this.minute,
    windowMinutes: windowMinutes ?? this.windowMinutes,
    weekdays: weekdays ?? this.weekdays,
    weekParity: weekParity ?? this.weekParity,
    activeFrom: activeFrom.present ? activeFrom.value : this.activeFrom,
    activeUntil: activeUntil.present ? activeUntil.value : this.activeUntil,
    rewardDiamonds: rewardDiamonds ?? this.rewardDiamonds,
    rewardXp: rewardXp ?? this.rewardXp,
    rewardStats: rewardStats ?? this.rewardStats,
    penaltyDiamonds: penaltyDiamonds ?? this.penaltyDiamonds,
    refusePenaltyDiamonds: refusePenaltyDiamonds.present
        ? refusePenaltyDiamonds.value
        : this.refusePenaltyDiamonds,
    confirm: confirm ?? this.confirm,
    target: target.present ? target.value : this.target,
    nag: nag ?? this.nag,
    cancellable: cancellable ?? this.cancellable,
    source: source ?? this.source,
    planId: planId.present ? planId.value : this.planId,
    active: active ?? this.active,
  );
  QuestRow copyWithCompanion(QuestsCompanion data) {
    return QuestRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      kind: data.kind.present ? data.kind.value : this.kind,
      stat: data.stat.present ? data.stat.value : this.stat,
      titleKey: data.titleKey.present ? data.titleKey.value : this.titleKey,
      title: data.title.present ? data.title.value : this.title,
      params: data.params.present ? data.params.value : this.params,
      subtasks: data.subtasks.present ? data.subtasks.value : this.subtasks,
      minute: data.minute.present ? data.minute.value : this.minute,
      windowMinutes: data.windowMinutes.present
          ? data.windowMinutes.value
          : this.windowMinutes,
      weekdays: data.weekdays.present ? data.weekdays.value : this.weekdays,
      weekParity: data.weekParity.present
          ? data.weekParity.value
          : this.weekParity,
      activeFrom: data.activeFrom.present
          ? data.activeFrom.value
          : this.activeFrom,
      activeUntil: data.activeUntil.present
          ? data.activeUntil.value
          : this.activeUntil,
      rewardDiamonds: data.rewardDiamonds.present
          ? data.rewardDiamonds.value
          : this.rewardDiamonds,
      rewardXp: data.rewardXp.present ? data.rewardXp.value : this.rewardXp,
      rewardStats: data.rewardStats.present
          ? data.rewardStats.value
          : this.rewardStats,
      penaltyDiamonds: data.penaltyDiamonds.present
          ? data.penaltyDiamonds.value
          : this.penaltyDiamonds,
      refusePenaltyDiamonds: data.refusePenaltyDiamonds.present
          ? data.refusePenaltyDiamonds.value
          : this.refusePenaltyDiamonds,
      confirm: data.confirm.present ? data.confirm.value : this.confirm,
      target: data.target.present ? data.target.value : this.target,
      nag: data.nag.present ? data.nag.value : this.nag,
      cancellable: data.cancellable.present
          ? data.cancellable.value
          : this.cancellable,
      source: data.source.present ? data.source.value : this.source,
      planId: data.planId.present ? data.planId.value : this.planId,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('kind: $kind, ')
          ..write('stat: $stat, ')
          ..write('titleKey: $titleKey, ')
          ..write('title: $title, ')
          ..write('params: $params, ')
          ..write('subtasks: $subtasks, ')
          ..write('minute: $minute, ')
          ..write('windowMinutes: $windowMinutes, ')
          ..write('weekdays: $weekdays, ')
          ..write('weekParity: $weekParity, ')
          ..write('activeFrom: $activeFrom, ')
          ..write('activeUntil: $activeUntil, ')
          ..write('rewardDiamonds: $rewardDiamonds, ')
          ..write('rewardXp: $rewardXp, ')
          ..write('rewardStats: $rewardStats, ')
          ..write('penaltyDiamonds: $penaltyDiamonds, ')
          ..write('refusePenaltyDiamonds: $refusePenaltyDiamonds, ')
          ..write('confirm: $confirm, ')
          ..write('target: $target, ')
          ..write('nag: $nag, ')
          ..write('cancellable: $cancellable, ')
          ..write('source: $source, ')
          ..write('planId: $planId, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    kind,
    stat,
    titleKey,
    title,
    params,
    subtasks,
    minute,
    windowMinutes,
    weekdays,
    weekParity,
    activeFrom,
    activeUntil,
    rewardDiamonds,
    rewardXp,
    rewardStats,
    penaltyDiamonds,
    refusePenaltyDiamonds,
    confirm,
    target,
    nag,
    cancellable,
    source,
    planId,
    active,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.kind == this.kind &&
          other.stat == this.stat &&
          other.titleKey == this.titleKey &&
          other.title == this.title &&
          other.params == this.params &&
          other.subtasks == this.subtasks &&
          other.minute == this.minute &&
          other.windowMinutes == this.windowMinutes &&
          other.weekdays == this.weekdays &&
          other.weekParity == this.weekParity &&
          other.activeFrom == this.activeFrom &&
          other.activeUntil == this.activeUntil &&
          other.rewardDiamonds == this.rewardDiamonds &&
          other.rewardXp == this.rewardXp &&
          other.rewardStats == this.rewardStats &&
          other.penaltyDiamonds == this.penaltyDiamonds &&
          other.refusePenaltyDiamonds == this.refusePenaltyDiamonds &&
          other.confirm == this.confirm &&
          other.target == this.target &&
          other.nag == this.nag &&
          other.cancellable == this.cancellable &&
          other.source == this.source &&
          other.planId == this.planId &&
          other.active == this.active);
}

class QuestsCompanion extends UpdateCompanion<QuestRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<String> kind;
  final Value<String?> stat;
  final Value<String?> titleKey;
  final Value<String?> title;
  final Value<String> params;
  final Value<String> subtasks;
  final Value<int?> minute;
  final Value<int> windowMinutes;
  final Value<String> weekdays;
  final Value<int> weekParity;
  final Value<DateTime?> activeFrom;
  final Value<DateTime?> activeUntil;
  final Value<int> rewardDiamonds;
  final Value<int> rewardXp;
  final Value<String> rewardStats;
  final Value<int> penaltyDiamonds;
  final Value<int?> refusePenaltyDiamonds;
  final Value<String> confirm;
  final Value<int?> target;
  final Value<bool> nag;
  final Value<bool> cancellable;
  final Value<String> source;
  final Value<String?> planId;
  final Value<bool> active;
  final Value<int> rowid;
  const QuestsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.kind = const Value.absent(),
    this.stat = const Value.absent(),
    this.titleKey = const Value.absent(),
    this.title = const Value.absent(),
    this.params = const Value.absent(),
    this.subtasks = const Value.absent(),
    this.minute = const Value.absent(),
    this.windowMinutes = const Value.absent(),
    this.weekdays = const Value.absent(),
    this.weekParity = const Value.absent(),
    this.activeFrom = const Value.absent(),
    this.activeUntil = const Value.absent(),
    this.rewardDiamonds = const Value.absent(),
    this.rewardXp = const Value.absent(),
    this.rewardStats = const Value.absent(),
    this.penaltyDiamonds = const Value.absent(),
    this.refusePenaltyDiamonds = const Value.absent(),
    this.confirm = const Value.absent(),
    this.target = const Value.absent(),
    this.nag = const Value.absent(),
    this.cancellable = const Value.absent(),
    this.source = const Value.absent(),
    this.planId = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required String kind,
    this.stat = const Value.absent(),
    this.titleKey = const Value.absent(),
    this.title = const Value.absent(),
    this.params = const Value.absent(),
    this.subtasks = const Value.absent(),
    this.minute = const Value.absent(),
    this.windowMinutes = const Value.absent(),
    this.weekdays = const Value.absent(),
    this.weekParity = const Value.absent(),
    this.activeFrom = const Value.absent(),
    this.activeUntil = const Value.absent(),
    this.rewardDiamonds = const Value.absent(),
    this.rewardXp = const Value.absent(),
    this.rewardStats = const Value.absent(),
    this.penaltyDiamonds = const Value.absent(),
    this.refusePenaltyDiamonds = const Value.absent(),
    this.confirm = const Value.absent(),
    this.target = const Value.absent(),
    this.nag = const Value.absent(),
    this.cancellable = const Value.absent(),
    this.source = const Value.absent(),
    this.planId = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       kind = Value(kind);
  static Insertable<QuestRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<String>? kind,
    Expression<String>? stat,
    Expression<String>? titleKey,
    Expression<String>? title,
    Expression<String>? params,
    Expression<String>? subtasks,
    Expression<int>? minute,
    Expression<int>? windowMinutes,
    Expression<String>? weekdays,
    Expression<int>? weekParity,
    Expression<DateTime>? activeFrom,
    Expression<DateTime>? activeUntil,
    Expression<int>? rewardDiamonds,
    Expression<int>? rewardXp,
    Expression<String>? rewardStats,
    Expression<int>? penaltyDiamonds,
    Expression<int>? refusePenaltyDiamonds,
    Expression<String>? confirm,
    Expression<int>? target,
    Expression<bool>? nag,
    Expression<bool>? cancellable,
    Expression<String>? source,
    Expression<String>? planId,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (kind != null) 'kind': kind,
      if (stat != null) 'stat': stat,
      if (titleKey != null) 'title_key': titleKey,
      if (title != null) 'title': title,
      if (params != null) 'params': params,
      if (subtasks != null) 'subtasks': subtasks,
      if (minute != null) 'minute': minute,
      if (windowMinutes != null) 'window_minutes': windowMinutes,
      if (weekdays != null) 'weekdays': weekdays,
      if (weekParity != null) 'week_parity': weekParity,
      if (activeFrom != null) 'active_from': activeFrom,
      if (activeUntil != null) 'active_until': activeUntil,
      if (rewardDiamonds != null) 'reward_diamonds': rewardDiamonds,
      if (rewardXp != null) 'reward_xp': rewardXp,
      if (rewardStats != null) 'reward_stats': rewardStats,
      if (penaltyDiamonds != null) 'penalty_diamonds': penaltyDiamonds,
      if (refusePenaltyDiamonds != null)
        'refuse_penalty_diamonds': refusePenaltyDiamonds,
      if (confirm != null) 'confirm': confirm,
      if (target != null) 'target': target,
      if (nag != null) 'nag': nag,
      if (cancellable != null) 'cancellable': cancellable,
      if (source != null) 'source': source,
      if (planId != null) 'plan_id': planId,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<String>? kind,
    Value<String?>? stat,
    Value<String?>? titleKey,
    Value<String?>? title,
    Value<String>? params,
    Value<String>? subtasks,
    Value<int?>? minute,
    Value<int>? windowMinutes,
    Value<String>? weekdays,
    Value<int>? weekParity,
    Value<DateTime?>? activeFrom,
    Value<DateTime?>? activeUntil,
    Value<int>? rewardDiamonds,
    Value<int>? rewardXp,
    Value<String>? rewardStats,
    Value<int>? penaltyDiamonds,
    Value<int?>? refusePenaltyDiamonds,
    Value<String>? confirm,
    Value<int?>? target,
    Value<bool>? nag,
    Value<bool>? cancellable,
    Value<String>? source,
    Value<String?>? planId,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return QuestsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      kind: kind ?? this.kind,
      stat: stat ?? this.stat,
      titleKey: titleKey ?? this.titleKey,
      title: title ?? this.title,
      params: params ?? this.params,
      subtasks: subtasks ?? this.subtasks,
      minute: minute ?? this.minute,
      windowMinutes: windowMinutes ?? this.windowMinutes,
      weekdays: weekdays ?? this.weekdays,
      weekParity: weekParity ?? this.weekParity,
      activeFrom: activeFrom ?? this.activeFrom,
      activeUntil: activeUntil ?? this.activeUntil,
      rewardDiamonds: rewardDiamonds ?? this.rewardDiamonds,
      rewardXp: rewardXp ?? this.rewardXp,
      rewardStats: rewardStats ?? this.rewardStats,
      penaltyDiamonds: penaltyDiamonds ?? this.penaltyDiamonds,
      refusePenaltyDiamonds:
          refusePenaltyDiamonds ?? this.refusePenaltyDiamonds,
      confirm: confirm ?? this.confirm,
      target: target ?? this.target,
      nag: nag ?? this.nag,
      cancellable: cancellable ?? this.cancellable,
      source: source ?? this.source,
      planId: planId ?? this.planId,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (stat.present) {
      map['stat'] = Variable<String>(stat.value);
    }
    if (titleKey.present) {
      map['title_key'] = Variable<String>(titleKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (params.present) {
      map['params'] = Variable<String>(params.value);
    }
    if (subtasks.present) {
      map['subtasks'] = Variable<String>(subtasks.value);
    }
    if (minute.present) {
      map['minute'] = Variable<int>(minute.value);
    }
    if (windowMinutes.present) {
      map['window_minutes'] = Variable<int>(windowMinutes.value);
    }
    if (weekdays.present) {
      map['weekdays'] = Variable<String>(weekdays.value);
    }
    if (weekParity.present) {
      map['week_parity'] = Variable<int>(weekParity.value);
    }
    if (activeFrom.present) {
      map['active_from'] = Variable<DateTime>(activeFrom.value);
    }
    if (activeUntil.present) {
      map['active_until'] = Variable<DateTime>(activeUntil.value);
    }
    if (rewardDiamonds.present) {
      map['reward_diamonds'] = Variable<int>(rewardDiamonds.value);
    }
    if (rewardXp.present) {
      map['reward_xp'] = Variable<int>(rewardXp.value);
    }
    if (rewardStats.present) {
      map['reward_stats'] = Variable<String>(rewardStats.value);
    }
    if (penaltyDiamonds.present) {
      map['penalty_diamonds'] = Variable<int>(penaltyDiamonds.value);
    }
    if (refusePenaltyDiamonds.present) {
      map['refuse_penalty_diamonds'] = Variable<int>(
        refusePenaltyDiamonds.value,
      );
    }
    if (confirm.present) {
      map['confirm'] = Variable<String>(confirm.value);
    }
    if (target.present) {
      map['target'] = Variable<int>(target.value);
    }
    if (nag.present) {
      map['nag'] = Variable<bool>(nag.value);
    }
    if (cancellable.present) {
      map['cancellable'] = Variable<bool>(cancellable.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('kind: $kind, ')
          ..write('stat: $stat, ')
          ..write('titleKey: $titleKey, ')
          ..write('title: $title, ')
          ..write('params: $params, ')
          ..write('subtasks: $subtasks, ')
          ..write('minute: $minute, ')
          ..write('windowMinutes: $windowMinutes, ')
          ..write('weekdays: $weekdays, ')
          ..write('weekParity: $weekParity, ')
          ..write('activeFrom: $activeFrom, ')
          ..write('activeUntil: $activeUntil, ')
          ..write('rewardDiamonds: $rewardDiamonds, ')
          ..write('rewardXp: $rewardXp, ')
          ..write('rewardStats: $rewardStats, ')
          ..write('penaltyDiamonds: $penaltyDiamonds, ')
          ..write('refusePenaltyDiamonds: $refusePenaltyDiamonds, ')
          ..write('confirm: $confirm, ')
          ..write('target: $target, ')
          ..write('nag: $nag, ')
          ..write('cancellable: $cancellable, ')
          ..write('source: $source, ')
          ..write('planId: $planId, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestInstancesTable extends QuestInstances
    with TableInfo<$QuestInstancesTable, QuestInstanceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestInstancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _questIdMeta = const VerificationMeta(
    'questId',
  );
  @override
  late final GeneratedColumn<String> questId = GeneratedColumn<String>(
    'quest_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startsAtMeta = const VerificationMeta(
    'startsAt',
  );
  @override
  late final GeneratedColumn<DateTime> startsAt = GeneratedColumn<DateTime>(
    'starts_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deadlineAtMeta = const VerificationMeta(
    'deadlineAt',
  );
  @override
  late final GeneratedColumn<DateTime> deadlineAt = GeneratedColumn<DateTime>(
    'deadline_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozedUntilMeta = const VerificationMeta(
    'snoozedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> snoozedUntil = GeneratedColumn<DateTime>(
    'snoozed_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snoozeCountMeta = const VerificationMeta(
    'snoozeCount',
  );
  @override
  late final GeneratedColumn<int> snoozeCount = GeneratedColumn<int>(
    'snooze_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<int> progress = GeneratedColumn<int>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _subtasksDoneMeta = const VerificationMeta(
    'subtasksDone',
  );
  @override
  late final GeneratedColumn<String> subtasksDone = GeneratedColumn<String>(
    'subtasks_done',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _rewardDiamondsMeta = const VerificationMeta(
    'rewardDiamonds',
  );
  @override
  late final GeneratedColumn<int> rewardDiamonds = GeneratedColumn<int>(
    'reward_diamonds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rewardXpMeta = const VerificationMeta(
    'rewardXp',
  );
  @override
  late final GeneratedColumn<int> rewardXp = GeneratedColumn<int>(
    'reward_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rewardStatsMeta = const VerificationMeta(
    'rewardStats',
  );
  @override
  late final GeneratedColumn<String> rewardStats = GeneratedColumn<String>(
    'reward_stats',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _penaltyDiamondsMeta = const VerificationMeta(
    'penaltyDiamonds',
  );
  @override
  late final GeneratedColumn<int> penaltyDiamonds = GeneratedColumn<int>(
    'penalty_diamonds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _refusePenaltyDiamondsMeta =
      const VerificationMeta('refusePenaltyDiamonds');
  @override
  late final GeneratedColumn<int> refusePenaltyDiamonds = GeneratedColumn<int>(
    'refuse_penalty_diamonds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    questId,
    day,
    startsAt,
    deadlineAt,
    status,
    resolvedAt,
    snoozedUntil,
    snoozeCount,
    progress,
    subtasksDone,
    rewardDiamonds,
    rewardXp,
    rewardStats,
    penaltyDiamonds,
    refusePenaltyDiamonds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quest_instances';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestInstanceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('quest_id')) {
      context.handle(
        _questIdMeta,
        questId.isAcceptableOrUnknown(data['quest_id']!, _questIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('starts_at')) {
      context.handle(
        _startsAtMeta,
        startsAt.isAcceptableOrUnknown(data['starts_at']!, _startsAtMeta),
      );
    }
    if (data.containsKey('deadline_at')) {
      context.handle(
        _deadlineAtMeta,
        deadlineAt.isAcceptableOrUnknown(data['deadline_at']!, _deadlineAtMeta),
      );
    } else if (isInserting) {
      context.missing(_deadlineAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('snoozed_until')) {
      context.handle(
        _snoozedUntilMeta,
        snoozedUntil.isAcceptableOrUnknown(
          data['snoozed_until']!,
          _snoozedUntilMeta,
        ),
      );
    }
    if (data.containsKey('snooze_count')) {
      context.handle(
        _snoozeCountMeta,
        snoozeCount.isAcceptableOrUnknown(
          data['snooze_count']!,
          _snoozeCountMeta,
        ),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('subtasks_done')) {
      context.handle(
        _subtasksDoneMeta,
        subtasksDone.isAcceptableOrUnknown(
          data['subtasks_done']!,
          _subtasksDoneMeta,
        ),
      );
    }
    if (data.containsKey('reward_diamonds')) {
      context.handle(
        _rewardDiamondsMeta,
        rewardDiamonds.isAcceptableOrUnknown(
          data['reward_diamonds']!,
          _rewardDiamondsMeta,
        ),
      );
    }
    if (data.containsKey('reward_xp')) {
      context.handle(
        _rewardXpMeta,
        rewardXp.isAcceptableOrUnknown(data['reward_xp']!, _rewardXpMeta),
      );
    }
    if (data.containsKey('reward_stats')) {
      context.handle(
        _rewardStatsMeta,
        rewardStats.isAcceptableOrUnknown(
          data['reward_stats']!,
          _rewardStatsMeta,
        ),
      );
    }
    if (data.containsKey('penalty_diamonds')) {
      context.handle(
        _penaltyDiamondsMeta,
        penaltyDiamonds.isAcceptableOrUnknown(
          data['penalty_diamonds']!,
          _penaltyDiamondsMeta,
        ),
      );
    }
    if (data.containsKey('refuse_penalty_diamonds')) {
      context.handle(
        _refusePenaltyDiamondsMeta,
        refusePenaltyDiamonds.isAcceptableOrUnknown(
          data['refuse_penalty_diamonds']!,
          _refusePenaltyDiamondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {questId, day},
  ];
  @override
  QuestInstanceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestInstanceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      questId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quest_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}day'],
      )!,
      startsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starts_at'],
      ),
      deadlineAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
      snoozedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}snoozed_until'],
      ),
      snoozeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snooze_count'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress'],
      )!,
      subtasksDone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtasks_done'],
      )!,
      rewardDiamonds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reward_diamonds'],
      )!,
      rewardXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reward_xp'],
      )!,
      rewardStats: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reward_stats'],
      )!,
      penaltyDiamonds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}penalty_diamonds'],
      )!,
      refusePenaltyDiamonds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refuse_penalty_diamonds'],
      )!,
    );
  }

  @override
  $QuestInstancesTable createAlias(String alias) {
    return $QuestInstancesTable(attachedDatabase, alias);
  }
}

class QuestInstanceRow extends DataClass
    implements Insertable<QuestInstanceRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final String questId;
  final DateTime day;
  final DateTime? startsAt;
  final DateTime deadlineAt;
  final String status;
  final DateTime? resolvedAt;
  final DateTime? snoozedUntil;
  final int snoozeCount;
  final int progress;
  final String subtasksDone;
  final int rewardDiamonds;
  final int rewardXp;
  final String rewardStats;
  final int penaltyDiamonds;
  final int refusePenaltyDiamonds;
  const QuestInstanceRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.questId,
    required this.day,
    this.startsAt,
    required this.deadlineAt,
    required this.status,
    this.resolvedAt,
    this.snoozedUntil,
    required this.snoozeCount,
    required this.progress,
    required this.subtasksDone,
    required this.rewardDiamonds,
    required this.rewardXp,
    required this.rewardStats,
    required this.penaltyDiamonds,
    required this.refusePenaltyDiamonds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['quest_id'] = Variable<String>(questId);
    map['day'] = Variable<DateTime>(day);
    if (!nullToAbsent || startsAt != null) {
      map['starts_at'] = Variable<DateTime>(startsAt);
    }
    map['deadline_at'] = Variable<DateTime>(deadlineAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    if (!nullToAbsent || snoozedUntil != null) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil);
    }
    map['snooze_count'] = Variable<int>(snoozeCount);
    map['progress'] = Variable<int>(progress);
    map['subtasks_done'] = Variable<String>(subtasksDone);
    map['reward_diamonds'] = Variable<int>(rewardDiamonds);
    map['reward_xp'] = Variable<int>(rewardXp);
    map['reward_stats'] = Variable<String>(rewardStats);
    map['penalty_diamonds'] = Variable<int>(penaltyDiamonds);
    map['refuse_penalty_diamonds'] = Variable<int>(refusePenaltyDiamonds);
    return map;
  }

  QuestInstancesCompanion toCompanion(bool nullToAbsent) {
    return QuestInstancesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      questId: Value(questId),
      day: Value(day),
      startsAt: startsAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startsAt),
      deadlineAt: Value(deadlineAt),
      status: Value(status),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      snoozedUntil: snoozedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(snoozedUntil),
      snoozeCount: Value(snoozeCount),
      progress: Value(progress),
      subtasksDone: Value(subtasksDone),
      rewardDiamonds: Value(rewardDiamonds),
      rewardXp: Value(rewardXp),
      rewardStats: Value(rewardStats),
      penaltyDiamonds: Value(penaltyDiamonds),
      refusePenaltyDiamonds: Value(refusePenaltyDiamonds),
    );
  }

  factory QuestInstanceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestInstanceRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      questId: serializer.fromJson<String>(json['questId']),
      day: serializer.fromJson<DateTime>(json['day']),
      startsAt: serializer.fromJson<DateTime?>(json['startsAt']),
      deadlineAt: serializer.fromJson<DateTime>(json['deadlineAt']),
      status: serializer.fromJson<String>(json['status']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
      snoozedUntil: serializer.fromJson<DateTime?>(json['snoozedUntil']),
      snoozeCount: serializer.fromJson<int>(json['snoozeCount']),
      progress: serializer.fromJson<int>(json['progress']),
      subtasksDone: serializer.fromJson<String>(json['subtasksDone']),
      rewardDiamonds: serializer.fromJson<int>(json['rewardDiamonds']),
      rewardXp: serializer.fromJson<int>(json['rewardXp']),
      rewardStats: serializer.fromJson<String>(json['rewardStats']),
      penaltyDiamonds: serializer.fromJson<int>(json['penaltyDiamonds']),
      refusePenaltyDiamonds: serializer.fromJson<int>(
        json['refusePenaltyDiamonds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'questId': serializer.toJson<String>(questId),
      'day': serializer.toJson<DateTime>(day),
      'startsAt': serializer.toJson<DateTime?>(startsAt),
      'deadlineAt': serializer.toJson<DateTime>(deadlineAt),
      'status': serializer.toJson<String>(status),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
      'snoozedUntil': serializer.toJson<DateTime?>(snoozedUntil),
      'snoozeCount': serializer.toJson<int>(snoozeCount),
      'progress': serializer.toJson<int>(progress),
      'subtasksDone': serializer.toJson<String>(subtasksDone),
      'rewardDiamonds': serializer.toJson<int>(rewardDiamonds),
      'rewardXp': serializer.toJson<int>(rewardXp),
      'rewardStats': serializer.toJson<String>(rewardStats),
      'penaltyDiamonds': serializer.toJson<int>(penaltyDiamonds),
      'refusePenaltyDiamonds': serializer.toJson<int>(refusePenaltyDiamonds),
    };
  }

  QuestInstanceRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    String? questId,
    DateTime? day,
    Value<DateTime?> startsAt = const Value.absent(),
    DateTime? deadlineAt,
    String? status,
    Value<DateTime?> resolvedAt = const Value.absent(),
    Value<DateTime?> snoozedUntil = const Value.absent(),
    int? snoozeCount,
    int? progress,
    String? subtasksDone,
    int? rewardDiamonds,
    int? rewardXp,
    String? rewardStats,
    int? penaltyDiamonds,
    int? refusePenaltyDiamonds,
  }) => QuestInstanceRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    questId: questId ?? this.questId,
    day: day ?? this.day,
    startsAt: startsAt.present ? startsAt.value : this.startsAt,
    deadlineAt: deadlineAt ?? this.deadlineAt,
    status: status ?? this.status,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    snoozedUntil: snoozedUntil.present ? snoozedUntil.value : this.snoozedUntil,
    snoozeCount: snoozeCount ?? this.snoozeCount,
    progress: progress ?? this.progress,
    subtasksDone: subtasksDone ?? this.subtasksDone,
    rewardDiamonds: rewardDiamonds ?? this.rewardDiamonds,
    rewardXp: rewardXp ?? this.rewardXp,
    rewardStats: rewardStats ?? this.rewardStats,
    penaltyDiamonds: penaltyDiamonds ?? this.penaltyDiamonds,
    refusePenaltyDiamonds: refusePenaltyDiamonds ?? this.refusePenaltyDiamonds,
  );
  QuestInstanceRow copyWithCompanion(QuestInstancesCompanion data) {
    return QuestInstanceRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      questId: data.questId.present ? data.questId.value : this.questId,
      day: data.day.present ? data.day.value : this.day,
      startsAt: data.startsAt.present ? data.startsAt.value : this.startsAt,
      deadlineAt: data.deadlineAt.present
          ? data.deadlineAt.value
          : this.deadlineAt,
      status: data.status.present ? data.status.value : this.status,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      snoozedUntil: data.snoozedUntil.present
          ? data.snoozedUntil.value
          : this.snoozedUntil,
      snoozeCount: data.snoozeCount.present
          ? data.snoozeCount.value
          : this.snoozeCount,
      progress: data.progress.present ? data.progress.value : this.progress,
      subtasksDone: data.subtasksDone.present
          ? data.subtasksDone.value
          : this.subtasksDone,
      rewardDiamonds: data.rewardDiamonds.present
          ? data.rewardDiamonds.value
          : this.rewardDiamonds,
      rewardXp: data.rewardXp.present ? data.rewardXp.value : this.rewardXp,
      rewardStats: data.rewardStats.present
          ? data.rewardStats.value
          : this.rewardStats,
      penaltyDiamonds: data.penaltyDiamonds.present
          ? data.penaltyDiamonds.value
          : this.penaltyDiamonds,
      refusePenaltyDiamonds: data.refusePenaltyDiamonds.present
          ? data.refusePenaltyDiamonds.value
          : this.refusePenaltyDiamonds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestInstanceRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('questId: $questId, ')
          ..write('day: $day, ')
          ..write('startsAt: $startsAt, ')
          ..write('deadlineAt: $deadlineAt, ')
          ..write('status: $status, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('progress: $progress, ')
          ..write('subtasksDone: $subtasksDone, ')
          ..write('rewardDiamonds: $rewardDiamonds, ')
          ..write('rewardXp: $rewardXp, ')
          ..write('rewardStats: $rewardStats, ')
          ..write('penaltyDiamonds: $penaltyDiamonds, ')
          ..write('refusePenaltyDiamonds: $refusePenaltyDiamonds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    questId,
    day,
    startsAt,
    deadlineAt,
    status,
    resolvedAt,
    snoozedUntil,
    snoozeCount,
    progress,
    subtasksDone,
    rewardDiamonds,
    rewardXp,
    rewardStats,
    penaltyDiamonds,
    refusePenaltyDiamonds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestInstanceRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.questId == this.questId &&
          other.day == this.day &&
          other.startsAt == this.startsAt &&
          other.deadlineAt == this.deadlineAt &&
          other.status == this.status &&
          other.resolvedAt == this.resolvedAt &&
          other.snoozedUntil == this.snoozedUntil &&
          other.snoozeCount == this.snoozeCount &&
          other.progress == this.progress &&
          other.subtasksDone == this.subtasksDone &&
          other.rewardDiamonds == this.rewardDiamonds &&
          other.rewardXp == this.rewardXp &&
          other.rewardStats == this.rewardStats &&
          other.penaltyDiamonds == this.penaltyDiamonds &&
          other.refusePenaltyDiamonds == this.refusePenaltyDiamonds);
}

class QuestInstancesCompanion extends UpdateCompanion<QuestInstanceRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<String> questId;
  final Value<DateTime> day;
  final Value<DateTime?> startsAt;
  final Value<DateTime> deadlineAt;
  final Value<String> status;
  final Value<DateTime?> resolvedAt;
  final Value<DateTime?> snoozedUntil;
  final Value<int> snoozeCount;
  final Value<int> progress;
  final Value<String> subtasksDone;
  final Value<int> rewardDiamonds;
  final Value<int> rewardXp;
  final Value<String> rewardStats;
  final Value<int> penaltyDiamonds;
  final Value<int> refusePenaltyDiamonds;
  final Value<int> rowid;
  const QuestInstancesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.questId = const Value.absent(),
    this.day = const Value.absent(),
    this.startsAt = const Value.absent(),
    this.deadlineAt = const Value.absent(),
    this.status = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.snoozeCount = const Value.absent(),
    this.progress = const Value.absent(),
    this.subtasksDone = const Value.absent(),
    this.rewardDiamonds = const Value.absent(),
    this.rewardXp = const Value.absent(),
    this.rewardStats = const Value.absent(),
    this.penaltyDiamonds = const Value.absent(),
    this.refusePenaltyDiamonds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestInstancesCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required String questId,
    required DateTime day,
    this.startsAt = const Value.absent(),
    required DateTime deadlineAt,
    this.status = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.snoozedUntil = const Value.absent(),
    this.snoozeCount = const Value.absent(),
    this.progress = const Value.absent(),
    this.subtasksDone = const Value.absent(),
    this.rewardDiamonds = const Value.absent(),
    this.rewardXp = const Value.absent(),
    this.rewardStats = const Value.absent(),
    this.penaltyDiamonds = const Value.absent(),
    this.refusePenaltyDiamonds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       questId = Value(questId),
       day = Value(day),
       deadlineAt = Value(deadlineAt);
  static Insertable<QuestInstanceRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<String>? questId,
    Expression<DateTime>? day,
    Expression<DateTime>? startsAt,
    Expression<DateTime>? deadlineAt,
    Expression<String>? status,
    Expression<DateTime>? resolvedAt,
    Expression<DateTime>? snoozedUntil,
    Expression<int>? snoozeCount,
    Expression<int>? progress,
    Expression<String>? subtasksDone,
    Expression<int>? rewardDiamonds,
    Expression<int>? rewardXp,
    Expression<String>? rewardStats,
    Expression<int>? penaltyDiamonds,
    Expression<int>? refusePenaltyDiamonds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (questId != null) 'quest_id': questId,
      if (day != null) 'day': day,
      if (startsAt != null) 'starts_at': startsAt,
      if (deadlineAt != null) 'deadline_at': deadlineAt,
      if (status != null) 'status': status,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (snoozedUntil != null) 'snoozed_until': snoozedUntil,
      if (snoozeCount != null) 'snooze_count': snoozeCount,
      if (progress != null) 'progress': progress,
      if (subtasksDone != null) 'subtasks_done': subtasksDone,
      if (rewardDiamonds != null) 'reward_diamonds': rewardDiamonds,
      if (rewardXp != null) 'reward_xp': rewardXp,
      if (rewardStats != null) 'reward_stats': rewardStats,
      if (penaltyDiamonds != null) 'penalty_diamonds': penaltyDiamonds,
      if (refusePenaltyDiamonds != null)
        'refuse_penalty_diamonds': refusePenaltyDiamonds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestInstancesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<String>? questId,
    Value<DateTime>? day,
    Value<DateTime?>? startsAt,
    Value<DateTime>? deadlineAt,
    Value<String>? status,
    Value<DateTime?>? resolvedAt,
    Value<DateTime?>? snoozedUntil,
    Value<int>? snoozeCount,
    Value<int>? progress,
    Value<String>? subtasksDone,
    Value<int>? rewardDiamonds,
    Value<int>? rewardXp,
    Value<String>? rewardStats,
    Value<int>? penaltyDiamonds,
    Value<int>? refusePenaltyDiamonds,
    Value<int>? rowid,
  }) {
    return QuestInstancesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      questId: questId ?? this.questId,
      day: day ?? this.day,
      startsAt: startsAt ?? this.startsAt,
      deadlineAt: deadlineAt ?? this.deadlineAt,
      status: status ?? this.status,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      progress: progress ?? this.progress,
      subtasksDone: subtasksDone ?? this.subtasksDone,
      rewardDiamonds: rewardDiamonds ?? this.rewardDiamonds,
      rewardXp: rewardXp ?? this.rewardXp,
      rewardStats: rewardStats ?? this.rewardStats,
      penaltyDiamonds: penaltyDiamonds ?? this.penaltyDiamonds,
      refusePenaltyDiamonds:
          refusePenaltyDiamonds ?? this.refusePenaltyDiamonds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (questId.present) {
      map['quest_id'] = Variable<String>(questId.value);
    }
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (startsAt.present) {
      map['starts_at'] = Variable<DateTime>(startsAt.value);
    }
    if (deadlineAt.present) {
      map['deadline_at'] = Variable<DateTime>(deadlineAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (snoozedUntil.present) {
      map['snoozed_until'] = Variable<DateTime>(snoozedUntil.value);
    }
    if (snoozeCount.present) {
      map['snooze_count'] = Variable<int>(snoozeCount.value);
    }
    if (progress.present) {
      map['progress'] = Variable<int>(progress.value);
    }
    if (subtasksDone.present) {
      map['subtasks_done'] = Variable<String>(subtasksDone.value);
    }
    if (rewardDiamonds.present) {
      map['reward_diamonds'] = Variable<int>(rewardDiamonds.value);
    }
    if (rewardXp.present) {
      map['reward_xp'] = Variable<int>(rewardXp.value);
    }
    if (rewardStats.present) {
      map['reward_stats'] = Variable<String>(rewardStats.value);
    }
    if (penaltyDiamonds.present) {
      map['penalty_diamonds'] = Variable<int>(penaltyDiamonds.value);
    }
    if (refusePenaltyDiamonds.present) {
      map['refuse_penalty_diamonds'] = Variable<int>(
        refusePenaltyDiamonds.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestInstancesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('questId: $questId, ')
          ..write('day: $day, ')
          ..write('startsAt: $startsAt, ')
          ..write('deadlineAt: $deadlineAt, ')
          ..write('status: $status, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('snoozedUntil: $snoozedUntil, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('progress: $progress, ')
          ..write('subtasksDone: $subtasksDone, ')
          ..write('rewardDiamonds: $rewardDiamonds, ')
          ..write('rewardXp: $rewardXp, ')
          ..write('rewardStats: $rewardStats, ')
          ..write('penaltyDiamonds: $penaltyDiamonds, ')
          ..write('refusePenaltyDiamonds: $refusePenaltyDiamonds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestEventsTable extends QuestEvents
    with TableInfo<$QuestEventsTable, QuestEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questIdMeta = const VerificationMeta(
    'questId',
  );
  @override
  late final GeneratedColumn<String> questId = GeneratedColumn<String>(
    'quest_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _instanceIdMeta = const VerificationMeta(
    'instanceId',
  );
  @override
  late final GeneratedColumn<String> instanceId = GeneratedColumn<String>(
    'instance_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _diamondsMeta = const VerificationMeta(
    'diamonds',
  );
  @override
  late final GeneratedColumn<int> diamonds = GeneratedColumn<int>(
    'diamonds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statsMeta = const VerificationMeta('stats');
  @override
  late final GeneratedColumn<String> stats = GeneratedColumn<String>(
    'stats',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    type,
    occurredAt,
    questId,
    instanceId,
    diamonds,
    xp,
    stats,
    payload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quest_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('quest_id')) {
      context.handle(
        _questIdMeta,
        questId.isAcceptableOrUnknown(data['quest_id']!, _questIdMeta),
      );
    }
    if (data.containsKey('instance_id')) {
      context.handle(
        _instanceIdMeta,
        instanceId.isAcceptableOrUnknown(data['instance_id']!, _instanceIdMeta),
      );
    }
    if (data.containsKey('diamonds')) {
      context.handle(
        _diamondsMeta,
        diamonds.isAcceptableOrUnknown(data['diamonds']!, _diamondsMeta),
      );
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    }
    if (data.containsKey('stats')) {
      context.handle(
        _statsMeta,
        stats.isAcceptableOrUnknown(data['stats']!, _statsMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      questId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quest_id'],
      ),
      instanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_id'],
      ),
      diamonds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}diamonds'],
      )!,
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
      stats: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stats'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $QuestEventsTable createAlias(String alias) {
    return $QuestEventsTable(attachedDatabase, alias);
  }
}

class QuestEventRow extends DataClass implements Insertable<QuestEventRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final String type;
  final DateTime occurredAt;
  final String? questId;
  final String? instanceId;
  final int diamonds;
  final int xp;
  final String stats;
  final String payload;
  const QuestEventRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.type,
    required this.occurredAt,
    this.questId,
    this.instanceId,
    required this.diamonds,
    required this.xp,
    required this.stats,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['type'] = Variable<String>(type);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || questId != null) {
      map['quest_id'] = Variable<String>(questId);
    }
    if (!nullToAbsent || instanceId != null) {
      map['instance_id'] = Variable<String>(instanceId);
    }
    map['diamonds'] = Variable<int>(diamonds);
    map['xp'] = Variable<int>(xp);
    map['stats'] = Variable<String>(stats);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  QuestEventsCompanion toCompanion(bool nullToAbsent) {
    return QuestEventsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      type: Value(type),
      occurredAt: Value(occurredAt),
      questId: questId == null && nullToAbsent
          ? const Value.absent()
          : Value(questId),
      instanceId: instanceId == null && nullToAbsent
          ? const Value.absent()
          : Value(instanceId),
      diamonds: Value(diamonds),
      xp: Value(xp),
      stats: Value(stats),
      payload: Value(payload),
    );
  }

  factory QuestEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestEventRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      type: serializer.fromJson<String>(json['type']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      questId: serializer.fromJson<String?>(json['questId']),
      instanceId: serializer.fromJson<String?>(json['instanceId']),
      diamonds: serializer.fromJson<int>(json['diamonds']),
      xp: serializer.fromJson<int>(json['xp']),
      stats: serializer.fromJson<String>(json['stats']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'type': serializer.toJson<String>(type),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'questId': serializer.toJson<String?>(questId),
      'instanceId': serializer.toJson<String?>(instanceId),
      'diamonds': serializer.toJson<int>(diamonds),
      'xp': serializer.toJson<int>(xp),
      'stats': serializer.toJson<String>(stats),
      'payload': serializer.toJson<String>(payload),
    };
  }

  QuestEventRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    String? type,
    DateTime? occurredAt,
    Value<String?> questId = const Value.absent(),
    Value<String?> instanceId = const Value.absent(),
    int? diamonds,
    int? xp,
    String? stats,
    String? payload,
  }) => QuestEventRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    type: type ?? this.type,
    occurredAt: occurredAt ?? this.occurredAt,
    questId: questId.present ? questId.value : this.questId,
    instanceId: instanceId.present ? instanceId.value : this.instanceId,
    diamonds: diamonds ?? this.diamonds,
    xp: xp ?? this.xp,
    stats: stats ?? this.stats,
    payload: payload ?? this.payload,
  );
  QuestEventRow copyWithCompanion(QuestEventsCompanion data) {
    return QuestEventRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      type: data.type.present ? data.type.value : this.type,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      questId: data.questId.present ? data.questId.value : this.questId,
      instanceId: data.instanceId.present
          ? data.instanceId.value
          : this.instanceId,
      diamonds: data.diamonds.present ? data.diamonds.value : this.diamonds,
      xp: data.xp.present ? data.xp.value : this.xp,
      stats: data.stats.present ? data.stats.value : this.stats,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestEventRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('questId: $questId, ')
          ..write('instanceId: $instanceId, ')
          ..write('diamonds: $diamonds, ')
          ..write('xp: $xp, ')
          ..write('stats: $stats, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    type,
    occurredAt,
    questId,
    instanceId,
    diamonds,
    xp,
    stats,
    payload,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestEventRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.type == this.type &&
          other.occurredAt == this.occurredAt &&
          other.questId == this.questId &&
          other.instanceId == this.instanceId &&
          other.diamonds == this.diamonds &&
          other.xp == this.xp &&
          other.stats == this.stats &&
          other.payload == this.payload);
}

class QuestEventsCompanion extends UpdateCompanion<QuestEventRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<String> type;
  final Value<DateTime> occurredAt;
  final Value<String?> questId;
  final Value<String?> instanceId;
  final Value<int> diamonds;
  final Value<int> xp;
  final Value<String> stats;
  final Value<String> payload;
  final Value<int> rowid;
  const QuestEventsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.type = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.questId = const Value.absent(),
    this.instanceId = const Value.absent(),
    this.diamonds = const Value.absent(),
    this.xp = const Value.absent(),
    this.stats = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestEventsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required String type,
    required DateTime occurredAt,
    this.questId = const Value.absent(),
    this.instanceId = const Value.absent(),
    this.diamonds = const Value.absent(),
    this.xp = const Value.absent(),
    this.stats = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       type = Value(type),
       occurredAt = Value(occurredAt);
  static Insertable<QuestEventRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<String>? type,
    Expression<DateTime>? occurredAt,
    Expression<String>? questId,
    Expression<String>? instanceId,
    Expression<int>? diamonds,
    Expression<int>? xp,
    Expression<String>? stats,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (type != null) 'type': type,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (questId != null) 'quest_id': questId,
      if (instanceId != null) 'instance_id': instanceId,
      if (diamonds != null) 'diamonds': diamonds,
      if (xp != null) 'xp': xp,
      if (stats != null) 'stats': stats,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestEventsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<String>? type,
    Value<DateTime>? occurredAt,
    Value<String?>? questId,
    Value<String?>? instanceId,
    Value<int>? diamonds,
    Value<int>? xp,
    Value<String>? stats,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return QuestEventsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      type: type ?? this.type,
      occurredAt: occurredAt ?? this.occurredAt,
      questId: questId ?? this.questId,
      instanceId: instanceId ?? this.instanceId,
      diamonds: diamonds ?? this.diamonds,
      xp: xp ?? this.xp,
      stats: stats ?? this.stats,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (questId.present) {
      map['quest_id'] = Variable<String>(questId.value);
    }
    if (instanceId.present) {
      map['instance_id'] = Variable<String>(instanceId.value);
    }
    if (diamonds.present) {
      map['diamonds'] = Variable<int>(diamonds.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (stats.present) {
      map['stats'] = Variable<String>(stats.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestEventsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('type: $type, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('questId: $questId, ')
          ..write('instanceId: $instanceId, ')
          ..write('diamonds: $diamonds, ')
          ..write('xp: $xp, ')
          ..write('stats: $stats, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EffectsTable extends Effects with TableInfo<$EffectsTable, EffectRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EffectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startsAtMeta = const VerificationMeta(
    'startsAt',
  );
  @override
  late final GeneratedColumn<DateTime> startsAt = GeneratedColumn<DateTime>(
    'starts_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceEventIdMeta = const VerificationMeta(
    'sourceEventId',
  );
  @override
  late final GeneratedColumn<String> sourceEventId = GeneratedColumn<String>(
    'source_event_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    kind,
    startsAt,
    expiresAt,
    sourceEventId,
    payload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'effects';
  @override
  VerificationContext validateIntegrity(
    Insertable<EffectRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('starts_at')) {
      context.handle(
        _startsAtMeta,
        startsAt.isAcceptableOrUnknown(data['starts_at']!, _startsAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startsAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('source_event_id')) {
      context.handle(
        _sourceEventIdMeta,
        sourceEventId.isAcceptableOrUnknown(
          data['source_event_id']!,
          _sourceEventIdMeta,
        ),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EffectRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EffectRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      startsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starts_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
      sourceEventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_event_id'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $EffectsTable createAlias(String alias) {
    return $EffectsTable(attachedDatabase, alias);
  }
}

class EffectRow extends DataClass implements Insertable<EffectRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final String kind;
  final DateTime startsAt;
  final DateTime expiresAt;
  final String? sourceEventId;
  final String payload;
  const EffectRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.kind,
    required this.startsAt,
    required this.expiresAt,
    this.sourceEventId,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['kind'] = Variable<String>(kind);
    map['starts_at'] = Variable<DateTime>(startsAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    if (!nullToAbsent || sourceEventId != null) {
      map['source_event_id'] = Variable<String>(sourceEventId);
    }
    map['payload'] = Variable<String>(payload);
    return map;
  }

  EffectsCompanion toCompanion(bool nullToAbsent) {
    return EffectsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      kind: Value(kind),
      startsAt: Value(startsAt),
      expiresAt: Value(expiresAt),
      sourceEventId: sourceEventId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceEventId),
      payload: Value(payload),
    );
  }

  factory EffectRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EffectRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      kind: serializer.fromJson<String>(json['kind']),
      startsAt: serializer.fromJson<DateTime>(json['startsAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      sourceEventId: serializer.fromJson<String?>(json['sourceEventId']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'kind': serializer.toJson<String>(kind),
      'startsAt': serializer.toJson<DateTime>(startsAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'sourceEventId': serializer.toJson<String?>(sourceEventId),
      'payload': serializer.toJson<String>(payload),
    };
  }

  EffectRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    String? kind,
    DateTime? startsAt,
    DateTime? expiresAt,
    Value<String?> sourceEventId = const Value.absent(),
    String? payload,
  }) => EffectRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    kind: kind ?? this.kind,
    startsAt: startsAt ?? this.startsAt,
    expiresAt: expiresAt ?? this.expiresAt,
    sourceEventId: sourceEventId.present
        ? sourceEventId.value
        : this.sourceEventId,
    payload: payload ?? this.payload,
  );
  EffectRow copyWithCompanion(EffectsCompanion data) {
    return EffectRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      kind: data.kind.present ? data.kind.value : this.kind,
      startsAt: data.startsAt.present ? data.startsAt.value : this.startsAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      sourceEventId: data.sourceEventId.present
          ? data.sourceEventId.value
          : this.sourceEventId,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EffectRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('kind: $kind, ')
          ..write('startsAt: $startsAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('sourceEventId: $sourceEventId, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    kind,
    startsAt,
    expiresAt,
    sourceEventId,
    payload,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EffectRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.kind == this.kind &&
          other.startsAt == this.startsAt &&
          other.expiresAt == this.expiresAt &&
          other.sourceEventId == this.sourceEventId &&
          other.payload == this.payload);
}

class EffectsCompanion extends UpdateCompanion<EffectRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<String> kind;
  final Value<DateTime> startsAt;
  final Value<DateTime> expiresAt;
  final Value<String?> sourceEventId;
  final Value<String> payload;
  final Value<int> rowid;
  const EffectsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.kind = const Value.absent(),
    this.startsAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.sourceEventId = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EffectsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required String kind,
    required DateTime startsAt,
    required DateTime expiresAt,
    this.sourceEventId = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       kind = Value(kind),
       startsAt = Value(startsAt),
       expiresAt = Value(expiresAt);
  static Insertable<EffectRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<String>? kind,
    Expression<DateTime>? startsAt,
    Expression<DateTime>? expiresAt,
    Expression<String>? sourceEventId,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (kind != null) 'kind': kind,
      if (startsAt != null) 'starts_at': startsAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (sourceEventId != null) 'source_event_id': sourceEventId,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EffectsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<String>? kind,
    Value<DateTime>? startsAt,
    Value<DateTime>? expiresAt,
    Value<String?>? sourceEventId,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return EffectsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      kind: kind ?? this.kind,
      startsAt: startsAt ?? this.startsAt,
      expiresAt: expiresAt ?? this.expiresAt,
      sourceEventId: sourceEventId ?? this.sourceEventId,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (startsAt.present) {
      map['starts_at'] = Variable<DateTime>(startsAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (sourceEventId.present) {
      map['source_event_id'] = Variable<String>(sourceEventId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EffectsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('kind: $kind, ')
          ..write('startsAt: $startsAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('sourceEventId: $sourceEventId, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PausesTable extends Pauses with TableInfo<$PausesTable, PauseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PausesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startsAtMeta = const VerificationMeta(
    'startsAt',
  );
  @override
  late final GeneratedColumn<DateTime> startsAt = GeneratedColumn<DateTime>(
    'starts_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsAtMeta = const VerificationMeta('endsAt');
  @override
  late final GeneratedColumn<DateTime> endsAt = GeneratedColumn<DateTime>(
    'ends_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    reason,
    startsAt,
    endsAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pauses';
  @override
  VerificationContext validateIntegrity(
    Insertable<PauseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('starts_at')) {
      context.handle(
        _startsAtMeta,
        startsAt.isAcceptableOrUnknown(data['starts_at']!, _startsAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startsAtMeta);
    }
    if (data.containsKey('ends_at')) {
      context.handle(
        _endsAtMeta,
        endsAt.isAcceptableOrUnknown(data['ends_at']!, _endsAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PauseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PauseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      startsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starts_at'],
      )!,
      endsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ends_at'],
      ),
    );
  }

  @override
  $PausesTable createAlias(String alias) {
    return $PausesTable(attachedDatabase, alias);
  }
}

class PauseRow extends DataClass implements Insertable<PauseRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final String reason;
  final DateTime startsAt;
  final DateTime? endsAt;
  const PauseRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.reason,
    required this.startsAt,
    this.endsAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['reason'] = Variable<String>(reason);
    map['starts_at'] = Variable<DateTime>(startsAt);
    if (!nullToAbsent || endsAt != null) {
      map['ends_at'] = Variable<DateTime>(endsAt);
    }
    return map;
  }

  PausesCompanion toCompanion(bool nullToAbsent) {
    return PausesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      reason: Value(reason),
      startsAt: Value(startsAt),
      endsAt: endsAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endsAt),
    );
  }

  factory PauseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PauseRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      reason: serializer.fromJson<String>(json['reason']),
      startsAt: serializer.fromJson<DateTime>(json['startsAt']),
      endsAt: serializer.fromJson<DateTime?>(json['endsAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'reason': serializer.toJson<String>(reason),
      'startsAt': serializer.toJson<DateTime>(startsAt),
      'endsAt': serializer.toJson<DateTime?>(endsAt),
    };
  }

  PauseRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    String? reason,
    DateTime? startsAt,
    Value<DateTime?> endsAt = const Value.absent(),
  }) => PauseRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    reason: reason ?? this.reason,
    startsAt: startsAt ?? this.startsAt,
    endsAt: endsAt.present ? endsAt.value : this.endsAt,
  );
  PauseRow copyWithCompanion(PausesCompanion data) {
    return PauseRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      reason: data.reason.present ? data.reason.value : this.reason,
      startsAt: data.startsAt.present ? data.startsAt.value : this.startsAt,
      endsAt: data.endsAt.present ? data.endsAt.value : this.endsAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PauseRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('reason: $reason, ')
          ..write('startsAt: $startsAt, ')
          ..write('endsAt: $endsAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    reason,
    startsAt,
    endsAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PauseRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.reason == this.reason &&
          other.startsAt == this.startsAt &&
          other.endsAt == this.endsAt);
}

class PausesCompanion extends UpdateCompanion<PauseRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<String> reason;
  final Value<DateTime> startsAt;
  final Value<DateTime?> endsAt;
  final Value<int> rowid;
  const PausesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.reason = const Value.absent(),
    this.startsAt = const Value.absent(),
    this.endsAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PausesCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required String reason,
    required DateTime startsAt,
    this.endsAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       reason = Value(reason),
       startsAt = Value(startsAt);
  static Insertable<PauseRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<String>? reason,
    Expression<DateTime>? startsAt,
    Expression<DateTime>? endsAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (reason != null) 'reason': reason,
      if (startsAt != null) 'starts_at': startsAt,
      if (endsAt != null) 'ends_at': endsAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PausesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<String>? reason,
    Value<DateTime>? startsAt,
    Value<DateTime?>? endsAt,
    Value<int>? rowid,
  }) {
    return PausesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      reason: reason ?? this.reason,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (startsAt.present) {
      map['starts_at'] = Variable<DateTime>(startsAt.value);
    }
    if (endsAt.present) {
      map['ends_at'] = Variable<DateTime>(endsAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PausesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('reason: $reason, ')
          ..write('startsAt: $startsAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RewardsTable extends Rewards with TableInfo<$RewardsTable, RewardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RewardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<int> price = GeneratedColumn<int>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitCountMeta = const VerificationMeta(
    'limitCount',
  );
  @override
  late final GeneratedColumn<int> limitCount = GeneratedColumn<int>(
    'limit_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _limitPeriodMeta = const VerificationMeta(
    'limitPeriod',
  );
  @override
  late final GeneratedColumn<String> limitPeriod = GeneratedColumn<String>(
    'limit_period',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    title,
    price,
    limitCount,
    limitPeriod,
    active,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rewards';
  @override
  VerificationContext validateIntegrity(
    Insertable<RewardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('limit_count')) {
      context.handle(
        _limitCountMeta,
        limitCount.isAcceptableOrUnknown(data['limit_count']!, _limitCountMeta),
      );
    }
    if (data.containsKey('limit_period')) {
      context.handle(
        _limitPeriodMeta,
        limitPeriod.isAcceptableOrUnknown(
          data['limit_period']!,
          _limitPeriodMeta,
        ),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RewardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RewardRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price'],
      )!,
      limitCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limit_count'],
      ),
      limitPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}limit_period'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $RewardsTable createAlias(String alias) {
    return $RewardsTable(attachedDatabase, alias);
  }
}

class RewardRow extends DataClass implements Insertable<RewardRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final String title;
  final int price;
  final int? limitCount;
  final String? limitPeriod;
  final bool active;
  final int sortOrder;
  const RewardRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.title,
    required this.price,
    this.limitCount,
    this.limitPeriod,
    required this.active,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['title'] = Variable<String>(title);
    map['price'] = Variable<int>(price);
    if (!nullToAbsent || limitCount != null) {
      map['limit_count'] = Variable<int>(limitCount);
    }
    if (!nullToAbsent || limitPeriod != null) {
      map['limit_period'] = Variable<String>(limitPeriod);
    }
    map['active'] = Variable<bool>(active);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  RewardsCompanion toCompanion(bool nullToAbsent) {
    return RewardsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      title: Value(title),
      price: Value(price),
      limitCount: limitCount == null && nullToAbsent
          ? const Value.absent()
          : Value(limitCount),
      limitPeriod: limitPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(limitPeriod),
      active: Value(active),
      sortOrder: Value(sortOrder),
    );
  }

  factory RewardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RewardRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      title: serializer.fromJson<String>(json['title']),
      price: serializer.fromJson<int>(json['price']),
      limitCount: serializer.fromJson<int?>(json['limitCount']),
      limitPeriod: serializer.fromJson<String?>(json['limitPeriod']),
      active: serializer.fromJson<bool>(json['active']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'title': serializer.toJson<String>(title),
      'price': serializer.toJson<int>(price),
      'limitCount': serializer.toJson<int?>(limitCount),
      'limitPeriod': serializer.toJson<String?>(limitPeriod),
      'active': serializer.toJson<bool>(active),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  RewardRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    String? title,
    int? price,
    Value<int?> limitCount = const Value.absent(),
    Value<String?> limitPeriod = const Value.absent(),
    bool? active,
    int? sortOrder,
  }) => RewardRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    title: title ?? this.title,
    price: price ?? this.price,
    limitCount: limitCount.present ? limitCount.value : this.limitCount,
    limitPeriod: limitPeriod.present ? limitPeriod.value : this.limitPeriod,
    active: active ?? this.active,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  RewardRow copyWithCompanion(RewardsCompanion data) {
    return RewardRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      title: data.title.present ? data.title.value : this.title,
      price: data.price.present ? data.price.value : this.price,
      limitCount: data.limitCount.present
          ? data.limitCount.value
          : this.limitCount,
      limitPeriod: data.limitPeriod.present
          ? data.limitPeriod.value
          : this.limitPeriod,
      active: data.active.present ? data.active.value : this.active,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RewardRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('title: $title, ')
          ..write('price: $price, ')
          ..write('limitCount: $limitCount, ')
          ..write('limitPeriod: $limitPeriod, ')
          ..write('active: $active, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    title,
    price,
    limitCount,
    limitPeriod,
    active,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RewardRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.title == this.title &&
          other.price == this.price &&
          other.limitCount == this.limitCount &&
          other.limitPeriod == this.limitPeriod &&
          other.active == this.active &&
          other.sortOrder == this.sortOrder);
}

class RewardsCompanion extends UpdateCompanion<RewardRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<String> title;
  final Value<int> price;
  final Value<int?> limitCount;
  final Value<String?> limitPeriod;
  final Value<bool> active;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const RewardsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.title = const Value.absent(),
    this.price = const Value.absent(),
    this.limitCount = const Value.absent(),
    this.limitPeriod = const Value.absent(),
    this.active = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RewardsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required String title,
    required int price,
    this.limitCount = const Value.absent(),
    this.limitPeriod = const Value.absent(),
    this.active = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       title = Value(title),
       price = Value(price);
  static Insertable<RewardRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<String>? title,
    Expression<int>? price,
    Expression<int>? limitCount,
    Expression<String>? limitPeriod,
    Expression<bool>? active,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (title != null) 'title': title,
      if (price != null) 'price': price,
      if (limitCount != null) 'limit_count': limitCount,
      if (limitPeriod != null) 'limit_period': limitPeriod,
      if (active != null) 'active': active,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RewardsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<String>? title,
    Value<int>? price,
    Value<int?>? limitCount,
    Value<String?>? limitPeriod,
    Value<bool>? active,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return RewardsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      title: title ?? this.title,
      price: price ?? this.price,
      limitCount: limitCount ?? this.limitCount,
      limitPeriod: limitPeriod ?? this.limitPeriod,
      active: active ?? this.active,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    if (limitCount.present) {
      map['limit_count'] = Variable<int>(limitCount.value);
    }
    if (limitPeriod.present) {
      map['limit_period'] = Variable<String>(limitPeriod.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RewardsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('title: $title, ')
          ..write('price: $price, ')
          ..write('limitCount: $limitCount, ')
          ..write('limitPeriod: $limitPeriod, ')
          ..write('active: $active, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    value,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSettingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSettingRow extends DataClass implements Insertable<UserSettingRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final String value;
  const UserSettingRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['value'] = Variable<String>(value);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      value: Value(value),
    );
  }

  factory UserSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSettingRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'value': serializer.toJson<String>(value),
    };
  }

  UserSettingRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    String? value,
  }) => UserSettingRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    value: value ?? this.value,
  );
  UserSettingRow copyWithCompanion(UserSettingsCompanion data) {
    return UserSettingRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, deletedAt, deviceId, version, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSettingRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.value == this.value);
}

class UserSettingsCompanion extends UpdateCompanion<UserSettingRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<String> value;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required String value,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       value = Value(value);
  static Insertable<UserSettingRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserSettingsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return UserSettingsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSettingsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoodItemsTable extends FoodItems
    with TableInfo<$FoodItemsTable, FoodItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kcal100Meta = const VerificationMeta(
    'kcal100',
  );
  @override
  late final GeneratedColumn<double> kcal100 = GeneratedColumn<double>(
    'kcal100',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _protein100Meta = const VerificationMeta(
    'protein100',
  );
  @override
  late final GeneratedColumn<double> protein100 = GeneratedColumn<double>(
    'protein100',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fat100Meta = const VerificationMeta('fat100');
  @override
  late final GeneratedColumn<double> fat100 = GeneratedColumn<double>(
    'fat100',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _carbs100Meta = const VerificationMeta(
    'carbs100',
  );
  @override
  late final GeneratedColumn<double> carbs100 = GeneratedColumn<double>(
    'carbs100',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _servingGMeta = const VerificationMeta(
    'servingG',
  );
  @override
  late final GeneratedColumn<double> servingG = GeneratedColumn<double>(
    'serving_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    name,
    brand,
    barcode,
    kcal100,
    protein100,
    fat100,
    carbs100,
    servingG,
    source,
    favorite,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'food_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<FoodItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('kcal100')) {
      context.handle(
        _kcal100Meta,
        kcal100.isAcceptableOrUnknown(data['kcal100']!, _kcal100Meta),
      );
    } else if (isInserting) {
      context.missing(_kcal100Meta);
    }
    if (data.containsKey('protein100')) {
      context.handle(
        _protein100Meta,
        protein100.isAcceptableOrUnknown(data['protein100']!, _protein100Meta),
      );
    }
    if (data.containsKey('fat100')) {
      context.handle(
        _fat100Meta,
        fat100.isAcceptableOrUnknown(data['fat100']!, _fat100Meta),
      );
    }
    if (data.containsKey('carbs100')) {
      context.handle(
        _carbs100Meta,
        carbs100.isAcceptableOrUnknown(data['carbs100']!, _carbs100Meta),
      );
    }
    if (data.containsKey('serving_g')) {
      context.handle(
        _servingGMeta,
        servingG.isAcceptableOrUnknown(data['serving_g']!, _servingGMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FoodItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FoodItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      kcal100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal100'],
      )!,
      protein100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein100'],
      )!,
      fat100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat100'],
      )!,
      carbs100: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs100'],
      )!,
      servingG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}serving_g'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
    );
  }

  @override
  $FoodItemsTable createAlias(String alias) {
    return $FoodItemsTable(attachedDatabase, alias);
  }
}

class FoodItemRow extends DataClass implements Insertable<FoodItemRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final String name;
  final String? brand;
  final String? barcode;
  final double kcal100;
  final double protein100;
  final double fat100;
  final double carbs100;
  final double? servingG;
  final String source;
  final bool favorite;
  const FoodItemRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.name,
    this.brand,
    this.barcode,
    required this.kcal100,
    required this.protein100,
    required this.fat100,
    required this.carbs100,
    this.servingG,
    required this.source,
    required this.favorite,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['kcal100'] = Variable<double>(kcal100);
    map['protein100'] = Variable<double>(protein100);
    map['fat100'] = Variable<double>(fat100);
    map['carbs100'] = Variable<double>(carbs100);
    if (!nullToAbsent || servingG != null) {
      map['serving_g'] = Variable<double>(servingG);
    }
    map['source'] = Variable<String>(source);
    map['favorite'] = Variable<bool>(favorite);
    return map;
  }

  FoodItemsCompanion toCompanion(bool nullToAbsent) {
    return FoodItemsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      kcal100: Value(kcal100),
      protein100: Value(protein100),
      fat100: Value(fat100),
      carbs100: Value(carbs100),
      servingG: servingG == null && nullToAbsent
          ? const Value.absent()
          : Value(servingG),
      source: Value(source),
      favorite: Value(favorite),
    );
  }

  factory FoodItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FoodItemRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      kcal100: serializer.fromJson<double>(json['kcal100']),
      protein100: serializer.fromJson<double>(json['protein100']),
      fat100: serializer.fromJson<double>(json['fat100']),
      carbs100: serializer.fromJson<double>(json['carbs100']),
      servingG: serializer.fromJson<double?>(json['servingG']),
      source: serializer.fromJson<String>(json['source']),
      favorite: serializer.fromJson<bool>(json['favorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'barcode': serializer.toJson<String?>(barcode),
      'kcal100': serializer.toJson<double>(kcal100),
      'protein100': serializer.toJson<double>(protein100),
      'fat100': serializer.toJson<double>(fat100),
      'carbs100': serializer.toJson<double>(carbs100),
      'servingG': serializer.toJson<double?>(servingG),
      'source': serializer.toJson<String>(source),
      'favorite': serializer.toJson<bool>(favorite),
    };
  }

  FoodItemRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    String? name,
    Value<String?> brand = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    double? kcal100,
    double? protein100,
    double? fat100,
    double? carbs100,
    Value<double?> servingG = const Value.absent(),
    String? source,
    bool? favorite,
  }) => FoodItemRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    barcode: barcode.present ? barcode.value : this.barcode,
    kcal100: kcal100 ?? this.kcal100,
    protein100: protein100 ?? this.protein100,
    fat100: fat100 ?? this.fat100,
    carbs100: carbs100 ?? this.carbs100,
    servingG: servingG.present ? servingG.value : this.servingG,
    source: source ?? this.source,
    favorite: favorite ?? this.favorite,
  );
  FoodItemRow copyWithCompanion(FoodItemsCompanion data) {
    return FoodItemRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      kcal100: data.kcal100.present ? data.kcal100.value : this.kcal100,
      protein100: data.protein100.present
          ? data.protein100.value
          : this.protein100,
      fat100: data.fat100.present ? data.fat100.value : this.fat100,
      carbs100: data.carbs100.present ? data.carbs100.value : this.carbs100,
      servingG: data.servingG.present ? data.servingG.value : this.servingG,
      source: data.source.present ? data.source.value : this.source,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FoodItemRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('barcode: $barcode, ')
          ..write('kcal100: $kcal100, ')
          ..write('protein100: $protein100, ')
          ..write('fat100: $fat100, ')
          ..write('carbs100: $carbs100, ')
          ..write('servingG: $servingG, ')
          ..write('source: $source, ')
          ..write('favorite: $favorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    name,
    brand,
    barcode,
    kcal100,
    protein100,
    fat100,
    carbs100,
    servingG,
    source,
    favorite,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FoodItemRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.barcode == this.barcode &&
          other.kcal100 == this.kcal100 &&
          other.protein100 == this.protein100 &&
          other.fat100 == this.fat100 &&
          other.carbs100 == this.carbs100 &&
          other.servingG == this.servingG &&
          other.source == this.source &&
          other.favorite == this.favorite);
}

class FoodItemsCompanion extends UpdateCompanion<FoodItemRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String?> barcode;
  final Value<double> kcal100;
  final Value<double> protein100;
  final Value<double> fat100;
  final Value<double> carbs100;
  final Value<double?> servingG;
  final Value<String> source;
  final Value<bool> favorite;
  final Value<int> rowid;
  const FoodItemsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.barcode = const Value.absent(),
    this.kcal100 = const Value.absent(),
    this.protein100 = const Value.absent(),
    this.fat100 = const Value.absent(),
    this.carbs100 = const Value.absent(),
    this.servingG = const Value.absent(),
    this.source = const Value.absent(),
    this.favorite = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoodItemsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    this.barcode = const Value.absent(),
    required double kcal100,
    this.protein100 = const Value.absent(),
    this.fat100 = const Value.absent(),
    this.carbs100 = const Value.absent(),
    this.servingG = const Value.absent(),
    this.source = const Value.absent(),
    this.favorite = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       name = Value(name),
       kcal100 = Value(kcal100);
  static Insertable<FoodItemRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? barcode,
    Expression<double>? kcal100,
    Expression<double>? protein100,
    Expression<double>? fat100,
    Expression<double>? carbs100,
    Expression<double>? servingG,
    Expression<String>? source,
    Expression<bool>? favorite,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (barcode != null) 'barcode': barcode,
      if (kcal100 != null) 'kcal100': kcal100,
      if (protein100 != null) 'protein100': protein100,
      if (fat100 != null) 'fat100': fat100,
      if (carbs100 != null) 'carbs100': carbs100,
      if (servingG != null) 'serving_g': servingG,
      if (source != null) 'source': source,
      if (favorite != null) 'favorite': favorite,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoodItemsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<String>? name,
    Value<String?>? brand,
    Value<String?>? barcode,
    Value<double>? kcal100,
    Value<double>? protein100,
    Value<double>? fat100,
    Value<double>? carbs100,
    Value<double?>? servingG,
    Value<String>? source,
    Value<bool>? favorite,
    Value<int>? rowid,
  }) {
    return FoodItemsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      kcal100: kcal100 ?? this.kcal100,
      protein100: protein100 ?? this.protein100,
      fat100: fat100 ?? this.fat100,
      carbs100: carbs100 ?? this.carbs100,
      servingG: servingG ?? this.servingG,
      source: source ?? this.source,
      favorite: favorite ?? this.favorite,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (kcal100.present) {
      map['kcal100'] = Variable<double>(kcal100.value);
    }
    if (protein100.present) {
      map['protein100'] = Variable<double>(protein100.value);
    }
    if (fat100.present) {
      map['fat100'] = Variable<double>(fat100.value);
    }
    if (carbs100.present) {
      map['carbs100'] = Variable<double>(carbs100.value);
    }
    if (servingG.present) {
      map['serving_g'] = Variable<double>(servingG.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodItemsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('barcode: $barcode, ')
          ..write('kcal100: $kcal100, ')
          ..write('protein100: $protein100, ')
          ..write('fat100: $fat100, ')
          ..write('carbs100: $carbs100, ')
          ..write('servingG: $servingG, ')
          ..write('source: $source, ')
          ..write('favorite: $favorite, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealEntriesTable extends MealEntries
    with TableInfo<$MealEntriesTable, MealEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _eatenAtMeta = const VerificationMeta(
    'eatenAt',
  );
  @override
  late final GeneratedColumn<DateTime> eatenAt = GeneratedColumn<DateTime>(
    'eaten_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealTypeMeta = const VerificationMeta(
    'mealType',
  );
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
    'meal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodItemIdMeta = const VerificationMeta(
    'foodItemId',
  );
  @override
  late final GeneratedColumn<String> foodItemId = GeneratedColumn<String>(
    'food_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
    'carbs',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _photoIdMeta = const VerificationMeta(
    'photoId',
  );
  @override
  late final GeneratedColumn<String> photoId = GeneratedColumn<String>(
    'photo_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    eatenAt,
    mealType,
    title,
    foodItemId,
    recipeId,
    grams,
    kcal,
    protein,
    fat,
    carbs,
    photoId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('eaten_at')) {
      context.handle(
        _eatenAtMeta,
        eatenAt.isAcceptableOrUnknown(data['eaten_at']!, _eatenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_eatenAtMeta);
    }
    if (data.containsKey('meal_type')) {
      context.handle(
        _mealTypeMeta,
        mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('food_item_id')) {
      context.handle(
        _foodItemIdMeta,
        foodItemId.isAcceptableOrUnknown(
          data['food_item_id']!,
          _foodItemIdMeta,
        ),
      );
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    }
    if (data.containsKey('grams')) {
      context.handle(
        _gramsMeta,
        grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta),
      );
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    } else if (isInserting) {
      context.missing(_kcalMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    }
    if (data.containsKey('photo_id')) {
      context.handle(
        _photoIdMeta,
        photoId.isAcceptableOrUnknown(data['photo_id']!, _photoIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      eatenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}eaten_at'],
      )!,
      mealType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      foodItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_item_id'],
      ),
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      ),
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      ),
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      )!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      )!,
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat'],
      )!,
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs'],
      )!,
      photoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_id'],
      ),
    );
  }

  @override
  $MealEntriesTable createAlias(String alias) {
    return $MealEntriesTable(attachedDatabase, alias);
  }
}

class MealEntryRow extends DataClass implements Insertable<MealEntryRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final DateTime eatenAt;
  final String mealType;
  final String title;
  final String? foodItemId;
  final String? recipeId;
  final double? grams;
  final double kcal;
  final double protein;
  final double fat;
  final double carbs;
  final String? photoId;
  const MealEntryRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.eatenAt,
    required this.mealType,
    required this.title,
    this.foodItemId,
    this.recipeId,
    this.grams,
    required this.kcal,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.photoId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['eaten_at'] = Variable<DateTime>(eatenAt);
    map['meal_type'] = Variable<String>(mealType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || foodItemId != null) {
      map['food_item_id'] = Variable<String>(foodItemId);
    }
    if (!nullToAbsent || recipeId != null) {
      map['recipe_id'] = Variable<String>(recipeId);
    }
    if (!nullToAbsent || grams != null) {
      map['grams'] = Variable<double>(grams);
    }
    map['kcal'] = Variable<double>(kcal);
    map['protein'] = Variable<double>(protein);
    map['fat'] = Variable<double>(fat);
    map['carbs'] = Variable<double>(carbs);
    if (!nullToAbsent || photoId != null) {
      map['photo_id'] = Variable<String>(photoId);
    }
    return map;
  }

  MealEntriesCompanion toCompanion(bool nullToAbsent) {
    return MealEntriesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      eatenAt: Value(eatenAt),
      mealType: Value(mealType),
      title: Value(title),
      foodItemId: foodItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(foodItemId),
      recipeId: recipeId == null && nullToAbsent
          ? const Value.absent()
          : Value(recipeId),
      grams: grams == null && nullToAbsent
          ? const Value.absent()
          : Value(grams),
      kcal: Value(kcal),
      protein: Value(protein),
      fat: Value(fat),
      carbs: Value(carbs),
      photoId: photoId == null && nullToAbsent
          ? const Value.absent()
          : Value(photoId),
    );
  }

  factory MealEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealEntryRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      eatenAt: serializer.fromJson<DateTime>(json['eatenAt']),
      mealType: serializer.fromJson<String>(json['mealType']),
      title: serializer.fromJson<String>(json['title']),
      foodItemId: serializer.fromJson<String?>(json['foodItemId']),
      recipeId: serializer.fromJson<String?>(json['recipeId']),
      grams: serializer.fromJson<double?>(json['grams']),
      kcal: serializer.fromJson<double>(json['kcal']),
      protein: serializer.fromJson<double>(json['protein']),
      fat: serializer.fromJson<double>(json['fat']),
      carbs: serializer.fromJson<double>(json['carbs']),
      photoId: serializer.fromJson<String?>(json['photoId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'eatenAt': serializer.toJson<DateTime>(eatenAt),
      'mealType': serializer.toJson<String>(mealType),
      'title': serializer.toJson<String>(title),
      'foodItemId': serializer.toJson<String?>(foodItemId),
      'recipeId': serializer.toJson<String?>(recipeId),
      'grams': serializer.toJson<double?>(grams),
      'kcal': serializer.toJson<double>(kcal),
      'protein': serializer.toJson<double>(protein),
      'fat': serializer.toJson<double>(fat),
      'carbs': serializer.toJson<double>(carbs),
      'photoId': serializer.toJson<String?>(photoId),
    };
  }

  MealEntryRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    DateTime? eatenAt,
    String? mealType,
    String? title,
    Value<String?> foodItemId = const Value.absent(),
    Value<String?> recipeId = const Value.absent(),
    Value<double?> grams = const Value.absent(),
    double? kcal,
    double? protein,
    double? fat,
    double? carbs,
    Value<String?> photoId = const Value.absent(),
  }) => MealEntryRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    eatenAt: eatenAt ?? this.eatenAt,
    mealType: mealType ?? this.mealType,
    title: title ?? this.title,
    foodItemId: foodItemId.present ? foodItemId.value : this.foodItemId,
    recipeId: recipeId.present ? recipeId.value : this.recipeId,
    grams: grams.present ? grams.value : this.grams,
    kcal: kcal ?? this.kcal,
    protein: protein ?? this.protein,
    fat: fat ?? this.fat,
    carbs: carbs ?? this.carbs,
    photoId: photoId.present ? photoId.value : this.photoId,
  );
  MealEntryRow copyWithCompanion(MealEntriesCompanion data) {
    return MealEntryRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      eatenAt: data.eatenAt.present ? data.eatenAt.value : this.eatenAt,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      title: data.title.present ? data.title.value : this.title,
      foodItemId: data.foodItemId.present
          ? data.foodItemId.value
          : this.foodItemId,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      grams: data.grams.present ? data.grams.value : this.grams,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      protein: data.protein.present ? data.protein.value : this.protein,
      fat: data.fat.present ? data.fat.value : this.fat,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      photoId: data.photoId.present ? data.photoId.value : this.photoId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealEntryRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('eatenAt: $eatenAt, ')
          ..write('mealType: $mealType, ')
          ..write('title: $title, ')
          ..write('foodItemId: $foodItemId, ')
          ..write('recipeId: $recipeId, ')
          ..write('grams: $grams, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('fat: $fat, ')
          ..write('carbs: $carbs, ')
          ..write('photoId: $photoId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    eatenAt,
    mealType,
    title,
    foodItemId,
    recipeId,
    grams,
    kcal,
    protein,
    fat,
    carbs,
    photoId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealEntryRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.eatenAt == this.eatenAt &&
          other.mealType == this.mealType &&
          other.title == this.title &&
          other.foodItemId == this.foodItemId &&
          other.recipeId == this.recipeId &&
          other.grams == this.grams &&
          other.kcal == this.kcal &&
          other.protein == this.protein &&
          other.fat == this.fat &&
          other.carbs == this.carbs &&
          other.photoId == this.photoId);
}

class MealEntriesCompanion extends UpdateCompanion<MealEntryRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<DateTime> eatenAt;
  final Value<String> mealType;
  final Value<String> title;
  final Value<String?> foodItemId;
  final Value<String?> recipeId;
  final Value<double?> grams;
  final Value<double> kcal;
  final Value<double> protein;
  final Value<double> fat;
  final Value<double> carbs;
  final Value<String?> photoId;
  final Value<int> rowid;
  const MealEntriesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.eatenAt = const Value.absent(),
    this.mealType = const Value.absent(),
    this.title = const Value.absent(),
    this.foodItemId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.grams = const Value.absent(),
    this.kcal = const Value.absent(),
    this.protein = const Value.absent(),
    this.fat = const Value.absent(),
    this.carbs = const Value.absent(),
    this.photoId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealEntriesCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required DateTime eatenAt,
    required String mealType,
    required String title,
    this.foodItemId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.grams = const Value.absent(),
    required double kcal,
    this.protein = const Value.absent(),
    this.fat = const Value.absent(),
    this.carbs = const Value.absent(),
    this.photoId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       eatenAt = Value(eatenAt),
       mealType = Value(mealType),
       title = Value(title),
       kcal = Value(kcal);
  static Insertable<MealEntryRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<DateTime>? eatenAt,
    Expression<String>? mealType,
    Expression<String>? title,
    Expression<String>? foodItemId,
    Expression<String>? recipeId,
    Expression<double>? grams,
    Expression<double>? kcal,
    Expression<double>? protein,
    Expression<double>? fat,
    Expression<double>? carbs,
    Expression<String>? photoId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (eatenAt != null) 'eaten_at': eatenAt,
      if (mealType != null) 'meal_type': mealType,
      if (title != null) 'title': title,
      if (foodItemId != null) 'food_item_id': foodItemId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (grams != null) 'grams': grams,
      if (kcal != null) 'kcal': kcal,
      if (protein != null) 'protein': protein,
      if (fat != null) 'fat': fat,
      if (carbs != null) 'carbs': carbs,
      if (photoId != null) 'photo_id': photoId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealEntriesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<DateTime>? eatenAt,
    Value<String>? mealType,
    Value<String>? title,
    Value<String?>? foodItemId,
    Value<String?>? recipeId,
    Value<double?>? grams,
    Value<double>? kcal,
    Value<double>? protein,
    Value<double>? fat,
    Value<double>? carbs,
    Value<String?>? photoId,
    Value<int>? rowid,
  }) {
    return MealEntriesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      eatenAt: eatenAt ?? this.eatenAt,
      mealType: mealType ?? this.mealType,
      title: title ?? this.title,
      foodItemId: foodItemId ?? this.foodItemId,
      recipeId: recipeId ?? this.recipeId,
      grams: grams ?? this.grams,
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      photoId: photoId ?? this.photoId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (eatenAt.present) {
      map['eaten_at'] = Variable<DateTime>(eatenAt.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (foodItemId.present) {
      map['food_item_id'] = Variable<String>(foodItemId.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (photoId.present) {
      map['photo_id'] = Variable<String>(photoId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealEntriesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('eatenAt: $eatenAt, ')
          ..write('mealType: $mealType, ')
          ..write('title: $title, ')
          ..write('foodItemId: $foodItemId, ')
          ..write('recipeId: $recipeId, ')
          ..write('grams: $grams, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('fat: $fat, ')
          ..write('carbs: $carbs, ')
          ..write('photoId: $photoId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipesTable extends Recipes with TableInfo<$RecipesTable, RecipeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemsMeta = const VerificationMeta('items');
  @override
  late final GeneratedColumn<String> items = GeneratedColumn<String>(
    'items',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _servingsMeta = const VerificationMeta(
    'servings',
  );
  @override
  late final GeneratedColumn<int> servings = GeneratedColumn<int>(
    'servings',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
    'carbs',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    title,
    items,
    servings,
    kcal,
    protein,
    fat,
    carbs,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('items')) {
      context.handle(
        _itemsMeta,
        items.isAcceptableOrUnknown(data['items']!, _itemsMeta),
      );
    }
    if (data.containsKey('servings')) {
      context.handle(
        _servingsMeta,
        servings.isAcceptableOrUnknown(data['servings']!, _servingsMeta),
      );
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      items: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}items'],
      )!,
      servings: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}servings'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      )!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      )!,
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat'],
      )!,
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class RecipeRow extends DataClass implements Insertable<RecipeRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final String title;
  final String items;
  final int servings;
  final double kcal;
  final double protein;
  final double fat;
  final double carbs;
  final int sortOrder;
  const RecipeRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.title,
    required this.items,
    required this.servings,
    required this.kcal,
    required this.protein,
    required this.fat,
    required this.carbs,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['title'] = Variable<String>(title);
    map['items'] = Variable<String>(items);
    map['servings'] = Variable<int>(servings);
    map['kcal'] = Variable<double>(kcal);
    map['protein'] = Variable<double>(protein);
    map['fat'] = Variable<double>(fat);
    map['carbs'] = Variable<double>(carbs);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      title: Value(title),
      items: Value(items),
      servings: Value(servings),
      kcal: Value(kcal),
      protein: Value(protein),
      fat: Value(fat),
      carbs: Value(carbs),
      sortOrder: Value(sortOrder),
    );
  }

  factory RecipeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      title: serializer.fromJson<String>(json['title']),
      items: serializer.fromJson<String>(json['items']),
      servings: serializer.fromJson<int>(json['servings']),
      kcal: serializer.fromJson<double>(json['kcal']),
      protein: serializer.fromJson<double>(json['protein']),
      fat: serializer.fromJson<double>(json['fat']),
      carbs: serializer.fromJson<double>(json['carbs']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'title': serializer.toJson<String>(title),
      'items': serializer.toJson<String>(items),
      'servings': serializer.toJson<int>(servings),
      'kcal': serializer.toJson<double>(kcal),
      'protein': serializer.toJson<double>(protein),
      'fat': serializer.toJson<double>(fat),
      'carbs': serializer.toJson<double>(carbs),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  RecipeRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    String? title,
    String? items,
    int? servings,
    double? kcal,
    double? protein,
    double? fat,
    double? carbs,
    int? sortOrder,
  }) => RecipeRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    title: title ?? this.title,
    items: items ?? this.items,
    servings: servings ?? this.servings,
    kcal: kcal ?? this.kcal,
    protein: protein ?? this.protein,
    fat: fat ?? this.fat,
    carbs: carbs ?? this.carbs,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  RecipeRow copyWithCompanion(RecipesCompanion data) {
    return RecipeRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      title: data.title.present ? data.title.value : this.title,
      items: data.items.present ? data.items.value : this.items,
      servings: data.servings.present ? data.servings.value : this.servings,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      protein: data.protein.present ? data.protein.value : this.protein,
      fat: data.fat.present ? data.fat.value : this.fat,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('title: $title, ')
          ..write('items: $items, ')
          ..write('servings: $servings, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('fat: $fat, ')
          ..write('carbs: $carbs, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    title,
    items,
    servings,
    kcal,
    protein,
    fat,
    carbs,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.title == this.title &&
          other.items == this.items &&
          other.servings == this.servings &&
          other.kcal == this.kcal &&
          other.protein == this.protein &&
          other.fat == this.fat &&
          other.carbs == this.carbs &&
          other.sortOrder == this.sortOrder);
}

class RecipesCompanion extends UpdateCompanion<RecipeRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<String> title;
  final Value<String> items;
  final Value<int> servings;
  final Value<double> kcal;
  final Value<double> protein;
  final Value<double> fat;
  final Value<double> carbs;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const RecipesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.title = const Value.absent(),
    this.items = const Value.absent(),
    this.servings = const Value.absent(),
    this.kcal = const Value.absent(),
    this.protein = const Value.absent(),
    this.fat = const Value.absent(),
    this.carbs = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipesCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required String title,
    this.items = const Value.absent(),
    this.servings = const Value.absent(),
    this.kcal = const Value.absent(),
    this.protein = const Value.absent(),
    this.fat = const Value.absent(),
    this.carbs = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       title = Value(title);
  static Insertable<RecipeRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<String>? title,
    Expression<String>? items,
    Expression<int>? servings,
    Expression<double>? kcal,
    Expression<double>? protein,
    Expression<double>? fat,
    Expression<double>? carbs,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (title != null) 'title': title,
      if (items != null) 'items': items,
      if (servings != null) 'servings': servings,
      if (kcal != null) 'kcal': kcal,
      if (protein != null) 'protein': protein,
      if (fat != null) 'fat': fat,
      if (carbs != null) 'carbs': carbs,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<String>? title,
    Value<String>? items,
    Value<int>? servings,
    Value<double>? kcal,
    Value<double>? protein,
    Value<double>? fat,
    Value<double>? carbs,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return RecipesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      title: title ?? this.title,
      items: items ?? this.items,
      servings: servings ?? this.servings,
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (items.present) {
      map['items'] = Variable<String>(items.value);
    }
    if (servings.present) {
      map['servings'] = Variable<int>(servings.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('title: $title, ')
          ..write('items: $items, ')
          ..write('servings: $servings, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('fat: $fat, ')
          ..write('carbs: $carbs, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WaterLogsTable extends WaterLogs
    with TableInfo<$WaterLogsTable, WaterLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaterLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mlMeta = const VerificationMeta('ml');
  @override
  late final GeneratedColumn<int> ml = GeneratedColumn<int>(
    'ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    loggedAt,
    ml,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'water_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WaterLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('ml')) {
      context.handle(_mlMeta, ml.isAcceptableOrUnknown(data['ml']!, _mlMeta));
    } else if (isInserting) {
      context.missing(_mlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WaterLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WaterLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_at'],
      )!,
      ml: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ml'],
      )!,
    );
  }

  @override
  $WaterLogsTable createAlias(String alias) {
    return $WaterLogsTable(attachedDatabase, alias);
  }
}

class WaterLogRow extends DataClass implements Insertable<WaterLogRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final DateTime loggedAt;
  final int ml;
  const WaterLogRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.loggedAt,
    required this.ml,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['ml'] = Variable<int>(ml);
    return map;
  }

  WaterLogsCompanion toCompanion(bool nullToAbsent) {
    return WaterLogsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      loggedAt: Value(loggedAt),
      ml: Value(ml),
    );
  }

  factory WaterLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WaterLogRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      ml: serializer.fromJson<int>(json['ml']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'ml': serializer.toJson<int>(ml),
    };
  }

  WaterLogRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    DateTime? loggedAt,
    int? ml,
  }) => WaterLogRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    loggedAt: loggedAt ?? this.loggedAt,
    ml: ml ?? this.ml,
  );
  WaterLogRow copyWithCompanion(WaterLogsCompanion data) {
    return WaterLogRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      ml: data.ml.present ? data.ml.value : this.ml,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WaterLogRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('ml: $ml')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, deletedAt, deviceId, version, loggedAt, ml);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaterLogRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.loggedAt == this.loggedAt &&
          other.ml == this.ml);
}

class WaterLogsCompanion extends UpdateCompanion<WaterLogRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<DateTime> loggedAt;
  final Value<int> ml;
  final Value<int> rowid;
  const WaterLogsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.ml = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WaterLogsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required DateTime loggedAt,
    required int ml,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       loggedAt = Value(loggedAt),
       ml = Value(ml);
  static Insertable<WaterLogRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<DateTime>? loggedAt,
    Expression<int>? ml,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (ml != null) 'ml': ml,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WaterLogsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<DateTime>? loggedAt,
    Value<int>? ml,
    Value<int>? rowid,
  }) {
    return WaterLogsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      loggedAt: loggedAt ?? this.loggedAt,
      ml: ml ?? this.ml,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (ml.present) {
      map['ml'] = Variable<int>(ml.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WaterLogsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('ml: $ml, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoppingItemsTable extends ShoppingItems
    with TableInfo<$ShoppingItemsTable, ShoppingItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estPriceMinorMeta = const VerificationMeta(
    'estPriceMinor',
  );
  @override
  late final GeneratedColumn<int> estPriceMinor = GeneratedColumn<int>(
    'est_price_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    title,
    quantity,
    unit,
    estPriceMinor,
    currency,
    done,
    source,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoppingItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('est_price_minor')) {
      context.handle(
        _estPriceMinorMeta,
        estPriceMinor.isAcceptableOrUnknown(
          data['est_price_minor']!,
          _estPriceMinorMeta,
        ),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      ),
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      estPriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}est_price_minor'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      ),
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ShoppingItemsTable createAlias(String alias) {
    return $ShoppingItemsTable(attachedDatabase, alias);
  }
}

class ShoppingItemRow extends DataClass implements Insertable<ShoppingItemRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final String title;
  final double? quantity;
  final String? unit;
  final int? estPriceMinor;
  final String? currency;
  final bool done;
  final String source;
  final int sortOrder;
  const ShoppingItemRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.title,
    this.quantity,
    this.unit,
    this.estPriceMinor,
    this.currency,
    required this.done,
    required this.source,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<double>(quantity);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || estPriceMinor != null) {
      map['est_price_minor'] = Variable<int>(estPriceMinor);
    }
    if (!nullToAbsent || currency != null) {
      map['currency'] = Variable<String>(currency);
    }
    map['done'] = Variable<bool>(done);
    map['source'] = Variable<String>(source);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ShoppingItemsCompanion toCompanion(bool nullToAbsent) {
    return ShoppingItemsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      title: Value(title),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      estPriceMinor: estPriceMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(estPriceMinor),
      currency: currency == null && nullToAbsent
          ? const Value.absent()
          : Value(currency),
      done: Value(done),
      source: Value(source),
      sortOrder: Value(sortOrder),
    );
  }

  factory ShoppingItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingItemRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      title: serializer.fromJson<String>(json['title']),
      quantity: serializer.fromJson<double?>(json['quantity']),
      unit: serializer.fromJson<String?>(json['unit']),
      estPriceMinor: serializer.fromJson<int?>(json['estPriceMinor']),
      currency: serializer.fromJson<String?>(json['currency']),
      done: serializer.fromJson<bool>(json['done']),
      source: serializer.fromJson<String>(json['source']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'title': serializer.toJson<String>(title),
      'quantity': serializer.toJson<double?>(quantity),
      'unit': serializer.toJson<String?>(unit),
      'estPriceMinor': serializer.toJson<int?>(estPriceMinor),
      'currency': serializer.toJson<String?>(currency),
      'done': serializer.toJson<bool>(done),
      'source': serializer.toJson<String>(source),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ShoppingItemRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    String? title,
    Value<double?> quantity = const Value.absent(),
    Value<String?> unit = const Value.absent(),
    Value<int?> estPriceMinor = const Value.absent(),
    Value<String?> currency = const Value.absent(),
    bool? done,
    String? source,
    int? sortOrder,
  }) => ShoppingItemRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    title: title ?? this.title,
    quantity: quantity.present ? quantity.value : this.quantity,
    unit: unit.present ? unit.value : this.unit,
    estPriceMinor: estPriceMinor.present
        ? estPriceMinor.value
        : this.estPriceMinor,
    currency: currency.present ? currency.value : this.currency,
    done: done ?? this.done,
    source: source ?? this.source,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ShoppingItemRow copyWithCompanion(ShoppingItemsCompanion data) {
    return ShoppingItemRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      title: data.title.present ? data.title.value : this.title,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      estPriceMinor: data.estPriceMinor.present
          ? data.estPriceMinor.value
          : this.estPriceMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      done: data.done.present ? data.done.value : this.done,
      source: data.source.present ? data.source.value : this.source,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingItemRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('title: $title, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('estPriceMinor: $estPriceMinor, ')
          ..write('currency: $currency, ')
          ..write('done: $done, ')
          ..write('source: $source, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    title,
    quantity,
    unit,
    estPriceMinor,
    currency,
    done,
    source,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingItemRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.title == this.title &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.estPriceMinor == this.estPriceMinor &&
          other.currency == this.currency &&
          other.done == this.done &&
          other.source == this.source &&
          other.sortOrder == this.sortOrder);
}

class ShoppingItemsCompanion extends UpdateCompanion<ShoppingItemRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<String> title;
  final Value<double?> quantity;
  final Value<String?> unit;
  final Value<int?> estPriceMinor;
  final Value<String?> currency;
  final Value<bool> done;
  final Value<String> source;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const ShoppingItemsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.title = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.estPriceMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.done = const Value.absent(),
    this.source = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingItemsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required String title,
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.estPriceMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.done = const Value.absent(),
    this.source = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       title = Value(title);
  static Insertable<ShoppingItemRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<String>? title,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<int>? estPriceMinor,
    Expression<String>? currency,
    Expression<bool>? done,
    Expression<String>? source,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (title != null) 'title': title,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (estPriceMinor != null) 'est_price_minor': estPriceMinor,
      if (currency != null) 'currency': currency,
      if (done != null) 'done': done,
      if (source != null) 'source': source,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingItemsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<String>? title,
    Value<double?>? quantity,
    Value<String?>? unit,
    Value<int?>? estPriceMinor,
    Value<String?>? currency,
    Value<bool>? done,
    Value<String>? source,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return ShoppingItemsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      title: title ?? this.title,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      estPriceMinor: estPriceMinor ?? this.estPriceMinor,
      currency: currency ?? this.currency,
      done: done ?? this.done,
      source: source ?? this.source,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (estPriceMinor.present) {
      map['est_price_minor'] = Variable<int>(estPriceMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingItemsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('title: $title, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('estPriceMinor: $estPriceMinor, ')
          ..write('currency: $currency, ')
          ..write('done: $done, ')
          ..write('source: $source, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StepLogsTable extends StepLogs
    with TableInfo<$StepLogsTable, StepLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StepLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<int> steps = GeneratedColumn<int>(
    'steps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMMeta = const VerificationMeta(
    'distanceM',
  );
  @override
  late final GeneratedColumn<double> distanceM = GeneratedColumn<double>(
    'distance_m',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _floorsMeta = const VerificationMeta('floors');
  @override
  late final GeneratedColumn<int> floors = GeneratedColumn<int>(
    'floors',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    day,
    steps,
    distanceM,
    floors,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'step_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<StepLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    } else if (isInserting) {
      context.missing(_stepsMeta);
    }
    if (data.containsKey('distance_m')) {
      context.handle(
        _distanceMMeta,
        distanceM.isAcceptableOrUnknown(data['distance_m']!, _distanceMMeta),
      );
    }
    if (data.containsKey('floors')) {
      context.handle(
        _floorsMeta,
        floors.isAcceptableOrUnknown(data['floors']!, _floorsMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {day, source},
  ];
  @override
  StepLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StepLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}day'],
      )!,
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}steps'],
      )!,
      distanceM: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_m'],
      ),
      floors: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}floors'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $StepLogsTable createAlias(String alias) {
    return $StepLogsTable(attachedDatabase, alias);
  }
}

class StepLogRow extends DataClass implements Insertable<StepLogRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final DateTime day;
  final int steps;
  final double? distanceM;
  final int? floors;
  final String source;
  const StepLogRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.day,
    required this.steps,
    this.distanceM,
    this.floors,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['day'] = Variable<DateTime>(day);
    map['steps'] = Variable<int>(steps);
    if (!nullToAbsent || distanceM != null) {
      map['distance_m'] = Variable<double>(distanceM);
    }
    if (!nullToAbsent || floors != null) {
      map['floors'] = Variable<int>(floors);
    }
    map['source'] = Variable<String>(source);
    return map;
  }

  StepLogsCompanion toCompanion(bool nullToAbsent) {
    return StepLogsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      day: Value(day),
      steps: Value(steps),
      distanceM: distanceM == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceM),
      floors: floors == null && nullToAbsent
          ? const Value.absent()
          : Value(floors),
      source: Value(source),
    );
  }

  factory StepLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StepLogRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      day: serializer.fromJson<DateTime>(json['day']),
      steps: serializer.fromJson<int>(json['steps']),
      distanceM: serializer.fromJson<double?>(json['distanceM']),
      floors: serializer.fromJson<int?>(json['floors']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'day': serializer.toJson<DateTime>(day),
      'steps': serializer.toJson<int>(steps),
      'distanceM': serializer.toJson<double?>(distanceM),
      'floors': serializer.toJson<int?>(floors),
      'source': serializer.toJson<String>(source),
    };
  }

  StepLogRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    DateTime? day,
    int? steps,
    Value<double?> distanceM = const Value.absent(),
    Value<int?> floors = const Value.absent(),
    String? source,
  }) => StepLogRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    day: day ?? this.day,
    steps: steps ?? this.steps,
    distanceM: distanceM.present ? distanceM.value : this.distanceM,
    floors: floors.present ? floors.value : this.floors,
    source: source ?? this.source,
  );
  StepLogRow copyWithCompanion(StepLogsCompanion data) {
    return StepLogRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      day: data.day.present ? data.day.value : this.day,
      steps: data.steps.present ? data.steps.value : this.steps,
      distanceM: data.distanceM.present ? data.distanceM.value : this.distanceM,
      floors: data.floors.present ? data.floors.value : this.floors,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StepLogRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('day: $day, ')
          ..write('steps: $steps, ')
          ..write('distanceM: $distanceM, ')
          ..write('floors: $floors, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    day,
    steps,
    distanceM,
    floors,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StepLogRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.day == this.day &&
          other.steps == this.steps &&
          other.distanceM == this.distanceM &&
          other.floors == this.floors &&
          other.source == this.source);
}

class StepLogsCompanion extends UpdateCompanion<StepLogRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<DateTime> day;
  final Value<int> steps;
  final Value<double?> distanceM;
  final Value<int?> floors;
  final Value<String> source;
  final Value<int> rowid;
  const StepLogsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.day = const Value.absent(),
    this.steps = const Value.absent(),
    this.distanceM = const Value.absent(),
    this.floors = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StepLogsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required DateTime day,
    required int steps,
    this.distanceM = const Value.absent(),
    this.floors = const Value.absent(),
    required String source,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       day = Value(day),
       steps = Value(steps),
       source = Value(source);
  static Insertable<StepLogRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<DateTime>? day,
    Expression<int>? steps,
    Expression<double>? distanceM,
    Expression<int>? floors,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (day != null) 'day': day,
      if (steps != null) 'steps': steps,
      if (distanceM != null) 'distance_m': distanceM,
      if (floors != null) 'floors': floors,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StepLogsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<DateTime>? day,
    Value<int>? steps,
    Value<double?>? distanceM,
    Value<int?>? floors,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return StepLogsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      day: day ?? this.day,
      steps: steps ?? this.steps,
      distanceM: distanceM ?? this.distanceM,
      floors: floors ?? this.floors,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (steps.present) {
      map['steps'] = Variable<int>(steps.value);
    }
    if (distanceM.present) {
      map['distance_m'] = Variable<double>(distanceM.value);
    }
    if (floors.present) {
      map['floors'] = Variable<int>(floors.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StepLogsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('day: $day, ')
          ..write('steps: $steps, ')
          ..write('distanceM: $distanceM, ')
          ..write('floors: $floors, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SleepLogsTable extends SleepLogs
    with TableInfo<$SleepLogsTable, SleepLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _bedAtMeta = const VerificationMeta('bedAt');
  @override
  late final GeneratedColumn<DateTime> bedAt = GeneratedColumn<DateTime>(
    'bed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wakeAtMeta = const VerificationMeta('wakeAt');
  @override
  late final GeneratedColumn<DateTime> wakeAt = GeneratedColumn<DateTime>(
    'wake_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _qualityMeta = const VerificationMeta(
    'quality',
  );
  @override
  late final GeneratedColumn<int> quality = GeneratedColumn<int>(
    'quality',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    bedAt,
    wakeAt,
    quality,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SleepLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('bed_at')) {
      context.handle(
        _bedAtMeta,
        bedAt.isAcceptableOrUnknown(data['bed_at']!, _bedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_bedAtMeta);
    }
    if (data.containsKey('wake_at')) {
      context.handle(
        _wakeAtMeta,
        wakeAt.isAcceptableOrUnknown(data['wake_at']!, _wakeAtMeta),
      );
    } else if (isInserting) {
      context.missing(_wakeAtMeta);
    }
    if (data.containsKey('quality')) {
      context.handle(
        _qualityMeta,
        quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SleepLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      bedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}bed_at'],
      )!,
      wakeAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}wake_at'],
      )!,
      quality: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quality'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $SleepLogsTable createAlias(String alias) {
    return $SleepLogsTable(attachedDatabase, alias);
  }
}

class SleepLogRow extends DataClass implements Insertable<SleepLogRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final DateTime bedAt;
  final DateTime wakeAt;
  final int? quality;
  final String source;
  const SleepLogRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.bedAt,
    required this.wakeAt,
    this.quality,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['bed_at'] = Variable<DateTime>(bedAt);
    map['wake_at'] = Variable<DateTime>(wakeAt);
    if (!nullToAbsent || quality != null) {
      map['quality'] = Variable<int>(quality);
    }
    map['source'] = Variable<String>(source);
    return map;
  }

  SleepLogsCompanion toCompanion(bool nullToAbsent) {
    return SleepLogsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      bedAt: Value(bedAt),
      wakeAt: Value(wakeAt),
      quality: quality == null && nullToAbsent
          ? const Value.absent()
          : Value(quality),
      source: Value(source),
    );
  }

  factory SleepLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepLogRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      bedAt: serializer.fromJson<DateTime>(json['bedAt']),
      wakeAt: serializer.fromJson<DateTime>(json['wakeAt']),
      quality: serializer.fromJson<int?>(json['quality']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'bedAt': serializer.toJson<DateTime>(bedAt),
      'wakeAt': serializer.toJson<DateTime>(wakeAt),
      'quality': serializer.toJson<int?>(quality),
      'source': serializer.toJson<String>(source),
    };
  }

  SleepLogRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    DateTime? bedAt,
    DateTime? wakeAt,
    Value<int?> quality = const Value.absent(),
    String? source,
  }) => SleepLogRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    bedAt: bedAt ?? this.bedAt,
    wakeAt: wakeAt ?? this.wakeAt,
    quality: quality.present ? quality.value : this.quality,
    source: source ?? this.source,
  );
  SleepLogRow copyWithCompanion(SleepLogsCompanion data) {
    return SleepLogRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      bedAt: data.bedAt.present ? data.bedAt.value : this.bedAt,
      wakeAt: data.wakeAt.present ? data.wakeAt.value : this.wakeAt,
      quality: data.quality.present ? data.quality.value : this.quality,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepLogRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('bedAt: $bedAt, ')
          ..write('wakeAt: $wakeAt, ')
          ..write('quality: $quality, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    bedAt,
    wakeAt,
    quality,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepLogRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.bedAt == this.bedAt &&
          other.wakeAt == this.wakeAt &&
          other.quality == this.quality &&
          other.source == this.source);
}

class SleepLogsCompanion extends UpdateCompanion<SleepLogRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<DateTime> bedAt;
  final Value<DateTime> wakeAt;
  final Value<int?> quality;
  final Value<String> source;
  final Value<int> rowid;
  const SleepLogsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.bedAt = const Value.absent(),
    this.wakeAt = const Value.absent(),
    this.quality = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SleepLogsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required DateTime bedAt,
    required DateTime wakeAt,
    this.quality = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       bedAt = Value(bedAt),
       wakeAt = Value(wakeAt);
  static Insertable<SleepLogRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<DateTime>? bedAt,
    Expression<DateTime>? wakeAt,
    Expression<int>? quality,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (bedAt != null) 'bed_at': bedAt,
      if (wakeAt != null) 'wake_at': wakeAt,
      if (quality != null) 'quality': quality,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SleepLogsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<DateTime>? bedAt,
    Value<DateTime>? wakeAt,
    Value<int?>? quality,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return SleepLogsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      bedAt: bedAt ?? this.bedAt,
      wakeAt: wakeAt ?? this.wakeAt,
      quality: quality ?? this.quality,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (bedAt.present) {
      map['bed_at'] = Variable<DateTime>(bedAt.value);
    }
    if (wakeAt.present) {
      map['wake_at'] = Variable<DateTime>(wakeAt.value);
    }
    if (quality.present) {
      map['quality'] = Variable<int>(quality.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepLogsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('bedAt: $bedAt, ')
          ..write('wakeAt: $wakeAt, ')
          ..write('quality: $quality, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CareChecksTable extends CareChecks
    with TableInfo<$CareChecksTable, CareCheckRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CareChecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _routineMeta = const VerificationMeta(
    'routine',
  );
  @override
  late final GeneratedColumn<String> routine = GeneratedColumn<String>(
    'routine',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemKeyMeta = const VerificationMeta(
    'itemKey',
  );
  @override
  late final GeneratedColumn<String> itemKey = GeneratedColumn<String>(
    'item_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneAtMeta = const VerificationMeta('doneAt');
  @override
  late final GeneratedColumn<DateTime> doneAt = GeneratedColumn<DateTime>(
    'done_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    day,
    routine,
    itemKey,
    doneAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'care_checks';
  @override
  VerificationContext validateIntegrity(
    Insertable<CareCheckRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('routine')) {
      context.handle(
        _routineMeta,
        routine.isAcceptableOrUnknown(data['routine']!, _routineMeta),
      );
    } else if (isInserting) {
      context.missing(_routineMeta);
    }
    if (data.containsKey('item_key')) {
      context.handle(
        _itemKeyMeta,
        itemKey.isAcceptableOrUnknown(data['item_key']!, _itemKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_itemKeyMeta);
    }
    if (data.containsKey('done_at')) {
      context.handle(
        _doneAtMeta,
        doneAt.isAcceptableOrUnknown(data['done_at']!, _doneAtMeta),
      );
    } else if (isInserting) {
      context.missing(_doneAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {day, routine, itemKey},
  ];
  @override
  CareCheckRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CareCheckRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}day'],
      )!,
      routine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine'],
      )!,
      itemKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_key'],
      )!,
      doneAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}done_at'],
      )!,
    );
  }

  @override
  $CareChecksTable createAlias(String alias) {
    return $CareChecksTable(attachedDatabase, alias);
  }
}

class CareCheckRow extends DataClass implements Insertable<CareCheckRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final DateTime day;
  final String routine;
  final String itemKey;
  final DateTime doneAt;
  const CareCheckRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.day,
    required this.routine,
    required this.itemKey,
    required this.doneAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['day'] = Variable<DateTime>(day);
    map['routine'] = Variable<String>(routine);
    map['item_key'] = Variable<String>(itemKey);
    map['done_at'] = Variable<DateTime>(doneAt);
    return map;
  }

  CareChecksCompanion toCompanion(bool nullToAbsent) {
    return CareChecksCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      day: Value(day),
      routine: Value(routine),
      itemKey: Value(itemKey),
      doneAt: Value(doneAt),
    );
  }

  factory CareCheckRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CareCheckRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      day: serializer.fromJson<DateTime>(json['day']),
      routine: serializer.fromJson<String>(json['routine']),
      itemKey: serializer.fromJson<String>(json['itemKey']),
      doneAt: serializer.fromJson<DateTime>(json['doneAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'day': serializer.toJson<DateTime>(day),
      'routine': serializer.toJson<String>(routine),
      'itemKey': serializer.toJson<String>(itemKey),
      'doneAt': serializer.toJson<DateTime>(doneAt),
    };
  }

  CareCheckRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    DateTime? day,
    String? routine,
    String? itemKey,
    DateTime? doneAt,
  }) => CareCheckRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    day: day ?? this.day,
    routine: routine ?? this.routine,
    itemKey: itemKey ?? this.itemKey,
    doneAt: doneAt ?? this.doneAt,
  );
  CareCheckRow copyWithCompanion(CareChecksCompanion data) {
    return CareCheckRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      day: data.day.present ? data.day.value : this.day,
      routine: data.routine.present ? data.routine.value : this.routine,
      itemKey: data.itemKey.present ? data.itemKey.value : this.itemKey,
      doneAt: data.doneAt.present ? data.doneAt.value : this.doneAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CareCheckRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('day: $day, ')
          ..write('routine: $routine, ')
          ..write('itemKey: $itemKey, ')
          ..write('doneAt: $doneAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    day,
    routine,
    itemKey,
    doneAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CareCheckRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.day == this.day &&
          other.routine == this.routine &&
          other.itemKey == this.itemKey &&
          other.doneAt == this.doneAt);
}

class CareChecksCompanion extends UpdateCompanion<CareCheckRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<DateTime> day;
  final Value<String> routine;
  final Value<String> itemKey;
  final Value<DateTime> doneAt;
  final Value<int> rowid;
  const CareChecksCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.day = const Value.absent(),
    this.routine = const Value.absent(),
    this.itemKey = const Value.absent(),
    this.doneAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CareChecksCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required DateTime day,
    required String routine,
    required String itemKey,
    required DateTime doneAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       day = Value(day),
       routine = Value(routine),
       itemKey = Value(itemKey),
       doneAt = Value(doneAt);
  static Insertable<CareCheckRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<DateTime>? day,
    Expression<String>? routine,
    Expression<String>? itemKey,
    Expression<DateTime>? doneAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (day != null) 'day': day,
      if (routine != null) 'routine': routine,
      if (itemKey != null) 'item_key': itemKey,
      if (doneAt != null) 'done_at': doneAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CareChecksCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<DateTime>? day,
    Value<String>? routine,
    Value<String>? itemKey,
    Value<DateTime>? doneAt,
    Value<int>? rowid,
  }) {
    return CareChecksCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      day: day ?? this.day,
      routine: routine ?? this.routine,
      itemKey: itemKey ?? this.itemKey,
      doneAt: doneAt ?? this.doneAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (routine.present) {
      map['routine'] = Variable<String>(routine.value);
    }
    if (itemKey.present) {
      map['item_key'] = Variable<String>(itemKey.value);
    }
    if (doneAt.present) {
      map['done_at'] = Variable<DateTime>(doneAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CareChecksCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('day: $day, ')
          ..write('routine: $routine, ')
          ..write('itemKey: $itemKey, ')
          ..write('doneAt: $doneAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutProgramsTable extends WorkoutPrograms
    with TableInfo<$WorkoutProgramsTable, WorkoutProgramRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutProgramsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('template'),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    title,
    level,
    source,
    payload,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_programs';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutProgramRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutProgramRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutProgramRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $WorkoutProgramsTable createAlias(String alias) {
    return $WorkoutProgramsTable(attachedDatabase, alias);
  }
}

class WorkoutProgramRow extends DataClass
    implements Insertable<WorkoutProgramRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final String title;
  final String level;
  final String source;
  final String payload;
  final bool active;
  const WorkoutProgramRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    required this.title,
    required this.level,
    required this.source,
    required this.payload,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    map['title'] = Variable<String>(title);
    map['level'] = Variable<String>(level);
    map['source'] = Variable<String>(source);
    map['payload'] = Variable<String>(payload);
    map['active'] = Variable<bool>(active);
    return map;
  }

  WorkoutProgramsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutProgramsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      title: Value(title),
      level: Value(level),
      source: Value(source),
      payload: Value(payload),
      active: Value(active),
    );
  }

  factory WorkoutProgramRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutProgramRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      title: serializer.fromJson<String>(json['title']),
      level: serializer.fromJson<String>(json['level']),
      source: serializer.fromJson<String>(json['source']),
      payload: serializer.fromJson<String>(json['payload']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'title': serializer.toJson<String>(title),
      'level': serializer.toJson<String>(level),
      'source': serializer.toJson<String>(source),
      'payload': serializer.toJson<String>(payload),
      'active': serializer.toJson<bool>(active),
    };
  }

  WorkoutProgramRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    String? title,
    String? level,
    String? source,
    String? payload,
    bool? active,
  }) => WorkoutProgramRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    title: title ?? this.title,
    level: level ?? this.level,
    source: source ?? this.source,
    payload: payload ?? this.payload,
    active: active ?? this.active,
  );
  WorkoutProgramRow copyWithCompanion(WorkoutProgramsCompanion data) {
    return WorkoutProgramRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      title: data.title.present ? data.title.value : this.title,
      level: data.level.present ? data.level.value : this.level,
      source: data.source.present ? data.source.value : this.source,
      payload: data.payload.present ? data.payload.value : this.payload,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutProgramRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('title: $title, ')
          ..write('level: $level, ')
          ..write('source: $source, ')
          ..write('payload: $payload, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    title,
    level,
    source,
    payload,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutProgramRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.title == this.title &&
          other.level == this.level &&
          other.source == this.source &&
          other.payload == this.payload &&
          other.active == this.active);
}

class WorkoutProgramsCompanion extends UpdateCompanion<WorkoutProgramRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<String> title;
  final Value<String> level;
  final Value<String> source;
  final Value<String> payload;
  final Value<bool> active;
  final Value<int> rowid;
  const WorkoutProgramsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.title = const Value.absent(),
    this.level = const Value.absent(),
    this.source = const Value.absent(),
    this.payload = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutProgramsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    required String title,
    required String level,
    this.source = const Value.absent(),
    required String payload,
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       title = Value(title),
       level = Value(level),
       payload = Value(payload);
  static Insertable<WorkoutProgramRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<String>? title,
    Expression<String>? level,
    Expression<String>? source,
    Expression<String>? payload,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (title != null) 'title': title,
      if (level != null) 'level': level,
      if (source != null) 'source': source,
      if (payload != null) 'payload': payload,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutProgramsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<String>? title,
    Value<String>? level,
    Value<String>? source,
    Value<String>? payload,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return WorkoutProgramsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      title: title ?? this.title,
      level: level ?? this.level,
      source: source ?? this.source,
      payload: payload ?? this.payload,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutProgramsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('title: $title, ')
          ..write('level: $level, ')
          ..write('source: $source, ')
          ..write('payload: $payload, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _programIdMeta = const VerificationMeta(
    'programId',
  );
  @override
  late final GeneratedColumn<String> programId = GeneratedColumn<String>(
    'program_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
    'day_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeSecondsMeta = const VerificationMeta(
    'activeSeconds',
  );
  @override
  late final GeneratedColumn<int> activeSeconds = GeneratedColumn<int>(
    'active_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    programId,
    dayKey,
    startedAt,
    finishedAt,
    activeSeconds,
    kcal,
    payload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('program_id')) {
      context.handle(
        _programIdMeta,
        programId.isAcceptableOrUnknown(data['program_id']!, _programIdMeta),
      );
    }
    if (data.containsKey('day_key')) {
      context.handle(
        _dayKeyMeta,
        dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('active_seconds')) {
      context.handle(
        _activeSecondsMeta,
        activeSeconds.isAcceptableOrUnknown(
          data['active_seconds']!,
          _activeSecondsMeta,
        ),
      );
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      programId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}program_id'],
      ),
      dayKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_key'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      activeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_seconds'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }
}

class WorkoutSessionRow extends DataClass
    implements Insertable<WorkoutSessionRow> {
  final String id;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  final int version;
  final String? programId;
  final String? dayKey;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int activeSeconds;
  final double? kcal;
  final String payload;
  const WorkoutSessionRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
    required this.version,
    this.programId,
    this.dayKey,
    required this.startedAt,
    this.finishedAt,
    required this.activeSeconds,
    this.kcal,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || programId != null) {
      map['program_id'] = Variable<String>(programId);
    }
    if (!nullToAbsent || dayKey != null) {
      map['day_key'] = Variable<String>(dayKey);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['active_seconds'] = Variable<int>(activeSeconds);
    if (!nullToAbsent || kcal != null) {
      map['kcal'] = Variable<double>(kcal);
    }
    map['payload'] = Variable<String>(payload);
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
      version: Value(version),
      programId: programId == null && nullToAbsent
          ? const Value.absent()
          : Value(programId),
      dayKey: dayKey == null && nullToAbsent
          ? const Value.absent()
          : Value(dayKey),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      activeSeconds: Value(activeSeconds),
      kcal: kcal == null && nullToAbsent ? const Value.absent() : Value(kcal),
      payload: Value(payload),
    );
  }

  factory WorkoutSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSessionRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      version: serializer.fromJson<int>(json['version']),
      programId: serializer.fromJson<String?>(json['programId']),
      dayKey: serializer.fromJson<String?>(json['dayKey']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      activeSeconds: serializer.fromJson<int>(json['activeSeconds']),
      kcal: serializer.fromJson<double?>(json['kcal']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
      'version': serializer.toJson<int>(version),
      'programId': serializer.toJson<String?>(programId),
      'dayKey': serializer.toJson<String?>(dayKey),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'activeSeconds': serializer.toJson<int>(activeSeconds),
      'kcal': serializer.toJson<double?>(kcal),
      'payload': serializer.toJson<String>(payload),
    };
  }

  WorkoutSessionRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
    int? version,
    Value<String?> programId = const Value.absent(),
    Value<String?> dayKey = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    int? activeSeconds,
    Value<double?> kcal = const Value.absent(),
    String? payload,
  }) => WorkoutSessionRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
    version: version ?? this.version,
    programId: programId.present ? programId.value : this.programId,
    dayKey: dayKey.present ? dayKey.value : this.dayKey,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    activeSeconds: activeSeconds ?? this.activeSeconds,
    kcal: kcal.present ? kcal.value : this.kcal,
    payload: payload ?? this.payload,
  );
  WorkoutSessionRow copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSessionRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      version: data.version.present ? data.version.value : this.version,
      programId: data.programId.present ? data.programId.value : this.programId,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      activeSeconds: data.activeSeconds.present
          ? data.activeSeconds.value
          : this.activeSeconds,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('programId: $programId, ')
          ..write('dayKey: $dayKey, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('activeSeconds: $activeSeconds, ')
          ..write('kcal: $kcal, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    deviceId,
    version,
    programId,
    dayKey,
    startedAt,
    finishedAt,
    activeSeconds,
    kcal,
    payload,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSessionRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId &&
          other.version == this.version &&
          other.programId == this.programId &&
          other.dayKey == this.dayKey &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.activeSeconds == this.activeSeconds &&
          other.kcal == this.kcal &&
          other.payload == this.payload);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSessionRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> version;
  final Value<String?> programId;
  final Value<String?> dayKey;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<int> activeSeconds;
  final Value<double?> kcal;
  final Value<String> payload;
  final Value<int> rowid;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.programId = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.activeSeconds = const Value.absent(),
    this.kcal = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.version = const Value.absent(),
    this.programId = const Value.absent(),
    this.dayKey = const Value.absent(),
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    this.activeSeconds = const Value.absent(),
    this.kcal = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId),
       startedAt = Value(startedAt);
  static Insertable<WorkoutSessionRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? version,
    Expression<String>? programId,
    Expression<String>? dayKey,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? activeSeconds,
    Expression<double>? kcal,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (version != null) 'version': version,
      if (programId != null) 'program_id': programId,
      if (dayKey != null) 'day_key': dayKey,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (activeSeconds != null) 'active_seconds': activeSeconds,
      if (kcal != null) 'kcal': kcal,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? version,
    Value<String?>? programId,
    Value<String?>? dayKey,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<int>? activeSeconds,
    Value<double?>? kcal,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      version: version ?? this.version,
      programId: programId ?? this.programId,
      dayKey: dayKey ?? this.dayKey,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      activeSeconds: activeSeconds ?? this.activeSeconds,
      kcal: kcal ?? this.kcal,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (programId.present) {
      map['program_id'] = Variable<String>(programId.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (activeSeconds.present) {
      map['active_seconds'] = Variable<int>(activeSeconds.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('version: $version, ')
          ..write('programId: $programId, ')
          ..write('dayKey: $dayKey, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('activeSeconds: $activeSeconds, ')
          ..write('kcal: $kcal, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $BodyMeasurementsTable bodyMeasurements = $BodyMeasurementsTable(
    this,
  );
  late final $PhotosTable photos = $PhotosTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $ScheduleSettingsTable scheduleSettings = $ScheduleSettingsTable(
    this,
  );
  late final $ScheduleItemsTable scheduleItems = $ScheduleItemsTable(this);
  late final $PlansTable plans = $PlansTable(this);
  late final $QuestionnaireSectionsTable questionnaireSections =
      $QuestionnaireSectionsTable(this);
  late final $QuestsTable quests = $QuestsTable(this);
  late final $QuestInstancesTable questInstances = $QuestInstancesTable(this);
  late final $QuestEventsTable questEvents = $QuestEventsTable(this);
  late final $EffectsTable effects = $EffectsTable(this);
  late final $PausesTable pauses = $PausesTable(this);
  late final $RewardsTable rewards = $RewardsTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $FoodItemsTable foodItems = $FoodItemsTable(this);
  late final $MealEntriesTable mealEntries = $MealEntriesTable(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $WaterLogsTable waterLogs = $WaterLogsTable(this);
  late final $ShoppingItemsTable shoppingItems = $ShoppingItemsTable(this);
  late final $StepLogsTable stepLogs = $StepLogsTable(this);
  late final $SleepLogsTable sleepLogs = $SleepLogsTable(this);
  late final $CareChecksTable careChecks = $CareChecksTable(this);
  late final $WorkoutProgramsTable workoutPrograms = $WorkoutProgramsTable(
    this,
  );
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettings,
    profiles,
    bodyMeasurements,
    photos,
    goals,
    scheduleSettings,
    scheduleItems,
    plans,
    questionnaireSections,
    quests,
    questInstances,
    questEvents,
    effects,
    pauses,
    rewards,
    userSettings,
    foodItems,
    mealEntries,
    recipes,
    waterLogs,
    shoppingItems,
    stepLogs,
    sleepLogs,
    careChecks,
    workoutPrograms,
    workoutSessions,
  ];
}

typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<int> version,
  Value<String> name,
  Value<String?> locale,
  Value<String?> sex,
  Value<DateTime?> birthDate,
  Value<String?> timezone,
  Value<String?> city,
  Value<double?> heightCm,
  Value<String?> activityLevel,
  Value<String?> workload,
  Value<int> rowid,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<int> version,
  Value<String> name,
  Value<String?> locale,
  Value<String?> sex,
  Value<DateTime?> birthDate,
  Value<String?> timezone,
  Value<String?> city,
  Value<double?> heightCm,
  Value<String?> activityLevel,
  Value<String?> workload,
  Value<int> rowid,
});

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workload => $composableBuilder(
    column: $table.workload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workload => $composableBuilder(
    column: $table.workload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get workload =>
      $composableBuilder(column: $table.workload, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          ProfileRow,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (
            ProfileRow,
            BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>,
          ),
          ProfileRow,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> locale = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> timezone = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<String?> activityLevel = const Value.absent(),
                Value<String?> workload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                name: name,
                locale: locale,
                sex: sex,
                birthDate: birthDate,
                timezone: timezone,
                city: city,
                heightCm: heightCm,
                activityLevel: activityLevel,
                workload: workload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> locale = const Value.absent(),
                Value<String?> sex = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> timezone = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<String?> activityLevel = const Value.absent(),
                Value<String?> workload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                name: name,
                locale: locale,
                sex: sex,
                birthDate: birthDate,
                timezone: timezone,
                city: city,
                heightCm: heightCm,
                activityLevel: activityLevel,
                workload: workload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, ProfileRow>(table),
                  BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      ProfileRow,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfileRow, BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>),
      ProfileRow,
      PrefetchHooks Function()
    >;
typedef $$BodyMeasurementsTableCreateCompanionBuilder =
    BodyMeasurementsCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String deviceId,
      Value<int> version,
      required DateTime measuredAt,
      Value<double?> weightKg,
      Value<double?> waistCm,
      Value<double?> hipsCm,
      Value<double?> chestCm,
      Value<double?> neckCm,
      Value<double?> armCm,
      Value<double?> bodyFatPct,
      Value<double?> muscleMassKg,
      Value<String> source,
      Value<int> rowid,
    });
typedef $$BodyMeasurementsTableUpdateCompanionBuilder =
    BodyMeasurementsCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> deviceId,
      Value<int> version,
      Value<DateTime> measuredAt,
      Value<double?> weightKg,
      Value<double?> waistCm,
      Value<double?> hipsCm,
      Value<double?> chestCm,
      Value<double?> neckCm,
      Value<double?> armCm,
      Value<double?> bodyFatPct,
      Value<double?> muscleMassKg,
      Value<String> source,
      Value<int> rowid,
    });

class $$BodyMeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hipsCm => $composableBuilder(
    column: $table.hipsCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get chestCm => $composableBuilder(
    column: $table.chestCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get neckCm => $composableBuilder(
    column: $table.neckCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get armCm => $composableBuilder(
    column: $table.armCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bodyFatPct => $composableBuilder(
    column: $table.bodyFatPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get muscleMassKg => $composableBuilder(
    column: $table.muscleMassKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BodyMeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hipsCm => $composableBuilder(
    column: $table.hipsCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get chestCm => $composableBuilder(
    column: $table.chestCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get neckCm => $composableBuilder(
    column: $table.neckCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get armCm => $composableBuilder(
    column: $table.armCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bodyFatPct => $composableBuilder(
    column: $table.bodyFatPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get muscleMassKg => $composableBuilder(
    column: $table.muscleMassKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BodyMeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyMeasurementsTable> {
  $$BodyMeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get waistCm =>
      $composableBuilder(column: $table.waistCm, builder: (column) => column);

  GeneratedColumn<double> get hipsCm =>
      $composableBuilder(column: $table.hipsCm, builder: (column) => column);

  GeneratedColumn<double> get chestCm =>
      $composableBuilder(column: $table.chestCm, builder: (column) => column);

  GeneratedColumn<double> get neckCm =>
      $composableBuilder(column: $table.neckCm, builder: (column) => column);

  GeneratedColumn<double> get armCm =>
      $composableBuilder(column: $table.armCm, builder: (column) => column);

  GeneratedColumn<double> get bodyFatPct => $composableBuilder(
    column: $table.bodyFatPct,
    builder: (column) => column,
  );

  GeneratedColumn<double> get muscleMassKg => $composableBuilder(
    column: $table.muscleMassKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$BodyMeasurementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BodyMeasurementsTable,
          BodyMeasurementRow,
          $$BodyMeasurementsTableFilterComposer,
          $$BodyMeasurementsTableOrderingComposer,
          $$BodyMeasurementsTableAnnotationComposer,
          $$BodyMeasurementsTableCreateCompanionBuilder,
          $$BodyMeasurementsTableUpdateCompanionBuilder,
          (
            BodyMeasurementRow,
            BaseReferences<
              _$AppDatabase,
              $BodyMeasurementsTable,
              BodyMeasurementRow
            >,
          ),
          BodyMeasurementRow,
          PrefetchHooks Function()
        > {
  $$BodyMeasurementsTableTableManager(
    _$AppDatabase db,
    $BodyMeasurementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyMeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyMeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyMeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> measuredAt = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<double?> waistCm = const Value.absent(),
                Value<double?> hipsCm = const Value.absent(),
                Value<double?> chestCm = const Value.absent(),
                Value<double?> neckCm = const Value.absent(),
                Value<double?> armCm = const Value.absent(),
                Value<double?> bodyFatPct = const Value.absent(),
                Value<double?> muscleMassKg = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BodyMeasurementsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                measuredAt: measuredAt,
                weightKg: weightKg,
                waistCm: waistCm,
                hipsCm: hipsCm,
                chestCm: chestCm,
                neckCm: neckCm,
                armCm: armCm,
                bodyFatPct: bodyFatPct,
                muscleMassKg: muscleMassKg,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required DateTime measuredAt,
                Value<double?> weightKg = const Value.absent(),
                Value<double?> waistCm = const Value.absent(),
                Value<double?> hipsCm = const Value.absent(),
                Value<double?> chestCm = const Value.absent(),
                Value<double?> neckCm = const Value.absent(),
                Value<double?> armCm = const Value.absent(),
                Value<double?> bodyFatPct = const Value.absent(),
                Value<double?> muscleMassKg = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BodyMeasurementsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                measuredAt: measuredAt,
                weightKg: weightKg,
                waistCm: waistCm,
                hipsCm: hipsCm,
                chestCm: chestCm,
                neckCm: neckCm,
                armCm: armCm,
                bodyFatPct: bodyFatPct,
                muscleMassKg: muscleMassKg,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BodyMeasurementsTable, BodyMeasurementRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $BodyMeasurementsTable,
                    BodyMeasurementRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BodyMeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BodyMeasurementsTable,
      BodyMeasurementRow,
      $$BodyMeasurementsTableFilterComposer,
      $$BodyMeasurementsTableOrderingComposer,
      $$BodyMeasurementsTableAnnotationComposer,
      $$BodyMeasurementsTableCreateCompanionBuilder,
      $$BodyMeasurementsTableUpdateCompanionBuilder,
      (
        BodyMeasurementRow,
        BaseReferences<
          _$AppDatabase,
          $BodyMeasurementsTable,
          BodyMeasurementRow
        >,
      ),
      BodyMeasurementRow,
      PrefetchHooks Function()
    >;
typedef $$PhotosTableCreateCompanionBuilder = PhotosCompanion Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<int> version,
  required String kind,
  required String pose,
  required String localPath,
  required DateTime takenAt,
  Value<String?> sessionId,
  Value<String?> remotePath,
  Value<int> rowid,
});
typedef $$PhotosTableUpdateCompanionBuilder = PhotosCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<int> version,
  Value<String> kind,
  Value<String> pose,
  Value<String> localPath,
  Value<DateTime> takenAt,
  Value<String?> sessionId,
  Value<String?> remotePath,
  Value<int> rowid,
});

class $$PhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pose => $composableBuilder(
    column: $table.pose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remotePath => $composableBuilder(
    column: $table.remotePath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pose => $composableBuilder(
    column: $table.pose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remotePath => $composableBuilder(
    column: $table.remotePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get pose =>
      $composableBuilder(column: $table.pose, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get remotePath => $composableBuilder(
    column: $table.remotePath,
    builder: (column) => column,
  );
}

class $$PhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotosTable,
          PhotoRow,
          $$PhotosTableFilterComposer,
          $$PhotosTableOrderingComposer,
          $$PhotosTableAnnotationComposer,
          $$PhotosTableCreateCompanionBuilder,
          $$PhotosTableUpdateCompanionBuilder,
          (PhotoRow, BaseReferences<_$AppDatabase, $PhotosTable, PhotoRow>),
          PhotoRow,
          PrefetchHooks Function()
        > {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> pose = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<String?> remotePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                kind: kind,
                pose: pose,
                localPath: localPath,
                takenAt: takenAt,
                sessionId: sessionId,
                remotePath: remotePath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required String kind,
                required String pose,
                required String localPath,
                required DateTime takenAt,
                Value<String?> sessionId = const Value.absent(),
                Value<String?> remotePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                kind: kind,
                pose: pose,
                localPath: localPath,
                takenAt: takenAt,
                sessionId: sessionId,
                remotePath: remotePath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhotosTable, PhotoRow>(table),
                  BaseReferences<_$AppDatabase, $PhotosTable, PhotoRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotosTable,
      PhotoRow,
      $$PhotosTableFilterComposer,
      $$PhotosTableOrderingComposer,
      $$PhotosTableAnnotationComposer,
      $$PhotosTableCreateCompanionBuilder,
      $$PhotosTableUpdateCompanionBuilder,
      (PhotoRow, BaseReferences<_$AppDatabase, $PhotosTable, PhotoRow>),
      PhotoRow,
      PrefetchHooks Function()
    >;
typedef $$GoalsTableCreateCompanionBuilder = GoalsCompanion Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<int> version,
  required String kind,
  Value<String?> title,
  Value<int> priority,
  Value<DateTime?> deadline,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$GoalsTableUpdateCompanionBuilder = GoalsCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<int> version,
  Value<String> kind,
  Value<String?> title,
  Value<int> priority,
  Value<DateTime?> deadline,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          GoalRow,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (GoalRow, BaseReferences<_$AppDatabase, $GoalsTable, GoalRow>),
          GoalRow,
          PrefetchHooks Function()
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                kind: kind,
                title: title,
                priority: priority,
                deadline: deadline,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required String kind,
                Value<String?> title = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<DateTime?> deadline = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                kind: kind,
                title: title,
                priority: priority,
                deadline: deadline,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GoalsTable, GoalRow>(table),
                  BaseReferences<_$AppDatabase, $GoalsTable, GoalRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      GoalRow,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (GoalRow, BaseReferences<_$AppDatabase, $GoalsTable, GoalRow>),
      GoalRow,
      PrefetchHooks Function()
    >;
typedef $$ScheduleSettingsTableCreateCompanionBuilder =
    ScheduleSettingsCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String deviceId,
      Value<int> version,
      Value<String?> institutionType,
      Value<String?> institutionName,
      Value<bool> alternationEnabled,
      Value<DateTime?> week1Anchor,
      Value<int> wakeMinute,
      Value<int> bedMinute,
      Value<int> commuteMinutes,
      Value<String> weekendDays,
      Value<int> rowid,
    });
typedef $$ScheduleSettingsTableUpdateCompanionBuilder =
    ScheduleSettingsCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> deviceId,
      Value<int> version,
      Value<String?> institutionType,
      Value<String?> institutionName,
      Value<bool> alternationEnabled,
      Value<DateTime?> week1Anchor,
      Value<int> wakeMinute,
      Value<int> bedMinute,
      Value<int> commuteMinutes,
      Value<String> weekendDays,
      Value<int> rowid,
    });

class $$ScheduleSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleSettingsTable> {
  $$ScheduleSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institutionType => $composableBuilder(
    column: $table.institutionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institutionName => $composableBuilder(
    column: $table.institutionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get alternationEnabled => $composableBuilder(
    column: $table.alternationEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get week1Anchor => $composableBuilder(
    column: $table.week1Anchor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wakeMinute => $composableBuilder(
    column: $table.wakeMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bedMinute => $composableBuilder(
    column: $table.bedMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get commuteMinutes => $composableBuilder(
    column: $table.commuteMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekendDays => $composableBuilder(
    column: $table.weekendDays,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScheduleSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleSettingsTable> {
  $$ScheduleSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institutionType => $composableBuilder(
    column: $table.institutionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institutionName => $composableBuilder(
    column: $table.institutionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get alternationEnabled => $composableBuilder(
    column: $table.alternationEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get week1Anchor => $composableBuilder(
    column: $table.week1Anchor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wakeMinute => $composableBuilder(
    column: $table.wakeMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bedMinute => $composableBuilder(
    column: $table.bedMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get commuteMinutes => $composableBuilder(
    column: $table.commuteMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekendDays => $composableBuilder(
    column: $table.weekendDays,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScheduleSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleSettingsTable> {
  $$ScheduleSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get institutionType => $composableBuilder(
    column: $table.institutionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get institutionName => $composableBuilder(
    column: $table.institutionName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get alternationEnabled => $composableBuilder(
    column: $table.alternationEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get week1Anchor => $composableBuilder(
    column: $table.week1Anchor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wakeMinute => $composableBuilder(
    column: $table.wakeMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bedMinute =>
      $composableBuilder(column: $table.bedMinute, builder: (column) => column);

  GeneratedColumn<int> get commuteMinutes => $composableBuilder(
    column: $table.commuteMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weekendDays => $composableBuilder(
    column: $table.weekendDays,
    builder: (column) => column,
  );
}

class $$ScheduleSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduleSettingsTable,
          ScheduleSettingsRow,
          $$ScheduleSettingsTableFilterComposer,
          $$ScheduleSettingsTableOrderingComposer,
          $$ScheduleSettingsTableAnnotationComposer,
          $$ScheduleSettingsTableCreateCompanionBuilder,
          $$ScheduleSettingsTableUpdateCompanionBuilder,
          (
            ScheduleSettingsRow,
            BaseReferences<
              _$AppDatabase,
              $ScheduleSettingsTable,
              ScheduleSettingsRow
            >,
          ),
          ScheduleSettingsRow,
          PrefetchHooks Function()
        > {
  $$ScheduleSettingsTableTableManager(
    _$AppDatabase db,
    $ScheduleSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> institutionType = const Value.absent(),
                Value<String?> institutionName = const Value.absent(),
                Value<bool> alternationEnabled = const Value.absent(),
                Value<DateTime?> week1Anchor = const Value.absent(),
                Value<int> wakeMinute = const Value.absent(),
                Value<int> bedMinute = const Value.absent(),
                Value<int> commuteMinutes = const Value.absent(),
                Value<String> weekendDays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleSettingsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                institutionType: institutionType,
                institutionName: institutionName,
                alternationEnabled: alternationEnabled,
                week1Anchor: week1Anchor,
                wakeMinute: wakeMinute,
                bedMinute: bedMinute,
                commuteMinutes: commuteMinutes,
                weekendDays: weekendDays,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                Value<String?> institutionType = const Value.absent(),
                Value<String?> institutionName = const Value.absent(),
                Value<bool> alternationEnabled = const Value.absent(),
                Value<DateTime?> week1Anchor = const Value.absent(),
                Value<int> wakeMinute = const Value.absent(),
                Value<int> bedMinute = const Value.absent(),
                Value<int> commuteMinutes = const Value.absent(),
                Value<String> weekendDays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleSettingsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                institutionType: institutionType,
                institutionName: institutionName,
                alternationEnabled: alternationEnabled,
                week1Anchor: week1Anchor,
                wakeMinute: wakeMinute,
                bedMinute: bedMinute,
                commuteMinutes: commuteMinutes,
                weekendDays: weekendDays,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScheduleSettingsTable, ScheduleSettingsRow>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $ScheduleSettingsTable,
                    ScheduleSettingsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScheduleSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduleSettingsTable,
      ScheduleSettingsRow,
      $$ScheduleSettingsTableFilterComposer,
      $$ScheduleSettingsTableOrderingComposer,
      $$ScheduleSettingsTableAnnotationComposer,
      $$ScheduleSettingsTableCreateCompanionBuilder,
      $$ScheduleSettingsTableUpdateCompanionBuilder,
      (
        ScheduleSettingsRow,
        BaseReferences<
          _$AppDatabase,
          $ScheduleSettingsTable,
          ScheduleSettingsRow
        >,
      ),
      ScheduleSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$ScheduleItemsTableCreateCompanionBuilder =
    ScheduleItemsCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String deviceId,
      Value<int> version,
      required String kind,
      required String title,
      required int weekday,
      required int startMinute,
      required int durationMinutes,
      Value<int> weekParity,
      Value<String?> location,
      Value<bool> requiresCommute,
      Value<int> rowid,
    });
typedef $$ScheduleItemsTableUpdateCompanionBuilder =
    ScheduleItemsCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> deviceId,
      Value<int> version,
      Value<String> kind,
      Value<String> title,
      Value<int> weekday,
      Value<int> startMinute,
      Value<int> durationMinutes,
      Value<int> weekParity,
      Value<String?> location,
      Value<bool> requiresCommute,
      Value<int> rowid,
    });

class $$ScheduleItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleItemsTable> {
  $$ScheduleItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekParity => $composableBuilder(
    column: $table.weekParity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requiresCommute => $composableBuilder(
    column: $table.requiresCommute,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScheduleItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleItemsTable> {
  $$ScheduleItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekParity => $composableBuilder(
    column: $table.weekParity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requiresCommute => $composableBuilder(
    column: $table.requiresCommute,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScheduleItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleItemsTable> {
  $$ScheduleItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<int> get startMinute => $composableBuilder(
    column: $table.startMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMinutes => $composableBuilder(
    column: $table.durationMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get weekParity => $composableBuilder(
    column: $table.weekParity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<bool> get requiresCommute => $composableBuilder(
    column: $table.requiresCommute,
    builder: (column) => column,
  );
}

class $$ScheduleItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduleItemsTable,
          ScheduleItemRow,
          $$ScheduleItemsTableFilterComposer,
          $$ScheduleItemsTableOrderingComposer,
          $$ScheduleItemsTableAnnotationComposer,
          $$ScheduleItemsTableCreateCompanionBuilder,
          $$ScheduleItemsTableUpdateCompanionBuilder,
          (
            ScheduleItemRow,
            BaseReferences<_$AppDatabase, $ScheduleItemsTable, ScheduleItemRow>,
          ),
          ScheduleItemRow,
          PrefetchHooks Function()
        > {
  $$ScheduleItemsTableTableManager(_$AppDatabase db, $ScheduleItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> weekday = const Value.absent(),
                Value<int> startMinute = const Value.absent(),
                Value<int> durationMinutes = const Value.absent(),
                Value<int> weekParity = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<bool> requiresCommute = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleItemsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                kind: kind,
                title: title,
                weekday: weekday,
                startMinute: startMinute,
                durationMinutes: durationMinutes,
                weekParity: weekParity,
                location: location,
                requiresCommute: requiresCommute,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required String kind,
                required String title,
                required int weekday,
                required int startMinute,
                required int durationMinutes,
                Value<int> weekParity = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<bool> requiresCommute = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ScheduleItemsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                kind: kind,
                title: title,
                weekday: weekday,
                startMinute: startMinute,
                durationMinutes: durationMinutes,
                weekParity: weekParity,
                location: location,
                requiresCommute: requiresCommute,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScheduleItemsTable, ScheduleItemRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ScheduleItemsTable,
                    ScheduleItemRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScheduleItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduleItemsTable,
      ScheduleItemRow,
      $$ScheduleItemsTableFilterComposer,
      $$ScheduleItemsTableOrderingComposer,
      $$ScheduleItemsTableAnnotationComposer,
      $$ScheduleItemsTableCreateCompanionBuilder,
      $$ScheduleItemsTableUpdateCompanionBuilder,
      (
        ScheduleItemRow,
        BaseReferences<_$AppDatabase, $ScheduleItemsTable, ScheduleItemRow>,
      ),
      ScheduleItemRow,
      PrefetchHooks Function()
    >;
typedef $$PlansTableCreateCompanionBuilder = PlansCompanion Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<int> version,
  required DateTime createdAt,
  Value<DateTime?> acceptedAt,
  Value<String> source,
  required String payload,
  Value<int> rowid,
});
typedef $$PlansTableUpdateCompanionBuilder = PlansCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<int> version,
  Value<DateTime> createdAt,
  Value<DateTime?> acceptedAt,
  Value<String> source,
  Value<String> payload,
  Value<int> rowid,
});

class $$PlansTableFilterComposer extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlansTableOrderingComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$PlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlansTable,
          PlanRow,
          $$PlansTableFilterComposer,
          $$PlansTableOrderingComposer,
          $$PlansTableAnnotationComposer,
          $$PlansTableCreateCompanionBuilder,
          $$PlansTableUpdateCompanionBuilder,
          (PlanRow, BaseReferences<_$AppDatabase, $PlansTable, PlanRow>),
          PlanRow,
          PrefetchHooks Function()
        > {
  $$PlansTableTableManager(_$AppDatabase db, $PlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> acceptedAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlansCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                createdAt: createdAt,
                acceptedAt: acceptedAt,
                source: source,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> acceptedAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => PlansCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                createdAt: createdAt,
                acceptedAt: acceptedAt,
                source: source,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlansTable, PlanRow>(table),
                  BaseReferences<_$AppDatabase, $PlansTable, PlanRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlansTable,
      PlanRow,
      $$PlansTableFilterComposer,
      $$PlansTableOrderingComposer,
      $$PlansTableAnnotationComposer,
      $$PlansTableCreateCompanionBuilder,
      $$PlansTableUpdateCompanionBuilder,
      (PlanRow, BaseReferences<_$AppDatabase, $PlansTable, PlanRow>),
      PlanRow,
      PrefetchHooks Function()
    >;
typedef $$QuestionnaireSectionsTableCreateCompanionBuilder =
    QuestionnaireSectionsCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String deviceId,
      Value<int> version,
      required String payload,
      Value<int> rowid,
    });
typedef $$QuestionnaireSectionsTableUpdateCompanionBuilder =
    QuestionnaireSectionsCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> deviceId,
      Value<int> version,
      Value<String> payload,
      Value<int> rowid,
    });

class $$QuestionnaireSectionsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionnaireSectionsTable> {
  $$QuestionnaireSectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuestionnaireSectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionnaireSectionsTable> {
  $$QuestionnaireSectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuestionnaireSectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionnaireSectionsTable> {
  $$QuestionnaireSectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$QuestionnaireSectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionnaireSectionsTable,
          QuestionnaireSectionRow,
          $$QuestionnaireSectionsTableFilterComposer,
          $$QuestionnaireSectionsTableOrderingComposer,
          $$QuestionnaireSectionsTableAnnotationComposer,
          $$QuestionnaireSectionsTableCreateCompanionBuilder,
          $$QuestionnaireSectionsTableUpdateCompanionBuilder,
          (
            QuestionnaireSectionRow,
            BaseReferences<
              _$AppDatabase,
              $QuestionnaireSectionsTable,
              QuestionnaireSectionRow
            >,
          ),
          QuestionnaireSectionRow,
          PrefetchHooks Function()
        > {
  $$QuestionnaireSectionsTableTableManager(
    _$AppDatabase db,
    $QuestionnaireSectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionnaireSectionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$QuestionnaireSectionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$QuestionnaireSectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestionnaireSectionsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => QuestionnaireSectionsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $QuestionnaireSectionsTable,
                    QuestionnaireSectionRow
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $QuestionnaireSectionsTable,
                    QuestionnaireSectionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuestionnaireSectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionnaireSectionsTable,
      QuestionnaireSectionRow,
      $$QuestionnaireSectionsTableFilterComposer,
      $$QuestionnaireSectionsTableOrderingComposer,
      $$QuestionnaireSectionsTableAnnotationComposer,
      $$QuestionnaireSectionsTableCreateCompanionBuilder,
      $$QuestionnaireSectionsTableUpdateCompanionBuilder,
      (
        QuestionnaireSectionRow,
        BaseReferences<
          _$AppDatabase,
          $QuestionnaireSectionsTable,
          QuestionnaireSectionRow
        >,
      ),
      QuestionnaireSectionRow,
      PrefetchHooks Function()
    >;
typedef $$QuestsTableCreateCompanionBuilder = QuestsCompanion Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<int> version,
  required String kind,
  Value<String?> stat,
  Value<String?> titleKey,
  Value<String?> title,
  Value<String> params,
  Value<String> subtasks,
  Value<int?> minute,
  Value<int> windowMinutes,
  Value<String> weekdays,
  Value<int> weekParity,
  Value<DateTime?> activeFrom,
  Value<DateTime?> activeUntil,
  Value<int> rewardDiamonds,
  Value<int> rewardXp,
  Value<String> rewardStats,
  Value<int> penaltyDiamonds,
  Value<int?> refusePenaltyDiamonds,
  Value<String> confirm,
  Value<int?> target,
  Value<bool> nag,
  Value<bool> cancellable,
  Value<String> source,
  Value<String?> planId,
  Value<bool> active,
  Value<int> rowid,
});
typedef $$QuestsTableUpdateCompanionBuilder = QuestsCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<int> version,
  Value<String> kind,
  Value<String?> stat,
  Value<String?> titleKey,
  Value<String?> title,
  Value<String> params,
  Value<String> subtasks,
  Value<int?> minute,
  Value<int> windowMinutes,
  Value<String> weekdays,
  Value<int> weekParity,
  Value<DateTime?> activeFrom,
  Value<DateTime?> activeUntil,
  Value<int> rewardDiamonds,
  Value<int> rewardXp,
  Value<String> rewardStats,
  Value<int> penaltyDiamonds,
  Value<int?> refusePenaltyDiamonds,
  Value<String> confirm,
  Value<int?> target,
  Value<bool> nag,
  Value<bool> cancellable,
  Value<String> source,
  Value<String?> planId,
  Value<bool> active,
  Value<int> rowid,
});

class $$QuestsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stat => $composableBuilder(
    column: $table.stat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleKey => $composableBuilder(
    column: $table.titleKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get params => $composableBuilder(
    column: $table.params,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtasks => $composableBuilder(
    column: $table.subtasks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get windowMinutes => $composableBuilder(
    column: $table.windowMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekParity => $composableBuilder(
    column: $table.weekParity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get activeFrom => $composableBuilder(
    column: $table.activeFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get activeUntil => $composableBuilder(
    column: $table.activeUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rewardDiamonds => $composableBuilder(
    column: $table.rewardDiamonds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rewardXp => $composableBuilder(
    column: $table.rewardXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rewardStats => $composableBuilder(
    column: $table.rewardStats,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get penaltyDiamonds => $composableBuilder(
    column: $table.penaltyDiamonds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refusePenaltyDiamonds => $composableBuilder(
    column: $table.refusePenaltyDiamonds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confirm => $composableBuilder(
    column: $table.confirm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get nag => $composableBuilder(
    column: $table.nag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cancellable => $composableBuilder(
    column: $table.cancellable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuestsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stat => $composableBuilder(
    column: $table.stat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleKey => $composableBuilder(
    column: $table.titleKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get params => $composableBuilder(
    column: $table.params,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtasks => $composableBuilder(
    column: $table.subtasks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minute => $composableBuilder(
    column: $table.minute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get windowMinutes => $composableBuilder(
    column: $table.windowMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekdays => $composableBuilder(
    column: $table.weekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekParity => $composableBuilder(
    column: $table.weekParity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get activeFrom => $composableBuilder(
    column: $table.activeFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get activeUntil => $composableBuilder(
    column: $table.activeUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rewardDiamonds => $composableBuilder(
    column: $table.rewardDiamonds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rewardXp => $composableBuilder(
    column: $table.rewardXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rewardStats => $composableBuilder(
    column: $table.rewardStats,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get penaltyDiamonds => $composableBuilder(
    column: $table.penaltyDiamonds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refusePenaltyDiamonds => $composableBuilder(
    column: $table.refusePenaltyDiamonds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confirm => $composableBuilder(
    column: $table.confirm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get nag => $composableBuilder(
    column: $table.nag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cancellable => $composableBuilder(
    column: $table.cancellable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get stat =>
      $composableBuilder(column: $table.stat, builder: (column) => column);

  GeneratedColumn<String> get titleKey =>
      $composableBuilder(column: $table.titleKey, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get params =>
      $composableBuilder(column: $table.params, builder: (column) => column);

  GeneratedColumn<String> get subtasks =>
      $composableBuilder(column: $table.subtasks, builder: (column) => column);

  GeneratedColumn<int> get minute =>
      $composableBuilder(column: $table.minute, builder: (column) => column);

  GeneratedColumn<int> get windowMinutes => $composableBuilder(
    column: $table.windowMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weekdays =>
      $composableBuilder(column: $table.weekdays, builder: (column) => column);

  GeneratedColumn<int> get weekParity => $composableBuilder(
    column: $table.weekParity,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get activeFrom => $composableBuilder(
    column: $table.activeFrom,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get activeUntil => $composableBuilder(
    column: $table.activeUntil,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rewardDiamonds => $composableBuilder(
    column: $table.rewardDiamonds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rewardXp =>
      $composableBuilder(column: $table.rewardXp, builder: (column) => column);

  GeneratedColumn<String> get rewardStats => $composableBuilder(
    column: $table.rewardStats,
    builder: (column) => column,
  );

  GeneratedColumn<int> get penaltyDiamonds => $composableBuilder(
    column: $table.penaltyDiamonds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get refusePenaltyDiamonds => $composableBuilder(
    column: $table.refusePenaltyDiamonds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confirm =>
      $composableBuilder(column: $table.confirm, builder: (column) => column);

  GeneratedColumn<int> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<bool> get nag =>
      $composableBuilder(column: $table.nag, builder: (column) => column);

  GeneratedColumn<bool> get cancellable => $composableBuilder(
    column: $table.cancellable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$QuestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestsTable,
          QuestRow,
          $$QuestsTableFilterComposer,
          $$QuestsTableOrderingComposer,
          $$QuestsTableAnnotationComposer,
          $$QuestsTableCreateCompanionBuilder,
          $$QuestsTableUpdateCompanionBuilder,
          (QuestRow, BaseReferences<_$AppDatabase, $QuestsTable, QuestRow>),
          QuestRow,
          PrefetchHooks Function()
        > {
  $$QuestsTableTableManager(_$AppDatabase db, $QuestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> stat = const Value.absent(),
                Value<String?> titleKey = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String> params = const Value.absent(),
                Value<String> subtasks = const Value.absent(),
                Value<int?> minute = const Value.absent(),
                Value<int> windowMinutes = const Value.absent(),
                Value<String> weekdays = const Value.absent(),
                Value<int> weekParity = const Value.absent(),
                Value<DateTime?> activeFrom = const Value.absent(),
                Value<DateTime?> activeUntil = const Value.absent(),
                Value<int> rewardDiamonds = const Value.absent(),
                Value<int> rewardXp = const Value.absent(),
                Value<String> rewardStats = const Value.absent(),
                Value<int> penaltyDiamonds = const Value.absent(),
                Value<int?> refusePenaltyDiamonds = const Value.absent(),
                Value<String> confirm = const Value.absent(),
                Value<int?> target = const Value.absent(),
                Value<bool> nag = const Value.absent(),
                Value<bool> cancellable = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> planId = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                kind: kind,
                stat: stat,
                titleKey: titleKey,
                title: title,
                params: params,
                subtasks: subtasks,
                minute: minute,
                windowMinutes: windowMinutes,
                weekdays: weekdays,
                weekParity: weekParity,
                activeFrom: activeFrom,
                activeUntil: activeUntil,
                rewardDiamonds: rewardDiamonds,
                rewardXp: rewardXp,
                rewardStats: rewardStats,
                penaltyDiamonds: penaltyDiamonds,
                refusePenaltyDiamonds: refusePenaltyDiamonds,
                confirm: confirm,
                target: target,
                nag: nag,
                cancellable: cancellable,
                source: source,
                planId: planId,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required String kind,
                Value<String?> stat = const Value.absent(),
                Value<String?> titleKey = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String> params = const Value.absent(),
                Value<String> subtasks = const Value.absent(),
                Value<int?> minute = const Value.absent(),
                Value<int> windowMinutes = const Value.absent(),
                Value<String> weekdays = const Value.absent(),
                Value<int> weekParity = const Value.absent(),
                Value<DateTime?> activeFrom = const Value.absent(),
                Value<DateTime?> activeUntil = const Value.absent(),
                Value<int> rewardDiamonds = const Value.absent(),
                Value<int> rewardXp = const Value.absent(),
                Value<String> rewardStats = const Value.absent(),
                Value<int> penaltyDiamonds = const Value.absent(),
                Value<int?> refusePenaltyDiamonds = const Value.absent(),
                Value<String> confirm = const Value.absent(),
                Value<int?> target = const Value.absent(),
                Value<bool> nag = const Value.absent(),
                Value<bool> cancellable = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> planId = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                kind: kind,
                stat: stat,
                titleKey: titleKey,
                title: title,
                params: params,
                subtasks: subtasks,
                minute: minute,
                windowMinutes: windowMinutes,
                weekdays: weekdays,
                weekParity: weekParity,
                activeFrom: activeFrom,
                activeUntil: activeUntil,
                rewardDiamonds: rewardDiamonds,
                rewardXp: rewardXp,
                rewardStats: rewardStats,
                penaltyDiamonds: penaltyDiamonds,
                refusePenaltyDiamonds: refusePenaltyDiamonds,
                confirm: confirm,
                target: target,
                nag: nag,
                cancellable: cancellable,
                source: source,
                planId: planId,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuestsTable, QuestRow>(table),
                  BaseReferences<_$AppDatabase, $QuestsTable, QuestRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestsTable,
      QuestRow,
      $$QuestsTableFilterComposer,
      $$QuestsTableOrderingComposer,
      $$QuestsTableAnnotationComposer,
      $$QuestsTableCreateCompanionBuilder,
      $$QuestsTableUpdateCompanionBuilder,
      (QuestRow, BaseReferences<_$AppDatabase, $QuestsTable, QuestRow>),
      QuestRow,
      PrefetchHooks Function()
    >;
typedef $$QuestInstancesTableCreateCompanionBuilder =
    QuestInstancesCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String deviceId,
      Value<int> version,
      required String questId,
      required DateTime day,
      Value<DateTime?> startsAt,
      required DateTime deadlineAt,
      Value<String> status,
      Value<DateTime?> resolvedAt,
      Value<DateTime?> snoozedUntil,
      Value<int> snoozeCount,
      Value<int> progress,
      Value<String> subtasksDone,
      Value<int> rewardDiamonds,
      Value<int> rewardXp,
      Value<String> rewardStats,
      Value<int> penaltyDiamonds,
      Value<int> refusePenaltyDiamonds,
      Value<int> rowid,
    });
typedef $$QuestInstancesTableUpdateCompanionBuilder =
    QuestInstancesCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> deviceId,
      Value<int> version,
      Value<String> questId,
      Value<DateTime> day,
      Value<DateTime?> startsAt,
      Value<DateTime> deadlineAt,
      Value<String> status,
      Value<DateTime?> resolvedAt,
      Value<DateTime?> snoozedUntil,
      Value<int> snoozeCount,
      Value<int> progress,
      Value<String> subtasksDone,
      Value<int> rewardDiamonds,
      Value<int> rewardXp,
      Value<String> rewardStats,
      Value<int> penaltyDiamonds,
      Value<int> refusePenaltyDiamonds,
      Value<int> rowid,
    });

class $$QuestInstancesTableFilterComposer
    extends Composer<_$AppDatabase, $QuestInstancesTable> {
  $$QuestInstancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questId => $composableBuilder(
    column: $table.questId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadlineAt => $composableBuilder(
    column: $table.deadlineAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtasksDone => $composableBuilder(
    column: $table.subtasksDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rewardDiamonds => $composableBuilder(
    column: $table.rewardDiamonds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rewardXp => $composableBuilder(
    column: $table.rewardXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rewardStats => $composableBuilder(
    column: $table.rewardStats,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get penaltyDiamonds => $composableBuilder(
    column: $table.penaltyDiamonds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refusePenaltyDiamonds => $composableBuilder(
    column: $table.refusePenaltyDiamonds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuestInstancesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestInstancesTable> {
  $$QuestInstancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questId => $composableBuilder(
    column: $table.questId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadlineAt => $composableBuilder(
    column: $table.deadlineAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtasksDone => $composableBuilder(
    column: $table.subtasksDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rewardDiamonds => $composableBuilder(
    column: $table.rewardDiamonds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rewardXp => $composableBuilder(
    column: $table.rewardXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rewardStats => $composableBuilder(
    column: $table.rewardStats,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get penaltyDiamonds => $composableBuilder(
    column: $table.penaltyDiamonds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refusePenaltyDiamonds => $composableBuilder(
    column: $table.refusePenaltyDiamonds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuestInstancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestInstancesTable> {
  $$QuestInstancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get questId =>
      $composableBuilder(column: $table.questId, builder: (column) => column);

  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get startsAt =>
      $composableBuilder(column: $table.startsAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deadlineAt => $composableBuilder(
    column: $table.deadlineAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get snoozedUntil => $composableBuilder(
    column: $table.snoozedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get subtasksDone => $composableBuilder(
    column: $table.subtasksDone,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rewardDiamonds => $composableBuilder(
    column: $table.rewardDiamonds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rewardXp =>
      $composableBuilder(column: $table.rewardXp, builder: (column) => column);

  GeneratedColumn<String> get rewardStats => $composableBuilder(
    column: $table.rewardStats,
    builder: (column) => column,
  );

  GeneratedColumn<int> get penaltyDiamonds => $composableBuilder(
    column: $table.penaltyDiamonds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get refusePenaltyDiamonds => $composableBuilder(
    column: $table.refusePenaltyDiamonds,
    builder: (column) => column,
  );
}

class $$QuestInstancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestInstancesTable,
          QuestInstanceRow,
          $$QuestInstancesTableFilterComposer,
          $$QuestInstancesTableOrderingComposer,
          $$QuestInstancesTableAnnotationComposer,
          $$QuestInstancesTableCreateCompanionBuilder,
          $$QuestInstancesTableUpdateCompanionBuilder,
          (
            QuestInstanceRow,
            BaseReferences<
              _$AppDatabase,
              $QuestInstancesTable,
              QuestInstanceRow
            >,
          ),
          QuestInstanceRow,
          PrefetchHooks Function()
        > {
  $$QuestInstancesTableTableManager(
    _$AppDatabase db,
    $QuestInstancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestInstancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestInstancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestInstancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> questId = const Value.absent(),
                Value<DateTime> day = const Value.absent(),
                Value<DateTime?> startsAt = const Value.absent(),
                Value<DateTime> deadlineAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<int> snoozeCount = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<String> subtasksDone = const Value.absent(),
                Value<int> rewardDiamonds = const Value.absent(),
                Value<int> rewardXp = const Value.absent(),
                Value<String> rewardStats = const Value.absent(),
                Value<int> penaltyDiamonds = const Value.absent(),
                Value<int> refusePenaltyDiamonds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestInstancesCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                questId: questId,
                day: day,
                startsAt: startsAt,
                deadlineAt: deadlineAt,
                status: status,
                resolvedAt: resolvedAt,
                snoozedUntil: snoozedUntil,
                snoozeCount: snoozeCount,
                progress: progress,
                subtasksDone: subtasksDone,
                rewardDiamonds: rewardDiamonds,
                rewardXp: rewardXp,
                rewardStats: rewardStats,
                penaltyDiamonds: penaltyDiamonds,
                refusePenaltyDiamonds: refusePenaltyDiamonds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required String questId,
                required DateTime day,
                Value<DateTime?> startsAt = const Value.absent(),
                required DateTime deadlineAt,
                Value<String> status = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<DateTime?> snoozedUntil = const Value.absent(),
                Value<int> snoozeCount = const Value.absent(),
                Value<int> progress = const Value.absent(),
                Value<String> subtasksDone = const Value.absent(),
                Value<int> rewardDiamonds = const Value.absent(),
                Value<int> rewardXp = const Value.absent(),
                Value<String> rewardStats = const Value.absent(),
                Value<int> penaltyDiamonds = const Value.absent(),
                Value<int> refusePenaltyDiamonds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestInstancesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                questId: questId,
                day: day,
                startsAt: startsAt,
                deadlineAt: deadlineAt,
                status: status,
                resolvedAt: resolvedAt,
                snoozedUntil: snoozedUntil,
                snoozeCount: snoozeCount,
                progress: progress,
                subtasksDone: subtasksDone,
                rewardDiamonds: rewardDiamonds,
                rewardXp: rewardXp,
                rewardStats: rewardStats,
                penaltyDiamonds: penaltyDiamonds,
                refusePenaltyDiamonds: refusePenaltyDiamonds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuestInstancesTable, QuestInstanceRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $QuestInstancesTable,
                    QuestInstanceRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuestInstancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestInstancesTable,
      QuestInstanceRow,
      $$QuestInstancesTableFilterComposer,
      $$QuestInstancesTableOrderingComposer,
      $$QuestInstancesTableAnnotationComposer,
      $$QuestInstancesTableCreateCompanionBuilder,
      $$QuestInstancesTableUpdateCompanionBuilder,
      (
        QuestInstanceRow,
        BaseReferences<_$AppDatabase, $QuestInstancesTable, QuestInstanceRow>,
      ),
      QuestInstanceRow,
      PrefetchHooks Function()
    >;
typedef $$QuestEventsTableCreateCompanionBuilder =
    QuestEventsCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String deviceId,
      Value<int> version,
      required String type,
      required DateTime occurredAt,
      Value<String?> questId,
      Value<String?> instanceId,
      Value<int> diamonds,
      Value<int> xp,
      Value<String> stats,
      Value<String> payload,
      Value<int> rowid,
    });
typedef $$QuestEventsTableUpdateCompanionBuilder =
    QuestEventsCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> deviceId,
      Value<int> version,
      Value<String> type,
      Value<DateTime> occurredAt,
      Value<String?> questId,
      Value<String?> instanceId,
      Value<int> diamonds,
      Value<int> xp,
      Value<String> stats,
      Value<String> payload,
      Value<int> rowid,
    });

class $$QuestEventsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestEventsTable> {
  $$QuestEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questId => $composableBuilder(
    column: $table.questId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instanceId => $composableBuilder(
    column: $table.instanceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diamonds => $composableBuilder(
    column: $table.diamonds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stats => $composableBuilder(
    column: $table.stats,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuestEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestEventsTable> {
  $$QuestEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questId => $composableBuilder(
    column: $table.questId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instanceId => $composableBuilder(
    column: $table.instanceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diamonds => $composableBuilder(
    column: $table.diamonds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stats => $composableBuilder(
    column: $table.stats,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuestEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestEventsTable> {
  $$QuestEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get questId =>
      $composableBuilder(column: $table.questId, builder: (column) => column);

  GeneratedColumn<String> get instanceId => $composableBuilder(
    column: $table.instanceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get diamonds =>
      $composableBuilder(column: $table.diamonds, builder: (column) => column);

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  GeneratedColumn<String> get stats =>
      $composableBuilder(column: $table.stats, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$QuestEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestEventsTable,
          QuestEventRow,
          $$QuestEventsTableFilterComposer,
          $$QuestEventsTableOrderingComposer,
          $$QuestEventsTableAnnotationComposer,
          $$QuestEventsTableCreateCompanionBuilder,
          $$QuestEventsTableUpdateCompanionBuilder,
          (
            QuestEventRow,
            BaseReferences<_$AppDatabase, $QuestEventsTable, QuestEventRow>,
          ),
          QuestEventRow,
          PrefetchHooks Function()
        > {
  $$QuestEventsTableTableManager(_$AppDatabase db, $QuestEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String?> questId = const Value.absent(),
                Value<String?> instanceId = const Value.absent(),
                Value<int> diamonds = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<String> stats = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestEventsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                type: type,
                occurredAt: occurredAt,
                questId: questId,
                instanceId: instanceId,
                diamonds: diamonds,
                xp: xp,
                stats: stats,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required String type,
                required DateTime occurredAt,
                Value<String?> questId = const Value.absent(),
                Value<String?> instanceId = const Value.absent(),
                Value<int> diamonds = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<String> stats = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestEventsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                type: type,
                occurredAt: occurredAt,
                questId: questId,
                instanceId: instanceId,
                diamonds: diamonds,
                xp: xp,
                stats: stats,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuestEventsTable, QuestEventRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $QuestEventsTable,
                    QuestEventRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuestEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestEventsTable,
      QuestEventRow,
      $$QuestEventsTableFilterComposer,
      $$QuestEventsTableOrderingComposer,
      $$QuestEventsTableAnnotationComposer,
      $$QuestEventsTableCreateCompanionBuilder,
      $$QuestEventsTableUpdateCompanionBuilder,
      (
        QuestEventRow,
        BaseReferences<_$AppDatabase, $QuestEventsTable, QuestEventRow>,
      ),
      QuestEventRow,
      PrefetchHooks Function()
    >;
typedef $$EffectsTableCreateCompanionBuilder = EffectsCompanion Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<int> version,
  required String kind,
  required DateTime startsAt,
  required DateTime expiresAt,
  Value<String?> sourceEventId,
  Value<String> payload,
  Value<int> rowid,
});
typedef $$EffectsTableUpdateCompanionBuilder = EffectsCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<int> version,
  Value<String> kind,
  Value<DateTime> startsAt,
  Value<DateTime> expiresAt,
  Value<String?> sourceEventId,
  Value<String> payload,
  Value<int> rowid,
});

class $$EffectsTableFilterComposer
    extends Composer<_$AppDatabase, $EffectsTable> {
  $$EffectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceEventId => $composableBuilder(
    column: $table.sourceEventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EffectsTableOrderingComposer
    extends Composer<_$AppDatabase, $EffectsTable> {
  $$EffectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceEventId => $composableBuilder(
    column: $table.sourceEventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EffectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EffectsTable> {
  $$EffectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get startsAt =>
      $composableBuilder(column: $table.startsAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get sourceEventId => $composableBuilder(
    column: $table.sourceEventId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$EffectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EffectsTable,
          EffectRow,
          $$EffectsTableFilterComposer,
          $$EffectsTableOrderingComposer,
          $$EffectsTableAnnotationComposer,
          $$EffectsTableCreateCompanionBuilder,
          $$EffectsTableUpdateCompanionBuilder,
          (EffectRow, BaseReferences<_$AppDatabase, $EffectsTable, EffectRow>),
          EffectRow,
          PrefetchHooks Function()
        > {
  $$EffectsTableTableManager(_$AppDatabase db, $EffectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EffectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EffectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EffectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<DateTime> startsAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<String?> sourceEventId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EffectsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                kind: kind,
                startsAt: startsAt,
                expiresAt: expiresAt,
                sourceEventId: sourceEventId,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required String kind,
                required DateTime startsAt,
                required DateTime expiresAt,
                Value<String?> sourceEventId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EffectsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                kind: kind,
                startsAt: startsAt,
                expiresAt: expiresAt,
                sourceEventId: sourceEventId,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EffectsTable, EffectRow>(table),
                  BaseReferences<_$AppDatabase, $EffectsTable, EffectRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EffectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EffectsTable,
      EffectRow,
      $$EffectsTableFilterComposer,
      $$EffectsTableOrderingComposer,
      $$EffectsTableAnnotationComposer,
      $$EffectsTableCreateCompanionBuilder,
      $$EffectsTableUpdateCompanionBuilder,
      (EffectRow, BaseReferences<_$AppDatabase, $EffectsTable, EffectRow>),
      EffectRow,
      PrefetchHooks Function()
    >;
typedef $$PausesTableCreateCompanionBuilder = PausesCompanion Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<int> version,
  required String reason,
  required DateTime startsAt,
  Value<DateTime?> endsAt,
  Value<int> rowid,
});
typedef $$PausesTableUpdateCompanionBuilder = PausesCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<int> version,
  Value<String> reason,
  Value<DateTime> startsAt,
  Value<DateTime?> endsAt,
  Value<int> rowid,
});

class $$PausesTableFilterComposer
    extends Composer<_$AppDatabase, $PausesTable> {
  $$PausesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PausesTableOrderingComposer
    extends Composer<_$AppDatabase, $PausesTable> {
  $$PausesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PausesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PausesTable> {
  $$PausesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get startsAt =>
      $composableBuilder(column: $table.startsAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endsAt =>
      $composableBuilder(column: $table.endsAt, builder: (column) => column);
}

class $$PausesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PausesTable,
          PauseRow,
          $$PausesTableFilterComposer,
          $$PausesTableOrderingComposer,
          $$PausesTableAnnotationComposer,
          $$PausesTableCreateCompanionBuilder,
          $$PausesTableUpdateCompanionBuilder,
          (PauseRow, BaseReferences<_$AppDatabase, $PausesTable, PauseRow>),
          PauseRow,
          PrefetchHooks Function()
        > {
  $$PausesTableTableManager(_$AppDatabase db, $PausesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PausesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PausesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PausesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<DateTime> startsAt = const Value.absent(),
                Value<DateTime?> endsAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PausesCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                reason: reason,
                startsAt: startsAt,
                endsAt: endsAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required String reason,
                required DateTime startsAt,
                Value<DateTime?> endsAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PausesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                reason: reason,
                startsAt: startsAt,
                endsAt: endsAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PausesTable, PauseRow>(table),
                  BaseReferences<_$AppDatabase, $PausesTable, PauseRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PausesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PausesTable,
      PauseRow,
      $$PausesTableFilterComposer,
      $$PausesTableOrderingComposer,
      $$PausesTableAnnotationComposer,
      $$PausesTableCreateCompanionBuilder,
      $$PausesTableUpdateCompanionBuilder,
      (PauseRow, BaseReferences<_$AppDatabase, $PausesTable, PauseRow>),
      PauseRow,
      PrefetchHooks Function()
    >;
typedef $$RewardsTableCreateCompanionBuilder = RewardsCompanion Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<int> version,
  required String title,
  required int price,
  Value<int?> limitCount,
  Value<String?> limitPeriod,
  Value<bool> active,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$RewardsTableUpdateCompanionBuilder = RewardsCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<int> version,
  Value<String> title,
  Value<int> price,
  Value<int?> limitCount,
  Value<String?> limitPeriod,
  Value<bool> active,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$RewardsTableFilterComposer
    extends Composer<_$AppDatabase, $RewardsTable> {
  $$RewardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limitCount => $composableBuilder(
    column: $table.limitCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get limitPeriod => $composableBuilder(
    column: $table.limitPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RewardsTableOrderingComposer
    extends Composer<_$AppDatabase, $RewardsTable> {
  $$RewardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limitCount => $composableBuilder(
    column: $table.limitCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get limitPeriod => $composableBuilder(
    column: $table.limitPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RewardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RewardsTable> {
  $$RewardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get limitCount => $composableBuilder(
    column: $table.limitCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get limitPeriod => $composableBuilder(
    column: $table.limitPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$RewardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RewardsTable,
          RewardRow,
          $$RewardsTableFilterComposer,
          $$RewardsTableOrderingComposer,
          $$RewardsTableAnnotationComposer,
          $$RewardsTableCreateCompanionBuilder,
          $$RewardsTableUpdateCompanionBuilder,
          (RewardRow, BaseReferences<_$AppDatabase, $RewardsTable, RewardRow>),
          RewardRow,
          PrefetchHooks Function()
        > {
  $$RewardsTableTableManager(_$AppDatabase db, $RewardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RewardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RewardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RewardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> price = const Value.absent(),
                Value<int?> limitCount = const Value.absent(),
                Value<String?> limitPeriod = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RewardsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                title: title,
                price: price,
                limitCount: limitCount,
                limitPeriod: limitPeriod,
                active: active,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required String title,
                required int price,
                Value<int?> limitCount = const Value.absent(),
                Value<String?> limitPeriod = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RewardsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                title: title,
                price: price,
                limitCount: limitCount,
                limitPeriod: limitPeriod,
                active: active,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RewardsTable, RewardRow>(table),
                  BaseReferences<_$AppDatabase, $RewardsTable, RewardRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RewardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RewardsTable,
      RewardRow,
      $$RewardsTableFilterComposer,
      $$RewardsTableOrderingComposer,
      $$RewardsTableAnnotationComposer,
      $$RewardsTableCreateCompanionBuilder,
      $$RewardsTableUpdateCompanionBuilder,
      (RewardRow, BaseReferences<_$AppDatabase, $RewardsTable, RewardRow>),
      RewardRow,
      PrefetchHooks Function()
    >;
typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String deviceId,
      Value<int> version,
      required String value,
      Value<int> rowid,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> deviceId,
      Value<int> version,
      Value<String> value,
      Value<int> rowid,
    });

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$UserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTable,
          UserSettingRow,
          $$UserSettingsTableFilterComposer,
          $$UserSettingsTableOrderingComposer,
          $$UserSettingsTableAnnotationComposer,
          $$UserSettingsTableCreateCompanionBuilder,
          $$UserSettingsTableUpdateCompanionBuilder,
          (
            UserSettingRow,
            BaseReferences<_$AppDatabase, $UserSettingsTable, UserSettingRow>,
          ),
          UserSettingRow,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserSettingsTable, UserSettingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserSettingsTable,
                    UserSettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTable,
      UserSettingRow,
      $$UserSettingsTableFilterComposer,
      $$UserSettingsTableOrderingComposer,
      $$UserSettingsTableAnnotationComposer,
      $$UserSettingsTableCreateCompanionBuilder,
      $$UserSettingsTableUpdateCompanionBuilder,
      (
        UserSettingRow,
        BaseReferences<_$AppDatabase, $UserSettingsTable, UserSettingRow>,
      ),
      UserSettingRow,
      PrefetchHooks Function()
    >;
typedef $$FoodItemsTableCreateCompanionBuilder = FoodItemsCompanion Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<int> version,
  required String name,
  Value<String?> brand,
  Value<String?> barcode,
  required double kcal100,
  Value<double> protein100,
  Value<double> fat100,
  Value<double> carbs100,
  Value<double?> servingG,
  Value<String> source,
  Value<bool> favorite,
  Value<int> rowid,
});
typedef $$FoodItemsTableUpdateCompanionBuilder = FoodItemsCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<int> version,
  Value<String> name,
  Value<String?> brand,
  Value<String?> barcode,
  Value<double> kcal100,
  Value<double> protein100,
  Value<double> fat100,
  Value<double> carbs100,
  Value<double?> servingG,
  Value<String> source,
  Value<bool> favorite,
  Value<int> rowid,
});

class $$FoodItemsTableFilterComposer
    extends Composer<_$AppDatabase, $FoodItemsTable> {
  $$FoodItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal100 => $composableBuilder(
    column: $table.kcal100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein100 => $composableBuilder(
    column: $table.protein100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat100 => $composableBuilder(
    column: $table.fat100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs100 => $composableBuilder(
    column: $table.carbs100,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servingG => $composableBuilder(
    column: $table.servingG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FoodItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodItemsTable> {
  $$FoodItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal100 => $composableBuilder(
    column: $table.kcal100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein100 => $composableBuilder(
    column: $table.protein100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat100 => $composableBuilder(
    column: $table.fat100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs100 => $composableBuilder(
    column: $table.carbs100,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servingG => $composableBuilder(
    column: $table.servingG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodItemsTable> {
  $$FoodItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<double> get kcal100 =>
      $composableBuilder(column: $table.kcal100, builder: (column) => column);

  GeneratedColumn<double> get protein100 => $composableBuilder(
    column: $table.protein100,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fat100 =>
      $composableBuilder(column: $table.fat100, builder: (column) => column);

  GeneratedColumn<double> get carbs100 =>
      $composableBuilder(column: $table.carbs100, builder: (column) => column);

  GeneratedColumn<double> get servingG =>
      $composableBuilder(column: $table.servingG, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);
}

class $$FoodItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodItemsTable,
          FoodItemRow,
          $$FoodItemsTableFilterComposer,
          $$FoodItemsTableOrderingComposer,
          $$FoodItemsTableAnnotationComposer,
          $$FoodItemsTableCreateCompanionBuilder,
          $$FoodItemsTableUpdateCompanionBuilder,
          (
            FoodItemRow,
            BaseReferences<_$AppDatabase, $FoodItemsTable, FoodItemRow>,
          ),
          FoodItemRow,
          PrefetchHooks Function()
        > {
  $$FoodItemsTableTableManager(_$AppDatabase db, $FoodItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<double> kcal100 = const Value.absent(),
                Value<double> protein100 = const Value.absent(),
                Value<double> fat100 = const Value.absent(),
                Value<double> carbs100 = const Value.absent(),
                Value<double?> servingG = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodItemsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                name: name,
                brand: brand,
                barcode: barcode,
                kcal100: kcal100,
                protein100: protein100,
                fat100: fat100,
                carbs100: carbs100,
                servingG: servingG,
                source: source,
                favorite: favorite,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required String name,
                Value<String?> brand = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                required double kcal100,
                Value<double> protein100 = const Value.absent(),
                Value<double> fat100 = const Value.absent(),
                Value<double> carbs100 = const Value.absent(),
                Value<double?> servingG = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoodItemsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                name: name,
                brand: brand,
                barcode: barcode,
                kcal100: kcal100,
                protein100: protein100,
                fat100: fat100,
                carbs100: carbs100,
                servingG: servingG,
                source: source,
                favorite: favorite,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoodItemsTable, FoodItemRow>(table),
                  BaseReferences<_$AppDatabase, $FoodItemsTable, FoodItemRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FoodItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodItemsTable,
      FoodItemRow,
      $$FoodItemsTableFilterComposer,
      $$FoodItemsTableOrderingComposer,
      $$FoodItemsTableAnnotationComposer,
      $$FoodItemsTableCreateCompanionBuilder,
      $$FoodItemsTableUpdateCompanionBuilder,
      (
        FoodItemRow,
        BaseReferences<_$AppDatabase, $FoodItemsTable, FoodItemRow>,
      ),
      FoodItemRow,
      PrefetchHooks Function()
    >;
typedef $$MealEntriesTableCreateCompanionBuilder =
    MealEntriesCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String deviceId,
      Value<int> version,
      required DateTime eatenAt,
      required String mealType,
      required String title,
      Value<String?> foodItemId,
      Value<String?> recipeId,
      Value<double?> grams,
      required double kcal,
      Value<double> protein,
      Value<double> fat,
      Value<double> carbs,
      Value<String?> photoId,
      Value<int> rowid,
    });
typedef $$MealEntriesTableUpdateCompanionBuilder =
    MealEntriesCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> deviceId,
      Value<int> version,
      Value<DateTime> eatenAt,
      Value<String> mealType,
      Value<String> title,
      Value<String?> foodItemId,
      Value<String?> recipeId,
      Value<double?> grams,
      Value<double> kcal,
      Value<double> protein,
      Value<double> fat,
      Value<double> carbs,
      Value<String?> photoId,
      Value<int> rowid,
    });

class $$MealEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MealEntriesTable> {
  $$MealEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eatenAt => $composableBuilder(
    column: $table.eatenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodItemId => $composableBuilder(
    column: $table.foodItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoId => $composableBuilder(
    column: $table.photoId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MealEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MealEntriesTable> {
  $$MealEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eatenAt => $composableBuilder(
    column: $table.eatenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealType => $composableBuilder(
    column: $table.mealType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodItemId => $composableBuilder(
    column: $table.foodItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get grams => $composableBuilder(
    column: $table.grams,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoId => $composableBuilder(
    column: $table.photoId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MealEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealEntriesTable> {
  $$MealEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get eatenAt =>
      $composableBuilder(column: $table.eatenAt, builder: (column) => column);

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get foodItemId => $composableBuilder(
    column: $table.foodItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<String> get photoId =>
      $composableBuilder(column: $table.photoId, builder: (column) => column);
}

class $$MealEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealEntriesTable,
          MealEntryRow,
          $$MealEntriesTableFilterComposer,
          $$MealEntriesTableOrderingComposer,
          $$MealEntriesTableAnnotationComposer,
          $$MealEntriesTableCreateCompanionBuilder,
          $$MealEntriesTableUpdateCompanionBuilder,
          (
            MealEntryRow,
            BaseReferences<_$AppDatabase, $MealEntriesTable, MealEntryRow>,
          ),
          MealEntryRow,
          PrefetchHooks Function()
        > {
  $$MealEntriesTableTableManager(_$AppDatabase db, $MealEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> eatenAt = const Value.absent(),
                Value<String> mealType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> foodItemId = const Value.absent(),
                Value<String?> recipeId = const Value.absent(),
                Value<double?> grams = const Value.absent(),
                Value<double> kcal = const Value.absent(),
                Value<double> protein = const Value.absent(),
                Value<double> fat = const Value.absent(),
                Value<double> carbs = const Value.absent(),
                Value<String?> photoId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealEntriesCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                eatenAt: eatenAt,
                mealType: mealType,
                title: title,
                foodItemId: foodItemId,
                recipeId: recipeId,
                grams: grams,
                kcal: kcal,
                protein: protein,
                fat: fat,
                carbs: carbs,
                photoId: photoId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required DateTime eatenAt,
                required String mealType,
                required String title,
                Value<String?> foodItemId = const Value.absent(),
                Value<String?> recipeId = const Value.absent(),
                Value<double?> grams = const Value.absent(),
                required double kcal,
                Value<double> protein = const Value.absent(),
                Value<double> fat = const Value.absent(),
                Value<double> carbs = const Value.absent(),
                Value<String?> photoId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealEntriesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                eatenAt: eatenAt,
                mealType: mealType,
                title: title,
                foodItemId: foodItemId,
                recipeId: recipeId,
                grams: grams,
                kcal: kcal,
                protein: protein,
                fat: fat,
                carbs: carbs,
                photoId: photoId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MealEntriesTable, MealEntryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MealEntriesTable,
                    MealEntryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MealEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealEntriesTable,
      MealEntryRow,
      $$MealEntriesTableFilterComposer,
      $$MealEntriesTableOrderingComposer,
      $$MealEntriesTableAnnotationComposer,
      $$MealEntriesTableCreateCompanionBuilder,
      $$MealEntriesTableUpdateCompanionBuilder,
      (
        MealEntryRow,
        BaseReferences<_$AppDatabase, $MealEntriesTable, MealEntryRow>,
      ),
      MealEntryRow,
      PrefetchHooks Function()
    >;
typedef $$RecipesTableCreateCompanionBuilder = RecipesCompanion Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<int> version,
  required String title,
  Value<String> items,
  Value<int> servings,
  Value<double> kcal,
  Value<double> protein,
  Value<double> fat,
  Value<double> carbs,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $$RecipesTableUpdateCompanionBuilder = RecipesCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<int> version,
  Value<String> title,
  Value<String> items,
  Value<int> servings,
  Value<double> kcal,
  Value<double> protein,
  Value<double> fat,
  Value<double> carbs,
  Value<int> sortOrder,
  Value<int> rowid,
});

class $$RecipesTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get items => $composableBuilder(
    column: $table.items,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get items => $composableBuilder(
    column: $table.items,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get servings => $composableBuilder(
    column: $table.servings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get items =>
      $composableBuilder(column: $table.items, builder: (column) => column);

  GeneratedColumn<int> get servings =>
      $composableBuilder(column: $table.servings, builder: (column) => column);

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$RecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipesTable,
          RecipeRow,
          $$RecipesTableFilterComposer,
          $$RecipesTableOrderingComposer,
          $$RecipesTableAnnotationComposer,
          $$RecipesTableCreateCompanionBuilder,
          $$RecipesTableUpdateCompanionBuilder,
          (RecipeRow, BaseReferences<_$AppDatabase, $RecipesTable, RecipeRow>),
          RecipeRow,
          PrefetchHooks Function()
        > {
  $$RecipesTableTableManager(_$AppDatabase db, $RecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> items = const Value.absent(),
                Value<int> servings = const Value.absent(),
                Value<double> kcal = const Value.absent(),
                Value<double> protein = const Value.absent(),
                Value<double> fat = const Value.absent(),
                Value<double> carbs = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                title: title,
                items: items,
                servings: servings,
                kcal: kcal,
                protein: protein,
                fat: fat,
                carbs: carbs,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required String title,
                Value<String> items = const Value.absent(),
                Value<int> servings = const Value.absent(),
                Value<double> kcal = const Value.absent(),
                Value<double> protein = const Value.absent(),
                Value<double> fat = const Value.absent(),
                Value<double> carbs = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                title: title,
                items: items,
                servings: servings,
                kcal: kcal,
                protein: protein,
                fat: fat,
                carbs: carbs,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecipesTable, RecipeRow>(table),
                  BaseReferences<_$AppDatabase, $RecipesTable, RecipeRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipesTable,
      RecipeRow,
      $$RecipesTableFilterComposer,
      $$RecipesTableOrderingComposer,
      $$RecipesTableAnnotationComposer,
      $$RecipesTableCreateCompanionBuilder,
      $$RecipesTableUpdateCompanionBuilder,
      (RecipeRow, BaseReferences<_$AppDatabase, $RecipesTable, RecipeRow>),
      RecipeRow,
      PrefetchHooks Function()
    >;
typedef $$WaterLogsTableCreateCompanionBuilder = WaterLogsCompanion Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<int> version,
  required DateTime loggedAt,
  required int ml,
  Value<int> rowid,
});
typedef $$WaterLogsTableUpdateCompanionBuilder = WaterLogsCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<int> version,
  Value<DateTime> loggedAt,
  Value<int> ml,
  Value<int> rowid,
});

class $$WaterLogsTableFilterComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ml => $composableBuilder(
    column: $table.ml,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WaterLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ml => $composableBuilder(
    column: $table.ml,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WaterLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WaterLogsTable> {
  $$WaterLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<int> get ml =>
      $composableBuilder(column: $table.ml, builder: (column) => column);
}

class $$WaterLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WaterLogsTable,
          WaterLogRow,
          $$WaterLogsTableFilterComposer,
          $$WaterLogsTableOrderingComposer,
          $$WaterLogsTableAnnotationComposer,
          $$WaterLogsTableCreateCompanionBuilder,
          $$WaterLogsTableUpdateCompanionBuilder,
          (
            WaterLogRow,
            BaseReferences<_$AppDatabase, $WaterLogsTable, WaterLogRow>,
          ),
          WaterLogRow,
          PrefetchHooks Function()
        > {
  $$WaterLogsTableTableManager(_$AppDatabase db, $WaterLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WaterLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WaterLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WaterLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<int> ml = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WaterLogsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                loggedAt: loggedAt,
                ml: ml,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required DateTime loggedAt,
                required int ml,
                Value<int> rowid = const Value.absent(),
              }) => WaterLogsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                loggedAt: loggedAt,
                ml: ml,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WaterLogsTable, WaterLogRow>(table),
                  BaseReferences<_$AppDatabase, $WaterLogsTable, WaterLogRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WaterLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WaterLogsTable,
      WaterLogRow,
      $$WaterLogsTableFilterComposer,
      $$WaterLogsTableOrderingComposer,
      $$WaterLogsTableAnnotationComposer,
      $$WaterLogsTableCreateCompanionBuilder,
      $$WaterLogsTableUpdateCompanionBuilder,
      (
        WaterLogRow,
        BaseReferences<_$AppDatabase, $WaterLogsTable, WaterLogRow>,
      ),
      WaterLogRow,
      PrefetchHooks Function()
    >;
typedef $$ShoppingItemsTableCreateCompanionBuilder =
    ShoppingItemsCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String deviceId,
      Value<int> version,
      required String title,
      Value<double?> quantity,
      Value<String?> unit,
      Value<int?> estPriceMinor,
      Value<String?> currency,
      Value<bool> done,
      Value<String> source,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$ShoppingItemsTableUpdateCompanionBuilder =
    ShoppingItemsCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> deviceId,
      Value<int> version,
      Value<String> title,
      Value<double?> quantity,
      Value<String?> unit,
      Value<int?> estPriceMinor,
      Value<String?> currency,
      Value<bool> done,
      Value<String> source,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$ShoppingItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ShoppingItemsTable> {
  $$ShoppingItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estPriceMinor => $composableBuilder(
    column: $table.estPriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShoppingItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShoppingItemsTable> {
  $$ShoppingItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estPriceMinor => $composableBuilder(
    column: $table.estPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShoppingItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShoppingItemsTable> {
  $$ShoppingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get estPriceMinor => $composableBuilder(
    column: $table.estPriceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$ShoppingItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShoppingItemsTable,
          ShoppingItemRow,
          $$ShoppingItemsTableFilterComposer,
          $$ShoppingItemsTableOrderingComposer,
          $$ShoppingItemsTableAnnotationComposer,
          $$ShoppingItemsTableCreateCompanionBuilder,
          $$ShoppingItemsTableUpdateCompanionBuilder,
          (
            ShoppingItemRow,
            BaseReferences<_$AppDatabase, $ShoppingItemsTable, ShoppingItemRow>,
          ),
          ShoppingItemRow,
          PrefetchHooks Function()
        > {
  $$ShoppingItemsTableTableManager(_$AppDatabase db, $ShoppingItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShoppingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShoppingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShoppingItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<double?> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<int?> estPriceMinor = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShoppingItemsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                title: title,
                quantity: quantity,
                unit: unit,
                estPriceMinor: estPriceMinor,
                currency: currency,
                done: done,
                source: source,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required String title,
                Value<double?> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<int?> estPriceMinor = const Value.absent(),
                Value<String?> currency = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShoppingItemsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                title: title,
                quantity: quantity,
                unit: unit,
                estPriceMinor: estPriceMinor,
                currency: currency,
                done: done,
                source: source,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShoppingItemsTable, ShoppingItemRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ShoppingItemsTable,
                    ShoppingItemRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShoppingItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShoppingItemsTable,
      ShoppingItemRow,
      $$ShoppingItemsTableFilterComposer,
      $$ShoppingItemsTableOrderingComposer,
      $$ShoppingItemsTableAnnotationComposer,
      $$ShoppingItemsTableCreateCompanionBuilder,
      $$ShoppingItemsTableUpdateCompanionBuilder,
      (
        ShoppingItemRow,
        BaseReferences<_$AppDatabase, $ShoppingItemsTable, ShoppingItemRow>,
      ),
      ShoppingItemRow,
      PrefetchHooks Function()
    >;
typedef $$StepLogsTableCreateCompanionBuilder = StepLogsCompanion Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<int> version,
  required DateTime day,
  required int steps,
  Value<double?> distanceM,
  Value<int?> floors,
  required String source,
  Value<int> rowid,
});
typedef $$StepLogsTableUpdateCompanionBuilder = StepLogsCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<int> version,
  Value<DateTime> day,
  Value<int> steps,
  Value<double?> distanceM,
  Value<int?> floors,
  Value<String> source,
  Value<int> rowid,
});

class $$StepLogsTableFilterComposer
    extends Composer<_$AppDatabase, $StepLogsTable> {
  $$StepLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get floors => $composableBuilder(
    column: $table.floors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StepLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $StepLogsTable> {
  $$StepLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceM => $composableBuilder(
    column: $table.distanceM,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get floors => $composableBuilder(
    column: $table.floors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StepLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StepLogsTable> {
  $$StepLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<double> get distanceM =>
      $composableBuilder(column: $table.distanceM, builder: (column) => column);

  GeneratedColumn<int> get floors =>
      $composableBuilder(column: $table.floors, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$StepLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StepLogsTable,
          StepLogRow,
          $$StepLogsTableFilterComposer,
          $$StepLogsTableOrderingComposer,
          $$StepLogsTableAnnotationComposer,
          $$StepLogsTableCreateCompanionBuilder,
          $$StepLogsTableUpdateCompanionBuilder,
          (
            StepLogRow,
            BaseReferences<_$AppDatabase, $StepLogsTable, StepLogRow>,
          ),
          StepLogRow,
          PrefetchHooks Function()
        > {
  $$StepLogsTableTableManager(_$AppDatabase db, $StepLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StepLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StepLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StepLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> day = const Value.absent(),
                Value<int> steps = const Value.absent(),
                Value<double?> distanceM = const Value.absent(),
                Value<int?> floors = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StepLogsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                day: day,
                steps: steps,
                distanceM: distanceM,
                floors: floors,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required DateTime day,
                required int steps,
                Value<double?> distanceM = const Value.absent(),
                Value<int?> floors = const Value.absent(),
                required String source,
                Value<int> rowid = const Value.absent(),
              }) => StepLogsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                day: day,
                steps: steps,
                distanceM: distanceM,
                floors: floors,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StepLogsTable, StepLogRow>(table),
                  BaseReferences<_$AppDatabase, $StepLogsTable, StepLogRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StepLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StepLogsTable,
      StepLogRow,
      $$StepLogsTableFilterComposer,
      $$StepLogsTableOrderingComposer,
      $$StepLogsTableAnnotationComposer,
      $$StepLogsTableCreateCompanionBuilder,
      $$StepLogsTableUpdateCompanionBuilder,
      (StepLogRow, BaseReferences<_$AppDatabase, $StepLogsTable, StepLogRow>),
      StepLogRow,
      PrefetchHooks Function()
    >;
typedef $$SleepLogsTableCreateCompanionBuilder = SleepLogsCompanion Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<int> version,
  required DateTime bedAt,
  required DateTime wakeAt,
  Value<int?> quality,
  Value<String> source,
  Value<int> rowid,
});
typedef $$SleepLogsTableUpdateCompanionBuilder = SleepLogsCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<int> version,
  Value<DateTime> bedAt,
  Value<DateTime> wakeAt,
  Value<int?> quality,
  Value<String> source,
  Value<int> rowid,
});

class $$SleepLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SleepLogsTable> {
  $$SleepLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get bedAt => $composableBuilder(
    column: $table.bedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get wakeAt => $composableBuilder(
    column: $table.wakeAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SleepLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SleepLogsTable> {
  $$SleepLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get bedAt => $composableBuilder(
    column: $table.bedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get wakeAt => $composableBuilder(
    column: $table.wakeAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quality => $composableBuilder(
    column: $table.quality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SleepLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SleepLogsTable> {
  $$SleepLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get bedAt =>
      $composableBuilder(column: $table.bedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get wakeAt =>
      $composableBuilder(column: $table.wakeAt, builder: (column) => column);

  GeneratedColumn<int> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$SleepLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SleepLogsTable,
          SleepLogRow,
          $$SleepLogsTableFilterComposer,
          $$SleepLogsTableOrderingComposer,
          $$SleepLogsTableAnnotationComposer,
          $$SleepLogsTableCreateCompanionBuilder,
          $$SleepLogsTableUpdateCompanionBuilder,
          (
            SleepLogRow,
            BaseReferences<_$AppDatabase, $SleepLogsTable, SleepLogRow>,
          ),
          SleepLogRow,
          PrefetchHooks Function()
        > {
  $$SleepLogsTableTableManager(_$AppDatabase db, $SleepLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SleepLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SleepLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SleepLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> bedAt = const Value.absent(),
                Value<DateTime> wakeAt = const Value.absent(),
                Value<int?> quality = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SleepLogsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                bedAt: bedAt,
                wakeAt: wakeAt,
                quality: quality,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required DateTime bedAt,
                required DateTime wakeAt,
                Value<int?> quality = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SleepLogsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                bedAt: bedAt,
                wakeAt: wakeAt,
                quality: quality,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SleepLogsTable, SleepLogRow>(table),
                  BaseReferences<_$AppDatabase, $SleepLogsTable, SleepLogRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SleepLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SleepLogsTable,
      SleepLogRow,
      $$SleepLogsTableFilterComposer,
      $$SleepLogsTableOrderingComposer,
      $$SleepLogsTableAnnotationComposer,
      $$SleepLogsTableCreateCompanionBuilder,
      $$SleepLogsTableUpdateCompanionBuilder,
      (
        SleepLogRow,
        BaseReferences<_$AppDatabase, $SleepLogsTable, SleepLogRow>,
      ),
      SleepLogRow,
      PrefetchHooks Function()
    >;
typedef $$CareChecksTableCreateCompanionBuilder = CareChecksCompanion Function({
  required String id,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  required String deviceId,
  Value<int> version,
  required DateTime day,
  required String routine,
  required String itemKey,
  required DateTime doneAt,
  Value<int> rowid,
});
typedef $$CareChecksTableUpdateCompanionBuilder = CareChecksCompanion Function({
  Value<String> id,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> deviceId,
  Value<int> version,
  Value<DateTime> day,
  Value<String> routine,
  Value<String> itemKey,
  Value<DateTime> doneAt,
  Value<int> rowid,
});

class $$CareChecksTableFilterComposer
    extends Composer<_$AppDatabase, $CareChecksTable> {
  $$CareChecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get routine => $composableBuilder(
    column: $table.routine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemKey => $composableBuilder(
    column: $table.itemKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CareChecksTableOrderingComposer
    extends Composer<_$AppDatabase, $CareChecksTable> {
  $$CareChecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get routine => $composableBuilder(
    column: $table.routine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemKey => $composableBuilder(
    column: $table.itemKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get doneAt => $composableBuilder(
    column: $table.doneAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CareChecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $CareChecksTable> {
  $$CareChecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<String> get routine =>
      $composableBuilder(column: $table.routine, builder: (column) => column);

  GeneratedColumn<String> get itemKey =>
      $composableBuilder(column: $table.itemKey, builder: (column) => column);

  GeneratedColumn<DateTime> get doneAt =>
      $composableBuilder(column: $table.doneAt, builder: (column) => column);
}

class $$CareChecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CareChecksTable,
          CareCheckRow,
          $$CareChecksTableFilterComposer,
          $$CareChecksTableOrderingComposer,
          $$CareChecksTableAnnotationComposer,
          $$CareChecksTableCreateCompanionBuilder,
          $$CareChecksTableUpdateCompanionBuilder,
          (
            CareCheckRow,
            BaseReferences<_$AppDatabase, $CareChecksTable, CareCheckRow>,
          ),
          CareCheckRow,
          PrefetchHooks Function()
        > {
  $$CareChecksTableTableManager(_$AppDatabase db, $CareChecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CareChecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CareChecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CareChecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> day = const Value.absent(),
                Value<String> routine = const Value.absent(),
                Value<String> itemKey = const Value.absent(),
                Value<DateTime> doneAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CareChecksCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                day: day,
                routine: routine,
                itemKey: itemKey,
                doneAt: doneAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required DateTime day,
                required String routine,
                required String itemKey,
                required DateTime doneAt,
                Value<int> rowid = const Value.absent(),
              }) => CareChecksCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                day: day,
                routine: routine,
                itemKey: itemKey,
                doneAt: doneAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CareChecksTable, CareCheckRow>(table),
                  BaseReferences<_$AppDatabase, $CareChecksTable, CareCheckRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CareChecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CareChecksTable,
      CareCheckRow,
      $$CareChecksTableFilterComposer,
      $$CareChecksTableOrderingComposer,
      $$CareChecksTableAnnotationComposer,
      $$CareChecksTableCreateCompanionBuilder,
      $$CareChecksTableUpdateCompanionBuilder,
      (
        CareCheckRow,
        BaseReferences<_$AppDatabase, $CareChecksTable, CareCheckRow>,
      ),
      CareCheckRow,
      PrefetchHooks Function()
    >;
typedef $$WorkoutProgramsTableCreateCompanionBuilder =
    WorkoutProgramsCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String deviceId,
      Value<int> version,
      required String title,
      required String level,
      Value<String> source,
      required String payload,
      Value<bool> active,
      Value<int> rowid,
    });
typedef $$WorkoutProgramsTableUpdateCompanionBuilder =
    WorkoutProgramsCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> deviceId,
      Value<int> version,
      Value<String> title,
      Value<String> level,
      Value<String> source,
      Value<String> payload,
      Value<bool> active,
      Value<int> rowid,
    });

class $$WorkoutProgramsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutProgramsTable> {
  $$WorkoutProgramsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutProgramsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutProgramsTable> {
  $$WorkoutProgramsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutProgramsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutProgramsTable> {
  $$WorkoutProgramsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$WorkoutProgramsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutProgramsTable,
          WorkoutProgramRow,
          $$WorkoutProgramsTableFilterComposer,
          $$WorkoutProgramsTableOrderingComposer,
          $$WorkoutProgramsTableAnnotationComposer,
          $$WorkoutProgramsTableCreateCompanionBuilder,
          $$WorkoutProgramsTableUpdateCompanionBuilder,
          (
            WorkoutProgramRow,
            BaseReferences<
              _$AppDatabase,
              $WorkoutProgramsTable,
              WorkoutProgramRow
            >,
          ),
          WorkoutProgramRow,
          PrefetchHooks Function()
        > {
  $$WorkoutProgramsTableTableManager(
    _$AppDatabase db,
    $WorkoutProgramsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutProgramsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutProgramsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutProgramsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutProgramsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                title: title,
                level: level,
                source: source,
                payload: payload,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                required String title,
                required String level,
                Value<String> source = const Value.absent(),
                required String payload,
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutProgramsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                title: title,
                level: level,
                source: source,
                payload: payload,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutProgramsTable, WorkoutProgramRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WorkoutProgramsTable,
                    WorkoutProgramRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutProgramsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutProgramsTable,
      WorkoutProgramRow,
      $$WorkoutProgramsTableFilterComposer,
      $$WorkoutProgramsTableOrderingComposer,
      $$WorkoutProgramsTableAnnotationComposer,
      $$WorkoutProgramsTableCreateCompanionBuilder,
      $$WorkoutProgramsTableUpdateCompanionBuilder,
      (
        WorkoutProgramRow,
        BaseReferences<_$AppDatabase, $WorkoutProgramsTable, WorkoutProgramRow>,
      ),
      WorkoutProgramRow,
      PrefetchHooks Function()
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String deviceId,
      Value<int> version,
      Value<String?> programId,
      Value<String?> dayKey,
      required DateTime startedAt,
      Value<DateTime?> finishedAt,
      Value<int> activeSeconds,
      Value<double?> kcal,
      Value<String> payload,
      Value<int> rowid,
    });
typedef $$WorkoutSessionsTableUpdateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> deviceId,
      Value<int> version,
      Value<String?> programId,
      Value<String?> dayKey,
      Value<DateTime> startedAt,
      Value<DateTime?> finishedAt,
      Value<int> activeSeconds,
      Value<double?> kcal,
      Value<String> payload,
      Value<int> rowid,
    });

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get programId => $composableBuilder(
    column: $table.programId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeSeconds => $composableBuilder(
    column: $table.activeSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get programId => $composableBuilder(
    column: $table.programId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeSeconds => $composableBuilder(
    column: $table.activeSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get programId =>
      $composableBuilder(column: $table.programId, builder: (column) => column);

  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activeSeconds => $composableBuilder(
    column: $table.activeSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSessionRow,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (
            WorkoutSessionRow,
            BaseReferences<
              _$AppDatabase,
              $WorkoutSessionsTable,
              WorkoutSessionRow
            >,
          ),
          WorkoutSessionRow,
          PrefetchHooks Function()
        > {
  $$WorkoutSessionsTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> programId = const Value.absent(),
                Value<String?> dayKey = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> activeSeconds = const Value.absent(),
                Value<double?> kcal = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                programId: programId,
                dayKey: dayKey,
                startedAt: startedAt,
                finishedAt: finishedAt,
                activeSeconds: activeSeconds,
                kcal: kcal,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> version = const Value.absent(),
                Value<String?> programId = const Value.absent(),
                Value<String?> dayKey = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> activeSeconds = const Value.absent(),
                Value<double?> kcal = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                version: version,
                programId: programId,
                dayKey: dayKey,
                startedAt: startedAt,
                finishedAt: finishedAt,
                activeSeconds: activeSeconds,
                kcal: kcal,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutSessionsTable, WorkoutSessionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WorkoutSessionsTable,
                    WorkoutSessionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionsTable,
      WorkoutSessionRow,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (
        WorkoutSessionRow,
        BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSessionRow>,
      ),
      WorkoutSessionRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$BodyMeasurementsTableTableManager get bodyMeasurements =>
      $$BodyMeasurementsTableTableManager(_db, _db.bodyMeasurements);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$ScheduleSettingsTableTableManager get scheduleSettings =>
      $$ScheduleSettingsTableTableManager(_db, _db.scheduleSettings);
  $$ScheduleItemsTableTableManager get scheduleItems =>
      $$ScheduleItemsTableTableManager(_db, _db.scheduleItems);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db, _db.plans);
  $$QuestionnaireSectionsTableTableManager get questionnaireSections =>
      $$QuestionnaireSectionsTableTableManager(_db, _db.questionnaireSections);
  $$QuestsTableTableManager get quests =>
      $$QuestsTableTableManager(_db, _db.quests);
  $$QuestInstancesTableTableManager get questInstances =>
      $$QuestInstancesTableTableManager(_db, _db.questInstances);
  $$QuestEventsTableTableManager get questEvents =>
      $$QuestEventsTableTableManager(_db, _db.questEvents);
  $$EffectsTableTableManager get effects =>
      $$EffectsTableTableManager(_db, _db.effects);
  $$PausesTableTableManager get pauses =>
      $$PausesTableTableManager(_db, _db.pauses);
  $$RewardsTableTableManager get rewards =>
      $$RewardsTableTableManager(_db, _db.rewards);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$FoodItemsTableTableManager get foodItems =>
      $$FoodItemsTableTableManager(_db, _db.foodItems);
  $$MealEntriesTableTableManager get mealEntries =>
      $$MealEntriesTableTableManager(_db, _db.mealEntries);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$WaterLogsTableTableManager get waterLogs =>
      $$WaterLogsTableTableManager(_db, _db.waterLogs);
  $$ShoppingItemsTableTableManager get shoppingItems =>
      $$ShoppingItemsTableTableManager(_db, _db.shoppingItems);
  $$StepLogsTableTableManager get stepLogs =>
      $$StepLogsTableTableManager(_db, _db.stepLogs);
  $$SleepLogsTableTableManager get sleepLogs =>
      $$SleepLogsTableTableManager(_db, _db.sleepLogs);
  $$CareChecksTableTableManager get careChecks =>
      $$CareChecksTableTableManager(_db, _db.careChecks);
  $$WorkoutProgramsTableTableManager get workoutPrograms =>
      $$WorkoutProgramsTableTableManager(_db, _db.workoutPrograms);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
}
