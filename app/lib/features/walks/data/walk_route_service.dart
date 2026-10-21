// RouteService поверх RoutingBackend (MapKit на iOS, OSRM/Overpass на остальных).
// Круг: опорные точки на окружности через старт, радиус подгоняется под длину (до [maxLoopAttempts] запросов).
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../domain/walks/walk_api.dart';
import '../domain/geo.dart';
import '../domain/loop_planner.dart';
import '../domain/route_cues.dart';
import '../domain/walk_segments.dart';
import 'mapkit_routing_backend.dart';
import 'osm_routing_backend.dart';
import 'routing_backend.dart';

/// Радиусы поиска мест, м: сначала рядом, затем шире.
const List<double> nearbyRadii = [1500, 4000];

class WalkRouteService implements RouteService {
  WalkRouteService(this._backend, {math.Random? random, this.maxLoopAttempts = 4})
      : _random = random ?? math.Random();

  final RoutingBackend _backend;
  final math.Random _random;
  final int maxLoopAttempts;

  @override
  Future<RoutePlan?> loop(GeoPoint start, double targetM) async {
    if (targetM <= 0) return null;
    // Дороги длиннее окружности — начинаем с радиуса поменьше.
    var radius = initialLoopRadius(targetM) * 0.8;
    var rotation = _random.nextDouble() * 360;
    RawRoute? best;
    for (var i = 0; i < maxLoopAttempts; i++) {
      final wps = loopWaypoints(start, radius, rotation);
      final raw = await _backend.route([start, ...wps, start]);
      if (raw == null) {
        // Нет пути в эту сторону (вода, парк без дорожек) — повернуть круг.
        rotation = (rotation + 90) % 360;
        continue;
      }
      if (loopCloser(targetM, raw.distanceM, best?.distanceM)) best = raw;
      if (loopWithinTolerance(targetM, raw.distanceM)) break;
      radius = adjustLoopRadius(radius, targetM, raw.distanceM);
    }
    if (best == null) return null;
    return planFromRaw(best, kind: 'loop', intervals: true);
  }

  @override
  Future<RoutePlan?> toPlace(GeoPoint start, GeoPoint to) async {
    final raw = await _backend.route([start, to]);
    if (raw == null) return null;
    return planFromRaw(raw, kind: 'toPlace', intervals: false);
  }

  @override
  Future<List<Place>> nearby(GeoPoint start, PlaceCategory category, {int limit = 5}) async {
    for (final r in nearbyRadii) {
      final raw = await _backend.search(start, category, radiusM: r);
      final places = rankPlaces(start, raw, limit: limit);
      if (places.isNotEmpty) return places;
    }
    return const [];
  }
}

/// RawRoute → RoutePlan: отрезки режимов (шаблон или один «шаг») и подсказки поворотов.
RoutePlan planFromRaw(RawRoute raw, {required String kind, required bool intervals}) => RoutePlan(
      points: raw.points,
      distanceM: raw.distanceM,
      durationS: estimateDurationS(raw.distanceM),
      segments: buildSegments(raw.distanceM, intervals: intervals),
      cues: buildCues(raw.points, raw.distanceM, raw.steps),
      kind: kind,
    );

/// Тот же маршрут с другим шаблоном отрезков (переключатель «интервалы» на экране).
RoutePlan withIntervals(RoutePlan plan, bool intervals) => RoutePlan(
      points: plan.points,
      distanceM: plan.distanceM,
      durationS: plan.durationS,
      segments: buildSegments(plan.distanceM, intervals: intervals),
      cues: plan.cues,
      kind: plan.kind,
    );

/// Места по расстоянию, без дублей (одна точка в 30 м с тем же названием).
List<Place> rankPlaces(GeoPoint start, List<RawPlace> raw, {int limit = 5}) {
  final all = [
    for (final p in raw)
      Place(name: p.name, point: p.point, address: p.address, distanceM: distanceM(start, p.point)),
  ]..sort((a, b) => a.distanceM!.compareTo(b.distanceM!));
  final out = <Place>[];
  for (final p in all) {
    final dup = out.any((q) => q.name == p.name && distanceM(q.point, p.point) < 30);
    if (dup) continue;
    out.add(p);
    if (out.length >= limit) break;
  }
  return out;
}

/// Бэкенд по платформе: iOS — MapKit, иначе — OSM (HTTP). Переопределяется в тестах.
final walkRoutingBackendProvider = Provider<RoutingBackend>((ref) {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) return MapKitRoutingBackend();
  final client = http.Client();
  ref.onDispose(client.close);
  return OsmRoutingBackend(client);
});

/// Фабрика для main: `routeServiceProvider.overrideWith(buildWalkRouteService)`.
RouteService buildWalkRouteService(Ref ref) => WalkRouteService(ref.watch(walkRoutingBackendProvider));
