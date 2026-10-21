// Геометрия на сфере: расстояния, азимуты, точка по азимуту, длина и деление полилинии.
import 'dart:math' as math;

import '../../../domain/walks/walk_api.dart';

const double earthRadiusM = 6371008.8;

double _rad(double deg) => deg * math.pi / 180;
double _deg(double rad) => rad * 180 / math.pi;

/// Расстояние по большому кругу (гаверсинус), м.
double distanceM(GeoPoint a, GeoPoint b) {
  final dLat = _rad(b.lat - a.lat);
  final dLon = _rad(b.lon - a.lon);
  final h = math.pow(math.sin(dLat / 2), 2) +
      math.cos(_rad(a.lat)) * math.cos(_rad(b.lat)) * math.pow(math.sin(dLon / 2), 2);
  return 2 * earthRadiusM * math.asin(math.min(1, math.sqrt(h)));
}

/// Начальный азимут a → b, градусы 0…360 (0 — север, по часовой).
double bearingDeg(GeoPoint a, GeoPoint b) {
  final p1 = _rad(a.lat);
  final p2 = _rad(b.lat);
  final dl = _rad(b.lon - a.lon);
  final y = math.sin(dl) * math.cos(p2);
  final x = math.cos(p1) * math.sin(p2) - math.sin(p1) * math.cos(p2) * math.cos(dl);
  return (_deg(math.atan2(y, x)) + 360) % 360;
}

/// Точка на расстоянии [dist] м от [from] по азимуту [bearing] (градусы).
GeoPoint destination(GeoPoint from, double bearing, double dist) {
  final d = dist / earthRadiusM;
  final b = _rad(bearing);
  final p1 = _rad(from.lat);
  final l1 = _rad(from.lon);
  final p2 = math.asin(math.sin(p1) * math.cos(d) + math.cos(p1) * math.sin(d) * math.cos(b));
  final l2 = l1 + math.atan2(math.sin(b) * math.sin(d) * math.cos(p1), math.cos(d) - math.sin(p1) * math.sin(p2));
  final lon = (_deg(l2) + 540) % 360 - 180;
  return GeoPoint(_deg(p2), lon);
}

/// Нарастающая дистанция по вершинам: [0, d01, d01+d12, …].
List<double> cumulativeDistances(List<GeoPoint> points) {
  final out = <double>[];
  var acc = 0.0;
  for (var i = 0; i < points.length; i++) {
    if (i > 0) acc += distanceM(points[i - 1], points[i]);
    out.add(acc);
  }
  return out;
}

double polylineLengthM(List<GeoPoint> points) => points.length < 2 ? 0 : cumulativeDistances(points).last;

/// Точка полилинии на дистанции [atM] от начала (интерполяция по отрезку).
GeoPoint pointAtDistance(List<GeoPoint> points, List<double> cum, double atM) {
  if (points.isEmpty) throw ArgumentError('пустая полилиния');
  if (atM <= 0 || points.length == 1) return points.first;
  if (atM >= cum.last) return points.last;
  var lo = 0;
  var hi = cum.length - 1;
  while (hi - lo > 1) {
    final mid = (lo + hi) >> 1;
    if (cum[mid] <= atM) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  final span = cum[hi] - cum[lo];
  final t = span <= 0 ? 0.0 : (atM - cum[lo]) / span;
  final a = points[lo];
  final b = points[hi];
  return GeoPoint(a.lat + (b.lat - a.lat) * t, a.lon + (b.lon - a.lon) * t);
}

/// Части полилинии [fromM, toM] (с интерполированными концами) — для окраски по режимам.
List<GeoPoint> slicePolyline(List<GeoPoint> points, List<double> cum, double fromM, double toM) {
  if (points.length < 2 || toM <= fromM) return const [];
  final out = <GeoPoint>[pointAtDistance(points, cum, fromM)];
  for (var i = 0; i < points.length; i++) {
    if (cum[i] > fromM && cum[i] < toM) out.add(points[i]);
  }
  out.add(pointAtDistance(points, cum, toM));
  return out;
}

/// Разность азимутов b − a, нормированная в (−180, 180]. Плюс — поворот направо.
double bearingDelta(double a, double b) {
  var d = (b - a) % 360;
  if (d > 180) d -= 360;
  if (d <= -180) d += 360;
  return d;
}
