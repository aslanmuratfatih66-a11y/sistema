// RoutePlan ↔ JSON для payload прогулки (чтобы после перезапуска продолжить привязку к маршруту).
import '../../domain/walks/walk_api.dart';
import '../models/enums.dart';

Map<String, Object?> encodeRoutePlan(RoutePlan p) => {
      'kind': p.kind,
      'distanceM': p.distanceM,
      if (p.durationS != null) 'durationS': p.durationS,
      'points': [for (final g in p.points) g.toJson()],
      'segments': [for (final s in p.segments) s.toJson()],
      'cues': [for (final c in p.cues) c.toJson()],
    };

double? _num(Object? v) => v is num ? v.toDouble() : null;

RoutePlan? decodeRoutePlan(Object? j) {
  if (j is! Map) return null;
  final points = <GeoPoint>[
    for (final e in (j['points'] as List?) ?? const []) ?GeoPoint.fromJson(e),
  ];
  final segments = <WalkSegment>[
    for (final e in (j['segments'] as List?) ?? const [])
      if (e is Map && _num(e['from']) != null && _num(e['to']) != null)
        WalkSegment(
          mode: WalkMode.values.asNameMap()[e['mode']] ?? WalkMode.walk,
          fromM: _num(e['from'])!,
          toM: _num(e['to'])!,
        ),
  ];
  final cues = <RouteCue>[
    for (final e in (j['cues'] as List?) ?? const [])
      if (e is Map && _num(e['at']) != null)
        RouteCue(
          atM: _num(e['at'])!,
          turn: RouteTurn.values.asNameMap()[e['turn']] ?? RouteTurn.straight,
          street: e['street'] is String ? e['street'] as String : null,
        ),
  ];
  return RoutePlan(
    points: points,
    distanceM: _num(j['distanceM']) ?? 0,
    durationS: j['durationS'] is int ? j['durationS'] as int : null,
    segments: segments,
    cues: cues,
    kind: j['kind'] is String ? j['kind'] as String : 'loop',
  );
}
