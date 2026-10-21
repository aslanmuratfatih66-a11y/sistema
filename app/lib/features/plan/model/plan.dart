// Модель плана (SPEC §5): нормы, распорядок на неделю 1/2, квесты-черновики, предупреждения.
// Хранится как JSON в Plans.payload, версия формата `v: 1`. Строки UI здесь не хранятся —
// только ключи + параметры, локализация при показе (plan_l10n.dart).
import '../../../core/models/enums.dart';
import '../norms/plan_calculator.dart';

/// Нормы плана. Поля калорий/БЖУ/воды — null, если данных не хватает.
class PlanNorms {
  const PlanNorms({
    this.bmr,
    this.tdee,
    this.calories,
    this.calorieMode,
    this.proteinG,
    this.fatG,
    this.carbsG,
    this.waterMl,
    this.waterTrainingDayMl,
    required this.sleepTargetMinutes,
    required this.wakeMinute,
    required this.bedMinute,
    required this.recommendedBedMinute,
  });

  final int? bmr;
  final int? tdee;
  final int? calories;
  final CalorieMode? calorieMode;
  final int? proteinG;
  final int? fatG;
  final int? carbsG;
  final int? waterMl;
  final int? waterTrainingDayMl;
  final int sleepTargetMinutes;
  final int wakeMinute;

  /// Отбой из расписания.
  final int bedMinute;
  final int recommendedBedMinute;

  bool get hasEnergy => calories != null;

  Map<String, Object?> toJson() => {
        'bmr': bmr,
        'tdee': tdee,
        'calories': calories,
        'calorieMode': calorieMode?.name,
        'proteinG': proteinG,
        'fatG': fatG,
        'carbsG': carbsG,
        'waterMl': waterMl,
        'waterTrainingDayMl': waterTrainingDayMl,
        'sleepTargetMinutes': sleepTargetMinutes,
        'wakeMinute': wakeMinute,
        'bedMinute': bedMinute,
        'recommendedBedMinute': recommendedBedMinute,
      };

  factory PlanNorms.fromJson(Map<String, Object?> j) => PlanNorms(
        bmr: _int(j['bmr']),
        tdee: _int(j['tdee']),
        calories: _int(j['calories']),
        calorieMode: enumByName(CalorieMode.values, j['calorieMode'] as String?),
        proteinG: _int(j['proteinG']),
        fatG: _int(j['fatG']),
        carbsG: _int(j['carbsG']),
        waterMl: _int(j['waterMl']),
        waterTrainingDayMl: _int(j['waterTrainingDayMl']),
        sleepTargetMinutes: _int(j['sleepTargetMinutes']) ?? 480,
        wakeMinute: _int(j['wakeMinute']) ?? 420,
        bedMinute: _int(j['bedMinute']) ?? 1380,
        recommendedBedMinute: _int(j['recommendedBedMinute']) ?? 1380,
      );
}

enum RoutineKind { wake, skincareAm, meal, leaveHome, lesson, work, other, returnHome, training, skincarePm, bed }

/// Пункт суточного распорядка.
class RoutineItem {
  const RoutineItem({required this.kind, required this.startMinute, this.durationMinutes = 0, this.title, this.index});

  final RoutineKind kind;
  final int startMinute;
  final int durationMinutes;

  /// Название из расписания (пара/работа) — пользовательский текст, не локализуется.
  final String? title;

  /// Номер приёма пищи (1..n).
  final int? index;

  int get endMinute => startMinute + durationMinutes;

  Map<String, Object?> toJson() => {
        'kind': kind.name,
        'start': startMinute,
        if (durationMinutes != 0) 'duration': durationMinutes,
        if (title != null) 'title': title,
        if (index != null) 'index': index,
      };

  static RoutineItem? fromJson(Map<String, Object?> j) {
    final kind = enumByName(RoutineKind.values, j['kind'] as String?);
    final start = _int(j['start']);
    if (kind == null || start == null) return null;
    return RoutineItem(
      kind: kind,
      startMinute: start,
      durationMinutes: _int(j['duration']) ?? 0,
      title: j['title'] as String?,
      index: _int(j['index']),
    );
  }
}

class PlanDay {
  const PlanDay({required this.weekday, required this.items});
  final int weekday; // DateTime.monday..sunday
  final List<RoutineItem> items;

  Map<String, Object?> toJson() => {'weekday': weekday, 'items': [for (final i in items) i.toJson()]};

  factory PlanDay.fromJson(Map<String, Object?> j) => PlanDay(
        weekday: _int(j['weekday']) ?? 1,
        items: [
          for (final i in _list(j['items']))
            if (i is Map<String, Object?>) ?RoutineItem.fromJson(i),
        ],
      );
}

class PlanWeek {
  const PlanWeek({required this.number, required this.days});
  final int number; // 1 или 2
  final List<PlanDay> days; // 7 дней, пн..вс

  PlanDay? day(int weekday) {
    for (final d in days) {
      if (d.weekday == weekday) return d;
    }
    return null;
  }

  Map<String, Object?> toJson() => {'number': number, 'days': [for (final d in days) d.toJson()]};

  factory PlanWeek.fromJson(Map<String, Object?> j) => PlanWeek(
        number: _int(j['number']) ?? 1,
        days: [
          for (final d in _list(j['days']))
            if (d is Map<String, Object?>) PlanDay.fromJson(d),
        ],
      );
}

enum QuestCategory { schedule, daily, training, health, goal }

/// Ключи названий квестов (локализуются при показе, параметры — в [QuestDraft.params]).
enum QuestKey {
  leaveHome, // {time}
  attendLesson, // {title, time}
  attendWork, // {title, time}
  water, // {ml}
  sleepOnTime, // {time, hours}
  meals, // {count}
  training, // {minutes}
  skincareMorning,
  skincareEvening,
  wakeOnTime, // {time} — дисциплина
  study, // {minutes}
  trackExpenses, // деньги
}

/// Квест-черновик. На этапе 1 только показывается (движок квестов — этап 2).
class QuestDraft {
  const QuestDraft({
    required this.key,
    required this.category,
    this.params = const {},
    this.minute,
    this.weekdays = const [],
    this.week = 0,
    required this.diamonds,
    required this.xp,
  });

  final QuestKey key;
  final QuestCategory category;
  final Map<String, Object?> params;

  /// Время (минута суток), null — в течение дня.
  final int? minute;

  /// Дни недели; пусто — каждый день.
  final List<int> weekdays;

  /// 0 — каждую неделю, 1/2 — только эту.
  final int week;
  final int diamonds;
  final int xp;

  Map<String, Object?> toJson() => {
        'key': key.name,
        'category': category.name,
        if (params.isNotEmpty) 'params': params,
        if (minute != null) 'minute': minute,
        if (weekdays.isNotEmpty) 'weekdays': weekdays,
        if (week != 0) 'week': week,
        'diamonds': diamonds,
        'xp': xp,
      };

  static QuestDraft? fromJson(Map<String, Object?> j) {
    final key = enumByName(QuestKey.values, j['key'] as String?);
    final category = enumByName(QuestCategory.values, j['category'] as String?);
    if (key == null || category == null) return null;
    final params = j['params'];
    return QuestDraft(
      key: key,
      category: category,
      params: params is Map<String, Object?> ? params : const {},
      minute: _int(j['minute']),
      weekdays: [for (final d in _list(j['weekdays'])) ?_int(d)],
      week: _int(j['week']) ?? 0,
      diamonds: _int(j['diamonds']) ?? 0,
      xp: _int(j['xp']) ?? 0,
    );
  }
}

enum PlanWarningKind {
  sleepShort, // {scheduledMinutes, targetMinutes, recommendedBed}
  deficitFloor, // дефицит ограничен безопасным минимумом
  activityDefaulted, // уровень активности не указан — взят «сидячий»
  noTrainingWindow, // {weekday, week}
  injuries, // указаны травмы — учесть при тренировках
}

class PlanWarning {
  const PlanWarning(this.kind, [this.params = const {}]);
  final PlanWarningKind kind;
  final Map<String, Object?> params;

  Map<String, Object?> toJson() => {'kind': kind.name, if (params.isNotEmpty) 'params': params};

  static PlanWarning? fromJson(Map<String, Object?> j) {
    final kind = enumByName(PlanWarningKind.values, j['kind'] as String?);
    if (kind == null) return null;
    final p = j['params'];
    return PlanWarning(kind, p is Map<String, Object?> ? p : const {});
  }
}

class Plan {
  const Plan({
    required this.generatedAt,
    required this.norms,
    this.missing = const [],
    this.warnings = const [],
    required this.weeks,
    this.quests = const [],
  });

  static const formatVersion = 1;

  final DateTime generatedAt;
  final PlanNorms norms;
  final List<MissingField> missing;
  final List<PlanWarning> warnings;

  /// Одна неделя без чередования, две — с чередованием.
  final List<PlanWeek> weeks;
  final List<QuestDraft> quests;

  bool get alternation => weeks.length > 1;

  Map<String, Object?> toJson() => {
        'v': formatVersion,
        'generatedAt': generatedAt.toUtc().toIso8601String(),
        'norms': norms.toJson(),
        'missing': [for (final m in missing) m.name],
        'warnings': [for (final w in warnings) w.toJson()],
        'weeks': [for (final w in weeks) w.toJson()],
        'quests': [for (final q in quests) q.toJson()],
      };

  /// Разбор JSON. Неизвестная версия формата — FormatException.
  factory Plan.fromJson(Map<String, Object?> j) {
    if (j['v'] != formatVersion) throw FormatException('Неизвестная версия плана: ${j['v']}');
    final norms = j['norms'];
    return Plan(
      generatedAt: DateTime.tryParse(j['generatedAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      norms: PlanNorms.fromJson(norms is Map<String, Object?> ? norms : const {}),
      missing: [for (final m in _list(j['missing'])) ?enumByName(MissingField.values, m as String?)],
      warnings: [
        for (final w in _list(j['warnings']))
          if (w is Map<String, Object?>) ?PlanWarning.fromJson(w),
      ],
      weeks: [
        for (final w in _list(j['weeks']))
          if (w is Map<String, Object?>) PlanWeek.fromJson(w),
      ],
      quests: [
        for (final q in _list(j['quests']))
          if (q is Map<String, Object?>) ?QuestDraft.fromJson(q),
      ],
    );
  }
}

int? _int(Object? v) => v is num ? v.toInt() : null;

List<Object?> _list(Object? v) => v is List ? v.cast<Object?>() : const [];
