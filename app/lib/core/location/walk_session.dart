// Состояние одной прогулки без плагинов и БД: точки → дистанция, активное время с паузами, темп,
// привязка к маршруту, прореженный трек, статистика по отрезкам.
import 'dart:math' as math;

import '../../domain/walks/walk_api.dart';
import 'geo_math.dart';
import 'route_matcher.dart';
import 'track_filter.dart';

class WalkSession {
  WalkSession({
    required this.startedAt,
    this.plan,
    this.routeId,
    TrackFilter? filter,
    PaceWindow? pace,
    OffRouteDetector? offRoute,
    this.trackStepM = 10,
  })  : filter = filter ?? TrackFilter(),
        pace = pace ?? PaceWindow(),
        offRoute = offRoute ?? OffRouteDetector(),
        matcher = plan == null ? null : RouteMatcher(plan);

  final DateTime startedAt;
  final RoutePlan? plan;
  final String? routeId;
  final TrackFilter filter;
  final PaceWindow pace;
  final OffRouteDetector offRoute;
  final RouteMatcher? matcher;

  /// Точка трека пишется, если ушли от прошлой записанной хотя бы на столько.
  final double trackStepM;

  double distanceM = 0;

  /// Активное время до текущего отрезка «идём» (паузы не считаются).
  Duration _activeBefore = Duration.zero;
  DateTime? _runningSince;

  LocationFix? lastFix;
  RouteMatch? lastMatch;

  /// [[lat, lon, tMs], …] — прореженный трек.
  final List<List<num>> track = [];
  GeoPoint? _lastTrackPoint;

  /// Дистанция и активные секунды по индексу отрезка маршрута.
  final Map<int, ({double m, double s})> segmentStats = {};
  double? _lastAcceptedActiveS;

  bool get paused => _runningSince == null;

  /// Запустить отсчёт активного времени (старт или продолжение).
  void run(DateTime now) {
    _runningSince ??= now;
  }

  void pause(DateTime now) {
    final since = _runningSince;
    if (since == null) return;
    _activeBefore += _positive(now.difference(since));
    _runningSince = null;
    // После паузы первая точка — новая опора: путь «во время паузы» не засчитываем.
    filter.reset();
    pace.clear();
    _lastAcceptedActiveS = null;
  }

  Duration elapsed(DateTime now) {
    final since = _runningSince;
    return since == null ? _activeBefore : _activeBefore + _positive(now.difference(since));
  }

  static Duration _positive(Duration d) => d.isNegative ? Duration.zero : d;

  /// Восстановление сохранённого (после перезапуска приложения): прогулка на паузе.
  void restore({required double distanceM, required int activeSeconds, required List<List<num>> track, double? alongM}) {
    this.distanceM = distanceM;
    _activeBefore = Duration(seconds: activeSeconds);
    _runningSince = null;
    this.track
      ..clear()
      ..addAll(track);
    if (track.isNotEmpty) {
      final t = track.last;
      _lastTrackPoint = GeoPoint(t[0].toDouble(), t[1].toDouble());
    }
    if (alongM != null) matcher?.restore(alongM);
  }

  /// Новая точка. Возвращает вердикт фильтра; на паузе точки только обновляют позицию.
  FixVerdict addFix(LocationFix fix, DateTime now) {
    if (paused) {
      lastFix = fix;
      return FixVerdict.anchor;
    }
    final r = filter.add(fix);
    if (!r.usable) return r.verdict;
    lastFix = fix;
    final activeS = elapsed(now).inMilliseconds / 1000;
    distanceM += r.deltaM;
    pace.add(distanceM, activeS);
    _addTrackPoint(fix);

    final m = matcher;
    if (m != null) {
      final match = m.match(fix.point);
      lastMatch = match;
      offRoute.update(match.fromRouteM, fix.at);
      final idx = match.segmentIndex;
      final prevS = _lastAcceptedActiveS;
      if (idx != null && r.verdict == FixVerdict.accepted && prevS != null) {
        final s = segmentStats[idx] ?? (m: 0.0, s: 0.0);
        segmentStats[idx] = (m: s.m + r.deltaM, s: s.s + math.max(0, activeS - prevS));
      }
    }
    _lastAcceptedActiveS = activeS;
    return r.verdict;
  }

  void _addTrackPoint(LocationFix fix) {
    final last = _lastTrackPoint;
    if (last != null && haversineM(last, fix.point) < trackStepM) return;
    _lastTrackPoint = fix.point;
    track.add(_trackEntry(fix));
  }

  static List<num> _trackEntry(LocationFix f) => [
        (f.point.lat * 1e6).round() / 1e6,
        (f.point.lon * 1e6).round() / 1e6,
        f.at.millisecondsSinceEpoch,
      ];

  /// Последняя точка в трек, даже если ближе шага (финиш).
  void closeTrack() {
    final f = lastFix;
    if (f == null) return;
    final last = _lastTrackPoint;
    if (last != null && last == f.point) return;
    _lastTrackPoint = f.point;
    track.add(_trackEntry(f));
  }

  WalkProgress snapshot(DateTime now) {
    final el = elapsed(now);
    final m = matcher;
    final match = lastMatch ?? m?.describe(m.alongM);
    return WalkProgress(
      elapsed: el,
      distanceM: distanceM,
      position: lastFix,
      paceSecPerKm: paused ? null : pace.pace(nowActiveS: el.inMilliseconds / 1000),
      segmentIndex: match?.segmentIndex,
      mode: match?.mode,
      nextCue: match?.nextCue,
      metersToNextCue: match?.metersToNextCue,
      offRoute: m != null && offRoute.offRoute,
      routeProgress: match?.progress,
      paused: paused,
    );
  }
}
