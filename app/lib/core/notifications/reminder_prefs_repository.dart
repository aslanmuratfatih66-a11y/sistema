// Настройки напоминаний: UserSettings (id = 'notifications'), value — JSON (SPEC §7, «запоминаются»).
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import 'notification_api.dart';

const reminderPrefsSettingId = 'notifications';

/// Тихие часы по умолчанию при включении: 23:00–07:00.
const defaultQuietHours = QuietHours(startMinute: 23 * 60, endMinute: 7 * 60);

Map<String, Object?> reminderPrefsToJson(ReminderPrefs p) => {
      'enabled': p.enabled,
      'nag': p.nag,
      'reproach': p.reproach,
      'voiceSound': p.voiceSound,
      'quiet': p.quiet == null ? null : {'start': p.quiet!.startMinute, 'end': p.quiet!.endMinute},
    };

/// Битые/неполные данные — значения по умолчанию.
ReminderPrefs reminderPrefsFromJson(Object? json) {
  if (json is! Map) return const ReminderPrefs();
  bool flag(String k, bool def) => json[k] is bool ? json[k] as bool : def;
  QuietHours? quiet;
  final q = json['quiet'];
  if (q is Map && q['start'] is int && q['end'] is int) {
    final s = q['start'] as int, e = q['end'] as int;
    if (s >= 0 && s < 1440 && e >= 0 && e < 1440) quiet = QuietHours(startMinute: s, endMinute: e);
  }
  return ReminderPrefs(
    enabled: flag('enabled', true),
    nag: flag('nag', true),
    reproach: flag('reproach', true),
    voiceSound: flag('voiceSound', false),
    quiet: quiet,
  );
}

ReminderPrefs _decode(String? raw) {
  if (raw == null || raw.isEmpty) return const ReminderPrefs();
  try {
    return reminderPrefsFromJson(jsonDecode(raw));
  } on FormatException {
    return const ReminderPrefs();
  }
}

/// Копия с изменёнными полями (в контракте copyWith нет). [clearQuiet] — выключить тихие часы.
ReminderPrefs copyReminderPrefs(
  ReminderPrefs p, {
  bool? enabled,
  bool? nag,
  bool? reproach,
  bool? voiceSound,
  QuietHours? quiet,
  bool clearQuiet = false,
}) =>
    ReminderPrefs(
      enabled: enabled ?? p.enabled,
      nag: nag ?? p.nag,
      reproach: reproach ?? p.reproach,
      voiceSound: voiceSound ?? p.voiceSound,
      quiet: clearQuiet ? null : quiet ?? p.quiet,
    );

class ReminderPrefsRepository {
  ReminderPrefsRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$UserSettingsTable, UserSettingRow> _query() => _db.select(_db.userSettings)
    ..where((t) => t.id.equals(reminderPrefsSettingId) & t.deletedAt.isNull());

  Future<ReminderPrefs> load() async => _decode((await _query().getSingleOrNull())?.value);

  Stream<ReminderPrefs> watch() => _query().watchSingleOrNull().map((r) => _decode(r?.value));

  Future<void> save(ReminderPrefs prefs) async {
    final deviceId = await _db.deviceId();
    final value = jsonEncode(reminderPrefsToJson(prefs));
    await _db.transaction(() async {
      final existing = await (_db.select(_db.userSettings)..where((t) => t.id.equals(reminderPrefsSettingId)))
          .getSingleOrNull();
      await _db.into(_db.userSettings).insertOnConflictUpdate(UserSettingsCompanion.insert(
            id: reminderPrefsSettingId,
            updatedAt: DateTime.now().toUtc(),
            deletedAt: const Value(null),
            deviceId: deviceId,
            version: Value((existing?.version ?? 0) + 1),
            value: value,
          ));
    });
  }
}

final reminderPrefsRepositoryProvider =
    Provider<ReminderPrefsRepository>((ref) => ReminderPrefsRepository(ref.watch(databaseProvider)));

final reminderPrefsProvider =
    StreamProvider<ReminderPrefs>((ref) => ref.watch(reminderPrefsRepositoryProvider).watch());
