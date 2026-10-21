import 'package:sistema/domain/walks/walk_api.dart';

const base = GeoPoint(55.0, 37.0);
const mPerDegLat = 111195.08;

/// Точка в [m] метрах к северу от [base].
GeoPoint north(double m, {double eastM = 0}) =>
    GeoPoint(base.lat + m / mPerDegLat, base.lon + eastM / (mPerDegLat * 0.573576436));

final t0 = DateTime.utc(2026, 10, 21, 8);

LocationFix fixAt(double m, int sec, {double eastM = 0, double? acc = 5}) =>
    LocationFix(point: north(m, eastM: eastM), at: t0.add(Duration(seconds: sec)), accuracyM: acc);
