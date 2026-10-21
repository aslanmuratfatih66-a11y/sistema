// Строки Walks: старт (finishedAt = null), периодическое обновление, финал; поиск незавершённой.
import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import 'walk_kcal.dart';

class WalkRepository {
  WalkRepository(this._db);

  final AppDatabase _db;

  Future<String> start({required DateTime startedAt, String? routeId, required Map<String, Object?> payload}) async {
    final id = newId();
    await _db.into(_db.walks).insert(WalksCompanion.insert(
          id: id,
          updatedAt: DateTime.now().toUtc(),
          deviceId: await _db.deviceId(),
          routeId: Value(routeId),
          startedAt: startedAt,
          payload: Value(jsonEncode(payload)),
        ));
    return id;
  }

  /// Обновить строку. [finishedAt] — только при завершении.
  Future<void> save(
    String id, {
    required double distanceM,
    required int activeSeconds,
    required List<List<num>> track,
    required Map<String, Object?> payload,
    double? kcal,
    DateTime? finishedAt,
  }) async {
    final row = await (_db.select(_db.walks)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    await (_db.update(_db.walks)..where((t) => t.id.equals(id))).write(WalksCompanion(
      distanceM: Value(distanceM),
      activeSeconds: Value(activeSeconds),
      track: Value(jsonEncode(track)),
      payload: Value(jsonEncode(payload)),
      kcal: kcal == null ? const Value.absent() : Value(kcal),
      finishedAt: finishedAt == null ? const Value.absent() : Value(finishedAt),
      updatedAt: Value(DateTime.now().toUtc()),
      version: Value(row.version + 1),
    ));
  }

  /// Последняя незавершённая прогулка, начатая не раньше [notBefore].
  Future<WalkRow?> unfinished({required DateTime notBefore}) async {
    final row = await (_db.select(_db.walks)
          ..where((t) => t.finishedAt.isNull() & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null || row.startedAt.isBefore(notBefore)) return null;
    return row;
  }

  Future<WalkRow?> byId(String id) => (_db.select(_db.walks)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Вес для ккал: последний замер, иначе [walkFallbackWeightKg].
  Future<({double kg, bool assumed})> weightForKcal() async {
    final row = await (_db.select(_db.bodyMeasurements)
          ..where((t) => t.weightKg.isNotNull() & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)])
          ..limit(1))
        .getSingleOrNull();
    final kg = row?.weightKg;
    return kg == null || kg <= 0 ? (kg: walkFallbackWeightKg, assumed: true) : (kg: kg, assumed: false);
  }
}

/// Разбор трека из строки Walks.
List<List<num>> decodeTrack(String json) {
  try {
    final v = jsonDecode(json);
    if (v is! List) return [];
    return [
      for (final e in v)
        if (e is List && e.length >= 3 && e.every((x) => x is num)) [for (final x in e) x as num],
    ];
  } catch (_) {
    return [];
  }
}

Map<String, Object?> decodePayload(String json) {
  try {
    final v = jsonDecode(json);
    return v is Map ? v.cast<String, Object?>() : {};
  } catch (_) {
    return {};
  }
}
