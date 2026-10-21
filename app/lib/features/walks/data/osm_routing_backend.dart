// Android/прочее: пеший маршрут — публичный OSRM FOSSGIS (routing.openstreetmap.de, профиль foot),
// места — Overpass API. Публичные серверы: без ключа, с User-Agent, умеренно (один маршрут — 1–3 запроса).
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../domain/walks/walk_api.dart';
import '../domain/route_cues.dart';
import 'routing_backend.dart';

const String walkUserAgent = 'Sistema/1.0 (com.sistema.sistema; personal fitness app)';
const String osrmFootBase = 'https://routing.openstreetmap.de/routed-foot/route/v1/foot';
const String overpassUrl = 'https://overpass-api.de/api/interpreter';

/// URL запроса маршрута OSRM (координаты — «lon,lat;lon,lat»).
Uri osrmRouteUri(List<GeoPoint> waypoints) {
  final coords = waypoints.map((p) => '${p.lon.toStringAsFixed(6)},${p.lat.toStringAsFixed(6)}').join(';');
  return Uri.parse('$osrmFootBase/$coords?overview=full&geometries=geojson&steps=true');
}

/// Разбор ответа OSRM. null — нет маршрута/неверный формат.
RawRoute? parseOsrmRoute(Object? json) {
  if (json is! Map || json['code'] != 'Ok') return null;
  final routes = json['routes'];
  if (routes is! List || routes.isEmpty || routes.first is! Map) return null;
  final r = routes.first as Map;
  final distance = r['distance'];
  if (distance is! num || distance <= 0) return null;
  final geometry = r['geometry'];
  final coords = geometry is Map ? geometry['coordinates'] : null;
  if (coords is! List) return null;
  final points = <GeoPoint>[
    for (final c in coords)
      if (c is List && c.length >= 2 && c[0] is num && c[1] is num) GeoPoint((c[1] as num).toDouble(), (c[0] as num).toDouble()),
  ];
  if (points.length < 2) return null;
  final steps = <RawStep>[];
  var at = 0.0;
  final legs = r['legs'];
  if (legs is List) {
    for (final leg in legs) {
      final legSteps = leg is Map ? leg['steps'] : null;
      if (legSteps is! List) continue;
      for (final s in legSteps) {
        if (s is! Map) continue;
        final m = s['maneuver'];
        final type = m is Map ? m['type'] as String? : null;
        final modifier = m is Map ? m['modifier'] as String? : null;
        final name = s['name'];
        // Манёвр шага — в его начале.
        steps.add(RawStep(atM: at, turn: turnFromOsrm(type, modifier), street: name is String ? name : null));
        final d = s['distance'];
        if (d is num) at += d.toDouble();
      }
    }
  }
  final duration = r['duration'];
  return RawRoute(
    points: points,
    distanceM: distance.toDouble(),
    durationS: duration is num ? duration.toDouble() : null,
    steps: steps,
  );
}

/// Запрос Overpass QL для категории в радиусе.
String overpassQuery(GeoPoint c, PlaceCategory category, double radiusM, {int max = 40}) {
  final around = '(around:${radiusM.round()},${c.lat.toStringAsFixed(6)},${c.lon.toStringAsFixed(6)})';
  final filters = switch (category) {
    PlaceCategory.grocery => ['nwr["shop"~"^(supermarket|convenience)\$"]$around;'],
    // Воду можно купить в магазине или набрать из питьевого фонтанчика.
    PlaceCategory.water => [
        'nwr["shop"~"^(supermarket|convenience)\$"]$around;',
        'nwr["amenity"="drinking_water"]$around;',
      ],
    PlaceCategory.pharmacy => ['nwr["amenity"="pharmacy"]$around;'],
  };
  return '[out:json][timeout:20];(${filters.join()});out center $max;';
}

/// Разбор ответа Overpass: узлы (lat/lon) и пути/отношения (center).
List<RawPlace> parseOverpass(Object? json) {
  if (json is! Map) return const [];
  final elements = json['elements'];
  if (elements is! List) return const [];
  final out = <RawPlace>[];
  for (final e in elements) {
    if (e is! Map) continue;
    final center = e['center'];
    final lat = e['lat'] ?? (center is Map ? center['lat'] : null);
    final lon = e['lon'] ?? (center is Map ? center['lon'] : null);
    if (lat is! num || lon is! num) continue;
    final tags = e['tags'] is Map ? e['tags'] as Map : const {};
    final name = tags['name'] ?? tags['brand'] ?? '';
    final street = tags['addr:street'];
    final house = tags['addr:housenumber'];
    final address = street is String ? (house is String ? '$street, $house' : street) : null;
    out.add(RawPlace(
      name: name is String ? name : '',
      point: GeoPoint(lat.toDouble(), lon.toDouble()),
      address: address,
    ));
  }
  return out;
}

class OsmRoutingBackend implements RoutingBackend {
  OsmRoutingBackend(this._client, {this.timeout = const Duration(seconds: 20)});

  final http.Client _client;
  final Duration timeout;

  static const _headers = {'User-Agent': walkUserAgent, 'Accept': 'application/json'};

  @override
  Future<RawRoute?> route(List<GeoPoint> waypoints) async {
    if (waypoints.length < 2) return null;
    try {
      final res = await _client.get(osrmRouteUri(waypoints), headers: _headers).timeout(timeout);
      if (res.statusCode != 200) {
        debugPrint('OSRM: HTTP ${res.statusCode}');
        return null;
      }
      return parseOsrmRoute(jsonDecode(utf8.decode(res.bodyBytes)));
    } on Object catch (e) {
      // Сеть, таймаут, неверный JSON.
      debugPrint('OSRM: $e');
      return null;
    }
  }

  @override
  Future<List<RawPlace>> search(GeoPoint center, PlaceCategory category, {required double radiusM}) async {
    try {
      final res = await _client
          .post(Uri.parse(overpassUrl), headers: _headers, body: {'data': overpassQuery(center, category, radiusM)})
          .timeout(timeout);
      if (res.statusCode != 200) {
        debugPrint('Overpass: HTTP ${res.statusCode}');
        return const [];
      }
      return parseOverpass(jsonDecode(utf8.decode(res.bodyBytes)));
    } on Object catch (e) {
      debugPrint('Overpass: $e');
      return const [];
    }
  }
}
