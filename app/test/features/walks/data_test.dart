import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/walks/walk_api.dart';
import 'package:sistema/features/walks/data/mapkit_routing_backend.dart';
import 'package:sistema/features/walks/data/osm_routing_backend.dart';
import 'package:sistema/features/walks/data/route_codec.dart';
import 'package:sistema/features/walks/data/routing_backend.dart';
import 'package:sistema/features/walks/data/walk_route_service.dart';
import 'package:sistema/features/walks/domain/geo.dart';
import 'package:sistema/features/walks/domain/route_cues.dart';

const start = GeoPoint(55.7558, 37.6173);

const osrmFixture = {
  'code': 'Ok',
  'routes': [
    {
      'distance': 420.5,
      'duration': 300.0,
      'geometry': {
        'type': 'LineString',
        'coordinates': [
          [37.6173, 55.7558],
          [37.6173, 55.7576],
          [37.6205, 55.7576],
        ],
      },
      'legs': [
        {
          'steps': [
            {'distance': 200.0, 'name': 'Тверская', 'maneuver': {'type': 'depart'}},
            {'distance': 220.5, 'name': 'Охотный ряд', 'maneuver': {'type': 'turn', 'modifier': 'right'}},
            {'distance': 0.0, 'name': '', 'maneuver': {'type': 'arrive'}},
          ],
        },
      ],
    },
  ],
};

const overpassFixture = {
  'elements': [
    {
      'type': 'node',
      'lat': 55.7600,
      'lon': 37.6200,
      'tags': {'shop': 'supermarket', 'name': 'Далёкий', 'addr:street': 'Тверская', 'addr:housenumber': '7'},
    },
    {
      'type': 'way',
      'center': {'lat': 55.7560, 'lon': 37.6175},
      'tags': {'shop': 'convenience', 'brand': 'Близкий'},
    },
    {'type': 'node', 'lat': 55.7559, 'lon': 37.6174, 'tags': {'amenity': 'drinking_water'}},
    {'type': 'node', 'tags': {'name': 'без координат'}},
  ],
};

class FakeBackend implements RoutingBackend {
  FakeBackend(this.lengthFor);

  /// Длина маршрута по радиусу (расстояние старт → вторая точка ≈ радиус·√2 при 3 точках). null — нет пути.
  final double? Function(List<GeoPoint> wps) lengthFor;
  final calls = <List<GeoPoint>>[];
  List<RawPlace> places = const [];
  final searchRadii = <double>[];

  @override
  Future<RawRoute?> route(List<GeoPoint> waypoints) async {
    calls.add(waypoints);
    final len = lengthFor(waypoints);
    if (len == null) return null;
    return RawRoute(points: waypoints, distanceM: len, steps: const [RawStep(atM: 0, turn: RouteTurn.start)]);
  }

  @override
  Future<List<RawPlace>> search(GeoPoint center, PlaceCategory category, {required double radiusM}) async {
    searchRadii.add(radiusM);
    return radiusM < 2000 ? const [] : places;
  }
}

void main() {
  group('OSM backend', () {
    test('OSRM: URL, разбор геометрии и шагов', () async {
      late Uri requested;
      final client = MockClient((req) async {
        requested = req.url;
        expect(req.headers['User-Agent'], walkUserAgent);
        return http.Response.bytes(utf8.encode(jsonEncode(osrmFixture)), 200);
      });
      final raw = await OsmRoutingBackend(client).route([start, const GeoPoint(55.7576, 37.6205)]);
      expect(requested.toString(), contains('/foot/37.617300,55.755800;37.620500,55.757600'));
      expect(requested.queryParameters['steps'], 'true');
      expect(raw, isNotNull);
      expect(raw!.distanceM, 420.5);
      expect(raw.points.first, start);
      expect(raw.steps.map((s) => s.turn), [RouteTurn.start, RouteTurn.right, RouteTurn.arrive]);
      expect(raw.steps[1].atM, 200);
      expect(raw.steps[1].street, 'Охотный ряд');
    });

    test('OSRM: ошибка/не Ok/сеть → null', () async {
      expect(await OsmRoutingBackend(MockClient((_) async => http.Response('x', 500))).route([start, start]), isNull);
      expect(
        await OsmRoutingBackend(MockClient((_) async => http.Response('{"code":"NoRoute"}', 200))).route([start, start]),
        isNull,
      );
      expect(await OsmRoutingBackend(MockClient((_) async => throw http.ClientException('offline'))).route([start, start]),
          isNull);
      expect(parseOsrmRoute({'code': 'Ok', 'routes': []}), isNull);
    });

    test('Overpass: запрос и разбор узлов/путей', () async {
      late String body;
      final client = MockClient((req) async {
        body = req.body;
        return http.Response.bytes(utf8.encode(jsonEncode(overpassFixture)), 200);
      });
      final places = await OsmRoutingBackend(client).search(start, PlaceCategory.water, radiusM: 1500);
      expect(Uri.decodeQueryComponent(body), contains('amenity"="drinking_water"'));
      expect(places, hasLength(3));
      expect(places.first.address, 'Тверская, 7');
      expect(places[1].name, 'Близкий');
      expect(places[2].name, '');
      expect(overpassQuery(start, PlaceCategory.grocery, 1000), contains('around:1000,55.755800,37.617300'));
      expect(await OsmRoutingBackend(MockClient((_) async => http.Response('', 429))).search(start, PlaceCategory.grocery, radiusM: 1),
          isEmpty);
    });
  });

  group('MapKit backend', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel(mapsChannelName);

    tearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));

    test('route/search через канал', () async {
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        if (call.method == 'route') {
          return {
            'points': [
              [55.7558, 37.6173],
              [55.7576, 37.6173],
            ],
            'distanceM': 200.0,
            'durationS': 150.0,
            'steps': [
              {'atM': 0.0, 'instruction': ''},
              {'atM': 120.0, 'instruction': 'Turn right onto Tverskaya'},
            ],
          };
        }
        return [
          {'name': 'Магнит', 'lat': 55.756, 'lon': 37.618, 'address': 'Тверская, 1'},
          {'name': 'битый'},
        ];
      });
      final b = MapKitRoutingBackend();
      final raw = await b.route([start, const GeoPoint(55.7576, 37.6173)]);
      expect(calls.first.arguments, {
        'points': [
          [55.7558, 37.6173],
          [55.7576, 37.6173],
        ],
      });
      expect(raw!.distanceM, 200);
      expect(raw.steps[1].turn, RouteTurn.right);
      final places = await b.search(start, PlaceCategory.grocery, radiusM: 1500);
      expect((calls.last.arguments as Map)['category'], 'grocery');
      expect(places.single.name, 'Магнит');
    });

    test('ошибка канала → null/пусто', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => throw PlatformException(code: 'x'));
      final b = MapKitRoutingBackend();
      expect(await b.route([start, start]), isNull);
      expect(await b.search(start, PlaceCategory.water, radiusM: 1), isEmpty);
      expect(parseMapKitRoute({'points': [], 'distanceM': 1}), isNull);
    });
  });

  group('route codec', () {
    test('RoutePlan ⇄ JSON', () {
      const plan = RoutePlan(
        points: [GeoPoint(55.1234567, 37.1), GeoPoint(55.2, 37.2)],
        distanceM: 1234.56,
        durationS: 900,
        segments: [WalkSegment(mode: WalkMode.brisk, fromM: 0, toM: 1234.56)],
        cues: [RouteCue(atM: 0, turn: RouteTurn.start), RouteCue(atM: 600, turn: RouteTurn.left, street: 'Арбат')],
        kind: 'toPlace',
      );
      final back = routePlanFromJson(jsonDecode(jsonEncode(routePlanToJson(plan))));
      expect(back, isNotNull);
      expect(back!.points.first, const GeoPoint(55.123457, 37.1));
      expect(back.distanceM, 1234.6);
      expect(back.durationS, 900);
      expect(back.segments.single.mode, WalkMode.brisk);
      expect(back.cues[1].street, 'Арбат');
      expect(back.kind, 'toPlace');
      expect(routePlanFromJson({'points': []}), isNull);
      expect(routePlanFromJson('x'), isNull);
    });
  });

  group('WalkRouteService', () {
    test('loop: подгоняет радиус до допуска, план с отрезками и подсказками', () async {
      // Длина ≈ 1.6 × длины окружности по опорным точкам (дороги извилистее).
      final backend = FakeBackend((wps) {
        final r = distanceM(wps[0], wps[2]) / 2;
        return 2 * 3.14159 * r * 1.6;
      });
      final plan = await WalkRouteService(backend).loop(start, 3000);
      expect(plan, isNotNull);
      expect(plan!.kind, 'loop');
      expect((plan.distanceM - 3000).abs() / 3000, lessThanOrEqualTo(0.15));
      expect(backend.calls.length, greaterThan(1));
      expect(backend.calls.first.first, start);
      expect(backend.calls.first.last, start);
      expect(plan.segments.last.toM, plan.distanceM);
      expect(plan.cues.first.turn, RouteTurn.start);
      expect(plan.cues.last.turn, RouteTurn.arrive);
      expect(withIntervals(plan, false).segments.single.mode, WalkMode.walk);
    });

    test('loop: нет пути — поворачивает; совсем нет — null', () async {
      var n = 0;
      final backend = FakeBackend((_) => n++ == 0 ? null : 3000);
      final plan = await WalkRouteService(backend).loop(start, 3000);
      expect(plan?.distanceM, 3000);
      expect(backend.calls, hasLength(2));
      expect(await WalkRouteService(FakeBackend((_) => null)).loop(start, 3000), isNull);
    });

    test('toPlace и nearby: шире радиус, сортировка, без дублей, лимит', () async {
      final backend = FakeBackend((wps) => polylineLengthM(wps))
        ..places = [
          RawPlace(name: 'B', point: destination(start, 0, 800)),
          RawPlace(name: 'A', point: destination(start, 90, 300)),
          RawPlace(name: 'A', point: destination(start, 90, 310)), // дубль
          RawPlace(name: 'C', point: destination(start, 180, 1200)),
        ];
      final service = WalkRouteService(backend);
      final to = await service.toPlace(start, destination(start, 0, 500));
      expect(to!.kind, 'toPlace');
      expect(to.segments.single.mode, WalkMode.walk);
      final places = await service.nearby(start, PlaceCategory.grocery, limit: 2);
      expect(backend.searchRadii, nearbyRadii);
      expect(places.map((p) => p.name), ['A', 'B']);
      expect(places.first.distanceM, closeTo(300, 1));
    });
  });
}
