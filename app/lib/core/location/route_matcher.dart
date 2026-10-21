// Привязка позиции к маршруту: пройдено по маршруту, текущий отрезок/режим, следующая подсказка, сход.
import '../../domain/walks/walk_api.dart';
import '../models/enums.dart';
import 'geo_math.dart';

/// Результат привязки одной точки.
class RouteMatch {
  const RouteMatch({
    required this.alongM,
    required this.fromRouteM,
    required this.progress,
    this.segmentIndex,
    this.mode,
    this.nextCue,
    this.metersToNextCue,
  });

  /// Пройдено по маршруту (в шкале RoutePlan.distanceM), м.
  final double alongM;

  /// Расстояние от позиции до линии маршрута, м.
  final double fromRouteM;

  /// 0…1.
  final double progress;
  final int? segmentIndex;
  final WalkMode? mode;
  final RouteCue? nextCue;
  final double? metersToNextCue;
}

/// Проекция на полилинию [RoutePlan.points] с памятью о пройденном: ищем сначала в окне вокруг
/// прошлой позиции (на круговом маршруте старт и финиш совпадают — без окна точка у старта
/// «прыгнула» бы в конец), иначе — ближайшее по всей линии впереди, иначе — по всей линии.
class RouteMatcher {
  RouteMatcher(
    this.plan, {
    this.onRouteM = 40,
    this.backWindowM = 50,
    this.aheadWindowM = 300,
    this.cuePassedM = 8,
  }) {
    final pts = plan.points;
    _cum = List<double>.filled(pts.length, 0);
    for (var i = 1; i < pts.length; i++) {
      _cum[i] = _cum[i - 1] + haversineM(pts[i - 1], pts[i]);
    }
    final len = pts.isEmpty ? 0.0 : _cum.last;
    // Отрезки и подсказки заданы в метрах RoutePlan.distanceM; длина линии может слегка отличаться.
    _scale = len > 0 && plan.distanceM > 0 ? plan.distanceM / len : 1.0;
    _totalM = plan.distanceM > 0 ? plan.distanceM : len;
    _cues = [...plan.cues]..sort((a, b) => a.atM.compareTo(b.atM));
  }

  final RoutePlan plan;

  /// Ближе этого — «на маршруте».
  final double onRouteM;
  final double backWindowM;
  final double aheadWindowM;

  /// Подсказка считается пройденной, когда до неё меньше этого.
  final double cuePassedM;

  late final List<double> _cum;
  late final double _scale;
  late final double _totalM;
  late final List<RouteCue> _cues;

  double _alongM = 0;

  /// Пройдено по маршруту на последней точке, м.
  double get alongM => _alongM;
  double get totalM => _totalM;

  /// Восстановить положение (после перезапуска).
  void restore(double alongM) => _alongM = alongM.clamp(0, _totalM);

  RouteMatch match(GeoPoint p) {
    final pts = plan.points;
    if (pts.length < 2) {
      final d = pts.isEmpty ? double.infinity : haversineM(p, pts.first);
      return describe(_alongM, fromRouteM: d);
    }
    ({double along, double dist})? inWindow, ahead, global;
    for (var i = 0; i + 1 < pts.length; i++) {
      final pr = projectOnSegment(p, pts[i], pts[i + 1]);
      final along = (_cum[i] + pr.t * (_cum[i + 1] - _cum[i])) * _scale;
      final c = (along: along, dist: pr.distanceM);
      if (global == null || c.dist < global.dist) global = c;
      if (along >= _alongM - backWindowM) {
        if (ahead == null || c.dist < ahead.dist) ahead = c;
        if (along <= _alongM + aheadWindowM && (inWindow == null || c.dist < inWindow.dist)) inWindow = c;
      }
    }
    final pick = (inWindow != null && inWindow.dist <= onRouteM)
        ? inWindow
        : (ahead != null && ahead.dist <= onRouteM)
            ? ahead
            : global!;
    // Сошли с маршрута — положение по маршруту не двигаем.
    if (pick.dist <= onRouteM) _alongM = pick.along.clamp(0, _totalM);
    return describe(_alongM, fromRouteM: pick.dist);
  }

  /// Отрезок, режим и подсказка для положения [alongM].
  RouteMatch describe(double alongM, {double fromRouteM = 0}) {
    int? segIndex;
    final segs = plan.segments;
    for (var i = 0; i < segs.length; i++) {
      if (alongM >= segs[i].fromM && alongM < segs[i].toM) {
        segIndex = i;
        break;
      }
    }
    if (segIndex == null && segs.isNotEmpty) {
      segIndex = alongM < segs.first.fromM ? 0 : segs.length - 1;
    }
    RouteCue? cue;
    for (final c in _cues) {
      if (c.turn == RouteTurn.start) continue;
      if (c.atM - alongM > cuePassedM) {
        cue = c;
        break;
      }
    }
    // Финиш не теряем: если подсказок впереди нет, но до «arrive» меньше порога — показываем её.
    if (cue == null && _cues.isNotEmpty && _cues.last.turn == RouteTurn.arrive && _cues.last.atM >= alongM) {
      cue = _cues.last;
    }
    return RouteMatch(
      alongM: alongM,
      fromRouteM: fromRouteM,
      progress: _totalM > 0 ? (alongM / _totalM).clamp(0.0, 1.0) : 0,
      segmentIndex: segIndex,
      mode: segIndex == null ? null : segs[segIndex].mode,
      nextCue: cue,
      metersToNextCue: cue == null ? null : (cue.atM - alongM).clamp(0, double.infinity).toDouble(),
    );
  }
}

/// Сход с маршрута с гистерезисом по времени: дальше [thresholdM] дольше [hold] — сошли;
/// вернулись ближе [thresholdM] — сразу «на маршруте».
class OffRouteDetector {
  OffRouteDetector({this.thresholdM = 40, this.hold = const Duration(seconds: 15)});

  final double thresholdM;
  final Duration hold;

  DateTime? _farSince;
  bool _off = false;

  bool get offRoute => _off;

  void reset() {
    _farSince = null;
    _off = false;
  }

  bool update(double fromRouteM, DateTime at) {
    if (fromRouteM <= thresholdM) {
      _farSince = null;
      _off = false;
    } else {
      final since = _farSince ??= at;
      if (at.difference(since) >= hold) _off = true;
    }
    return _off;
  }
}
