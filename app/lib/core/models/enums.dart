// Перечисления домена (этапы 1–2). В БД хранятся как `name` (строка) — переименовывать нельзя,
// только добавлять. Правит главный агент.

enum Sex { male, female }

/// Коэффициенты активности для Миффлина–Сан Жеора — в features/plan.
enum ActivityLevel { sedentary, light, moderate, active, veryActive }

/// Характер нагрузки на учёбе/работе.
enum Workload { sitting, mixed, standing, physical }

enum MeasurementSource { manual, scale, aiEstimate }

enum PhotoKind { body, skin, food, receipt }

enum PhotoPose {
  bodyFront,
  bodySide,
  bodyBack,
  faceFront,
  faceLeft,
  faceRight,
  closeup,
  other,
}

enum GoalKind { acne, blackheads, swelling, weightLoss, muscle, discipline, study, money, custom }

enum InstitutionType { school, college, university, none }

enum ScheduleItemKind { lesson, work, other }

/// Персонажи-архетипы (SPEC §9.2), только оригинальные. Хранится в разделе анкеты character.archetype.
enum CharacterArchetype { animeGirl, animeGuy, stoicStrongman, grimSwordsman }

/// Состояния анимации персонажа (SPEC §9.2).
enum CharacterState { idle, walk, talk, happy, angry, sit, sleep, point }

/// Разделы анкеты, хранимые как JSON в QuestionnaireSections (id = name).
enum QuestionnaireSection { skin, health, nutrition, training, finance, character, permissions }

// ---- Этап 2: квесты, баллы, штрафы (SPEC §6) ----

/// Ранг игрока E → S.
enum PlayerRank { e, d, c, b, a, s }

/// Шесть характеристик (SPEC §4). Квест качает характеристику своей категории.
enum StatKind { strength, endurance, discipline, intellect, health, looks }

/// Вид квеста.
enum QuestKind {
  daily, // ежедневный
  schedule, // из расписания (пары, выход из дома)
  goal, // по цели
  penalty, // штрафной — нельзя отменить
  boss, // босс недели (прогресс за неделю)
  intro, // знакомство
  control, // контрольный (замер, фото)
  discipline, // из режима дисциплины
  custom, // свой
}

/// Состояние экземпляра квеста на конкретный день.
enum QuestStatus {
  pending,
  done,
  failed, // проигнорирован до дедлайна
  refused, // сознательный отказ (удержание 5 с)
  excused, // пауза: без штрафа
}

/// Способ подтверждения.
enum ConfirmMethod { button, steps, photo, timer, geo }

/// Откуда квест.
enum QuestSource { plan, user, system, ai }

/// Записи журнала событий. Баллы ◆, опыт и характеристики — сумма по журналу (SPEC §10).
enum QuestEventType {
  completed,
  failed,
  refused,
  penalty, // отдельный штраф (упрёк, срыв)
  bonus, // награда вне квеста (серия, титул)
  purchase, // покупка в магазине (payload.rewardId)
  mark, // отметка «гулял/алкоголь/сорвался» (payload.mark)
  pauseStarted,
  pauseEnded,
  statPointSpent, // payload.stat
  bossCompleted,
  bossFailed,
  disciplineOn,
  disciplineOff,
  adjustment, // ручная правка/импорт
}

/// Честные отметки (SPEC §6) — мягче скрытого срыва, на завтра усиленный план.
enum DayMark { walkedWithFriends, alcohol, relapse }

/// Причина паузы — штрафы не начисляются, серия не сгорает.
enum PauseReason { illness, vacation, holidays, other }

/// Лимит частоты награды в магазине.
enum RewardLimitPeriod { day, week, month }

/// Безопасный разбор `name` из БД/JSON: неизвестное значение → null.
T? enumByName<T extends Enum>(List<T> values, String? name) {
  if (name == null) return null;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}

// ---- Этап 3 ----

/// Откуда продукт.
enum FoodSource { openFoodFacts, manual, server }

/// Приём пищи.
enum MealType { breakfast, lunch, dinner, snack }

/// Источник шагов.
enum StepSourceKind { coreMotion, healthConnect, sensor, manual }

/// Источник записи сна.
enum SleepSource { manual, mark, schedule }

/// Чек-лист ухода за кожей.
enum CareRoutine { morning, evening }

// ---- Этап 4 ----

/// Режим отрезка прогулки (SPEC §8.5).
enum WalkMode { walk, brisk, cardio, rest }

// ---- Этап 7 ----

/// Вид счёта (SPEC §8.7).
enum FinAccountKind { cash, card, deposit, crypto }

/// Вид операции.
enum FinTxKind { expense, income, transfer }

/// Откуда операция.
enum FinTxSource { manual, receiptQr, receiptPhoto, food, bankNotification, sms, statement, subscription, market }

/// Пометка маркета по финансам (SPEC §8.8).
enum MarketBudget { ok, afterIncome, over }

/// Задание для выключения будильника (SPEC §8.11).
enum AlarmTask { squats, qr }
