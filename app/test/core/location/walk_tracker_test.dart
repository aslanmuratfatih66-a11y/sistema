import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/location/walk_repository.dart';
import 'package:sistema/core/location/walk_tracker_impl.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/walks/walk_api.dart';

import '../../helpers/test_db.dart';
import '_geo.dart';

void main() {
  late AppDatabase db;
  late DateTime now;
  late StreamController<LocationFix> fixes;
  var subscriptions = 0;

  GeolocatorWalkTracker tracker() => GeolocatorWalkTracker(
        repository: WalkRepository(db),
        positions: () {
          subscriptions++;
          return fixes.stream;
        },
        clock: () => now,
        tick: null,
        saveEvery: const Duration(seconds: 30),
      );

  Future<void> feed(double m, int sec) async {
    now = t0.add(Duration(seconds: sec));
    fixes.add(fixAt(m, sec));
    await pumpEventQueue();
  }

  setUp(() {
    db = memoryDb();
    now = t0;
    fixes = StreamController<LocationFix>.broadcast();
    subscriptions = 0;
  });
  tearDown(() async {
    await fixes.close();
    await db.close();
  });

  test('старт → точки → пауза → финиш с ккал и записью в Walks', () async {
    final t = tracker();
    final seen = <WalkProgress>[];
    final sub = t.progress.listen(seen.add);
    expect(t.isActive, isFalse);
    await t.start();
    expect(t.isActive, isTrue);
    expect(subscriptions, 1);
    for (var i = 0; i <= 12; i++) {
      await feed(i * 12.5, i * 10); // 1.25 м/с
    }
    // Периодическое сохранение (раз в 30 с по приходу точек).
    final mid = (await WalkRepository(db).byId(t.walkId!))!;
    expect(mid.distanceM, greaterThan(100));
    expect(mid.finishedAt, isNull);

    await t.pause();
    expect(seen.last.paused, isTrue);
    await feed(400, 200); // на паузе — не считается
    now = t0.add(const Duration(seconds: 300));
    await t.resume();
    expect(subscriptions, 1); // подписка не дублируется
    await feed(400, 300);
    await feed(412.5, 310);

    now = t0.add(const Duration(seconds: 320));
    final s = (await t.finish())!;
    expect(t.isActive, isFalse);
    expect(s.distanceM, closeTo(162.5, 1));
    expect(s.activeSeconds, 140);
    // 162.5 м за 140 с ≈ 4.2 км/ч → MET 3.0, вес по умолчанию 70.
    expect(s.kcal, closeTo(3.0 * 70 * 140 / 3600, 0.01));
    final row = (await WalkRepository(db).byId(s.walkId))!;
    expect(row.finishedAt, isNotNull);
    expect(row.kcal, s.kcal);
    expect(decodePayload(row.payload)['weightAssumed'], isTrue);
    expect(await t.finish(), isNull);
    await sub.cancel();
  });

  test('восстановление после перезапуска: на паузе, с маршрутом; старую не поднимаем', () async {
    final plan = RoutePlan(
      points: [base, north(1000)],
      distanceM: 1000,
      segments: const [WalkSegment(mode: WalkMode.cardio, fromM: 0, toM: 1000)],
    );
    final a = tracker();
    await a.start(plan: plan, routeId: 'r1');
    final id = a.walkId;
    for (var i = 0; i <= 4; i++) {
      await feed(i * 10.0, i * 10);
    }
    await a.pause();
    await a.dispose(); // «убили» приложение

    now = t0.add(const Duration(minutes: 5));
    final b = tracker();
    expect(await b.restore(), isTrue);
    expect(b.isActive, isTrue);
    expect(b.walkId, id);
    final p = await b.progress.first;
    expect(p.paused, isTrue);
    expect(p.distanceM, closeTo(40, 0.5));
    expect(p.elapsed, const Duration(seconds: 40));
    expect(p.mode, WalkMode.cardio);
    expect(p.routeProgress, closeTo(0.04, 0.005));
    await b.resume();
    expect(b.session!.paused, isFalse);
    final s = await b.finish();
    expect(s!.walkId, id);

    now = t0.add(const Duration(days: 2));
    final c = tracker();
    await c.start();
    await c.dispose();
    now = t0.add(const Duration(days: 3));
    expect(await tracker().restore(), isFalse);
  });
}
