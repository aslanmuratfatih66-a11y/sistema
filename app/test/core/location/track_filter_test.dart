import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/location/track_filter.dart';

import '_geo.dart';

void main() {
  test('опора, приём, точность, скачок, дубль', () {
    final f = TrackFilter();
    expect(f.add(fixAt(0, 0)).verdict, FixVerdict.anchor);
    final r = f.add(fixAt(10, 5));
    expect(r.verdict, FixVerdict.accepted);
    expect(r.deltaM, closeTo(10, 0.1));
    expect(f.add(fixAt(20, 10, acc: 80)).verdict, FixVerdict.inaccurate);
    expect(f.add(fixAt(500, 10)).verdict, FixVerdict.jump);
    expect(f.add(fixAt(12, 5)).verdict, FixVerdict.stale);
  });

  test('серия скачков → новая опора', () {
    final f = TrackFilter(reanchorAfter: 3);
    f.add(fixAt(0, 0));
    expect(f.add(fixAt(1000, 1)).verdict, FixVerdict.jump);
    expect(f.add(fixAt(1001, 2)).verdict, FixVerdict.jump);
    expect(f.add(fixAt(1002, 3)).verdict, FixVerdict.anchor);
    expect(f.add(fixAt(1007, 5)).verdict, FixVerdict.accepted);
  });

  test('reset — следующая точка опора', () {
    final f = TrackFilter()..add(fixAt(0, 0));
    f.reset();
    expect(f.add(fixAt(5, 2)).verdict, FixVerdict.anchor);
  });

  test('темп по окну: 1.5 м/с ≈ 667 с/км; стоим — темп пропадает', () {
    final p = PaceWindow();
    expect(p.pace(), isNull);
    for (var s = 0; s <= 60; s += 5) {
      p.add(s * 1.5, s.toDouble());
    }
    expect(p.pace(), closeTo(1000 / 1.5, 1));
    expect(p.pace(nowActiveS: 200), isNull);
  });
}
