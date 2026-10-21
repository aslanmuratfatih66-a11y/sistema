import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/walks/walk_api.dart';
import 'package:sistema/features/walks/domain/geo.dart';
import 'package:sistema/features/walks/domain/loop_planner.dart';
import 'package:sistema/features/walks/domain/route_cues.dart';
import 'package:sistema/features/walks/domain/walk_segments.dart';
import 'package:sistema/features/walks/domain/walk_voice.dart';

const start = GeoPoint(55.7558, 37.6173);

void main() {
  group('geo', () {
    test('расстояние и точка по азимуту согласованы', () {
      final p = destination(start, 90, 1000);
      expect(distanceM(start, p), closeTo(1000, 1));
      expect(bearingDeg(start, p), closeTo(90, 0.5));
    });

    test('точка на полилинии и срез', () {
      final pts = [start, destination(start, 0, 100), destination(destination(start, 0, 100), 90, 100)];
      final cum = cumulativeDistances(pts);
      expect(cum.last, closeTo(200, 0.5));
      expect(distanceM(pointAtDistance(pts, cum, 50), start), closeTo(50, 0.5));
      final slice = slicePolyline(pts, cum, 50, 150);
      expect(polylineLengthM(slice), closeTo(100, 0.5));
      expect(bearingDelta(350, 10), closeTo(20, 1e-9));
      expect(bearingDelta(10, 350), closeTo(-20, 1e-9));
    });
  });

  group('loop planner', () {
    test('опорные точки лежат на окружности через старт', () {
      const r = 500.0;
      final center = destination(start, 45, r);
      final wps = loopWaypoints(start, r, 45);
      expect(wps, hasLength(3));
      for (final p in wps) {
        expect(distanceM(center, p), closeTo(r, 1));
      }
      // Середина — напротив старта.
      expect(distanceM(start, wps[1]), closeTo(2 * r, 2));
    });

    test('подгонка радиуса и допуск', () {
      expect(initialLoopRadius(2 * 3.141592653589793 * 100), closeTo(100, 1e-6));
      expect(adjustLoopRadius(100, 3000, 4000), closeTo(75, 1e-9));
      expect(adjustLoopRadius(100, 3000, 100), 200); // ограничено ×2
      expect(loopWithinTolerance(3000, 3400), isTrue);
      expect(loopWithinTolerance(3000, 3500), isFalse);
      expect(loopCloser(3000, 3100, 3300), isTrue);
      expect(loopCloser(3000, 3300, 3100), isFalse);
      expect(loopCloser(3000, 9000, null), isTrue);
    });
  });

  group('cues', () {
    test('OSRM и инструкции MapKit', () {
      expect(turnFromOsrm('depart', null), RouteTurn.start);
      expect(turnFromOsrm('arrive', 'left'), RouteTurn.arrive);
      expect(turnFromOsrm('turn', 'sharp right'), RouteTurn.right);
      expect(turnFromOsrm('turn', 'slight left'), RouteTurn.slightLeft);
      expect(turnFromOsrm('new name', 'straight'), isNull);
      expect(turnFromInstruction('Turn left onto Main St'), RouteTurn.left);
      expect(turnFromInstruction('Поверните направо на ул. Ленина'), RouteTurn.right);
      expect(turnFromInstruction('Держитесь левее'), RouteTurn.slightLeft);
      expect(turnFromInstruction('Sağa dönün'), RouteTurn.right);
      expect(turnFromInstruction('Развернитесь'), RouteTurn.uTurn);
      expect(turnFromInstruction('The destination is on your left'), RouteTurn.arrive);
      expect(turnFromInstruction('Continue'), isNull);
      expect(turnFromAngle(10), isNull);
      expect(turnFromAngle(30), RouteTurn.slightRight);
      expect(turnFromAngle(-90), RouteTurn.left);
      expect(turnFromAngle(170), RouteTurn.uTurn);
    });

    test('buildCues: старт, поворот по углу, финиш; близкие схлопываются', () {
      final a = destination(start, 0, 200);
      final b = destination(a, 90, 200);
      final pts = [start, a, b];
      final cues = buildCues(pts, 400, const [
        RawStep(atM: 0, turn: RouteTurn.start),
        RawStep(atM: 200, turn: RouteTurn.arrive), // промежуточная опорная точка → по углу (направо)
        RawStep(atM: 205, turn: RouteTurn.left), // ближе 15 м — пропуск
        RawStep(atM: 300), // прямо — без подсказки
      ]);
      expect(cues.map((c) => c.turn), [RouteTurn.start, RouteTurn.right, RouteTurn.arrive]);
      expect(cues[1].atM, 200);
      expect(cues.last.atM, 400);
    });
  });

  group('segments', () {
    test('шаблон: короткая — только шаг; длинная — разминка, интервалы, заминка', () {
      expect(segmentTemplate(10 * 60), [(WalkMode.walk, 600)]);
      final t = segmentTemplate(40 * 60);
      expect(t.first.$1, WalkMode.walk);
      expect(t.last.$1, WalkMode.walk);
      expect(t.map((e) => e.$1), contains(WalkMode.cardio));
      expect(t.fold<int>(0, (s, e) => s + e.$2), 40 * 60);
      final short = segmentTemplate(20 * 60);
      expect(short.map((e) => e.$1), isNot(contains(WalkMode.cardio)));
    });

    test('buildSegments: смежные, точно до конца; без интервалов — один отрезок', () {
      final segs = buildSegments(3000);
      expect(segs.first.fromM, 0);
      expect(segs.last.toM, 3000);
      for (var i = 1; i < segs.length; i++) {
        expect(segs[i].fromM, segs[i - 1].toM);
      }
      expect(buildSegments(3000, intervals: false).single.mode, WalkMode.walk);
      expect(segmentIndexAt(segs, 0), 0);
      expect(segmentIndexAt(segs, 5000), segs.length - 1);
      expect(metersForMinutes(30), closeTo(2520, 1e-9));
    });
  });

  group('voice coach', () {
    WalkProgress p({int? seg, WalkMode? mode, RouteCue? cue, double? toCue, bool off = false, bool paused = false}) =>
        WalkProgress(
          elapsed: Duration.zero,
          distanceM: 0,
          segmentIndex: seg,
          mode: mode,
          nextCue: cue,
          metersToNextCue: toCue,
          offRoute: off,
          paused: paused,
        );

    test('старт, поворот + режим одной фразой, без повторов, сход, финиш', () {
      final c = WalkVoiceCoach();
      final first = c.next(p(seg: 0, mode: WalkMode.walk));
      expect(first?.start, isTrue);
      expect(first?.mode, WalkMode.walk);
      const left = RouteCue(atM: 300, turn: RouteTurn.left);
      expect(c.next(p(seg: 0, mode: WalkMode.walk, cue: left, toCue: 100)), isNull); // далеко
      final both = c.next(p(seg: 1, mode: WalkMode.brisk, cue: left, toCue: 30));
      expect(both?.turn, RouteTurn.left);
      expect(both?.mode, WalkMode.brisk);
      expect(c.next(p(seg: 1, mode: WalkMode.brisk, cue: left, toCue: 10)), isNull); // уже сказали
      expect(c.next(p(seg: 1, off: true))?.offRoute, isTrue);
      expect(c.next(p(seg: 1, off: true)), isNull);
      expect(c.next(p(seg: 2, mode: WalkMode.rest, paused: true)), isNull); // пауза — молчим
      const fin = RouteCue(atM: 3000, turn: RouteTurn.arrive);
      final end = c.next(p(seg: 2, mode: WalkMode.rest, cue: fin, toCue: 20));
      expect(end?.arrive, isTrue);
      expect(end?.mode, WalkMode.rest);
    });
  });
}
