// Шаги в БД (StepLogs): строка на день и источник, перезаписывается при опросе счётчика.
import 'package:drift/drift.dart';

import '../db/database.dart';
import '../models/daily.dart';
import '../models/enums.dart';

/// Локальная полночь дня [t].
DateTime localDay(DateTime t) {
  final l = t.isUtc ? t.toLocal() : t;
  return DateTime(l.year, l.month, l.day);
}

/// Порядок предпочтения источников при равных шагах: устройство важнее ручного ввода.
const _sourcePriority = {
  StepSourceKind.healthConnect: 0,
  StepSourceKind.coreMotion: 0,
  StepSourceKind.sensor: 1,
  StepSourceKind.manual: 2,
};

StepSourceKind? _parseSource(String name) {
  for (final k in StepSourceKind.values) {
    if (k.name == name) return k;
  }
  return null;
}

/// Лучший источник за день: больше шагов (счётчики скорее недосчитывают, чем пересчитывают —
/// например, телефон оставили на столе, а ручной ввод взят с часов); при равенстве — устройство.
/// Удалённые строки не учитываются. null — записей нет.
StepDay? bestStepDay(Iterable<StepLogRow> rows) {
  StepLogRow? best;
  for (final r in rows) {
    if (r.deletedAt != null) continue;
    if (best == null || r.steps > best.steps) {
      best = r;
    } else if (r.steps == best.steps) {
      final pr = _sourcePriority[_parseSource(r.source)] ?? 9;
      final pb = _sourcePriority[_parseSource(best.source)] ?? 9;
      if (pr < pb) best = r;
    }
  }
  if (best == null) return null;
  return StepDay(day: localDay(best.day), steps: best.steps, distanceM: best.distanceM, floors: best.floors);
}

class StepRepository {
  StepRepository(this._db);

  final AppDatabase _db;

  /// Записать шаги дня [StepDay.day] от источника [source] (upsert по день+источник).
  Future<void> upsert(StepDay value, StepSourceKind source) async {
    final day = localDay(value.day);
    final deviceId = await _db.deviceId();
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      final existing = await (_db.select(_db.stepLogs)
            ..where((t) => t.day.equals(day) & t.source.equals(source.name)))
          .getSingleOrNull();
      if (existing == null) {
        await _db.into(_db.stepLogs).insert(StepLogsCompanion.insert(
              id: newId(),
              updatedAt: now,
              deviceId: deviceId,
              day: day,
              steps: value.steps,
              distanceM: Value(value.distanceM),
              floors: Value(value.floors),
              source: source.name,
            ));
        return;
      }
      final same = existing.deletedAt == null &&
          existing.steps == value.steps &&
          existing.distanceM == value.distanceM &&
          existing.floors == value.floors;
      if (same) return; // не трогаем updatedAt/version — меньше синхронизации
      await (_db.update(_db.stepLogs)..where((t) => t.id.equals(existing.id))).write(StepLogsCompanion(
        steps: Value(value.steps),
        distanceM: Value(value.distanceM),
        floors: Value(value.floors),
        updatedAt: Value(now),
        deletedAt: const Value(null),
        deviceId: Value(deviceId),
        version: Value(existing.version + 1),
      ));
    });
  }

  SimpleSelectStatement<$StepLogsTable, StepLogRow> _range(DateTime from, DateTime to) =>
      _db.select(_db.stepLogs)
        ..where((t) =>
            t.deletedAt.isNull() &
            t.day.isBiggerOrEqualValue(localDay(from)) &
            t.day.isSmallerThanValue(localDay(to)));

  /// Лучшее значение за день.
  Future<StepDay?> bestOf(DateTime day) async {
    final d = localDay(day);
    return bestStepDay(await _range(d, _nextDay(d)).get());
  }

  Stream<StepDay?> watchDay(DateTime day) {
    final d = localDay(day);
    return _range(d, _nextDay(d)).watch().map(bestStepDay);
  }

  /// Дни [from, to) (локальные полуночи) — по одному значению на день, пропуски — 0 шагов.
  Stream<List<StepDay>> watchHistory(DateTime from, DateTime to) {
    final start = localDay(from);
    final end = localDay(to);
    return _range(start, end).watch().map((rows) {
      final byDay = <DateTime, List<StepLogRow>>{};
      for (final r in rows) {
        byDay.putIfAbsent(localDay(r.day), () => []).add(r);
      }
      final out = <StepDay>[];
      for (var d = start; d.isBefore(end); d = _nextDay(d)) {
        out.add(bestStepDay(byDay[d] ?? const []) ?? StepDay(day: d, steps: 0));
      }
      return out;
    });
  }
}

/// Следующая локальная полночь (через конструктор — без сдвига на час при переходе на летнее время).
DateTime _nextDay(DateTime d) => DateTime(d.year, d.month, d.day + 1);

/// Публичная версия для провайдеров.
DateTime nextLocalDay(DateTime d) => _nextDay(localDay(d));
