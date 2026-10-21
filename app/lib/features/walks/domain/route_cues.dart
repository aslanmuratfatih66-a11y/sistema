// Подсказки поворотов: из maneuver.modifier OSRM, из текста инструкций MapKit и из углов полилинии.
import '../../../domain/walks/walk_api.dart';
import 'geo.dart';

/// OSRM: тип манёвра + modifier → поворот. null — не озвучиваем (прямо, смена названия улицы).
RouteTurn? turnFromOsrm(String? type, String? modifier) {
  switch (type) {
    case 'depart':
      return RouteTurn.start;
    case 'arrive':
      return RouteTurn.arrive;
  }
  return switch (modifier) {
    'left' || 'sharp left' => RouteTurn.left,
    'right' || 'sharp right' => RouteTurn.right,
    'slight left' => RouteTurn.slightLeft,
    'slight right' => RouteTurn.slightRight,
    'uturn' => RouteTurn.uTurn,
    _ => null,
  };
}

/// Поворот по углу между входящим и исходящим направлением (плюс — направо).
RouteTurn? turnFromAngle(double delta) {
  final a = delta.abs();
  if (a < 25) return null;
  if (a >= 155) return RouteTurn.uTurn;
  if (a < 50) return delta > 0 ? RouteTurn.slightRight : RouteTurn.slightLeft;
  return delta > 0 ? RouteTurn.right : RouteTurn.left;
}

/// Угол поворота полилинии в точке [atM]: азимут [atM−window → atM] против [atM → atM+window].
double? turnAngleAt(List<GeoPoint> points, List<double> cum, double atM, {double window = 20}) {
  if (points.length < 3 || cum.isEmpty) return null;
  final total = cum.last;
  if (atM - window < 0 || atM + window > total) return null;
  final before = pointAtDistance(points, cum, atM - window);
  final at = pointAtDistance(points, cum, atM);
  final after = pointAtDistance(points, cum, atM + window);
  if (distanceM(before, at) < 1 || distanceM(at, after) < 1) return null;
  return bearingDelta(bearingDeg(before, at), bearingDeg(at, after));
}

/// MapKit: инструкции на языке системы (en/ru/tr). Ищем направление в тексте; «слегка» — slight.
RouteTurn? turnFromInstruction(String text) {
  final t = text.toLowerCase();
  if (t.isEmpty) return null;
  bool has(List<String> words) => words.any(t.contains);
  if (has(const ['u-turn', 'make a u', 'разворот', 'развернитесь', 'u dönüşü', 'geri dönün'])) return RouteTurn.uTurn;
  if (has(const ['arrive', 'destination', 'прибыт', 'пункт назначения', 'место назначения', 'varış', 'hedef'])) {
    return RouteTurn.arrive;
  }
  final slight = has(const ['slight', 'bear', 'keep', 'слегка', 'держитесь', 'hafif', 'tutun']);
  final left = has(const ['left', 'налево', 'левее', 'слева', 'sola', 'sol ']);
  final right = has(const ['right', 'направо', 'правее', 'справа', 'sağa', 'sağ ']);
  if (left == right) return null;
  if (left) return slight ? RouteTurn.slightLeft : RouteTurn.left;
  return slight ? RouteTurn.slightRight : RouteTurn.right;
}

/// Шаг маршрута до разбора: где (м от старта) и что известно.
class RawStep {
  const RawStep({required this.atM, this.turn, this.instruction, this.street});

  final double atM;
  final RouteTurn? turn;
  final String? instruction;
  final String? street;
}

/// Подсказки маршрута: шаги без поворота уточняются по углу полилинии; старт/финиш — по одной штуке;
/// подсказки ближе [minGapM] друг к другу схлопываются (оставляем первую).
List<RouteCue> buildCues(List<GeoPoint> points, double distanceM, List<RawStep> steps, {double minGapM = 15}) {
  final cum = cumulativeDistances(points);
  final out = <RouteCue>[const RouteCue(atM: 0, turn: RouteTurn.start)];
  final sorted = [...steps]..sort((a, b) => a.atM.compareTo(b.atM));
  for (final s in sorted) {
    if (s.atM <= minGapM || s.atM >= distanceM - minGapM) continue; // старт/финиш добавляем сами
    var turn = s.turn;
    // Промежуточные «прибытие/отправление» (опорные точки круга) — по углу: там бывает разворот.
    if (turn == null || turn == RouteTurn.straight || turn == RouteTurn.start || turn == RouteTurn.arrive) {
      final angle = turnAngleAt(points, cum, s.atM);
      turn = angle == null ? null : turnFromAngle(angle);
    }
    if (turn == null) continue;
    if (out.length > 1 && s.atM - out.last.atM < minGapM) continue;
    out.add(RouteCue(atM: s.atM, turn: turn, street: (s.street?.isEmpty ?? true) ? null : s.street));
  }
  out.add(RouteCue(atM: distanceM, turn: RouteTurn.arrive));
  return out;
}
