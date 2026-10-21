// Геометрия трека: расстояние по хаверсину, проекция точки на отрезок/полилинию.
// Чистые функции, без плагинов.
import 'dart:math' as math;

import '../../domain/walks/walk_api.dart';

/// Средний радиус Земли, м.
const double earthRadiusM = 6371008.8;

double _rad(double deg) => deg * math.pi / 180;

/// Расстояние по дуге большого круга (хаверсин), м.
double haversineM(GeoPoint a, GeoPoint b) {
  final dLat = _rad(b.lat - a.lat);
  final dLon = _rad(b.lon - a.lon);
  final s = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_rad(a.lat)) * math.cos(_rad(b.lat)) * math.sin(dLon / 2) * math.sin(dLon / 2);
  return 2 * earthRadiusM * math.asin(math.min(1, math.sqrt(s)));
}

/// Длина полилинии, м.
double polylineLengthM(List<GeoPoint> points) {
  var sum = 0.0;
  for (var i = 1; i < points.length; i++) {
    sum += haversineM(points[i - 1], points[i]);
  }
  return sum;
}

/// Проекция точки на отрезок.
class SegmentProjection {
  const SegmentProjection({required this.t, required this.distanceM});

  /// Доля отрезка 0…1 до ближайшей точки.
  final double t;

  /// Расстояние от точки до отрезка, м.
  final double distanceM;
}

/// Ближайшая точка отрезка [a]→[b] к [p]. На масштабе прогулки (сотни метров) достаточно
/// локальной равнопромежуточной проекции вокруг [p].
SegmentProjection projectOnSegment(GeoPoint p, GeoPoint a, GeoPoint b) {
  final k = math.cos(_rad(p.lat));
  double x(GeoPoint g) => _rad(g.lon - p.lon) * k * earthRadiusM;
  double y(GeoPoint g) => _rad(g.lat - p.lat) * earthRadiusM;
  final ax = x(a), ay = y(a), bx = x(b), by = y(b);
  final dx = bx - ax, dy = by - ay;
  final len2 = dx * dx + dy * dy;
  var t = len2 == 0 ? 0.0 : -(ax * dx + ay * dy) / len2;
  t = t.clamp(0.0, 1.0);
  final cx = ax + t * dx, cy = ay + t * dy;
  return SegmentProjection(t: t, distanceM: math.sqrt(cx * cx + cy * cy));
}
