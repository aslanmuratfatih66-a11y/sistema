// Прогулки (SPEC §8.5): модели маршрута и трекинга, контракты сервисов. КОНТРАКТ каркаса этапа 4
// (правит главный агент). Реализации:
//   RouteService — сабагент A (features/walks; iOS MapKit через канал `sistema/maps`, Android — OSRM/Overpass по HTTP);
//   LocationService, WalkTracker — сабагент C (core/location; geolocator, фон с выключенным экраном).
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';

@immutable
class GeoPoint {
  const GeoPoint(this.lat, this.lon);

  final double lat;
  final double lon;

  List<double> toJson() => [lat, lon];

  static GeoPoint? fromJson(Object? j) =>
      j is List && j.length >= 2 && j[0] is num && j[1] is num ? GeoPoint((j[0] as num).toDouble(), (j[1] as num).toDouble()) : null;

  @override
  bool operator ==(Object other) => other is GeoPoint && other.lat == lat && other.lon == lon;

  @override
  int get hashCode => Object.hash(lat, lon);

  @override
  String toString() => 'GeoPoint($lat, $lon)';
}

/// Отрезок маршрута с режимом: [fromM, toM) по дистанции от старта.
@immutable
class WalkSegment {
  const WalkSegment({required this.mode, required this.fromM, required this.toM});

  final WalkMode mode;
  final double fromM;
  final double toM;

  Map<String, Object?> toJson() => {'mode': mode.name, 'from': fromM, 'to': toM};
}

/// Поворот/подсказка на маршруте.
enum RouteTurn { start, straight, left, right, slightLeft, slightRight, uTurn, arrive }

@immutable
class RouteCue {
  const RouteCue({required this.atM, required this.turn, this.street});

  /// Дистанция от старта, где выполнить манёвр.
  final double atM;
  final RouteTurn turn;
  final String? street;

  Map<String, Object?> toJson() => {'at': atM, 'turn': turn.name, if (street != null) 'street': street};
}

/// Маршрут: линия, длина, отрезки режимов и подсказки поворотов.
@immutable
class RoutePlan {
  const RoutePlan({
    required this.points,
    required this.distanceM,
    this.durationS,
    this.segments = const [],
    this.cues = const [],
    this.kind = 'loop',
  });

  final List<GeoPoint> points;
  final double distanceM;
  final int? durationS;
  final List<WalkSegment> segments;
  final List<RouteCue> cues;

  /// 'loop' — круг от текущей точки; 'toPlace' — к месту (магазин).
  final String kind;
}

/// Место (магазин, вода) рядом.
@immutable
class Place {
  const Place({required this.name, required this.point, this.distanceM, this.address});

  final String name;
  final GeoPoint point;
  final double? distanceM;
  final String? address;
}

/// Что искать рядом.
enum PlaceCategory { grocery, water, pharmacy }

abstract interface class RouteService {
  /// Круговой пеший маршрут от [start] длиной около [targetM]. null — не построить (нет сети/сервиса).
  Future<RoutePlan?> loop(GeoPoint start, double targetM);

  /// Пеший маршрут до [to].
  Future<RoutePlan?> toPlace(GeoPoint start, GeoPoint to);

  /// Ближайшие места, по возрастанию расстояния.
  Future<List<Place>> nearby(GeoPoint start, PlaceCategory category, {int limit = 5});
}

/// Доступ к геолокации.
enum LocationAccess { unavailable, denied, deniedForever, whenInUse, always }

@immutable
class LocationFix {
  const LocationFix({required this.point, required this.at, this.accuracyM, this.speedMps});

  final GeoPoint point;
  final DateTime at;
  final double? accuracyM;
  final double? speedMps;
}

abstract interface class LocationService {
  Future<LocationAccess> access();

  /// Запрос «При использовании».
  Future<LocationAccess> requestWhenInUse();

  /// Запрос «Всегда» (для прогулки с выключенным экраном).
  Future<LocationAccess> requestAlways();

  Future<LocationFix?> current();
}

/// Состояние идущей прогулки.
@immutable
class WalkProgress {
  const WalkProgress({
    required this.elapsed,
    required this.distanceM,
    this.position,
    this.paceSecPerKm,
    this.segmentIndex,
    this.mode,
    this.nextCue,
    this.metersToNextCue,
    this.offRoute = false,
    this.routeProgress,
    this.paused = false,
  });

  final Duration elapsed;
  final double distanceM;
  final LocationFix? position;

  /// Текущий темп (скользящее окно); null — мало данных.
  final double? paceSecPerKm;
  final int? segmentIndex;
  final WalkMode? mode;
  final RouteCue? nextCue;
  final double? metersToNextCue;
  final bool offRoute;

  /// 0…1 по маршруту; null — без маршрута.
  final double? routeProgress;
  final bool paused;
}

/// Итог прогулки (пишется в Walks).
@immutable
class WalkSummary {
  const WalkSummary({
    required this.walkId,
    required this.startedAt,
    required this.finishedAt,
    required this.distanceM,
    required this.activeSeconds,
    this.kcal,
  });

  final String walkId;
  final DateTime startedAt;
  final DateTime finishedAt;
  final double distanceM;
  final int activeSeconds;
  final double? kcal;
}

/// Трекинг прогулки (фон, выключенный экран). Один активный трекинг на приложение.
abstract interface class WalkTracker {
  /// Идёт ли прогулка (после перезапуска приложения — восстановленная).
  bool get isActive;

  Stream<WalkProgress> get progress;

  /// Старт; [plan] — маршрут (отрезки и подсказки) или null — свободная прогулка.
  Future<void> start({RoutePlan? plan, String? routeId});

  Future<void> pause();
  Future<void> resume();

  /// Завершить и сохранить в Walks.
  Future<WalkSummary?> finish();
}

/// Переопределяются в main реализациями A и C. По умолчанию — «недоступно» (тесты, предпросмотр).
final routeServiceProvider = Provider<RouteService>((ref) => const UnavailableRouteService());
final locationServiceProvider = Provider<LocationService>((ref) => const UnavailableLocationService());

class UnavailableRouteService implements RouteService {
  const UnavailableRouteService();

  @override
  Future<RoutePlan?> loop(GeoPoint start, double targetM) async => null;

  @override
  Future<RoutePlan?> toPlace(GeoPoint start, GeoPoint to) async => null;

  @override
  Future<List<Place>> nearby(GeoPoint start, PlaceCategory category, {int limit = 5}) async => const [];
}

class UnavailableLocationService implements LocationService {
  const UnavailableLocationService();

  @override
  Future<LocationAccess> access() async => LocationAccess.unavailable;

  @override
  Future<LocationAccess> requestWhenInUse() async => LocationAccess.unavailable;

  @override
  Future<LocationAccess> requestAlways() async => LocationAccess.unavailable;

  @override
  Future<LocationFix?> current() async => null;
}

/// Трекер прогулки — реализация C (core/location), переопределяется в main; тесты подменяют фейком.
final walkTrackerProvider = Provider<WalkTracker>(
  (ref) => throw UnimplementedError('walkTrackerProvider: переопределите реализацией трекера'),
);
