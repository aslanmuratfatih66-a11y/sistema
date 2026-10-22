// Схема локальной БД (Drift). Правит только главный агент.
// Этап 1: профиль, замеры, фото, цели, расписание, план, разделы анкеты.
// Этап 2: квесты, экземпляры, журнал событий, эффекты, паузы, награды магазина, пользовательские настройки.
// Этап 3: продукты, дневник питания, рецепты, вода, список покупок, шаги, сон, уход за кожей, тренировки.
// Этап 4: прогулки и маршруты.
// Этап 6: чат с персонажем, знания (курсы, уроки с повторениями), анализы фото.
// Этап 7: финансы (счета, категории, операции, лимиты, цели, подписки, долги, крипта, входящие банков),
//         маркет покупок, блокировка приложений (список, попытки), будильники-квесты.
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

/// Сообщение чата с персонажем (SPEC §9.3).
@DataClassName('ChatMessageRow')
class ChatMessages extends Table with SyncColumns {
  TextColumn get role => text()(); // 'user' / 'assistant' / 'system' (журнал действий ИИ)
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get viaVoice => boolean().withDefault(const Constant(false))();
  TextColumn get actionIds => text().nullable()(); // JSON id действий ИИ (ai_actions) из этого ответа
}

/// Курс знаний (SPEC §8.9).
@DataClassName('CourseRow')
class Courses extends Table with SyncColumns {
  TextColumn get title => text()();
  TextColumn get topic => text()(); // свободная тема / ключ встроенного курса
  TextColumn get lang => text()(); // ru / tr
  IntColumn get totalLessons => integer().withDefault(const Constant(0))();
  IntColumn get dailyLessons => integer().withDefault(const Constant(1))();
  TextColumn get status => text().withDefault(const Constant('active'))(); // active / paused / done
  DateTimeColumn get createdAt => dateTime()();
}

/// Урок курса: содержание, проверка, интервальные повторения.
@DataClassName('LessonRow')
class Lessons extends Table with SyncColumns {
  TextColumn get courseId => text()();
  IntColumn get orderIndex => integer()();
  TextColumn get title => text()();
  TextColumn get content => text()(); // JSON: абзацы, примеры
  TextColumn get quiz => text().withDefault(const Constant('[]'))(); // JSON вопросов
  DateTimeColumn get openedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get score => integer().nullable()(); // % правильных
  IntColumn get reviewStep => integer().withDefault(const Constant(0))(); // ступень повторения
  DateTimeColumn get nextReviewAt => dateTime().nullable()();
}

/// Результат анализа фото ИИ (тело, кожа, еда, чек) — всегда «оценка» (SPEC §9.4).
@DataClassName('PhotoAnalysisRow')
class PhotoAnalyses extends Table with SyncColumns {
  TextColumn get photoId => text().nullable()(); // Photos.id, если фото сохранено
  TextColumn get kind => text()(); // body / skin / food / receipt
  TextColumn get result => text()(); // JSON ответа сервера
  DateTimeColumn get createdAt => dateTime()();
}

// ---- Этап 7: финансы (SPEC §8.7) ----
// Суммы — целые в минимальных единицах валюты (копейки/куруши/центы); крипта — количество real.
// Валюта — ISO-код (RUB, TRY, USD, EUR). Отчёты переводятся в RUB по курсам сервера.

/// Счёт: наличка, карта, вклад, крипто-кошелёк.
@DataClassName('FinAccountRow')
class FinAccounts extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get kind => text()(); // FinAccountKind.name: cash / card / deposit / crypto
  TextColumn get bank => text().nullable()(); // ключ банка (FinBanks: sber, vtb, tbank, alfa, ziraat, isbank, garanti…)
  TextColumn get currency => text().withDefault(const Constant('RUB'))();
  IntColumn get openingBalance => integer().withDefault(const Constant(0))(); // начальный остаток, мин. единицы
  TextColumn get cardLast4 => text().nullable()(); // для сопоставления уведомлений банка
  IntColumn get sortIndex => integer().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

/// Категория доходов/расходов. builtinKey — встроенная (название из l10n), иначе name.
@DataClassName('FinCategoryRow')
class FinCategories extends Table with SyncColumns {
  TextColumn get kind => text()(); // FinTxKind.name: expense / income
  TextColumn get builtinKey => text().nullable()(); // groceries, cafe, fastfood, transport, …
  TextColumn get name => text().nullable()();
  TextColumn get icon => text().nullable()(); // имя SysGlyph
  TextColumn get parentId => text().nullable()();
  BoolColumn get junkFood => boolean().withDefault(const Constant(false))(); // «налог на фастфуд»
  IntColumn get sortIndex => integer().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
}

/// Операция: расход, доход или перевод между счетами.
@DataClassName('FinTransactionRow')
class FinTransactions extends Table with SyncColumns {
  TextColumn get kind => text()(); // FinTxKind.name: expense / income / transfer
  TextColumn get accountId => text()();
  TextColumn get toAccountId => text().nullable()(); // для transfer
  IntColumn get amount => integer()(); // > 0, мин. единицы валюты счёта
  TextColumn get currency => text()();
  IntColumn get toAmount => integer().nullable()(); // сумма зачисления при переводе в другой валюте
  IntColumn get amountRub => integer().nullable()(); // копейки по курсу на дату (для отчётов)
  TextColumn get categoryId => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get merchant => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('manual'))(); // FinTxSource.name
  TextColumn get externalRef => text().nullable()(); // ключ дедупа (ФН/ФД/ФП чека, id уведомления, строка выписки)
  TextColumn get items => text().nullable()(); // JSON позиций чека [{name, qty, price}]
  TextColumn get photoId => text().nullable()(); // фото чека
  TextColumn get subscriptionId => text().nullable()();
  TextColumn get debtId => text().nullable()();
  TextColumn get goalId => text().nullable()();
}

/// Лимит по категории на период. Предлагает ИИ после 2–4 недель, пользователь подтверждает.
@DataClassName('FinBudgetRow')
class FinBudgets extends Table with SyncColumns {
  TextColumn get categoryId => text()();
  TextColumn get period => text().withDefault(const Constant('month'))(); // week / month
  IntColumn get limitRub => integer()(); // копейки
  TextColumn get status => text().withDefault(const Constant('active'))(); // proposed / active / rejected
  TextColumn get source => text().withDefault(const Constant('user'))(); // user / ai
  TextColumn get reason => text().nullable()(); // пояснение ИИ
  DateTimeColumn get startsOn => dateTime()();
  IntColumn get rewardDiamonds => integer().withDefault(const Constant(10))(); // уложился
  IntColumn get penaltyDiamonds => integer().withDefault(const Constant(10))(); // превысил
}

/// Цель накопления.
@DataClassName('FinGoalRow')
class FinGoals extends Table with SyncColumns {
  TextColumn get title => text()();
  IntColumn get target => integer()();
  TextColumn get currency => text().withDefault(const Constant('RUB'))();
  TextColumn get accountId => text().nullable()(); // счёт-копилка; null — взносы операциями с goalId
  DateTimeColumn get deadline => dateTime().nullable()();
  DateTimeColumn get reachedAt => dateTime().nullable()();
}

/// Подписка (регулярный платёж).
@DataClassName('FinSubscriptionRow')
class FinSubscriptions extends Table with SyncColumns {
  TextColumn get title => text()();
  IntColumn get amount => integer()();
  TextColumn get currency => text().withDefault(const Constant('RUB'))();
  TextColumn get period => text().withDefault(const Constant('month'))(); // week / month / year
  DateTimeColumn get nextChargeOn => dateTime()();
  TextColumn get accountId => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

/// Долг: я должен (owe) или мне должны (lent).
@DataClassName('FinDebtRow')
class FinDebts extends Table with SyncColumns {
  TextColumn get person => text()();
  TextColumn get direction => text()(); // owe / lent
  IntColumn get amount => integer()();
  TextColumn get currency => text().withDefault(const Constant('RUB'))();
  DateTimeColumn get dueOn => dateTime().nullable()(); // напоминание
  DateTimeColumn get settledAt => dateTime().nullable()();
  TextColumn get note => text().nullable()();
}

/// Крипта: количество вручную, курс — с сервера (CoinGecko).
@DataClassName('CryptoHoldingRow')
class CryptoHoldings extends Table with SyncColumns {
  TextColumn get symbol => text()(); // BTC
  TextColumn get coinId => text()(); // id CoinGecko: bitcoin
  RealColumn get amount => real()();
  TextColumn get accountId => text().nullable()();
}

/// Входящие банков (Android: уведомления/SMS; iOS: строки выписки) до превращения в операцию.
@DataClassName('BankInboxRow')
class BankInbox extends Table with SyncColumns {
  TextColumn get channel => text()(); // notification / sms / statement
  TextColumn get sender => text()(); // пакет приложения / номер SMS / имя файла выписки
  TextColumn get bank => text().nullable()();
  TextColumn get body => text()();
  DateTimeColumn get receivedAt => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending / parsed / ignored / failed
  TextColumn get parsed => text().nullable()(); // JSON разбора (сумма, валюта, тип, мерчант, карта)
  TextColumn get parser => text().nullable()(); // template / ai
  TextColumn get transactionId => text().nullable()();
}

// ---- Этап 7: маркет покупок (SPEC §8.8) ----

/// Товар-подборка ИИ: примерная цена (веб-поиск сервера) с датой и источником, ссылки на магазины.
@DataClassName('MarketItemRow')
class MarketItems extends Table with SyncColumns {
  TextColumn get title => text()();
  TextColumn get category => text()(); // skin / nutrition / equipment / other
  TextColumn get reason => text().nullable()(); // зачем, под какой пункт плана
  IntColumn get price => integer().nullable()(); // мин. единицы
  TextColumn get currency => text().withDefault(const Constant('RUB'))();
  TextColumn get priceSource => text().nullable()();
  DateTimeColumn get priceAt => dateTime().nullable()();
  TextColumn get links => text().withDefault(const Constant('[]'))(); // JSON [{store, url, search}]
  TextColumn get budget => text().nullable()(); // MarketBudget.name: ok / afterIncome / over
  TextColumn get status => text().withDefault(const Constant('suggested'))(); // suggested / saved / bought / dismissed
  TextColumn get transactionId => text().nullable()(); // покупка → операция
  DateTimeColumn get createdAt => dateTime()();
}

// ---- Этап 7: блокировка приложений (SPEC §8.6) ----

/// Отвлекающее приложение. appId: Android — пакет, iOS — ключ из списка (tiktok, youtube, instagram…).
@DataClassName('BlockedAppRow')
class BlockedApps extends Table with SyncColumns {
  TextColumn get platform => text()(); // android / ios
  TextColumn get appId => text()();
  TextColumn get name => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}

/// Попытка открыть заблокированное (Android — оверлей, iOS — deep link sistema://blocked?app=…).
@DataClassName('BlockAttemptRow')
class BlockAttempts extends Table with SyncColumns {
  TextColumn get appId => text()();
  DateTimeColumn get at => dateTime()();
}

// ---- Этап 7: будильник-квест (SPEC §8.11) ----

/// Будильник: отключается только заданием (приседания или QR в другой комнате).
@DataClassName('AlarmRow')
class Alarms extends Table with SyncColumns {
  IntColumn get minute => integer()(); // минуты от полуночи
  IntColumn get weekdays => integer().withDefault(const Constant(127))(); // маска пн=1 … вс=64; 0 — разово
  TextColumn get label => text().nullable()();
  TextColumn get task => text().withDefault(const Constant('squats'))(); // AlarmTask.name: squats / qr
  IntColumn get squats => integer().withDefault(const Constant(15))();
  TextColumn get qrCode => text().nullable()(); // содержимое напечатанного QR
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  BoolColumn get fromDiscipline => boolean().withDefault(const Constant(false))(); // подъём режима дисциплины
}

/// Срабатывание будильника и его выключение заданием.
@DataClassName('AlarmRunRow')
class AlarmRuns extends Table with SyncColumns {
  TextColumn get alarmId => text()();
  DateTimeColumn get firedAt => dateTime()();
  DateTimeColumn get dismissedAt => dateTime().nullable()();
  TextColumn get task => text()();
  IntColumn get snoozes => integer().withDefault(const Constant(0))();
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
  ChatMessages,
  Courses,
  Lessons,
  PhotoAnalyses,
  FinAccounts,
  FinCategories,
  FinTransactions,
  FinBudgets,
  FinGoals,
  FinSubscriptions,
  FinDebts,
  CryptoHoldings,
  BankInbox,
  MarketItems,
  BlockedApps,
  BlockAttempts,
  Alarms,
  AlarmRuns,
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
  int get schemaVersion => 7;

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
          if (from < 6) {
            await m.createTable(chatMessages);
            await m.createTable(courses);
            await m.createTable(lessons);
            await m.createTable(photoAnalyses);
          }
          if (from < 7) {
            for (final t in <TableInfo<Table, Object?>>[
              finAccounts,
              finCategories,
              finTransactions,
              finBudgets,
              finGoals,
              finSubscriptions,
              finDebts,
              cryptoHoldings,
              bankInbox,
              marketItems,
              blockedApps,
              blockAttempts,
              alarms,
              alarmRuns,
            ]) {
              await m.createTable(t);
            }
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
