// Интеграция: план (D) поверх реальной логики расписания (C) и данных анкеты (A).
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/data/profile_repository.dart';
import 'package:sistema/core/data/questionnaire_repository.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/plan/data/plan_inputs_loader.dart';
import 'package:sistema/features/plan/data/plan_repository.dart';
import 'package:sistema/features/plan/draft_plan_builder.dart';
import 'package:sistema/features/plan/model/plan.dart';
import 'package:sistema/features/schedule/data/schedule_repository.dart';
import 'package:sistema/features/schedule/schedule_logic.dart';

import '../helpers/test_db.dart';

void main() {
  test('чередование недель: пара только в неделю 2 попадает в распорядок недели 2, выход из дома учтён', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final now = DateTime(2026, 10, 21, 9); // среда
    final schedule = ScheduleRepository(db, clock: () => now);

    await ProfileRepository(db).update(ProfilesCompanion(
      name: const Value('Игрок'),
      sex: Value(Sex.male.name),
      birthDate: Value(DateTime(2005, 5, 1)),
      heightCm: const Value(180),
      activityLevel: Value(ActivityLevel.light.name),
    ));
    final mid = newId();
    await db.into(db.bodyMeasurements).insert(BodyMeasurementsCompanion.insert(
          id: mid,
          updatedAt: DateTime.now().toUtc(),
          deviceId: await db.deviceId(),
          measuredAt: now,
          weightKg: const Value(75),
        ));
    await schedule.updateSettings(const ScheduleSettingsCompanion(commuteMinutes: Value(40)));
    await schedule.setAlternation(true);
    await schedule.saveEntry(const ScheduleEntry(
        id: '', kind: ScheduleItemKind.lesson, title: 'Матан', weekday: DateTime.monday,
        startMinute: 9 * 60, durationMinutes: 90, weekParity: 2));
    await schedule.saveEntry(const ScheduleEntry(
        id: '', kind: ScheduleItemKind.lesson, title: 'Физика', weekday: DateTime.monday,
        startMinute: 11 * 60, durationMinutes: 90));

    final config = await schedule.getConfig();
    expect(ScheduleLogic.weekNumber(now, config), 1);

    final inputs = await PlanInputsLoader(db, QuestionnaireRepository(db)).load(now: now);
    final plan = const DraftPlanBuilder().build(inputs, now: now);

    List<RoutineItem> monday(int week) =>
        plan.weeks.firstWhere((w) => w.number == week).days.firstWhere((d) => d.weekday == DateTime.monday).items;
    bool hasLesson(int week, String title) =>
        monday(week).any((i) => i.kind == RoutineKind.lesson && i.title == title);

    expect(hasLesson(1, 'Матан'), isFalse);
    expect(hasLesson(2, 'Матан'), isTrue);
    expect(hasLesson(1, 'Физика'), isTrue);
    final leave1 = monday(1).firstWhere((i) => i.kind == RoutineKind.leaveHome);
    final leave2 = monday(2).firstWhere((i) => i.kind == RoutineKind.leaveHome);
    expect(leave1.startMinute, 11 * 60 - 40);
    expect(leave2.startMinute, 9 * 60 - 40);
    expect(plan.norms.calories, isNotNull);

    // Сохранение и принятие черновика.
    final repo = PlanRepository(db);
    final id = await repo.saveDraft(plan);
    await repo.accept(id);
    expect((await repo.latestAccepted())?.plan.weeks.length, 2);
  });
}
