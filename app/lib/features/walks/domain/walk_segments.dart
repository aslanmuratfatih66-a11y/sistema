// Отрезки режимов: шаблон по длительности (разминка шагом → интервалы → заминка) → WalkSegment по дистанции.
import '../../../core/models/enums.dart';
import '../../../domain/walks/walk_api.dart';

/// Скорость по режимам, м/с (шаг ≈ 5 км/ч, быстрый ≈ 6, кардио ≈ 7.5, отдых ≈ 4).
const Map<WalkMode, double> walkModeSpeed = {
  WalkMode.walk: 5 / 3.6,
  WalkMode.brisk: 6 / 3.6,
  WalkMode.cardio: 7.5 / 3.6,
  WalkMode.rest: 4 / 3.6,
};

/// Средняя скорость прогулки для перевода минут в метры (смесь режимов), м/с.
const double averageWalkSpeed = 1.4;

/// Длина маршрута на [minutes] минут.
double metersForMinutes(int minutes) => minutes * 60 * averageWalkSpeed;

/// Оценка длительности маршрута, с.
int estimateDurationS(double distanceM) => (distanceM / averageWalkSpeed).round();

/// Шаблон по времени: (режим, секунды).
List<(WalkMode, int)> segmentTemplate(int totalS) {
  if (totalS <= 0) return const [];
  // Короткая прогулка — без интервалов.
  if (totalS < 12 * 60) return [(WalkMode.walk, totalS)];
  final warm = totalS < 25 * 60 ? 3 * 60 : 5 * 60;
  final cool = warm;
  final out = <(WalkMode, int)>[(WalkMode.walk, warm)];
  var middle = totalS - warm - cool;
  // Цикл: ускорение 3 мин → кардио 1 мин → отдых шагом 2 мин. В коротком — без кардио.
  final cycle = totalS < 25 * 60
      ? const [(WalkMode.brisk, 2 * 60), (WalkMode.rest, 60)]
      : const [(WalkMode.brisk, 3 * 60), (WalkMode.cardio, 60), (WalkMode.rest, 2 * 60)];
  final cycleS = cycle.fold<int>(0, (s, e) => s + e.$2);
  while (middle >= cycleS) {
    out.addAll(cycle);
    middle -= cycleS;
  }
  // Остаток — ускорение (если заметный) или к заминке.
  if (middle >= 60) {
    out.add((WalkMode.brisk, middle));
    middle = 0;
  }
  out.add((WalkMode.walk, cool + middle));
  return _merge(out);
}

List<(WalkMode, int)> _merge(List<(WalkMode, int)> list) {
  final out = <(WalkMode, int)>[];
  for (final e in list) {
    if (out.isNotEmpty && out.last.$1 == e.$1) {
      out[out.length - 1] = (e.$1, out.last.$2 + e.$2);
    } else {
      out.add(e);
    }
  }
  return out;
}

/// Отрезки на дистанцию [distanceM]: шаблон по оценке времени, метры по скорости режима,
/// масштаб — чтобы сумма точно совпала с длиной маршрута. Отрезки смежные, последний кончается на [distanceM].
List<WalkSegment> buildSegments(double distanceM, {bool intervals = true}) {
  if (distanceM <= 0) return const [];
  if (!intervals) return [WalkSegment(mode: WalkMode.walk, fromM: 0, toM: distanceM)];
  final template = segmentTemplate(estimateDurationS(distanceM));
  final raw = [for (final (mode, s) in template) s * walkModeSpeed[mode]!];
  final sum = raw.fold<double>(0, (a, b) => a + b);
  final k = distanceM / sum;
  final out = <WalkSegment>[];
  var at = 0.0;
  for (var i = 0; i < template.length; i++) {
    final to = i == template.length - 1 ? distanceM : at + raw[i] * k;
    out.add(WalkSegment(mode: template[i].$1, fromM: at, toM: to));
    at = to;
  }
  return out;
}

/// Отрезок, в котором находится дистанция [atM] (по индексу); за концом — последний.
int? segmentIndexAt(List<WalkSegment> segments, double atM) {
  if (segments.isEmpty) return null;
  for (var i = 0; i < segments.length; i++) {
    if (atM < segments[i].toM) return i;
  }
  return segments.length - 1;
}
