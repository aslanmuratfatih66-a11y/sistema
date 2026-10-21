import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/location/walk_session.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/walks/walk_api.dart';

import '_geo.dart';

DateTime at(int s) => t0.add(Duration(seconds: s));

void main() {
  test('дистанция и время, пауза не считается', () {
    final s = WalkSession(startedAt: t0)..run(t0);
    for (var i = 0; i <= 10; i++) {
      s.addFix(fixAt(i * 15, i * 10), at(i * 10));
    }
    expect(s.distanceM, closeTo(150, 0.5));
    expect(s.elapsed(at(100)), const Duration(seconds: 100));
    s.pause(at(100));
    expect(s.paused, isTrue);
    // На паузе ушли на 300 м — не считается.
    s.addFix(fixAt(450, 200), at(200));
    expect(s.elapsed(at(200)), const Duration(seconds: 100));
    s.run(at(200));
    s.addFix(fixAt(450, 200), at(200));
    s.addFix(fixAt(465, 210), at(210));
    expect(s.distanceM, closeTo(165, 0.5));
    expect(s.elapsed(at(210)), const Duration(seconds: 110));
    final p = s.snapshot(at(210));
    expect(p.paused, isFalse);
    expect(p.paceSecPerKm, closeTo(10 / 15 * 1000, 1)); // окно — только после паузы
    expect(s.track, isNotEmpty);
  });

  test('маршрут: отрезки и статистика, восстановление', () {
    final plan = RoutePlan(
      points: [base, north(1000)],
      distanceM: 1000,
      segments: const [
        WalkSegment(mode: WalkMode.walk, fromM: 0, toM: 100),
        WalkSegment(mode: WalkMode.brisk, fromM: 100, toM: 1000),
      ],
    );
    final s = WalkSession(startedAt: t0, plan: plan)..run(t0);
    for (var i = 0; i <= 15; i++) {
      s.addFix(fixAt(i * 10.0, i * 5), at(i * 5));
    }
    final snap = s.snapshot(at(75));
    expect(snap.mode, WalkMode.brisk);
    expect(snap.routeProgress, closeTo(0.15, 0.01));
    expect(s.segmentStats[0]!.m, closeTo(100, 1));
    expect(s.segmentStats[1]!.m, closeTo(50, 1));

    final r = WalkSession(startedAt: t0, plan: plan)
      ..restore(distanceM: s.distanceM, activeSeconds: 75, track: s.track, alongM: s.matcher!.alongM);
    expect(r.paused, isTrue);
    expect(r.elapsed(at(1000)), const Duration(seconds: 75));
    expect(r.snapshot(at(1000)).mode, WalkMode.brisk);
  });
}
