// Будильник-квест (SPEC §8.11): строки Alarms / AlarmRuns, отложенные звонки, награда за подъём.
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/quests/quest_api.dart';
import '../db/database.dart';
import '../models/enums.dart';
import 'alarm_schedule.dart';

const _uuid = Uuid();

/// Стабильный id будильника дисциплины — один на все устройства (без дублей при синхронизации).
final disciplineAlarmId = _uuid.v5(Namespace.url.value, 'sistema:alarm:discipline-wake');

/// Отложить можно не больше [alarmMaxSnoozes] раз, на [alarmSnoozeDuration].
const alarmMaxSnoozes = 2;
const alarmSnoozeDuration = Duration(minutes: 5);

/// Окно, в течение которого несработавший будильник ещё считается «звонящим».
const alarmRingWindow = Duration(minutes: 60);

/// Подъём «вовремя» — задание выполнено за это время после звонка.
const alarmOnTimeWindow = Duration(minutes: 20);

/// Ключ причины награды (для журнала событий движка).
const alarmRewardReasonKey = 'almReasonWake';

class AlarmRepository {
  AlarmRepository(this._db);

  final AppDatabase _db;

  static const _oneShotPrefix = 'alarm.oneshot.';
  static const _testPrefix = 'alarm.test.';

  Stream<List<AlarmRow>> watchAll() => (_db.select(_db.alarms)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.minute)]))
      .watch();

  Future<List<AlarmRow>> all() => (_db.select(_db.alarms)..where((t) => t.deletedAt.isNull())).get();

  Future<AlarmRow?> get(String id) =>
      (_db.select(_db.alarms)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();

  /// Создать (id == null) или изменить будильник. Возвращает id.
  Future<String> save({
    String? id,
    required int minute,
    required int weekdays,
    String? label,
    required AlarmTask task,
    required int squats,
    String? qrCode,
    bool enabled = true,
  }) async {
    final now = DateTime.now().toUtc();
    final device = await _db.deviceId();
    final existing = id == null ? null : await (_db.select(_db.alarms)..where((t) => t.id.equals(id))).getSingleOrNull();
    final rowId = id ?? _uuid.v4();
    if (existing == null) {
      await _db.into(_db.alarms).insert(AlarmsCompanion.insert(
            id: rowId,
            updatedAt: now,
            deviceId: device,
            minute: minute,
            weekdays: Value(weekdays),
            label: Value(label),
            task: Value(task.name),
            squats: Value(squats),
            qrCode: Value(qrCode),
            enabled: Value(enabled),
          ));
    } else {
      await (_db.update(_db.alarms)..where((t) => t.id.equals(rowId))).write(AlarmsCompanion(
        updatedAt: Value(now),
        deviceId: Value(device),
        version: Value(existing.version + 1),
        deletedAt: const Value(null),
        minute: Value(minute),
        weekdays: Value(weekdays),
        label: Value(label),
        task: Value(task.name),
        squats: Value(squats),
        qrCode: Value(qrCode),
        enabled: Value(enabled),
      ));
    }
    return rowId;
  }

  Future<void> _patch(AlarmRow row, AlarmsCompanion c) async {
    final device = await _db.deviceId();
    await (_db.update(_db.alarms)..where((t) => t.id.equals(row.id))).write(c.copyWith(
      updatedAt: Value(DateTime.now().toUtc()),
      deviceId: Value(device),
      version: Value(row.version + 1),
    ));
  }

  Future<void> setEnabled(AlarmRow row, bool enabled) => _patch(row, AlarmsCompanion(enabled: Value(enabled)));

  Future<void> delete(AlarmRow row) async {
    await _patch(row, AlarmsCompanion(deletedAt: Value(DateTime.now().toUtc())));
    await clearOneShot(row.id);
  }

  /// Будильник подъёма режима дисциплины (SPEC §6): включён, пока режим активен; время — [wakeMinute].
  /// Задание пользователь может поменять; время и дни — нет.
  Future<void> ensureDisciplineAlarm({required bool active, required int wakeMinute}) async {
    final row = await (_db.select(_db.alarms)..where((t) => t.id.equals(disciplineAlarmId))).getSingleOrNull();
    if (row == null) {
      if (!active) return;
      final device = await _db.deviceId();
      await _db.into(_db.alarms).insert(AlarmsCompanion.insert(
            id: disciplineAlarmId,
            updatedAt: DateTime.now().toUtc(),
            deviceId: device,
            minute: wakeMinute,
            weekdays: const Value(alarmAllDays),
            task: Value(AlarmTask.squats.name),
            squats: const Value(15),
            enabled: const Value(true),
            fromDiscipline: const Value(true),
          ));
      return;
    }
    final deleted = row.deletedAt != null;
    if (active) {
      if (!row.enabled || deleted || row.minute != wakeMinute || row.weekdays != alarmAllDays) {
        await _patch(
          row,
          AlarmsCompanion(
            enabled: const Value(true),
            deletedAt: const Value(null),
            minute: Value(wakeMinute),
            weekdays: const Value(alarmAllDays),
            fromDiscipline: const Value(true),
          ),
        );
      }
    } else if (row.enabled && !deleted) {
      await _patch(row, const AlarmsCompanion(enabled: Value(false)));
    }
  }

  // ---- Отложенные / проверочные звонки (локально, не синхронизируются) ----

  Future<DateTime?> oneShot(String alarmId) async {
    final v = int.tryParse(await _db.getSetting('$_oneShotPrefix$alarmId') ?? '');
    return v == null ? null : DateTime.fromMillisecondsSinceEpoch(v);
  }

  Future<void> setOneShot(String alarmId, DateTime at, {bool test = false}) async {
    await _db.setSetting('$_oneShotPrefix$alarmId', '${at.millisecondsSinceEpoch}');
    if (test) {
      await _db.setSetting('$_testPrefix$alarmId', '${at.millisecondsSinceEpoch}');
    }
  }

  Future<void> clearOneShot(String alarmId) async {
    await _db.deleteSetting('$_oneShotPrefix$alarmId');
    await _db.deleteSetting('$_testPrefix$alarmId');
  }

  /// Проверочный ли звонок сейчас (поставлен кнопкой «Проверить»).
  Future<bool> isTestRing(String alarmId) async => (await _db.getSetting('$_testPrefix$alarmId')) != null;

  // ---- Срабатывания ----

  /// Выключен ли звонок, сработавший в [firedAt], заданием (или отложен на будущее).
  Future<bool> isHandled(String alarmId, DateTime firedAt, {DateTime? now}) async {
    final t = now ?? DateTime.now();
    final snoozed = await oneShot(alarmId);
    if (snoozed != null && snoozed.isAfter(t)) return true;
    final from = firedAt.subtract(const Duration(minutes: 1)).toUtc();
    final done = await (_db.select(_db.alarmRuns)
          ..where((r) =>
              r.alarmId.equals(alarmId) & r.deletedAt.isNull() & r.dismissedAt.isNotNull() & r.dismissedAt.isBiggerThanValue(from))
          ..limit(1))
        .getSingleOrNull();
    return done != null;
  }

  /// Текущий (не выключенный) запуск будильника или новый.
  Future<AlarmRunRow> openRun(AlarmRow alarm, DateTime firedAt) async {
    final since = DateTime.now().subtract(const Duration(hours: 3)).toUtc();
    final existing = await (_db.select(_db.alarmRuns)
          ..where((r) =>
              r.alarmId.equals(alarm.id) & r.deletedAt.isNull() & r.dismissedAt.isNull() & r.firedAt.isBiggerThanValue(since))
          ..orderBy([(r) => OrderingTerm.desc(r.firedAt)])
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return existing;
    final id = _uuid.v4();
    await _db.into(_db.alarmRuns).insert(AlarmRunsCompanion.insert(
          id: id,
          updatedAt: DateTime.now().toUtc(),
          deviceId: await _db.deviceId(),
          alarmId: alarm.id,
          firedAt: firedAt.toUtc(),
          task: alarm.task,
        ));
    return (_db.select(_db.alarmRuns)..where((r) => r.id.equals(id))).getSingle();
  }

  /// Отложить: +1 к snoozes и звонок через [alarmSnoozeDuration]. false — лимит исчерпан.
  Future<bool> snooze(AlarmRunRow run) async {
    if (run.snoozes >= alarmMaxSnoozes) return false;
    await (_db.update(_db.alarmRuns)..where((r) => r.id.equals(run.id))).write(AlarmRunsCompanion(
      snoozes: Value(run.snoozes + 1),
      updatedAt: Value(DateTime.now().toUtc()),
      deviceId: Value(await _db.deviceId()),
      version: Value(run.version + 1),
    ));
    final test = await isTestRing(run.alarmId);
    await setOneShot(run.alarmId, DateTime.now().add(alarmSnoozeDuration), test: test);
    return true;
  }

  /// Задание выполнено: dismissedAt, разовый будильник выключается, награда за подъём вовремя.
  Future<void> dismiss(AlarmRunRow run, AlarmRow alarm, {QuestService? quests}) async {
    final now = DateTime.now();
    final test = await isTestRing(alarm.id);
    await (_db.update(_db.alarmRuns)..where((r) => r.id.equals(run.id))).write(AlarmRunsCompanion(
      dismissedAt: Value(now.toUtc()),
      updatedAt: Value(now.toUtc()),
      deviceId: Value(await _db.deviceId()),
      version: Value(run.version + 1),
    ));
    await clearOneShot(alarm.id);
    if (alarm.weekdays == 0 && alarm.enabled && !test) await setEnabled(alarm, false);
    if (test || quests == null) return;
    // Награда — только за регулярный звонок (не проверочный), выключенный вовремя.
    final occ = alarmLastOccurrence(alarm, now);
    if (occ == null || now.difference(occ) > alarmOnTimeWindow + alarmSnoozeDuration * alarmMaxSnoozes) return;
    final diamonds = max(0, 5 - run.snoozes * 2);
    if (diamonds == 0) return;
    try {
      await quests.award(
        diamonds: diamonds,
        xp: diamonds,
        stats: run.snoozes == 0 ? const {StatKind.discipline: 1} : const {},
        reasonKey: alarmRewardReasonKey,
        ref: 'alarm:${alarm.id}:${alarmDayKey(occ)}',
        at: now,
      );
    } catch (_) {
      // Движок недоступен (фоновый isolate / тесты) — будильник всё равно выключен.
    }
  }

  /// Сколько ◆ будет за выключение сейчас (для подсказки на экране звонка).
  static int rewardFor(int snoozes) => max(0, 5 - snoozes * 2);

  /// Содержимое QR для печати: случайное, с префиксом приложения.
  static String newQrCode() => 'SISTEMA-ALARM-${_uuid.v4().substring(0, 13).toUpperCase()}';
}

final alarmRepositoryProvider = Provider<AlarmRepository>((ref) => AlarmRepository(ref.watch(databaseProvider)));
