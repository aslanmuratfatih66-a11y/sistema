import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/database.dart';
import '../../../../core/models/enums.dart';

/// Приоритет цели: 1 высокий, 2 средний, 3 низкий.
const goalPriorityHigh = 1;
const goalPriorityMedium = 2;
const goalPriorityLow = 3;

/// Цели (SPEC §5 п.6): одна строка на цель, снятие выбора — мягкое удаление.
class GoalRepository {
  GoalRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$GoalsTable, GoalRow> _active() => _db.select(_db.goals)
    ..where((t) => t.deletedAt.isNull())
    ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.updatedAt)]);

  Future<List<GoalRow>> active() => _active().get();

  Stream<List<GoalRow>> watchActive() => _active().watch();

  Future<int> _nextOrder() async {
    final rows = await active();
    return rows.isEmpty ? 0 : rows.map((r) => r.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<String> _insert(GoalKind kind, {String? title}) async {
    final id = newId();
    await _db.into(_db.goals).insert(GoalsCompanion.insert(
          id: id,
          updatedAt: DateTime.now().toUtc(),
          deviceId: await _db.deviceId(),
          kind: kind.name,
          title: Value(title),
          priority: const Value(goalPriorityMedium),
          sortOrder: Value(await _nextOrder()),
        ));
    return id;
  }

  /// Выбрать стандартную цель. Если уже выбрана — вернуть существующую.
  Future<String> select(GoalKind kind) async {
    assert(kind != GoalKind.custom, 'для своих целей — addCustom');
    return _db.transaction(() async {
      final existing = await (_db.select(_db.goals)
            ..where((t) => t.kind.equals(kind.name) & t.deletedAt.isNull())
            ..limit(1))
          .getSingleOrNull();
      return existing?.id ?? await _insert(kind);
    });
  }

  /// Снять выбор стандартной цели (мягкое удаление всех активных строк этого вида).
  Future<void> unselect(GoalKind kind) async {
    final rows = await (_db.select(_db.goals)..where((t) => t.kind.equals(kind.name) & t.deletedAt.isNull())).get();
    for (final r in rows) {
      await remove(r.id);
    }
  }

  /// Своя цель текстом.
  Future<String> addCustom(String title) => _db.transaction(() => _insert(GoalKind.custom, title: title.trim()));

  Future<void> remove(String id) => _patch(id, GoalsCompanion(deletedAt: Value(DateTime.now().toUtc())));

  Future<void> setPriority(String id, int priority) {
    assert(priority >= goalPriorityHigh && priority <= goalPriorityLow);
    return _patch(id, GoalsCompanion(priority: Value(priority)));
  }

  Future<void> setDeadline(String id, DateTime? deadline) => _patch(id, GoalsCompanion(deadline: Value(deadline)));

  Future<void> setTitle(String id, String title) => _patch(id, GoalsCompanion(title: Value(title.trim())));

  Future<void> _patch(String id, GoalsCompanion patch) async {
    final deviceId = await _db.deviceId();
    await _db.transaction(() async {
      final row = await (_db.select(_db.goals)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null) return;
      await (_db.update(_db.goals)..where((t) => t.id.equals(id))).write(patch.copyWith(
            updatedAt: Value(DateTime.now().toUtc()),
            deviceId: Value(deviceId),
            version: Value(row.version + 1),
          ));
    });
  }
}

final goalRepositoryProvider = Provider<GoalRepository>((ref) => GoalRepository(ref.watch(databaseProvider)));

final activeGoalsProvider = StreamProvider<List<GoalRow>>((ref) => ref.watch(goalRepositoryProvider).watchActive());
