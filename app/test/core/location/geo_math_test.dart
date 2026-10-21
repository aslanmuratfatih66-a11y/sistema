import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/location/geo_math.dart';

import '_geo.dart';

void main() {
  test('хаверсин: 1° широты ≈ 111.2 км, 100 м на север', () {
    expect(haversineM(base, north(100)), closeTo(100, 0.1));
    expect(haversineM(base, base), 0);
  });

  test('длина полилинии', () {
    expect(polylineLengthM([base, north(50), north(150)]), closeTo(150, 0.2));
    expect(polylineLengthM([base]), 0);
  });

  test('проекция на отрезок', () {
    final p = projectOnSegment(north(50, eastM: 20), base, north(100));
    expect(p.t, closeTo(0.5, 0.01));
    expect(p.distanceM, closeTo(20, 0.5));
    final before = projectOnSegment(north(-30), base, north(100));
    expect(before.t, 0);
    expect(before.distanceM, closeTo(30, 0.2));
  });
}
