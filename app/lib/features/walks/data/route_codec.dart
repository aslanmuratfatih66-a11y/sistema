// RoutePlan ⇄ JSON (payload в WalkRoutes).
import '../../../core/models/enums.dart';
import '../../../domain/walks/walk_api.dart';

const int routePayloadVersion = 1;

double _round6(double v) => (v * 1e6).roundToDouble() / 1e6;
double _round1(double v) => (v * 10).roundToDouble() / 10;

Map<String, Object?> routePlanToJson(RoutePlan plan) => {
      'v': routePayloadVersion,
      'kind': plan.kind,
      'distanceM': _round1(plan.distanceM),
      if (plan.durationS != null) 'durationS': plan.durationS,
      'points': [for (final p in plan.points) [_round6(p.lat), _round6(p.lon)]],
      'segments': [
        for (final s in plan.segments) {'mode': s.mode.name, 'from': _round1(s.fromM), 'to': _round1(s.toM)},
      ],
      'cues': [
        for (final c in plan.cues) {'at': _round1(c.atM), 'turn': c.turn.name, if (c.street != null) 'street': c.street},
      ],
    };

double? _num(Object? v) => v is num ? v.toDouble() : null;

/// null — повреждённый/чужой формат.
RoutePlan? routePlanFromJson(Object? j) {
  if (j is! Map) return null;
  final rawPoints = j['points'];
  if (rawPoints is! List) return null;
  final points = [for (final p in rawPoints) ?GeoPoint.fromJson(p)];
  if (points.length < 2) return null;
  final distance = _num(j['distanceM']);
  if (distance == null || distance <= 0) return null;
  final segments = <WalkSegment>[];
  final rawSeg = j['segments'];
  if (rawSeg is List) {
    for (final s in rawSeg) {
      if (s is! Map) continue;
      final mode = WalkMode.values.asNameMap()[s['mode']];
      final from = _num(s['from']);
      final to = _num(s['to']);
      if (mode == null || from == null || to == null) continue;
      segments.add(WalkSegment(mode: mode, fromM: from, toM: to));
    }
  }
  final cues = <RouteCue>[];
  final rawCues = j['cues'];
  if (rawCues is List) {
    for (final c in rawCues) {
      if (c is! Map) continue;
      final turn = RouteTurn.values.asNameMap()[c['turn']];
      final at = _num(c['at']);
      if (turn == null || at == null) continue;
      final street = c['street'];
      cues.add(RouteCue(atM: at, turn: turn, street: street is String ? street : null));
    }
  }
  final kind = j['kind'];
  final dur = _num(j['durationS']);
  return RoutePlan(
    points: points,
    distanceM: distance,
    durationS: dur?.round(),
    segments: segments,
    cues: cues,
    kind: kind is String ? kind : 'loop',
  );
}
