// История прогулок (Walks) и сохранение построенных маршрутов (WalkRoutes).
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../domain/walks/walk_api.dart';
import 'route_codec.dart';

class WalkHistoryRepository {
  WalkHistoryRepository(this._db);

  final AppDatabase _db;

  /// Завершённые прогулки, новые сверху.
  Stream<List<WalkRow>> watchFinished({int limit = 20}) => (_db.select(_db.walks)
        ..where((t) => t.finishedAt.isNotNull() & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
        ..limit(limit))
      .watch();

  /// Сохранить маршрут, вернуть id (для WalkTracker.start(routeId:)).
  Future<String> saveRoute(RoutePlan plan, {DateTime? now}) async {
    final id = newId();
    final at = now ?? DateTime.now();
    await _db.into(_db.walkRoutes).insert(WalkRoutesCompanion.insert(
          id: id,
          updatedAt: at,
          deviceId: await _db.deviceId(),
          kind: plan.kind,
          distanceM: plan.distanceM,
          durationS: Value(plan.durationS),
          payload: jsonEncode(routePlanToJson(plan)),
          createdAt: at,
        ));
    return id;
  }
}

final walkHistoryRepositoryProvider = Provider<WalkHistoryRepository>(
  (ref) => WalkHistoryRepository(ref.watch(databaseProvider)),
);

final walkHistoryProvider = StreamProvider<List<WalkRow>>(
  (ref) => ref.watch(walkHistoryRepositoryProvider).watchFinished(),
);
