// Журнал сна (SleepLogs). Одна запись на ночь: ночь относится к дню подъёма (локальная полночь wakeAt).
// Поля синхронизации проставляются здесь; удаление мягкое.
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/models/daily.dart';
import '../../../core/models/enums.dart';
import '../../../domain/quests/section_hooks.dart';
import '../../plan/data/plan_repository.dart';
import '../../schedule/data/schedule_repository.dart';
import '../domain/sleep_math.dart';

class SleepRepository {
  SleepRepository(this._db);

  final AppDatabase _db;

  /// Самая длинная ночь недопустима: больше 20 ч — скорее ошибка ввода.
  static const maxSleep = Duration(hours: 20);

  SimpleSelectStatement<$SleepLogsTable, SleepLogRow> _range(DateTime fromDay, DateTime toDayExclusive) =>
      _db.select(_db.sleepLogs)
        ..where((t) =>
            t.deletedAt.isNull() &
            t.wakeAt.isBiggerOrEqualValue(dayOf(fromDay)) &
            t.wakeAt.isSmallerThanValue(dayOf(toDayExclusive)))
        ..orderBy([(t) => OrderingTerm.asc(t.wakeAt), (t) => OrderingTerm.desc(t.updatedAt)]);

  static SleepDay _toDay(SleepLogRow r) =>
      SleepDay(day: dayOf(r.wakeAt), bedAt: r.bedAt.toLocal(), wakeAt: r.wakeAt.toLocal(), quality: r.quality);

  /// Ночи с подъёмом в [fromDay]..[toDayExclusive) — по одной на день (если записей несколько — последняя правка).
  static List<SleepDay> _dedupe(List<SleepLogRow> rows) {
    final byDay = <DateTime, SleepDay>{};
    for (final r in rows) {
      byDay.putIfAbsent(dayOf(r.wakeAt), () => _toDay(r));
    }
    return byDay.values.toList()..sort((a, b) => a.day.compareTo(b.day));
  }

  Stream<List<SleepDay>> watchRange(DateTime fromDay, DateTime toDayExclusive) =>
      _range(fromDay, toDayExclusive).watch().map(_dedupe);

  Stream<SleepDay?> watchDay(DateTime day) {
    final d = dayOf(day);
    return watchRange(d, DateTime(d.year, d.month, d.day + 1)).map((l) => l.isEmpty ? null : l.first);
  }

  Future<SleepDay?> getDay(DateTime day) async {
    final d = dayOf(day);
    final l = _dedupe(await _range(d, DateTime(d.year, d.month, d.day + 1)).get());
    return l.isEmpty ? null : l.first;
  }

  /// Записать ночь. Запись того же дня подъёма перезаписывается. Бросает [ArgumentError], если подъём
  /// не позже отбоя или сон длиннее [maxSleep].
  Future<void> save({
    required DateTime bedAt,
    required DateTime wakeAt,
    int? quality,
    SleepSource source = SleepSource.manual,
  }) async {
    final duration = wakeAt.difference(bedAt);
    if (duration <= Duration.zero || duration > maxSleep) {
      throw ArgumentError('Некорректный сон: $bedAt → $wakeAt');
    }
    if (quality != null && (quality < 1 || quality > 5)) throw ArgumentError.value(quality, 'quality');
    final deviceId = await _db.deviceId();
    final now = DateTime.now().toUtc();
    final d = dayOf(wakeAt);
    await _db.transaction(() async {
      final existing = await _range(d, DateTime(d.year, d.month, d.day + 1)).get();
      if (existing.isEmpty) {
        await _db.into(_db.sleepLogs).insert(SleepLogsCompanion.insert(
              id: newId(),
              updatedAt: now,
              deviceId: deviceId,
              bedAt: bedAt,
              wakeAt: wakeAt,
              quality: Value(quality),
              source: Value(source.name),
            ));
        return;
      }
      final keep = existing.first;
      await (_db.update(_db.sleepLogs)..where((t) => t.id.equals(keep.id))).write(SleepLogsCompanion(
            bedAt: Value(bedAt),
            wakeAt: Value(wakeAt),
            quality: Value(quality),
            source: Value(source.name),
            updatedAt: Value(now),
            deviceId: Value(deviceId),
            version: Value(keep.version + 1),
          ));
      for (final extra in existing.skip(1)) {
        await _softDelete(extra, now, deviceId);
      }
    });
  }

  /// Удалить ночь дня подъёма [day].
  Future<void> deleteDay(DateTime day) async {
    final deviceId = await _db.deviceId();
    final now = DateTime.now().toUtc();
    final d = dayOf(day);
    await _db.transaction(() async {
      for (final r in await _range(d, DateTime(d.year, d.month, d.day + 1)).get()) {
        await _softDelete(r, now, deviceId);
      }
    });
  }

  Future<void> _softDelete(SleepLogRow r, DateTime now, String deviceId) =>
      (_db.update(_db.sleepLogs)..where((t) => t.id.equals(r.id))).write(SleepLogsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        deviceId: Value(deviceId),
        version: Value(r.version + 1),
      ));
}

/// Часы раздела «Тело» (переопределяются в тестах).
final bodyClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final sleepRepositoryProvider = Provider<SleepRepository>((ref) => SleepRepository(ref.watch(databaseProvider)));

/// Сон за ночь, закончившуюся утром дня [day] (передавайте локальную полночь; время отбрасывается).
/// null — ночь не записана.
final sleepDayProvider = StreamProvider.family<SleepDay?, DateTime>(
  (ref, day) => ref.watch(sleepRepositoryProvider).watchDay(dayOf(day)),
);

/// Ночи за последние [days] дней, включая сегодня.
final sleepHistoryProvider = StreamProvider.family<List<SleepDay>, int>((ref, days) {
  final today = dayOf(ref.watch(bodyClockProvider)());
  final from = DateTime(today.year, today.month, today.day - days + 1);
  return ref.watch(sleepRepositoryProvider).watchRange(from, DateTime(today.year, today.month, today.day + 1));
});

/// Цель сна и плановые подъём/отбой: из принятого плана, иначе из расписания, иначе 8 ч / 07:00 / 23:00.
typedef SleepTarget = ({int targetMinutes, int wakeMinute, int bedMinute});

final sleepTargetProvider = Provider<SleepTarget>((ref) {
  final norms = ref.watch(acceptedPlanProvider).value?.plan.norms;
  final schedule = ref.watch(scheduleConfigProvider).value;
  return (
    targetMinutes: norms?.sleepTargetMinutes ?? 480,
    wakeMinute: schedule?.wakeMinute ?? norms?.wakeMinute ?? 7 * 60,
    bedMinute: schedule?.bedMinute ?? norms?.bedMinute ?? 23 * 60,
  );
});

/// «Энергия» для «Статуса» (0–100) по прошедшей ночи; null — сон за последнюю ночь не записан
/// (или ещё грузится). Формула — [energyPercent]. Отбой сравнивается с отбоем из плана/расписания.
final energyPercentProvider = Provider<int?>((ref) {
  final today = dayOf(ref.watch(bodyClockProvider)());
  final sleep = ref.watch(sleepDayProvider(today)).value;
  if (sleep == null) return null;
  final target = ref.watch(sleepTargetProvider);
  return energyPercent(sleep, targetMinutes: target.targetMinutes, plannedBedMinute: target.bedMinute);
});

/// Записать сон и сообщить движку квестов.
Future<void> logSleep(
  WidgetRef ref, {
  required DateTime bedAt,
  required DateTime wakeAt,
  int? quality,
}) async {
  await ref.read(sleepRepositoryProvider).save(bedAt: bedAt, wakeAt: wakeAt, quality: quality);
  await ref.read(sectionQuestHooksProvider).sleepLogged(bedAt: bedAt, wakeAt: wakeAt);
}
