// iOS: пеший маршрут и поиск мест через MapKit (канал `sistema/maps`, ios/Runner/MapKitChannel.swift).
//   route  {points: [[lat, lon], …]} → {points: [[lat, lon], …], distanceM, durationS, steps: [{atM, instruction}]} | nil
//   search {lat, lon, radiusM, category: grocery|water|pharmacy} → [{name, lat, lon, address?}]
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../domain/walks/walk_api.dart';
import '../domain/route_cues.dart';
import 'routing_backend.dart';

const String mapsChannelName = 'sistema/maps';

double? _num(Object? v) => v is num ? v.toDouble() : null;

/// Разбор ответа `route`. null — нет маршрута/неверный формат.
RawRoute? parseMapKitRoute(Object? json) {
  if (json is! Map) return null;
  final raw = json['points'];
  if (raw is! List) return null;
  final points = [for (final p in raw) ?GeoPoint.fromJson(p)];
  if (points.length < 2) return null;
  final distance = _num(json['distanceM']);
  if (distance == null || distance <= 0) return null;
  final steps = <RawStep>[];
  final rawSteps = json['steps'];
  if (rawSteps is List) {
    for (final s in rawSteps) {
      if (s is! Map) continue;
      final at = _num(s['atM']);
      if (at == null) continue;
      final text = s['instruction'];
      final instruction = text is String ? text : '';
      steps.add(RawStep(atM: at, turn: turnFromInstruction(instruction), instruction: instruction));
    }
  }
  return RawRoute(points: points, distanceM: distance, durationS: _num(json['durationS']), steps: steps);
}

/// Разбор ответа `search`.
List<RawPlace> parseMapKitPlaces(Object? json) {
  if (json is! List) return const [];
  return [
    for (final e in json)
      if (e is Map && _num(e['lat']) != null && _num(e['lon']) != null)
        RawPlace(
          name: e['name'] is String ? e['name'] as String : '',
          point: GeoPoint(_num(e['lat'])!, _num(e['lon'])!),
          address: e['address'] is String ? e['address'] as String : null,
        ),
  ];
}

class MapKitRoutingBackend implements RoutingBackend {
  MapKitRoutingBackend({MethodChannel? channel}) : _channel = channel ?? const MethodChannel(mapsChannelName);

  final MethodChannel _channel;

  @override
  Future<RawRoute?> route(List<GeoPoint> waypoints) async {
    if (waypoints.length < 2) return null;
    try {
      final res = await _channel.invokeMethod<Object?>('route', {
        'points': [for (final p in waypoints) p.toJson()],
      });
      return parseMapKitRoute(res);
    } on Object catch (e) {
      debugPrint('MapKit route: $e');
      return null;
    }
  }

  @override
  Future<List<RawPlace>> search(GeoPoint center, PlaceCategory category, {required double radiusM}) async {
    try {
      final res = await _channel.invokeMethod<Object?>('search', {
        'lat': center.lat,
        'lon': center.lon,
        'radiusM': radiusM,
        'category': category.name,
      });
      return parseMapKitPlaces(res);
    } on Object catch (e) {
      debugPrint('MapKit search: $e');
      return const [];
    }
  }
}
