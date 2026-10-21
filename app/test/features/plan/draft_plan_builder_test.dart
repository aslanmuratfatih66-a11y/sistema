import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/plan/draft_plan_builder.dart';
import 'package:sistema/features/plan/model/plan.dart';
import 'package:sistema/features/plan/norms/plan_calculator.dart';
import 'package:sistema/features/schedule/schedule_logic.dart';

const _lesson = ScheduleEntry(
  id: 'l1',
  kind: ScheduleItemKind.lesson,
  title: 'Математика',
  weekday: DateTime.monday,
  startMinute: 9 * 60,
  durationMinutes: 90,
);

PlanInputs _inputs({
  List<PlanGoal> goals = const [],
  Map<String, Object?> nutrition = const {},
  Map<String, Object?> training = const {},
  List<PlanWeekInput> weeks = const [PlanWeekInput(number: 1)],
  int commute = 0,
}) =>
    PlanInputs(
      today: DateTime(2026, 10, 21),
      sex: Sex.male,
      birthDate: DateTime(1996, 1, 1),
      heightCm: 180,
      weightKg: 80,
      activity: ActivityLevel.moderate,
      goals: goals,
      nutrition: nutrition,
      training: training,
      commuteMinutes: commute,
      weeks: weeks,
    );

const _builder = DraftPlanBuilder();

List<RoutineItem> _items(Plan p, int weekday, {int week = 1}) =>
    p.weeks.firstWhere((w) => w.number == week).day(weekday)!.items;

void main() {
  test('тренировка только в выбранные дни', () {
    final p = _builder.build(_inputs(training: {
      'days': [DateTime.monday, DateTime.wednesday],
      'minutesPerDay': 45,
    }));
    for (var d = 1; d <= 7; d++) {
      final t = _items(p, d).where((i) => i.kind == RoutineKind.training).toList();
      if (d == DateTime.monday || d == DateTime.wednesday) {
        expect(t, hasLength(1), reason: 'день $d');
        expect(t.single.durationMinutes, 45);
      } else {
        expect(t, isEmpty, reason: 'день $d');
      }
    }
    final q = p.quests.singleWhere((q) => q.key == QuestKey.training);
    expect(q.weekdays, [1, 3]);
    expect(q.params['minutes'], 45);
  });

  test('приёмы пищи по количеству', () {
    final p = _builder.build(_inputs(nutrition: {'mealsPerDay': 4}));
    for (var d = 1; d <= 7; d++) {
      expect(_items(p, d).where((i) => i.kind == RoutineKind.meal), hasLength(4));
    }
    expect(p.quests.singleWhere((q) => q.key == QuestKey.meals).params['count'], 4);
    // По умолчанию — 3.
    expect(_items(_builder.build(_inputs()), 1).where((i) => i.kind == RoutineKind.meal), hasLength(3));
  });

  test('уход за кожей — только при целях acne/blackheads/swelling', () {
    final none = _builder.build(_inputs(goals: const [PlanGoal(GoalKind.muscle)]));
    expect(none.quests.where((q) => q.key == QuestKey.skincareMorning || q.key == QuestKey.skincareEvening), isEmpty);
    expect(_items(none, 1).where((i) => i.kind == RoutineKind.skincareAm), isEmpty);

    final skin = _builder.build(_inputs(goals: const [PlanGoal(GoalKind.blackheads)]));
    expect(skin.quests.map((q) => q.key), containsAll([QuestKey.skincareMorning, QuestKey.skincareEvening]));
    expect(_items(skin, 1).map((i) => i.kind), containsAll([RoutineKind.skincareAm, RoutineKind.skincarePm]));
  });

  test('квесты из расписания и по целям; тренировка не пересекается с парой', () {
    final p = _builder.build(_inputs(
      goals: const [PlanGoal(GoalKind.discipline), PlanGoal(GoalKind.study), PlanGoal(GoalKind.money)],
      training: {'days': [DateTime.monday], 'minutesPerDay': 60},
      commute: 30,
      weeks: const [
        PlanWeekInput(number: 1, days: {DateTime.monday: PlanDayInput(entries: [_lesson], leaveHomeMinute: 8 * 60 + 30)}),
      ],
    ));
    final leave = p.quests.singleWhere((q) => q.key == QuestKey.leaveHome);
    expect(leave.minute, 8 * 60 + 30);
    expect(leave.weekdays, [DateTime.monday]);
    final lesson = p.quests.singleWhere((q) => q.key == QuestKey.attendLesson);
    expect(lesson.params['title'], 'Математика');
    expect(p.quests.map((q) => q.key), containsAll([QuestKey.wakeOnTime, QuestKey.study, QuestKey.trackExpenses]));

    final mon = _items(p, DateTime.monday);
    final training = mon.singleWhere((i) => i.kind == RoutineKind.training);
    expect(training.startMinute >= _lesson.endMinute + 30 || training.endMinute <= 8 * 60 + 30, isTrue);
    expect(mon.map((i) => i.kind), containsAll([RoutineKind.leaveHome, RoutineKind.lesson, RoutineKind.returnHome]));
    // Приёмы пищи не попадают на пару и дорогу.
    for (final m in mon.where((i) => i.kind == RoutineKind.meal)) {
      expect(m.endMinute <= 8 * 60 + 30 || m.startMinute >= _lesson.endMinute + 30, isTrue, reason: '${m.startMinute}');
    }
  });

  test('чередование: квест только своей недели', () {
    final p = _builder.build(_inputs(weeks: const [
      PlanWeekInput(number: 1, days: {DateTime.monday: PlanDayInput(entries: [_lesson], leaveHomeMinute: 510)}),
      PlanWeekInput(number: 2),
    ]));
    expect(p.alternation, isTrue);
    expect(p.weeks, hasLength(2));
    final lesson = p.quests.singleWhere((q) => q.key == QuestKey.attendLesson);
    expect(lesson.week, 1);
    expect(_items(p, 1, week: 2).where((i) => i.kind == RoutineKind.lesson), isEmpty);
  });

  test('мало сна — предупреждение и рекомендуемый отбой в распорядке', () {
    final p = _builder.build(PlanInputs(today: DateTime(2026, 10, 21), wakeMinute: 6 * 60, bedMinute: 0));
    final w = p.warnings.singleWhere((w) => w.kind == PlanWarningKind.sleepShort);
    expect(w.params['recommendedBed'], 22 * 60);
    expect(_items(p, 1).last.kind, RoutineKind.bed);
    expect(_items(p, 1).last.startMinute, 22 * 60);
    // Данных о теле нет — нормы калорий пустые, причина указана.
    expect(p.norms.calories, isNull);
    expect(p.missing, containsAll(MissingField.values));
  });

  test('Plan → JSON → Plan', () {
    final p = _builder.build(
      _inputs(
        goals: const [PlanGoal(GoalKind.acne), PlanGoal(GoalKind.weightLoss, priority: 1)],
        training: {'days': [2, 4]},
        weeks: const [
          PlanWeekInput(number: 1, days: {DateTime.monday: PlanDayInput(entries: [_lesson], leaveHomeMinute: 510)}),
          PlanWeekInput(number: 2),
        ],
      ),
      now: DateTime.utc(2026, 10, 21, 10),
    );
    final json = jsonDecode(jsonEncode(p.toJson())) as Map<String, Object?>;
    expect(json['v'], 1);
    final back = Plan.fromJson(json);
    expect(jsonEncode(back.toJson()), jsonEncode(p.toJson()));
    expect(back.norms.calorieMode, CalorieMode.deficit);
    expect(back.generatedAt, DateTime.utc(2026, 10, 21, 10));
    expect(() => Plan.fromJson({...json, 'v': 99}), throwsFormatException);
  });
}
