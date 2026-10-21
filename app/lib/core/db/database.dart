// Схема локальной БД (Drift). Правит только главный агент.
// Этап 1: профиль, замеры, фото, цели, расписание, план, разделы анкеты.
// Остальные сущности SPEC §11 — на следующих этапах (миграции через schemaVersion).
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

part 'database.g.dart';

/// Поля синхронизации (SPEC §10) — подмешиваются во все синхронизируемые таблицы.
mixin SyncColumns on Table {
  TextColumn get id => text()(); // UUID, генерирует клиент
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Локальные настройки ключ-значение (не синхронизируются).
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Анкета §5.1 + постоянная часть §5.2. Одна строка на пользователя.
@DataClassName('ProfileRow')
class Profiles extends Table with SyncColumns {
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get locale => text().nullable()(); // 'ru' / 'tr'; null — язык системы
  TextColumn get sex => text().nullable()(); // Sex.name
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get timezone => text().nullable()(); // IANA или «UTC+3»
  TextColumn get city => text().nullable()();
  RealColumn get heightCm => real().nullable()();
  TextColumn get activityLevel => text().nullable()(); // ActivityLevel.name
  TextColumn get workload => text().nullable()(); // Workload.name
}

/// Замеры тела (§5.2, §8.3). Новая строка на каждый замер.
@DataClassName('BodyMeasurementRow')
class BodyMeasurements extends Table with SyncColumns {
  DateTimeColumn get measuredAt => dateTime()();
  RealColumn get weightKg => real().nullable()();
  RealColumn get waistCm => real().nullable()();
  RealColumn get hipsCm => real().nullable()();
  RealColumn get chestCm => real().nullable()();
  RealColumn get neckCm => real().nullable()();
  RealColumn get armCm => real().nullable()();
  RealColumn get bodyFatPct => real().nullable()();
  RealColumn get muscleMassKg => real().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))(); // MeasurementSource.name
}

/// Фото (тело/кожа/еда/чек). Файл — локально, на сервер — на этапе 5.
@DataClassName('PhotoRow')
class Photos extends Table with SyncColumns {
  TextColumn get kind => text()(); // PhotoKind.name
  TextColumn get pose => text()(); // PhotoPose.name
  TextColumn get localPath => text()(); // относительно каталога документов приложения
  DateTimeColumn get takenAt => dateTime()();
  TextColumn get sessionId => text().nullable()(); // серия «контрольного фото»
  TextColumn get remotePath => text().nullable()();
}

/// Цели (§5.6).
@DataClassName('GoalRow')
class Goals extends Table with SyncColumns {
  TextColumn get kind => text()(); // GoalKind.name
  TextColumn get title => text().nullable()(); // для GoalKind.custom
  IntColumn get priority => integer().withDefault(const Constant(2))(); // 1 высокий … 3 низкий
  DateTimeColumn get deadline => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Общие параметры расписания (§5.7). Одна строка (id = 'main').
@DataClassName('ScheduleSettingsRow')
class ScheduleSettings extends Table with SyncColumns {
  TextColumn get institutionType => text().nullable()(); // InstitutionType.name
  TextColumn get institutionName => text().nullable()();
  BoolColumn get alternationEnabled => boolean().withDefault(const Constant(false))();
  /// Понедельник недели, которая считается «неделей 1». Ручное переключение сдвигает якорь на 7 дней.
  DateTimeColumn get week1Anchor => dateTime().nullable()();
  IntColumn get wakeMinute => integer().withDefault(const Constant(7 * 60))(); // минута суток
  IntColumn get bedMinute => integer().withDefault(const Constant(23 * 60))();
  IntColumn get commuteMinutes => integer().withDefault(const Constant(0))();
  TextColumn get weekendDays => text().withDefault(const Constant('6,7'))(); // DateTime.weekday через запятую
}

/// Пункты расписания: пары, работа, прочее.
@DataClassName('ScheduleItemRow')
class ScheduleItems extends Table with SyncColumns {
  TextColumn get kind => text()(); // ScheduleItemKind.name
  TextColumn get title => text()();
  IntColumn get weekday => integer()(); // DateTime.monday..sunday (1..7)
  IntColumn get startMinute => integer()(); // минута суток
  IntColumn get durationMinutes => integer()();
  IntColumn get weekParity => integer().withDefault(const Constant(0))(); // 0 — каждую, 1 / 2 — только эту неделю
  TextColumn get location => text().nullable()();
  BoolColumn get requiresCommute => boolean().withDefault(const Constant(true))();
}

/// План (§5, «Системное окно» с «Принять»). payload — JSON модели плана.
@DataClassName('PlanRow')
class Plans extends Table with SyncColumns {
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get acceptedAt => dateTime().nullable()();
  TextColumn get source => text().withDefault(const Constant('local'))(); // 'local' / 'ai'
  TextColumn get payload => text()();
}

/// Разделы анкеты, у которых пока нет своих таблиц (кожа, здоровье, питание, тренировки,
/// финансы, персонаж, разрешения). id = ключ раздела (QuestionnaireSection.name), payload — JSON.
/// На этапах 3/6/7 данные переедут в полноценные таблицы.
@DataClassName('QuestionnaireSectionRow')
class QuestionnaireSections extends Table with SyncColumns {
  TextColumn get payload => text()();
}

@DriftDatabase(tables: [
  AppSettings,
  Profiles,
  BodyMeasurements,
  Photos,
  Goals,
  ScheduleSettings,
  ScheduleItems,
  Plans,
  QuestionnaireSections,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ??
            driftDatabase(
              name: 'sistema',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.js'),
              ),
            ));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(profiles);
            await m.createTable(bodyMeasurements);
            await m.createTable(photos);
            await m.createTable(goals);
            await m.createTable(scheduleSettings);
            await m.createTable(scheduleItems);
            await m.createTable(plans);
            await m.createTable(questionnaireSections);
          }
        },
      );

  Future<String?> getSetting(String key) async =>
      (await (select(appSettings)..where((t) => t.key.equals(key))).getSingleOrNull())?.value;

  Future<void> setSetting(String key, String value) =>
      into(appSettings).insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: value));

  Future<void> deleteSetting(String key) => (delete(appSettings)..where((t) => t.key.equals(key))).go();

  static const _deviceIdKey = 'device.id';
  String? _deviceId;

  /// UUID этого устройства (SPEC §10, поле device_id). Создаётся при первом обращении.
  Future<String> deviceId() async {
    final cached = _deviceId;
    if (cached != null) return cached;
    var id = await getSetting(_deviceIdKey);
    if (id == null) {
      id = newId();
      await setSetting(_deviceIdKey, id);
    }
    return _deviceId = id;
  }
}

const _uuid = Uuid();

/// Новый UUID записи (генерирует клиент, SPEC §10).
String newId() => _uuid.v4();

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
