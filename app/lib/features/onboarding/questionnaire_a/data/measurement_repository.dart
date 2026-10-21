import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/db/database.dart';
import '../../../../core/models/enums.dart';

/// Замер тела из анкеты: одна «текущая» запись BodyMeasurements (источник manual).
/// Её id хранится в AppSettings [settingKey]; создаётся при первом вводе, дальше обновляется она же.
class OnboardingMeasurementRepository {
  OnboardingMeasurementRepository(this._db);

  static const settingKey = 'onboarding.measurementId';

  final AppDatabase _db;

  Future<BodyMeasurementRow?> get() async {
    final id = await _db.getSetting(settingKey);
    if (id == null) return null;
    return (_db.select(_db.bodyMeasurements)..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Обновить поля замера (передавайте только изменённые, остальные — absent).
  /// Поля синхронизации, measuredAt и source проставляются здесь.
  Future<void> patch(BodyMeasurementsCompanion patch) async {
    final deviceId = await _db.deviceId();
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      final existing = await get();
      if (existing == null) {
        final id = newId();
        await _db.into(_db.bodyMeasurements).insert(patch.copyWith(
              id: Value(id),
              updatedAt: Value(now),
              deletedAt: const Value(null),
              deviceId: Value(deviceId),
              version: const Value(1),
              measuredAt: Value(now),
              source: Value(MeasurementSource.manual.name),
            ));
        await _db.setSetting(settingKey, id);
      } else {
        await (_db.update(_db.bodyMeasurements)..where((t) => t.id.equals(existing.id))).write(patch.copyWith(
              id: const Value.absent(),
              updatedAt: Value(now),
              deviceId: Value(deviceId),
              version: Value(existing.version + 1),
              measuredAt: Value(now),
              source: Value(MeasurementSource.manual.name),
            ));
      }
    });
  }
}

final onboardingMeasurementRepositoryProvider = Provider<OnboardingMeasurementRepository>(
  (ref) => OnboardingMeasurementRepository(ref.watch(databaseProvider)),
);
