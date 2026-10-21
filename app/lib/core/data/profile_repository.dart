import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';

/// Профиль — одна строка. Создаётся при первой записи; поля синхронизации проставляются здесь.
class ProfileRepository {
  ProfileRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$ProfilesTable, ProfileRow> _query() =>
      _db.select(_db.profiles)..where((t) => t.deletedAt.isNull())..limit(1);

  Future<ProfileRow?> get() => _query().getSingleOrNull();

  Stream<ProfileRow?> watch() => _query().watchSingleOrNull();

  /// Обновить поля профиля. Передавайте только изменённые поля (`Value(...)`), остальные — absent.
  /// id/updatedAt/deviceId/version в [patch] игнорируются.
  Future<void> update(ProfilesCompanion patch) async {
    final deviceId = await _db.deviceId();
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      final existing = await get();
      if (existing == null) {
        await _db.into(_db.profiles).insert(patch.copyWith(
              id: Value(newId()),
              updatedAt: Value(now),
              deviceId: Value(deviceId),
              version: const Value(1),
            ));
      } else {
        await (_db.update(_db.profiles)..where((t) => t.id.equals(existing.id))).write(patch.copyWith(
              id: const Value.absent(),
              updatedAt: Value(now),
              deviceId: Value(deviceId),
              version: Value(existing.version + 1),
            ));
      }
    });
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) => ProfileRepository(ref.watch(databaseProvider)));

final profileProvider = StreamProvider<ProfileRow?>((ref) => ref.watch(profileRepositoryProvider).watch());
