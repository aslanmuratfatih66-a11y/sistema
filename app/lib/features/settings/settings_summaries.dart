// Краткие итоги разделов анкеты для экрана настроек.
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';

/// Число активных целей.
final settingsGoalsCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final count = db.goals.id.count();
  final q = db.selectOnly(db.goals)
    ..addColumns([count])
    ..where(db.goals.deletedAt.isNull());
  return q.map((r) => r.read(count) ?? 0).watchSingle();
});

/// Последний вес (кг) из замеров.
final settingsLatestWeightProvider = StreamProvider<double?>((ref) {
  final db = ref.watch(databaseProvider);
  final q = db.select(db.bodyMeasurements)
    ..where((t) => t.deletedAt.isNull() & t.weightKg.isNotNull())
    ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)])
    ..limit(1);
  return q.watchSingleOrNull().map((r) => r?.weightKg);
});

/// Число пунктов расписания.
final settingsScheduleItemsCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final count = db.scheduleItems.id.count();
  final q = db.selectOnly(db.scheduleItems)
    ..addColumns([count])
    ..where(db.scheduleItems.deletedAt.isNull());
  return q.map((r) => r.read(count) ?? 0).watchSingle();
});

/// «175» / «70.5» — без лишних нулей.
String formatSettingsNumber(double v) {
  final s = v.toStringAsFixed(1);
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}


