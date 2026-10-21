import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/location/route_matcher.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/walks/walk_api.dart';

import '_geo.dart';

RoutePlan line() => RoutePlan(
      points: [base, north(500), north(1000)],
      distanceM: 1000,
      segments: const [
        WalkSegment(mode: WalkMode.walk, fromM: 0, toM: 400),
        WalkSegment(mode: WalkMode.brisk, fromM: 400, toM: 1000),
      ],
      cues: const [
        RouteCue(atM: 0, turn: RouteTurn.start),
        RouteCue(atM: 500, turn: RouteTurn.left),
        RouteCue(atM: 1000, turn: RouteTurn.arrive),
      ],
    );

void main() {
  test('позиция по маршруту, отрезок, подсказка', () {
    final m = RouteMatcher(line());
    final a = m.match(north(100, eastM: 5));
    expect(a.alongM, closeTo(100, 1));
    expect(a.fromRouteM, closeTo(5, 0.5));
    expect(a.segmentIndex, 0);
    expect(a.mode, WalkMode.walk);
    expect(a.nextCue?.turn, RouteTurn.left);
    expect(a.metersToNextCue, closeTo(400, 1));
    final b = m.match(north(450));
    expect(b.mode, WalkMode.brisk);
    expect(b.progress, closeTo(0.45, 0.01));
    final c = m.match(north(700));
    expect(c.nextCue?.turn, RouteTurn.arrive);
  });

  test('сход: позиция по маршруту не двигается', () {
    final m = RouteMatcher(line());
    m.match(north(200));
    final off = m.match(north(600, eastM: 200));
    expect(off.fromRouteM, greaterThan(100));
    expect(off.alongM, closeTo(200, 1));
  });

  test('круговой маршрут: у финиша не прыгает в начало и наоборот', () {
    final loop = RoutePlan(points: [base, north(300), north(300, eastM: 300), north(0, eastM: 300), base], distanceM: 1200);
    final m = RouteMatcher(loop);
    expect(m.match(north(5, eastM: 2)).alongM, lessThan(50));
    m.restore(1150);
    expect(m.match(north(0, eastM: 30)).alongM, greaterThan(1100));
  });

  test('детектор схода с гистерезисом', () {
    final d = OffRouteDetector(thresholdM: 40, hold: const Duration(seconds: 15));
    expect(d.update(60, t0), isFalse);
    expect(d.update(60, t0.add(const Duration(seconds: 10))), isFalse);
    expect(d.update(60, t0.add(const Duration(seconds: 16))), isTrue);
    expect(d.update(10, t0.add(const Duration(seconds: 17))), isFalse);
  });
}
