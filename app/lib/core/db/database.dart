// Схема локальной БД (Drift). Правит только главный агент.
// Этап 1: профиль, замеры, фото, цели, расписание, план, разделы анкеты.
// Этап 2: квесты, экземпляры, журнал событий, эффекты, паузы, награды магазина, пользовательские настройки.
// Этап 3: продукты, дневник питания, рецепты, вода, список покупок, шаги, сон, уход за кожей, тренировки.
// Этап 4: прогулки и маршруты.
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

// ---- Этап 2 (SPEC §6–7) ----

/// Шаблон квеста: что, когда, награда/штраф. Экземпляры на дни — [QuestInstances].
@DataClassName('QuestRow')
class Quests extends Table with SyncColumns {
  TextColumn get kind => text()(); // QuestKind.name
  TextColumn get stat => text().nullable()(); // StatKind.name — какую характеристику качает
  TextColumn get titleKey => text().nullable()(); // QuestKey.name (квест из плана, локализуется)
  TextColumn get title => text().nullable()(); // свой текст (custom/ai)
  TextColumn get params => text().withDefault(const Constant('{}'))(); // JSON параметров названия
  TextColumn get subtasks => text().withDefault(const Constant('[]'))(); // JSON: список названий подзадач
  IntColumn get minute => integer().nullable()(); // начало, минута суток; null — в течение дня
  IntColumn get windowMinutes => integer().withDefault(const Constant(60))(); // время на выполнение → дедлайн
  TextColumn get weekdays => text().withDefault(const Constant(''))(); // '1,3,5'; пусто — каждый день
  IntColumn get weekParity => integer().withDefault(const Constant(0))(); // 0 — каждую неделю, 1/2 — только эту
  DateTimeColumn get activeFrom => dateTime().nullable()(); // разовый/временный квест: с какого дня
  DateTimeColumn get activeUntil => dateTime().nullable()(); // по какой день включительно
  IntColumn get rewardDiamonds => integer().withDefault(const Constant(0))();
  IntColumn get rewardXp => integer().withDefault(const Constant(0))();
  TextColumn get rewardStats => text().withDefault(const Constant('{}'))(); // JSON {StatKind.name: n}
  IntColumn get penaltyDiamonds => integer().withDefault(const Constant(0))(); // за провал (игнор)
  IntColumn get refusePenaltyDiamonds => integer().nullable()(); // за отказ; null — по формуле движка
  TextColumn get confirm => text().withDefault(const Constant('button'))(); // ConfirmMethod.name
  IntColumn get target => integer().nullable()(); // шаги/минуты/цель босса
  BoolColumn get nag => boolean().withDefault(const Constant(true))(); // «надоедать» каждую минуту
  BoolColumn get cancellable => boolean().withDefault(const Constant(true))(); // штрафные — false
  TextColumn get source => text().withDefault(const Constant('user'))(); // QuestSource.name
  TextColumn get planId => text().nullable()(); // из какого плана
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

/// Экземпляр квеста на день (для босса — на неделю: day = понедельник).
/// Награда/штраф копируются при создании: правка шаблона не меняет прошлое.
@DataClassName('QuestInstanceRow')
class QuestInstances extends Table with SyncColumns {
  TextColumn get questId => text()();
  DateTimeColumn get day => dateTime()(); // локальная полночь
  DateTimeColumn get startsAt => dateTime().nullable()();
  DateTimeColumn get deadlineAt => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // QuestStatus.name
  DateTimeColumn get resolvedAt => dateTime().nullable()();
  DateTimeColumn get snoozedUntil => dateTime().nullable()(); // «+10 мин»
  IntColumn get snoozeCount => integer().withDefault(const Constant(0))();
  IntColumn get progress => integer().withDefault(const Constant(0))(); // к Quests.target
  TextColumn get subtasksDone => text().withDefault(const Constant('[]'))(); // JSON: индексы
  IntColumn get rewardDiamonds => integer().withDefault(const Constant(0))();
  IntColumn get rewardXp => integer().withDefault(const Constant(0))();
  TextColumn get rewardStats => text().withDefault(const Constant('{}'))();
  IntColumn get penaltyDiamonds => integer().withDefault(const Constant(0))();
  IntColumn get refusePenaltyDiamonds => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {questId, day},
      ];
}

/// Журнал событий (SPEC §10): ◆, опыт и характеристики считаются суммой, не перезаписываются.
@DataClassName('QuestEventRow')
class QuestEvents extends Table with SyncColumns {
  TextColumn get type => text()(); // QuestEventType.name
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get questId => text().nullable()();
  TextColumn get instanceId => text().nullable()();
  IntColumn get diamonds => integer().withDefault(const Constant(0))(); // ± ◆
  IntColumn get xp => integer().withDefault(const Constant(0))(); // ± опыт (≥0 по правилам движка)
  TextColumn get stats => text().withDefault(const Constant('{}'))(); // JSON {StatKind.name: ±n}
  TextColumn get payload => text().withDefault(const Constant('{}'))(); // JSON: mark, rewardId, reason…
}

/// Баффы/дебаффы с таймером (SPEC §4 «Эффекты»).
@DataClassName('EffectRow')
class Effects extends Table with SyncColumns {
  TextColumn get kind => text()(); // ключ эффекта (движок квестов)
  DateTimeColumn get startsAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime()();
  TextColumn get sourceEventId => text().nullable()();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
}

/// Пауза: болезнь/каникулы/отпуск.
@DataClassName('PauseRow')
class Pauses extends Table with SyncColumns {
  TextColumn get reason => text()(); // PauseReason.name
  DateTimeColumn get startsAt => dateTime()();
  DateTimeColumn get endsAt => dateTime().nullable()(); // null — до ручного снятия
}

/// Награды магазина (SPEC §6): создаёт пользователь. Покупка — событие purchase в журнале.
@DataClassName('RewardRow')
class Rewards extends Table with SyncColumns {
  TextColumn get title => text()();
  IntColumn get price => integer()();
  IntColumn get limitCount => integer().nullable()(); // сколько раз за период; null — без лимита
  TextColumn get limitPeriod => text().nullable()(); // RewardLimitPeriod.name
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Синхронизируемые настройки пользователя (тихие часы, режим дисциплины…). id = ключ, value — JSON.
@DataClassName('UserSettingRow')
class UserSettings extends Table with SyncColumns {
  TextColumn get value => text()();
}

// ---- Этап 3 (SPEC §8.2–8.4) ----

/// Продукт: из Open Food Facts (кэш по штрихкоду) или введённый вручную. Значения — на 100 г.
@DataClassName('FoodItemRow')
class FoodItems extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get barcode => text().nullable()(); // EAN/UPC; null — ручной продукт без штрихкода
  RealColumn get kcal100 => real()();
  RealColumn get protein100 => real().withDefault(const Constant(0))();
  RealColumn get fat100 => real().withDefault(const Constant(0))();
  RealColumn get carbs100 => real().withDefault(const Constant(0))();
  RealColumn get servingG => real().nullable()(); // типичная порция
  TextColumn get source => text().withDefault(const Constant('manual'))(); // FoodSource.name
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
}

/// Запись дневника питания. КБЖУ копируются на момент записи (правка продукта не меняет прошлое).
@DataClassName('MealEntryRow')
class MealEntries extends Table with SyncColumns {
  DateTimeColumn get eatenAt => dateTime()();
  TextColumn get mealType => text()(); // MealType.name
  TextColumn get title => text()(); // название/описание («овсянка с бананом»)
  TextColumn get foodItemId => text().nullable()();
  TextColumn get recipeId => text().nullable()();
  RealColumn get grams => real().nullable()(); // null — ввод «порцией» без веса
  RealColumn get kcal => real()();
  RealColumn get protein => real().withDefault(const Constant(0))();
  RealColumn get fat => real().withDefault(const Constant(0))();
  RealColumn get carbs => real().withDefault(const Constant(0))();
  TextColumn get photoId => text().nullable()(); // Photos (kind = food); распознавание — этап 5
}

/// Мои рецепты: состав JSON [{foodItemId?, title, grams, kcal, protein, fat, carbs}], итоги на всё блюдо.
@DataClassName('RecipeRow')
class Recipes extends Table with SyncColumns {
  TextColumn get title => text()();
  TextColumn get items => text().withDefault(const Constant('[]'))();
  IntColumn get servings => integer().withDefault(const Constant(1))();
  RealColumn get kcal => real().withDefault(const Constant(0))();
  RealColumn get protein => real().withDefault(const Constant(0))();
  RealColumn get fat => real().withDefault(const Constant(0))();
  RealColumn get carbs => real().withDefault(const Constant(0))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Выпитая вода: строка на каждое нажатие «+250/+500» (сумма за день — по журналу).
@DataClassName('WaterLogRow')
class WaterLogs extends Table with SyncColumns {
  DateTimeColumn get loggedAt => dateTime()();
  IntColumn get ml => integer()();
}

/// Список покупок (от плана питания или вручную).
@DataClassName('ShoppingItemRow')
class ShoppingItems extends Table with SyncColumns {
  TextColumn get title => text()();
  RealColumn get quantity => real().nullable()();
  TextColumn get unit => text().nullable()(); // 'g', 'kg', 'pcs', 'l'…
  IntColumn get estPriceMinor => integer().nullable()(); // примерная цена в копейках/курушах
  TextColumn get currency => text().nullable()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  TextColumn get source => text().withDefault(const Constant('manual'))(); // 'manual' / 'plan'
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Шаги за день (строка на день и источник; перезаписывается при опросе датчика).
@DataClassName('StepLogRow')
class StepLogs extends Table with SyncColumns {
  DateTimeColumn get day => dateTime()(); // локальная полночь
  IntColumn get steps => integer()();
  RealColumn get distanceM => real().nullable()();
  IntColumn get floors => integer().nullable()();
  TextColumn get source => text()(); // StepSourceKind.name

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {day, source},
      ];
}

/// Сон: отбой → подъём. Источник — отметка, расписание или ручной ввод.
@DataClassName('SleepLogRow')
class SleepLogs extends Table with SyncColumns {
  DateTimeColumn get bedAt => dateTime()();
  DateTimeColumn get wakeAt => dateTime()();
  IntColumn get quality => integer().nullable()(); // 1..5, субъективно
  TextColumn get source => text().withDefault(const Constant('manual'))(); // SleepSource.name
}

/// Отметки чек-листа ухода за кожей: строка = пункт, выполненный в этот день.
@DataClassName('CareCheckRow')
class CareChecks extends Table with SyncColumns {
  DateTimeColumn get day => dateTime()(); // локальная полночь
  TextColumn get routine => text()(); // CareRoutine.name
  TextColumn get itemKey => text()(); // ключ пункта шаблона
  DateTimeColumn get doneAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {day, routine, itemKey},
      ];
}

/// Программа тренировок (шаблон под уровень; от ИИ — этап 5). payload — JSON дней и упражнений.
@DataClassName('WorkoutProgramRow')
class WorkoutPrograms extends Table with SyncColumns {
  TextColumn get title => text()();
  TextColumn get level => text()(); // уровень из анкеты: beginner / intermediate / advanced
  TextColumn get source => text().withDefault(const Constant('template'))(); // 'template' / 'ai' / 'user'
  TextColumn get payload => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

/// Проведённая тренировка: что сделано (JSON подходов), длительность, оценка расхода.
@DataClassName('WorkoutSessionRow')
class WorkoutSessions extends Table with SyncColumns {
  TextColumn get programId => text().nullable()();
  TextColumn get dayKey => text().nullable()(); // какой день программы
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()(); // null — прервана/идёт
  IntColumn get activeSeconds => integer().withDefault(const Constant(0))();
  RealColumn get kcal => real().nullable()();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
}

// ---- Этап 4 (SPEC §8.5) ----

/// Маршрут прогулки (сгенерированный круг или к магазину). payload — JSON RoutePlan (точки, отрезки, подсказки).
@DataClassName('WalkRouteRow')
class WalkRoutes extends Table with SyncColumns {
  TextColumn get title => text().nullable()();
  TextColumn get kind => text()(); // 'loop' / 'toPlace'
  RealColumn get distanceM => real()();
  IntColumn get durationS => integer().nullable()(); // оценка
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Проведённая прогулка: трек (JSON точек, прореженный), дистанция, время, отрезки.
@DataClassName('WalkRow')
class Walks extends Table with SyncColumns {
  TextColumn get routeId => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()(); // null — идёт/прервана
  RealColumn get distanceM => real().withDefault(const Constant(0))();
  IntColumn get activeSeconds => integer().withDefault(const Constant(0))();
  RealColumn get kcal => real().nullable()();
  TextColumn get track => text().withDefault(const Constant('[]'))(); // [[lat, lon, tMs], …]
  TextColumn get payload => text().withDefault(const Constant('{}'))(); // отрезки, темп по отрезкам
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
  Quests,
  QuestInstances,
  QuestEvents,
  Effects,
  Pauses,
  Rewards,
  UserSettings,
  FoodItems,
  MealEntries,
  Recipes,
  WaterLogs,
  ShoppingItems,
  StepLogs,
  SleepLogs,
  CareChecks,
  WorkoutPrograms,
  WorkoutSessions,
  WalkRoutes,
  Walks,
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
  int get schemaVersion => 5;

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
          if (from < 3) {
            await m.createTable(quests);
            await m.createTable(questInstances);
            await m.createTable(questEvents);
            await m.createTable(effects);
            await m.createTable(pauses);
            await m.createTable(rewards);
            await m.createTable(userSettings);
          }
          if (from < 4) {
            await m.createTable(foodItems);
            await m.createTable(mealEntries);
            await m.createTable(recipes);
            await m.createTable(waterLogs);
            await m.createTable(shoppingItems);
            await m.createTable(stepLogs);
            await m.createTable(sleepLogs);
            await m.createTable(careChecks);
            await m.createTable(workoutPrograms);
            await m.createTable(workoutSessions);
          }
          if (from < 5) {
            await m.createTable(walkRoutes);
            await m.createTable(walks);
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
