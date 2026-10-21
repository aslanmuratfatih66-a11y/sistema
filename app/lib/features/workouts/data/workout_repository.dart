// Программы и проведённые тренировки (WorkoutPrograms, WorkoutSessions), вес для расчёта ккал.
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/database.dart';
import '../domain/kcal.dart';
import '../domain/progression.dart';
import '../model/workout_program.dart';

class StoredWorkoutProgram {
  const StoredWorkoutProgram({required this.row, required this.program});

  final WorkoutProgramRow row;

  /// Базовая программа (без прогрессии).
  final WorkoutProgram program;

  String get id => row.id;
  String get source => row.source;
}

/// Тренировки за день — для «Статуса» и расхода калорий.
class WorkoutsDay {
  const WorkoutsDay({required this.activeMinutes, required this.kcal, required this.finished, required this.sessions});

  static const empty = WorkoutsDay(activeMinutes: 0, kcal: 0, finished: 0, sessions: 0);

  /// Активные минуты (включая прерванные тренировки).
  final int activeMinutes;

  /// Оценка расхода, ккал (включая прерванные).
  final double kcal;

  /// Завершённых тренировок.
  final int finished;

  /// Всего записей (в т.ч. прерванных).
  final int sessions;

  @override
  bool operator ==(Object other) =>
      other is WorkoutsDay &&
      other.activeMinutes == activeMinutes &&
      other.kcal == kcal &&
      other.finished == finished &&
      other.sessions == sessions;

  @override
  int get hashCode => Object.hash(activeMinutes, kcal, finished, sessions);

  @override
  String toString() => 'WorkoutsDay($activeMinutes min, $kcal kcal, $finished/$sessions)';
}

/// Вес для расчёта ккал: последний замер, иначе [fallbackWeightKg] с пометкой.
typedef WeightForKcal = ({double kg, bool assumed});

class WorkoutRepository {
  WorkoutRepository(this._db);

  final AppDatabase _db;

  static StoredWorkoutProgram? _decode(WorkoutProgramRow? row) {
    if (row == null) return null;
    try {
      final j = jsonDecode(row.payload);
      final p = j is Map<String, Object?> ? WorkoutProgram.fromJson(j) : null;
      return p == null ? null : StoredWorkoutProgram(row: row, program: p);
    } on FormatException {
      return null;
    }
  }

  SimpleSelectStatement<$WorkoutProgramsTable, WorkoutProgramRow> _activeQuery() => _db.select(_db.workoutPrograms)
    ..where((t) => t.active.equals(true) & t.deletedAt.isNull())
    ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
    ..limit(1);

  Future<StoredWorkoutProgram?> activeProgram() async => _decode(await _activeQuery().getSingleOrNull());

  Stream<StoredWorkoutProgram?> watchActiveProgram() => _activeQuery().watchSingleOrNull().map(_decode);

  /// Сохранить новую активную программу; прежние становятся неактивными (история сессий остаётся).
  Future<StoredWorkoutProgram> saveProgram(WorkoutProgram program, {String source = 'template', DateTime? now}) async {
    final deviceId = await _db.deviceId();
    final at = (now ?? DateTime.now()).toUtc();
    final id = newId();
    await _db.transaction(() async {
      final old = await (_db.select(_db.workoutPrograms)..where((t) => t.active.equals(true))).get();
      for (final r in old) {
        await (_db.update(_db.workoutPrograms)..where((t) => t.id.equals(r.id))).write(WorkoutProgramsCompanion(
          active: const Value(false),
          updatedAt: Value(at),
          version: Value(r.version + 1),
          deviceId: Value(deviceId),
        ));
      }
      await _db.into(_db.workoutPrograms).insert(WorkoutProgramsCompanion.insert(
            id: id,
            updatedAt: at,
            deviceId: deviceId,
            title: '$source.${program.level.name}',
            level: program.level.name,
            source: Value(source),
            payload: jsonEncode(program.toJson()),
          ));
    });
    return (await activeProgram())!;
  }

  /// Начать тренировку: запись с finishedAt = null (если прервут — так и останется).
  Future<String> startSession({String? programId, String? dayKey, required DateTime startedAt}) async {
    final id = newId();
    await _db.into(_db.workoutSessions).insert(WorkoutSessionsCompanion.insert(
          id: id,
          updatedAt: DateTime.now().toUtc(),
          deviceId: await _db.deviceId(),
          programId: Value(programId),
          dayKey: Value(dayKey),
          startedAt: startedAt,
        ));
    return id;
  }

  /// Записать результат (частичный — без [finishedAt]).
  Future<void> saveSession(
    String id, {
    required int activeSeconds,
    required double kcal,
    required Map<String, Object?> payload,
    DateTime? finishedAt,
  }) async {
    final row = await (_db.select(_db.workoutSessions)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    await (_db.update(_db.workoutSessions)..where((t) => t.id.equals(id))).write(WorkoutSessionsCompanion(
      activeSeconds: Value(activeSeconds),
      kcal: Value(kcal),
      payload: Value(jsonEncode(payload)),
      finishedAt: Value(finishedAt),
      updatedAt: Value(DateTime.now().toUtc()),
      version: Value(row.version + 1),
    ));
  }

  Stream<List<WorkoutSessionRow>> watchSessions({int limit = 30}) => (_db.select(_db.workoutSessions)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
        ..limit(limit))
      .watch();

  /// Даты завершённых тренировок программы (для прогрессии).
  Stream<List<DateTime>> watchFinishedDates(String programId) => (_db.select(_db.workoutSessions)
        ..where((t) => t.programId.equals(programId) & t.finishedAt.isNotNull() & t.deletedAt.isNull()))
      .watch()
      .map((rows) => [for (final r in rows) r.finishedAt!]);

  /// Сколько недель выполнено по программе.
  Stream<int> watchCompletedWeeks(StoredWorkoutProgram p) => watchFinishedDates(p.id)
      .map((d) => completedWeeks(d, sessionsPerWeek: p.program.sessionsPerWeek));

  Future<WeightForKcal> weightForKcal() async {
    final row = await (_db.select(_db.bodyMeasurements)
          ..where((t) => t.weightKg.isNotNull() & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)])
          ..limit(1))
        .getSingleOrNull();
    final kg = row?.weightKg;
    return kg == null || kg <= 0 ? (kg: fallbackWeightKg, assumed: true) : (kg: kg, assumed: false);
  }

  /// Тренировки за локальный день [day] (по началу тренировки).
  Stream<WorkoutsDay> watchDay(DateTime day) {
    final from = DateTime(day.year, day.month, day.day);
    final to = DateTime(day.year, day.month, day.day + 1);
    return (_db.select(_db.workoutSessions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.startedAt.isBiggerOrEqualValue(from) &
              t.startedAt.isSmallerThanValue(to)))
        .watch()
        .map((rows) {
      var sec = 0;
      var kcal = 0.0;
      var finished = 0;
      for (final r in rows) {
        sec += r.activeSeconds;
        kcal += r.kcal ?? 0;
        if (r.finishedAt != null) finished++;
      }
      return WorkoutsDay(activeMinutes: (sec / 60).round(), kcal: kcal, finished: finished, sessions: rows.length);
    });
  }
}
