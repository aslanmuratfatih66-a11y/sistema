// Фильтр шумных GPS-точек и темп по скользящему окну.
import '../../domain/walks/walk_api.dart';
import 'geo_math.dart';

/// Решение фильтра по точке.
enum FixVerdict {
  /// Первая точка (или после паузы/сброса) — опора, дистанция не добавляется.
  anchor,

  /// Принята, дистанция добавляется.
  accepted,

  /// Плохая точность.
  inaccurate,

  /// Нереальный скачок скорости.
  jump,

  /// Не новее предыдущей (дубль/порядок нарушен).
  stale,
}

class FilterResult {
  const FilterResult(this.verdict, [this.deltaM = 0]);

  final FixVerdict verdict;

  /// Прирост дистанции, м (только для [FixVerdict.accepted]).
  final double deltaM;

  bool get usable => verdict == FixVerdict.accepted || verdict == FixVerdict.anchor;
}

/// Отсев шумных точек: точность хуже [maxAccuracyM], скорость между точками выше [maxSpeedMps].
/// Если подряд [reanchorAfter] скачков — значит, ошиблась опора (или был долгий провал сигнала):
/// новая точка становится опорой без прироста дистанции, чтобы не «застрять».
class TrackFilter {
  TrackFilter({this.maxAccuracyM = 35, this.maxSpeedMps = 7, this.reanchorAfter = 5});

  final double maxAccuracyM;
  final double maxSpeedMps;
  final int reanchorAfter;

  LocationFix? _last;
  int _jumps = 0;

  LocationFix? get last => _last;

  /// Сбросить опору (пауза): следующая точка — [FixVerdict.anchor].
  void reset() {
    _last = null;
    _jumps = 0;
  }

  FilterResult add(LocationFix fix) {
    final acc = fix.accuracyM;
    if (acc != null && acc > maxAccuracyM) return const FilterResult(FixVerdict.inaccurate);
    final prev = _last;
    if (prev == null) {
      _last = fix;
      return const FilterResult(FixVerdict.anchor);
    }
    final dtS = fix.at.difference(prev.at).inMilliseconds / 1000;
    if (dtS <= 0) return const FilterResult(FixVerdict.stale);
    final d = haversineM(prev.point, fix.point);
    if (d / dtS > maxSpeedMps) {
      _jumps++;
      if (_jumps >= reanchorAfter) {
        _jumps = 0;
        _last = fix;
        return const FilterResult(FixVerdict.anchor);
      }
      return const FilterResult(FixVerdict.jump);
    }
    _jumps = 0;
    _last = fix;
    return FilterResult(FixVerdict.accepted, d);
  }
}

/// Темп по скользящему окну: последние [windowS] секунд активного времени, но не больше [windowM] метров.
class PaceWindow {
  PaceWindow({this.windowS = 60, this.windowM = 200, this.minS = 10, this.minM = 10});

  final double windowS;
  final double windowM;
  final double minS;
  final double minM;

  final List<({double distanceM, double activeS})> _samples = [];

  void clear() => _samples.clear();

  /// Отметка: суммарная дистанция и суммарное активное время на момент точки.
  void add(double distanceM, double activeS) {
    _samples.add((distanceM: distanceM, activeS: activeS));
    // Держим запас за окном: удаляем образцы, которые уже точно не нужны.
    while (_samples.length > 2 && activeS - _samples[1].activeS > windowS) {
      _samples.removeAt(0);
    }
  }

  /// Темп, с/км; null — мало данных или стоим. [nowActiveS] — текущее активное время: если точек
  /// давно не было (стоим — платформа не шлёт точки из-за distanceFilter), окно «уезжает» и темп пропадает.
  double? pace({double? nowActiveS}) {
    if (_samples.isEmpty) return null;
    final lastS = _samples.last;
    final extended = nowActiveS != null && nowActiveS > lastS.activeS;
    final now = extended ? (distanceM: lastS.distanceM, activeS: nowActiveS) : lastS;
    var from = now;
    for (var i = _samples.length - (extended ? 1 : 2); i >= 0; i--) {
      final s = _samples[i];
      if (now.activeS - s.activeS > windowS) break;
      from = s;
      if (now.distanceM - s.distanceM >= windowM) break;
    }
    final dt = now.activeS - from.activeS;
    final dd = now.distanceM - from.distanceM;
    if (dt < minS || dd < minM) return null;
    return dt / dd * 1000;
  }
}
