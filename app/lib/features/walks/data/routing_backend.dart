// Источник маршрутов и мест: MapKit (iOS) или OSRM/Overpass (HTTP). WalkRouteService собирает из него RoutePlan.
import '../../../domain/walks/walk_api.dart';
import '../domain/route_cues.dart';

/// Маршрут через точки: линия, длина, время и сырые шаги (до разбора в подсказки).
class RawRoute {
  const RawRoute({required this.points, required this.distanceM, this.durationS, this.steps = const []});

  final List<GeoPoint> points;
  final double distanceM;
  final double? durationS;
  final List<RawStep> steps;
}

/// Место из поиска (расстояние считает сервис).
class RawPlace {
  const RawPlace({required this.name, required this.point, this.address});

  final String name;
  final GeoPoint point;
  final String? address;
}

abstract interface class RoutingBackend {
  /// Пеший маршрут через [waypoints] по порядку. null — не построить (сеть, нет пути).
  Future<RawRoute?> route(List<GeoPoint> waypoints);

  /// Места рядом с [center] в радиусе [radiusM]. Пусто — ничего/ошибка.
  Future<List<RawPlace>> search(GeoPoint center, PlaceCategory category, {required double radiusM});
}
