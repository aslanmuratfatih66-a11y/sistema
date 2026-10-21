// Выпитая вода (таблица WaterLogs): строка на каждое нажатие, сумма за день — по журналу.
// Публичное API для виджета / App Intent (этап 4): WaterRepository.add(ml, at:).
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../core/db/database.dart';
import '../../../domain/quests/section_hooks.dart';
import '../domain/nutrition_math.dart';

class WaterRepository {
  WaterRepository(this._db, {DateTime Function()? clock, this.hooks = const NoopSectionQuestHooks()})
      : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;
  /// Связь с движком квестов (ошибки движка не пробрасываются).
  final SectionQuestHooks hooks;

  /// Допустимый объём одной записи.
  static const minMl = 1;
  static const maxMl = 5000;

  SimpleSelectStatement<$WaterLogsTable, WaterLogRow> _day(DateTime day) => _db.select(_db.waterLogs)
    ..where((t) =>
        t.deletedAt.isNull() &
        t.loggedAt.isBiggerOrEqualValue(dayStart(day)) &
        t.loggedAt.isSmallerThanValue(nextDayStart(day)))
    ..orderBy([(t) => OrderingTerm.asc(t.loggedAt)]);

  Stream<List<WaterLogRow>> watchDay(DateTime day) => _day(day).watch();

  Future<List<WaterLogRow>> getDay(DateTime day) => _day(day).get();

  Stream<int> watchTotal(DateTime day) => watchDay(day).map((rows) => rows.fold(0, (a, r) => a + r.ml));

  Future<int> totalFor(DateTime day) async => (await getDay(day)).fold<int>(0, (a, r) => a + r.ml);

  /// Записать [ml] мл в момент [at] (по умолчанию — сейчас). Возвращает id записи.
  /// Если запись за сегодня — сообщает движку квестов (ошибки движка не пробрасываются).
  Future<String> add(int ml, {DateTime? at}) async {
    if (ml < minMl || ml > maxMl) throw ArgumentError.value(ml, 'ml', 'вне $minMl..$maxMl');
    final now = _clock();
    final when = at ?? now;
    final id = newId();
    await _db.into(_db.waterLogs).insert(WaterLogsCompanion.insert(
          id: id,
          updatedAt: now.toUtc(),
          deviceId: await _db.deviceId(),
          loggedAt: when,
          ml: ml,
        ));
    if (sameDay(when, now)) {
      try {
        await hooks.waterAdded(ml: ml, totalTodayMl: await totalFor(now), at: when);
      } catch (e) {
        debugPrint('WaterRepository: хук квестов: $e');
      }
    }
    return id;
  }

  /// Отменить последнюю запись дня [day] (мягкое удаление). Возвращает отменённый объём или null.
  Future<int?> undoLast(DateTime day) async {
    final rows = await getDay(day);
    if (rows.isEmpty) return null;
    final last = rows.reduce((a, b) => b.loggedAt.isBefore(a.loggedAt) ? a : b);
    final deviceId = await _db.deviceId();
    final now = _clock().toUtc();
    await (_db.update(_db.waterLogs)..where((t) => t.id.equals(last.id))).write(WaterLogsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          deviceId: Value(deviceId),
          version: Value(last.version + 1),
        ));
    return last.ml;
  }
}
