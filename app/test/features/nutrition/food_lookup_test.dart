import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/nutrition/data/food_lookup.dart';

http.Response _json(Object body, {int status = 200}) => http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  group('Open Food Facts', () {
    test('найден: название, бренд, КБЖУ на 100 г, порция; запрос с User-Agent и полями', () async {
      late http.Request seen;
      final client = MockClient((req) async {
        seen = req;
        return _json({
          'code': '4600000000001',
          'status': 1,
          'product': {
            'product_name': 'Yogurt',
            'product_name_ru': 'Йогурт натуральный',
            'brands': 'Простоквашино, Danone',
            'serving_size': '125 g',
            'nutriments': {
              'energy-kcal_100g': 68,
              'proteins_100g': 5.0,
              'fat_100g': '2,5',
              'carbohydrates_100g': 6.2,
            },
          },
        });
      });
      final r = await OpenFoodFactsLookup(client, preferLang: 'ru').byBarcode(' 4600000000001 ');
      expect(seen.headers['User-Agent'], 'Sistema/1.0 (personal app)');
      expect(seen.url.host, 'world.openfoodfacts.org');
      expect(seen.url.path, '/api/v2/product/4600000000001.json');
      expect(seen.url.queryParameters['fields'], contains('nutriments'));
      expect(r.status, FoodLookupStatus.found);
      final p = r.product!;
      expect(p.name, 'Йогурт натуральный');
      expect(p.brand, 'Простоквашино');
      expect(p.kcal100, 68);
      expect(p.protein100, 5);
      expect(p.fat100, 2.5);
      expect(p.carbs100, 6.2);
      expect(p.servingG, 125);
      expect(p.source, FoodSource.openFoodFacts);
      expect(p.barcode, '4600000000001');
    });

    test('status 0 (и HTTP 404) — не найден', () async {
      final notFound = {'code': '1', 'status': 0, 'status_verbose': 'product not found'};
      final r1 = await OpenFoodFactsLookup(MockClient((_) async => _json(notFound))).byBarcode('1');
      expect(r1.status, FoodLookupStatus.notFound);
      final r2 = await OpenFoodFactsLookup(MockClient((_) async => _json(notFound, status: 404))).byBarcode('1');
      expect(r2.status, FoodLookupStatus.notFound);
    });

    test('нет БЖУ — нули; нет ккал — пересчёт из кДж', () {
      final r = OpenFoodFactsLookup.parse('2', {
        'status': 1,
        'product': {
          'product_name': 'Вода',
          'nutriments': {'energy-kj_100g': 418.4},
        },
      });
      expect(r.status, FoodLookupStatus.found);
      expect(r.product!.kcal100, closeTo(100, 1e-9));
      expect(r.product!.protein100, 0);
      expect(r.product!.fat100, 0);
      expect(r.product!.carbs100, 0);
      expect(r.product!.brand, isNull);
      expect(r.product!.servingG, isNull);
    });

    test('нет калорий или названия — не найден (ручной ввод)', () {
      expect(
        OpenFoodFactsLookup.parse('3', {
          'status': 1,
          'product': {'product_name': 'X', 'nutriments': <String, Object?>{}},
        }).status,
        FoodLookupStatus.notFound,
      );
      expect(
        OpenFoodFactsLookup.parse('3', {
          'status': 1,
          'product': {
            'product_name': '  ',
            'nutriments': {'energy-kcal_100g': 10},
          },
        }).status,
        FoodLookupStatus.notFound,
      );
      expect(OpenFoodFactsLookup.parse('3', {'status': 1}).status, FoodLookupStatus.notFound);
    });

    test('турецкое название при preferLang tr', () {
      final r = OpenFoodFactsLookup.parse('4', {
        'status': 1,
        'product': {
          'product_name': 'Ayran',
          'product_name_tr': 'Ayran (TR)',
          'nutriments': {'energy-kcal_100g': 36},
        },
      }, preferLang: 'tr');
      expect(r.product!.name, 'Ayran (TR)');
    });

    test('нет сети / 500 / битый JSON — failed', () async {
      final offline = OpenFoodFactsLookup(MockClient((_) async => throw http.ClientException('offline')));
      expect((await offline.byBarcode('5')).status, FoodLookupStatus.failed);
      final server = OpenFoodFactsLookup(MockClient((_) async => http.Response('oops', 500)));
      expect((await server.byBarcode('5')).status, FoodLookupStatus.failed);
      final broken = OpenFoodFactsLookup(MockClient((_) async => http.Response('{not json', 200)));
      expect((await broken.byBarcode('5')).status, FoodLookupStatus.failed);
    });
  });

  group('цепочка источников', () {
    test('первый найденный; сбой без находок — failed', () async {
      final found = OpenFoodFactsLookup(MockClient((_) async => _json({
            'status': 1,
            'product': {
              'product_name': 'A',
              'nutriments': {'energy-kcal_100g': 1},
            },
          })));
      final failing = OpenFoodFactsLookup(MockClient((_) async => throw http.ClientException('x')));
      expect((await ChainedFoodLookup([failing, found]).byBarcode('1')).status, FoodLookupStatus.found);
      expect((await ChainedFoodLookup([failing, const ServerFoodLookup()]).byBarcode('1')).status,
          FoodLookupStatus.failed);
      expect((await const ChainedFoodLookup([ServerFoodLookup()]).byBarcode('1')).status, FoodLookupStatus.notFound);
    });
  });
}
