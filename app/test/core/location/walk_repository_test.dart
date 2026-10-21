import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/location/walk_kcal.dart';
import 'package:sistema/core/location/walk_repository.dart';

import '../../helpers/test_db.dart';
import '_geo.dart';

void main() {
  late AppDatabase db;
  late WalkRepository repo;
  setUp(() {
    db = memoryDb();
    repo = WalkRepository(db);
  });
  tearDown(() => db.close());

  test('старт, сохранение, незавершённая, финал', () async {
    final id = await repo.start(startedAt: t0, routeId: 'r1', payload: {'a': 1});
    expect((await repo.unfinished(notBefore: t0.subtract(const Duration(hours: 1))))?.id, id);
    expect(await repo.unfinished(notBefore: t0.add(const Duration(hours: 1))), isNull);

    await repo.save(id, distanceM: 120, activeSeconds: 90, track: [
      [55, 37, 1],
    ], payload: {'b': 2});
    var row = (await repo.byId(id))!;
    expect(row.distanceM, 120);
    expect(row.version, 2);
    expect(decodeTrack(row.track), [
      [55, 37, 1],
    ]);
    expect(decodePayload(row.payload), {'b': 2});

    await repo.save(id, distanceM: 130, activeSeconds: 100, track: const [], payload: const {}, kcal: 12, finishedAt: t0);
    row = (await repo.byId(id))!;
    expect(row.kcal, 12);
    expect(row.finishedAt, isNotNull);
    expect(await repo.unfinished(notBefore: t0.subtract(const Duration(days: 1))), isNull);
  });

  test('вес: фолбэк и последний замер', () async {
    expect((await repo.weightForKcal()).kg, walkFallbackWeightKg);
    final dev = await db.deviceId();
    for (final (d, kg) in [(1, 80.0), (2, 78.0)]) {
      await db.into(db.bodyMeasurements).insert(BodyMeasurementsCompanion.insert(
            id: newId(),
            updatedAt: t0,
            deviceId: dev,
            measuredAt: t0.add(Duration(days: d)),
            weightKg: Value(kg),
          ));
    }
    final w = await repo.weightForKcal();
    expect(w.kg, 78);
    expect(w.assumed, isFalse);
  });

  test('битый JSON не роняет', () {
    expect(decodeTrack('oops'), isEmpty);
    expect(decodePayload('[1]'), isEmpty);
  });
}
