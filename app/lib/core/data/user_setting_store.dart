// Синхронизируемые настройки-JSON (таблица UserSettings: id = ключ, value — JSON). Поля синхронизации — как
// в ReminderPrefsRepository: updatedAt (UTC), deviceId, version+1, удаление мягкое.
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';

class UserSettingStore {
  UserSettingStore(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$UserSettingsTable, UserSettingRow> _query(String id) =>
      _db.select(_db.userSettings)..where((t) => t.id.equals(id) & t.deletedAt.isNull());

  static Object? _decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<Object?> load(String id) async => _decode((await _query(id).getSingleOrNull())?.value);

  Stream<Object?> watch(String id) => _query(id).watchSingleOrNull().map((r) => _decode(r?.value));

  Future<void> save(String id, Object? value) async {
    final deviceId = await _db.deviceId();
    await _db.transaction(() async {
      final existing = await (_db.select(_db.userSettings)..where((t) => t.id.equals(id))).getSingleOrNull();
      await _db.into(_db.userSettings).insertOnConflictUpdate(UserSettingsCompanion.insert(
            id: id,
            updatedAt: DateTime.now().toUtc(),
            deletedAt: const Value(null),
            deviceId: deviceId,
            version: Value((existing?.version ?? 0) + 1),
            value: jsonEncode(value),
          ));
    });
  }
}

final userSettingStoreProvider = Provider<UserSettingStore>((ref) => UserSettingStore(ref.watch(databaseProvider)));

/// Map из JSON-настройки (или пустой).
Map<String, Object?> jsonMap(Object? v) => v is Map ? v.cast<String, Object?>() : const {};
