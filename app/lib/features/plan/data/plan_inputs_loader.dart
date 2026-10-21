// Сборка PlanInputs из локальной БД. Здесь же — склейка с ScheduleLogic (контракт фичи расписания).
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/questionnaire_repository.dart';
import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../schedule/schedule_logic.dart';
import '../draft_plan_builder.dart';
import '../norms/plan_calculator.dart';

class PlanInputsLoader {
  PlanInputsLoader(this._db, this._questionnaire);

  final AppDatabase _db;
  final QuestionnaireRepository _questionnaire;

  Future<PlanInputs> load({DateTime? now}) async {
    final today = now ?? DateTime.now();

    final profile = await (_db.select(_db.profiles)
          ..where((t) => t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();

    // Последний замер с весом.
    final measurement = await (_db.select(_db.bodyMeasurements)
          ..where((t) => t.deletedAt.isNull() & t.weightKg.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)])
          ..limit(1))
        .getSingleOrNull();

    final goals = await (_db.select(_db.goals)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();

    final settingsRow = await (_db.select(_db.scheduleSettings)
          ..where((t) => t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    final itemRows = await (_db.select(_db.scheduleItems)..where((t) => t.deletedAt.isNull())).get();

    final config = settingsRow == null ? const ScheduleConfig() : ScheduleConfig.fromRow(settingsRow);
    final entries = [for (final r in itemRows) ScheduleEntry.fromRow(r)];

    return PlanInputs(
      today: DateTime(today.year, today.month, today.day),
      sex: enumByName(Sex.values, profile?.sex),
      birthDate: profile?.birthDate,
      heightCm: profile?.heightCm,
      weightKg: measurement?.weightKg,
      activity: enumByName(ActivityLevel.values, profile?.activityLevel),
      workload: enumByName(Workload.values, profile?.workload),
      goals: [
        for (final g in goals)
          if (enumByName(GoalKind.values, g.kind) case final kind?) PlanGoal(kind, priority: g.priority),
      ],
      nutrition: await _questionnaire.read(QuestionnaireSection.nutrition),
      training: await _questionnaire.read(QuestionnaireSection.training),
      health: await _questionnaire.read(QuestionnaireSection.health),
      wakeMinute: config.wakeMinute,
      bedMinute: config.bedMinute,
      commuteMinutes: config.commuteMinutes,
      weeks: scheduleWeeks(today, config, entries),
    );
  }

  /// Расписание по неделям: для недели n берётся ближайшая (начиная с текущей) неделя с этим номером.
  static List<PlanWeekInput> scheduleWeeks(DateTime today, ScheduleConfig config, List<ScheduleEntry> entries) {
    final numbers = config.alternationEnabled ? const [1, 2] : const [1];
    if (entries.isEmpty) return [for (final n in numbers) PlanWeekInput(number: n)];
    final day = DateTime(today.year, today.month, today.day);
    final monday = day.subtract(Duration(days: day.weekday - DateTime.monday));
    final weeks = <PlanWeekInput>[];
    for (final n in numbers) {
      var start = monday;
      if (ScheduleLogic.weekNumber(start, config) != n) start = DateTime(start.year, start.month, start.day + 7);
      final days = <int, PlanDayInput>{};
      for (var i = 0; i < 7; i++) {
        final date = DateTime(start.year, start.month, start.day + i);
        days[date.weekday] = PlanDayInput(
          entries: ScheduleLogic.entriesFor(date, config, entries),
          leaveHomeMinute: ScheduleLogic.leaveHomeMinute(date, config, entries),
        );
      }
      weeks.add(PlanWeekInput(number: n, days: days));
    }
    return weeks;
  }
}

final planInputsLoaderProvider = Provider<PlanInputsLoader>(
  (ref) => PlanInputsLoader(ref.watch(databaseProvider), ref.watch(questionnaireRepositoryProvider)),
);
