// Генератор чернового плана без ИИ (этап 1). Чистый Dart: вход PlanInputs → Plan.
// Расписание приходит уже разложенным по неделям/дням (склейка с ScheduleLogic — в plan_inputs_loader.dart),
// поэтому генератор тестируется без логики расписания.
import 'dart:math' as math;

import '../../core/models/enums.dart';
import '../schedule/schedule_logic.dart';
import 'model/plan.dart';
import 'norms/plan_calculator.dart';

/// Пункты расписания одного дня недели.
class PlanDayInput {
  const PlanDayInput({this.entries = const [], this.leaveHomeMinute});

  /// Пункты на день, по времени начала.
  final List<ScheduleEntry> entries;

  /// Время выхода из дома; null — выходить не нужно.
  final int? leaveHomeMinute;
}

/// Расписание одной недели (номер 1/2) по дням недели.
class PlanWeekInput {
  const PlanWeekInput({required this.number, this.days = const {}});
  final int number;
  final Map<int, PlanDayInput> days;
}

/// Всё, что нужно генератору. Разделы анкеты — JSON по схемам брифа этапа 1.
class PlanInputs {
  const PlanInputs({
    required this.today,
    this.sex,
    this.birthDate,
    this.heightCm,
    this.weightKg,
    this.activity,
    this.workload,
    this.goals = const [],
    this.nutrition = const {},
    this.training = const {},
    this.health = const {},
    this.wakeMinute = 7 * 60,
    this.bedMinute = 23 * 60,
    this.commuteMinutes = 0,
    this.weeks = const [PlanWeekInput(number: 1)],
  });

  final DateTime today;
  final Sex? sex;
  final DateTime? birthDate;
  final double? heightCm;
  final double? weightKg;
  final ActivityLevel? activity;
  final Workload? workload;
  final List<PlanGoal> goals;
  final Map<String, Object?> nutrition;
  final Map<String, Object?> training;
  final Map<String, Object?> health;
  final int wakeMinute;
  final int bedMinute;
  final int commuteMinutes;

  /// Одна неделя без чередования, две (1 и 2) — с чередованием.
  final List<PlanWeekInput> weeks;
}

/// Награды квестов-черновиков по категориям: (◆, опыт).
const questRewards = <QuestCategory, (int, int)>{
  QuestCategory.schedule: (10, 15),
  QuestCategory.daily: (5, 10),
  QuestCategory.training: (15, 25),
  QuestCategory.health: (5, 10),
  QuestCategory.goal: (10, 20),
};

class DraftPlanBuilder {
  const DraftPlanBuilder();

  static const defaultMeals = 3;
  static const defaultTrainingMinutes = 30;
  static const _mealBlock = 30; // время на приём пищи
  static const _afterMealGap = 60; // тренировка не раньше чем через час после еды
  static const _day = 24 * 60;

  static const skinGoals = {GoalKind.acne, GoalKind.blackheads, GoalKind.swelling};

  Plan build(PlanInputs input, {DateTime? now}) {
    final norms = PlanCalculator.compute(
      sex: input.sex,
      birthDate: input.birthDate,
      heightCm: input.heightCm,
      weightKg: input.weightKg,
      activity: input.activity,
      workload: input.workload,
      goals: input.goals,
      wakeMinute: input.wakeMinute,
      bedMinute: input.bedMinute,
      today: input.today,
    );
    final sleep = norms.sleep;
    // Сон не сокращаем (SPEC §6): если по расписанию сна мало — в распорядке рекомендуемый отбой.
    final bed = sleep.isShort ? sleep.recommendedBedMinute : input.bedMinute;

    final goalKinds = {for (final g in input.goals) g.kind};
    final skincare = goalKinds.any(skinGoals.contains);
    final mealsPerDay = (_int(input.nutrition['mealsPerDay']) ?? defaultMeals).clamp(1, 6);
    final trainingDays = {
      for (final d in _list(input.training['days'])) ?_int(d),
    }.where((d) => d >= 1 && d <= 7).toSet();
    final trainingMinutes = (_int(input.training['minutesPerDay']) ?? defaultTrainingMinutes).clamp(10, 180);

    final warnings = <PlanWarning>[
      if (sleep.isShort)
        PlanWarning(PlanWarningKind.sleepShort, {
          'scheduledMinutes': sleep.scheduledMinutes,
          'targetMinutes': sleep.targetMinutes,
          'recommendedBed': sleep.recommendedBedMinute,
        }),
      if (norms.energy?.floorApplied ?? false) const PlanWarning(PlanWarningKind.deficitFloor),
      if (norms.activityDefaulted && norms.energy != null) const PlanWarning(PlanWarningKind.activityDefaulted),
      if ((input.health['injuries'] as String? ?? '').trim().isNotEmpty) const PlanWarning(PlanWarningKind.injuries),
    ];

    final weeks = <PlanWeek>[];
    for (final w in input.weeks) {
      final days = <PlanDay>[];
      for (var wd = DateTime.monday; wd <= DateTime.sunday; wd++) {
        final dayInput = w.days[wd] ?? const PlanDayInput();
        final (items, trainingPlaced) = _buildDay(
          dayInput,
          wake: input.wakeMinute,
          bed: bed,
          commute: input.commuteMinutes,
          meals: mealsPerDay,
          training: trainingDays.contains(wd) ? trainingMinutes : null,
          skincare: skincare,
        );
        if (trainingDays.contains(wd) && !trainingPlaced) {
          warnings.add(PlanWarning(PlanWarningKind.noTrainingWindow, {
            'weekday': wd,
            if (input.weeks.length > 1) 'week': w.number,
          }));
        }
        days.add(PlanDay(weekday: wd, items: items));
      }
      weeks.add(PlanWeek(number: w.number, days: days));
    }

    final quests = <QuestDraft>[
      ..._scheduleQuests(input.weeks),
      if (norms.water != null)
        _quest(QuestKey.water, QuestCategory.daily, params: {'ml': norms.water!.baseMl}),
      _quest(QuestKey.sleepOnTime, QuestCategory.daily,
          minute: bed, params: {'hours': sleep.targetMinutes / 60}),
      _quest(QuestKey.meals, QuestCategory.daily, params: {'count': mealsPerDay}),
      if (trainingDays.isNotEmpty)
        _quest(QuestKey.training, QuestCategory.training,
            params: {'minutes': trainingMinutes}, weekdays: trainingDays.toList()..sort()),
      if (skincare) ...[
        _quest(QuestKey.skincareMorning, QuestCategory.health, minute: input.wakeMinute + 10),
        _quest(QuestKey.skincareEvening, QuestCategory.health, minute: (bed - 30) % _day),
      ],
      if (goalKinds.contains(GoalKind.discipline))
        _quest(QuestKey.wakeOnTime, QuestCategory.goal, minute: input.wakeMinute),
      if (goalKinds.contains(GoalKind.study)) _quest(QuestKey.study, QuestCategory.goal, params: {'minutes': 30}),
      if (goalKinds.contains(GoalKind.money)) _quest(QuestKey.trackExpenses, QuestCategory.goal),
    ];

    final e = norms.energy;
    return Plan(
      generatedAt: (now ?? DateTime.now()).toUtc(),
      norms: PlanNorms(
        bmr: e?.bmr,
        tdee: e?.tdee,
        calories: e?.calories,
        calorieMode: e?.mode,
        proteinG: e?.proteinG,
        fatG: e?.fatG,
        carbsG: e?.carbsG,
        waterMl: norms.water?.baseMl,
        waterTrainingDayMl: norms.water?.trainingDayMl,
        sleepTargetMinutes: sleep.targetMinutes,
        wakeMinute: input.wakeMinute,
        bedMinute: input.bedMinute,
        recommendedBedMinute: sleep.recommendedBedMinute,
      ),
      missing: norms.missing,
      warnings: warnings,
      weeks: weeks,
      quests: quests,
    );
  }

  static QuestDraft _quest(
    QuestKey key,
    QuestCategory category, {
    Map<String, Object?> params = const {},
    int? minute,
    List<int> weekdays = const [],
    int week = 0,
  }) {
    final (diamonds, xp) = questRewards[category]!;
    return QuestDraft(
      key: key,
      category: category,
      params: params,
      minute: minute,
      weekdays: weekdays,
      week: week,
      diamonds: diamonds,
      xp: xp,
    );
  }

  /// Квесты из расписания: выход из дома и пары/работа. Одинаковые (ключ, время, название)
  /// объединяются по дням недели; если с чередованием набор дней в обеих неделях совпадает — week = 0.
  List<QuestDraft> _scheduleQuests(List<PlanWeekInput> weeks) {
    final groups = <(QuestKey, int, String?), Map<int, Set<int>>>{}; // → неделя → дни
    void add(QuestKey key, int minute, String? title, int week, int weekday) {
      groups.putIfAbsent((key, minute, title), () => {}).putIfAbsent(week, () => {}).add(weekday);
    }

    for (final w in weeks) {
      for (final MapEntry(key: wd, value: d) in w.days.entries) {
        final leave = d.leaveHomeMinute;
        if (leave != null) add(QuestKey.leaveHome, leave, null, w.number, wd);
        for (final e in d.entries) {
          final key = switch (e.kind) {
            ScheduleItemKind.lesson => QuestKey.attendLesson,
            ScheduleItemKind.work => QuestKey.attendWork,
            ScheduleItemKind.other => null,
          };
          if (key != null) add(key, e.startMinute, e.title, w.number, wd);
        }
      }
    }

    final alternation = weeks.length > 1;
    final result = <QuestDraft>[];
    for (final MapEntry(key: (key, minute, title), value: byWeek) in groups.entries) {
      final params = title == null ? const <String, Object?>{} : {'title': title};
      final w1 = byWeek[weeks.first.number] ?? const {};
      final sameAll = !alternation ||
          (byWeek.length == weeks.length && byWeek.values.every((s) => s.length == w1.length && s.containsAll(w1)));
      if (sameAll) {
        result.add(_quest(key, QuestCategory.schedule, params: params, minute: minute, weekdays: w1.toList()..sort()));
      } else {
        for (final MapEntry(key: week, value: days) in byWeek.entries) {
          result.add(_quest(key, QuestCategory.schedule,
              params: params, minute: minute, weekdays: days.toList()..sort(), week: week));
        }
      }
    }
    result.sort((a, b) {
      final c = (a.minute ?? 0).compareTo(b.minute ?? 0);
      return c != 0 ? c : a.week.compareTo(b.week);
    });
    return result;
  }

  /// Распорядок дня. Возвращает пункты и признак, удалось ли поставить тренировку.
  (List<RoutineItem>, bool) _buildDay(
    PlanDayInput day, {
    required int wake,
    required int bed,
    required int commute,
    required int meals,
    required int? training,
    required bool skincare,
  }) {
    // Время после полуночи для отбоя — «развёрнутое» (> 24:00), чтобы окна считались корректно.
    final bedEff = bed > wake ? bed : bed + _day;
    final items = <RoutineItem>[RoutineItem(kind: RoutineKind.wake, startMinute: wake)];
    final busy = <(int, int)>[];

    if (skincare) {
      items.add(RoutineItem(kind: RoutineKind.skincareAm, startMinute: wake + 10, durationMinutes: 10));
      busy.add((wake + 10, wake + 20));
    }

    for (final e in day.entries) {
      items.add(RoutineItem(
        kind: switch (e.kind) {
          ScheduleItemKind.lesson => RoutineKind.lesson,
          ScheduleItemKind.work => RoutineKind.work,
          ScheduleItemKind.other => RoutineKind.other,
        },
        startMinute: e.startMinute,
        durationMinutes: e.durationMinutes,
        title: e.title,
      ));
      busy.add((e.startMinute, e.endMinute));
    }

    final leave = day.leaveHomeMinute;
    if (leave != null) {
      items.add(RoutineItem(kind: RoutineKind.leaveHome, startMinute: leave));
      final commuting = day.entries.where((e) => e.requiresCommute).toList();
      if (commuting.isNotEmpty) {
        final firstStart = commuting.map((e) => e.startMinute).reduce(math.min);
        busy.add((leave, firstStart));
        if (commute > 0) {
          final lastEnd = commuting.map((e) => e.endMinute).reduce(math.max);
          items.add(RoutineItem(kind: RoutineKind.returnHome, startMinute: lastEnd + commute));
          busy.add((lastEnd, lastEnd + commute));
        }
      }
    }

    // Приёмы пищи: равномерно от «подъём + 30 мин» до «отбой − 3 ч», со сдвигом из занятых интервалов.
    final first = wake + 30;
    final last = math.max(first, bedEff - 180);
    final mealTimes = <int>[];
    for (var i = 0; i < meals; i++) {
      var t = meals == 1 ? (first + last) ~/ 2 : first + ((last - first) * i / (meals - 1)).round();
      t = _round5(t);
      t = _avoidBusy(t, _mealBlock, busy, first, last + 60);
      mealTimes.add(t);
    }
    mealTimes.sort();
    for (var i = 0; i < mealTimes.length; i++) {
      items.add(RoutineItem(kind: RoutineKind.meal, startMinute: mealTimes[i], durationMinutes: _mealBlock, index: i + 1));
    }

    var trainingPlaced = training == null;
    if (training != null) {
      final blocks = [...busy, for (final m in mealTimes) (m, m + _afterMealGap)];
      if (skincare) blocks.add((bedEff - 30, bedEff));
      final latestStart = bedEff - 120 - training; // не позже чем за 2 ч до сна
      final earliest = wake + 60;
      // Предпочтительно — после учёбы/работы.
      final afterBusy = busy.isEmpty ? earliest : math.max(earliest, busy.map((b) => b.$2).reduce(math.max));
      final slot = _findSlot(_round15(afterBusy), latestStart, training, blocks) ??
          _findSlot(_round15(earliest), latestStart, training, blocks);
      if (slot != null) {
        items.add(RoutineItem(kind: RoutineKind.training, startMinute: slot, durationMinutes: training));
        trainingPlaced = true;
      }
    }

    if (skincare) items.add(RoutineItem(kind: RoutineKind.skincarePm, startMinute: bedEff - 30, durationMinutes: 10));
    items.add(RoutineItem(kind: RoutineKind.bed, startMinute: bedEff));

    items.sort((a, b) {
      final c = a.startMinute.compareTo(b.startMinute);
      return c != 0 ? c : a.kind.index.compareTo(b.kind.index);
    });
    // Хранение — минуты суток 0..1439.
    return (
      [
        for (final i in items)
          RoutineItem(
            kind: i.kind,
            startMinute: i.startMinute % _day,
            durationMinutes: i.durationMinutes,
            title: i.title,
            index: i.index,
          ),
      ],
      trainingPlaced,
    );
  }

  static bool _overlaps(int s, int e, (int, int) b) => s < b.$2 && b.$1 < e;

  /// Сдвигает интервал [t, t+len) из занятых: сначала после помехи, если не влезает — до неё.
  static int _avoidBusy(int t, int len, List<(int, int)> busy, int min, int max) {
    for (var guard = 0; guard < 10; guard++) {
      final hit = busy.where((b) => _overlaps(t, t + len, b)).toList();
      if (hit.isEmpty) return t;
      final b = hit.first;
      if (b.$2 <= max) {
        t = _round5Up(b.$2);
      } else if (b.$1 - len >= min) {
        t = b.$1 - len;
      } else {
        return t;
      }
    }
    return t;
  }

  static int? _findSlot(int from, int to, int len, List<(int, int)> blocks) {
    for (var t = from; t <= to; t += 15) {
      if (!blocks.any((b) => _overlaps(t, t + len, b))) return t;
    }
    return null;
  }

  static int _round5(int m) => (m / 5).round() * 5;
  static int _round5Up(int m) => ((m + 4) ~/ 5) * 5;
  static int _round15(int m) => ((m + 14) ~/ 15) * 15;
}

int? _int(Object? v) => v is num ? v.toInt() : null;

List<Object?> _list(Object? v) => v is List ? v.cast<Object?>() : const [];
