import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/features/workouts/data/workout_recorder.dart';
import 'package:sistema/features/workouts/data/workout_repository.dart';
import 'package:sistema/features/workouts/domain/kcal.dart';
import 'package:sistema/features/workouts/domain/program_generator.dart';
import 'package:sistema/features/workouts/domain/training_profile.dart';
import 'package:sistema/features/workouts/domain/workout_runner.dart';

import '../../helpers/test_db.dart';
import 'fakes.dart';

WorkoutResult _result({required bool completed}) => WorkoutResult(
      completed: completed,
      activeSeconds: 600,
      restSeconds: 240,
      workSecondsByExercise: const {'squat': 180, 'plank': 180},
      sets: const [
        SetRecord(exerciseKey: 'squat', set: 1, reps: 12, seconds: 90),
        SetRecord(exerciseKey: 'plank', set: 1, seconds: 30, skipped: true),
      ],
    );

void main() {
  late AppDatabase db;
  late WorkoutRepository repo;
  late FakeHooks hooks;
  late WorkoutRecorder recorder;
  final now = DateTime(2026, 10, 21, 19);

  setUp(() {
    db = memoryDb();
    repo = WorkoutRepository(db);
    hooks = FakeHooks();
    recorder = WorkoutRecorder(repository: repo, hooks: hooks, clock: () => now);
  });
  tearDown(() => db.close());

  test('ккал = MET × вес × часы (отдых — MET 1.5)', () {
    // squat MET 5: 5×80×0.5ч = 200; отдых 1.5×80×0.25 = 30
    expect(workoutKcal(workSecondsByExercise: const {'squat': 1800}, restSeconds: 900, weightKg: 80), closeTo(230, 1e-9));
    // неизвестное упражнение — MET 4
    expect(workoutKcal(workSecondsByExercise: const {'aiMove': 3600}, weightKg: 50), closeTo(200, 1e-9));
  });

  test('завершение: последний замер веса, finishedAt, payload, хук квеста', () async {
    final deviceId = await db.deviceId();
    for (final (at, kg) in [(DateTime(2026, 10, 1), 90.0), (DateTime(2026, 10, 20), 80.0)]) {
      await db.into(db.bodyMeasurements).insert(BodyMeasurementsCompanion.insert(
            id: newId(),
            updatedAt: DateTime.now().toUtc(),
            deviceId: deviceId,
            measuredAt: at,
            weightKg: Value(kg),
          ));
    }
    final id = await recorder.begin(programId: 'p1', dayKey: 'A');
    final open = await (db.select(db.workoutSessions)..where((t) => t.id.equals(id))).getSingle();
    expect(open.finishedAt, isNull);
    expect(open.startedAt, now);

    final saved = await recorder.save(id, _result(completed: true), dayKey: 'A');
    // squat 5×80×180/3600 = 20; plank 4×80×180/3600 = 16; отдых 1.5×80×240/3600 = 8
    expect(saved.kcal, closeTo(44, 1e-9));
    expect(saved.weightAssumed, isFalse);
    expect(saved.activeMinutes, 10);
    expect(saved.doneSets, 1);
    expect(hooks.workouts, [10]);

    final row = await (db.select(db.workoutSessions)..where((t) => t.id.equals(id))).getSingle();
    expect(row.finishedAt, now);
    expect(row.activeSeconds, 600);
    expect(row.kcal, closeTo(44, 1e-9));
    expect(row.programId, 'p1');
    expect(row.dayKey, 'A');
    expect(row.version, 2);
    final payload = jsonDecode(row.payload) as Map<String, Object?>;
    expect(payload['day'], 'A');
    expect(payload['weightKg'], 80.0);
    expect(payload.containsKey('weightAssumed'), isFalse);
    expect((payload['sets']! as List).length, 2);
  });

  test('прерывание: finishedAt = null, хук не вызывается; веса нет — 70 кг с пометкой', () async {
    final id = await recorder.begin();
    final saved = await recorder.save(id, _result(completed: false));
    expect(saved.completed, isFalse);
    expect(saved.weightAssumed, isTrue);
    // (5×180 + 4×180 + 1.5×240) × 70 / 3600 = 38.5
    expect(saved.kcal, closeTo(38.5, 1e-9));
    expect(hooks.workouts, isEmpty);
    final row = await (db.select(db.workoutSessions)..where((t) => t.id.equals(id))).getSingle();
    expect(row.finishedAt, isNull);
    expect(row.activeSeconds, 600);
    expect((jsonDecode(row.payload) as Map)['weightAssumed'], isTrue);
  });

  test('очень короткая завершённая тренировка — хук с 1 минутой', () async {
    final id = await recorder.begin();
    await recorder.save(
      id,
      const WorkoutResult(
        completed: true,
        activeSeconds: 20,
        restSeconds: 0,
        workSecondsByExercise: {'plank': 20},
        sets: [SetRecord(exerciseKey: 'plank', set: 1, seconds: 20)],
      ),
    );
    expect(hooks.workouts, [1]);
  });

  test('все подходы пропущены — не засчитывается как завершённая', () async {
    final id = await recorder.begin();
    final saved = await recorder.save(
      id,
      const WorkoutResult(
        completed: true,
        activeSeconds: 5,
        restSeconds: 5,
        workSecondsByExercise: {},
        sets: [SetRecord(exerciseKey: 'plank', set: 1, seconds: 0, skipped: true)],
      ),
    );
    expect(saved.completed, isFalse);
    expect(hooks.workouts, isEmpty);
    final row = await (db.select(db.workoutSessions)..where((t) => t.id.equals(id))).getSingle();
    expect(row.finishedAt, isNull);
  });

  test('программа: сохранение, одна активная, пересоздание', () async {
    expect(await repo.activeProgram(), isNull);
    final p1 = await repo.saveProgram(generateTemplateProgram(const TrainingProfile()));
    expect(p1.source, 'template');
    expect(p1.row.level, 'beginner');
    final p2 = await repo.saveProgram(generateTemplateProgram(const TrainingProfile(limitations: true)));
    expect(p2.id, isNot(p1.id));
    expect((await repo.activeProgram())!.id, p2.id);
    expect((await repo.activeProgram())!.program.gentle, isTrue);
    final all = await db.select(db.workoutPrograms).get();
    expect(all.where((r) => r.active).length, 1);
  });

  test('день: минуты и ккал, включая прерванные; выполненные недели', () async {
    final stored = await repo.saveProgram(generateTemplateProgram(const TrainingProfile(weekdays: [1])));
    final r1 = WorkoutRecorder(repository: repo, hooks: hooks, clock: () => DateTime(2026, 10, 19, 18));
    final a = await r1.begin(programId: stored.id);
    await r1.save(a, _result(completed: true));
    final b = await r1.begin(programId: stored.id);
    await r1.save(b, _result(completed: false));
    final other = WorkoutRecorder(repository: repo, hooks: hooks, clock: () => DateTime(2026, 10, 20, 9));
    await other.save(await other.begin(), _result(completed: true));

    final day = await repo.watchDay(DateTime(2026, 10, 19, 23)).first;
    expect(day.activeMinutes, 20);
    expect(day.kcal, closeTo(77, 1e-9));
    expect(day.finished, 1);
    expect(day.sessions, 2);
    expect(await repo.watchDay(DateTime(2026, 10, 18)).first, WorkoutsDay.empty);

    expect(await repo.watchCompletedWeeks(stored).first, 1);
    expect((await repo.watchSessions().first).length, 3);
  });
}
