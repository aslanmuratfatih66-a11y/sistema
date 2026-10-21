import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../schedule_logic.dart';

/// Расписание: настройки (одна строка id='main') и пункты. Поля синхронизации проставляются здесь:
/// updatedAt (UTC), deviceId, version+1; удаление мягкое (deletedAt).
class ScheduleRepository {
  ScheduleRepository(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  static const settingsId = 'main';

  final AppDatabase _db;
  final DateTime Function() _clock;

  // ---------- Настройки ----------

  SimpleSelectStatement<$ScheduleSettingsTable, ScheduleSettingsRow> _settingsQuery() =>
      _db.select(_db.scheduleSettings)
        ..where((t) => t.id.equals(settingsId) & t.deletedAt.isNull())
        ..limit(1);

  Future<ScheduleSettingsRow?> getSettings() => _settingsQuery().getSingleOrNull();

  Stream<ScheduleSettingsRow?> watchSettings() => _settingsQuery().watchSingleOrNull();

  Future<ScheduleConfig> getConfig() async => ScheduleConfig.fromRow(await getSettings());

  Stream<ScheduleConfig> watchConfig() => watchSettings().map(ScheduleConfig.fromRow);

  /// Обновить настройки (передавайте только изменённые поля). Строка создаётся при первой записи.
  /// Включение чередования без якоря записывает якорь = понедельник текущей недели.
  Future<void> updateSettings(ScheduleSettingsCompanion patch) async {
    final deviceId = await _db.deviceId();
    final now = _clock();
    await _db.transaction(() async {
      final existing = await (_db.select(_db.scheduleSettings)..where((t) => t.id.equals(settingsId)))
          .getSingleOrNull();
      var p = patch.copyWith(
        id: const Value.absent(),
        updatedAt: Value(now.toUtc()),
        deviceId: Value(deviceId),
      );
      final enabling = p.alternationEnabled.present && p.alternationEnabled.value;
      final anchorAfter = p.week1Anchor.present ? p.week1Anchor.value : existing?.week1Anchor;
      if (enabling && anchorAfter == null) {
        p = p.copyWith(week1Anchor: Value(ScheduleLogic.mondayOf(now)));
      }
      if (existing == null) {
        await _db.into(_db.scheduleSettings).insert(p.copyWith(id: const Value(settingsId), version: const Value(1)));
      } else {
        await (_db.update(_db.scheduleSettings)..where((t) => t.id.equals(settingsId))).write(p.copyWith(
          version: Value(existing.version + 1),
          // Строку могли мягко удалить (импорт/сброс) — запись её восстанавливает.
          deletedAt: const Value(null),
        ));
      }
    });
  }

  Future<void> setAlternation(bool enabled) =>
      updateSettings(ScheduleSettingsCompanion(alternationEnabled: Value(enabled)));

  /// Ручное переключение недели 1↔2 для текущей даты.
  Future<void> switchWeek() async {
    final config = await getConfig();
    await updateSettings(
      ScheduleSettingsCompanion(week1Anchor: Value(ScheduleLogic.switchedAnchor(_clock(), config))),
    );
  }

  // ---------- Пункты ----------

  SimpleSelectStatement<$ScheduleItemsTable, ScheduleItemRow> _itemsQuery() => _db.select(_db.scheduleItems)
    ..where((t) => t.deletedAt.isNull())
    ..orderBy([(t) => OrderingTerm(expression: t.weekday), (t) => OrderingTerm(expression: t.startMinute)]);

  Future<List<ScheduleEntry>> getEntries() async =>
      (await _itemsQuery().get()).map(ScheduleEntry.fromRow).toList();

  Stream<List<ScheduleEntry>> watchEntries() =>
      _itemsQuery().watch().map((rows) => rows.map(ScheduleEntry.fromRow).toList());

  /// Создать или обновить пункт. Пустой id → новый пункт; возвращает id.
  Future<String> saveEntry(ScheduleEntry e) async {
    final deviceId = await _db.deviceId();
    final now = _clock().toUtc();
    return _db.transaction(() async {
      final id = e.id.isEmpty ? newId() : e.id;
      final existing = await (_db.select(_db.scheduleItems)..where((t) => t.id.equals(id))).getSingleOrNull();
      final data = ScheduleItemsCompanion(
        kind: Value(e.kind.name),
        title: Value(e.title.trim()),
        weekday: Value(e.weekday),
        startMinute: Value(e.startMinute),
        durationMinutes: Value(e.durationMinutes),
        weekParity: Value(e.weekParity),
        location: Value(e.location?.trim().isEmpty ?? true ? null : e.location!.trim()),
        requiresCommute: Value(e.requiresCommute),
        updatedAt: Value(now),
        deviceId: Value(deviceId),
      );
      if (existing == null) {
        await _db.into(_db.scheduleItems).insert(data.copyWith(id: Value(id), version: const Value(1)));
      } else {
        await (_db.update(_db.scheduleItems)..where((t) => t.id.equals(id))).write(data.copyWith(
          version: Value(existing.version + 1),
          deletedAt: const Value(null),
        ));
      }
      return id;
    });
  }

  /// Мягкое удаление пункта.
  Future<void> deleteEntry(String id) async {
    final deviceId = await _db.deviceId();
    final now = _clock().toUtc();
    await _db.transaction(() async {
      final existing = await (_db.select(_db.scheduleItems)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing == null || existing.deletedAt != null) return;
      await (_db.update(_db.scheduleItems)..where((t) => t.id.equals(id))).write(ScheduleItemsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        deviceId: Value(deviceId),
        version: Value(existing.version + 1),
      ));
    });
  }

  /// Скопировать все пункты дня [fromWeekday] на день [toWeekday] (новые id). Возвращает число копий.
  Future<int> copyDay(int fromWeekday, int toWeekday) async {
    if (fromWeekday == toWeekday) return 0;
    final src = (await getEntries()).where((e) => e.weekday == fromWeekday).toList();
    for (final e in src) {
      await saveEntry(e.copyWith(id: '', weekday: toWeekday));
    }
    return src.length;
  }
}

/// Часы расписания (переопределяются в тестах).
final scheduleClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final scheduleRepositoryProvider = Provider<ScheduleRepository>(
  (ref) => ScheduleRepository(ref.watch(databaseProvider), clock: ref.watch(scheduleClockProvider)),
);

final scheduleConfigProvider =
    StreamProvider<ScheduleConfig>((ref) => ref.watch(scheduleRepositoryProvider).watchConfig());

final scheduleEntriesProvider =
    StreamProvider<List<ScheduleEntry>>((ref) => ref.watch(scheduleRepositoryProvider).watchEntries());
