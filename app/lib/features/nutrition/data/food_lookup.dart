// Поиск продукта по штрихкоду во внешних базах (SPEC §8.2).
// Open Food Facts API v2 — сейчас; своя база на сервере — этап 5 (ServerFoodLookup, TODO).
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/models/enums.dart';

/// Продукт из внешней базы (значения на 100 г).
@immutable
class FoodProduct {
  const FoodProduct({
    required this.barcode,
    required this.name,
    this.brand,
    required this.kcal100,
    this.protein100 = 0,
    this.fat100 = 0,
    this.carbs100 = 0,
    this.servingG,
    required this.source,
  });

  final String barcode;
  final String name;
  final String? brand;
  final double kcal100;
  final double protein100;
  final double fat100;
  final double carbs100;
  final double? servingG;
  final FoodSource source;
}

enum FoodLookupStatus { found, notFound, failed }

/// Итог поиска: найден / нет в базе / ошибка сети или ответа.
@immutable
class FoodLookupResult {
  const FoodLookupResult.found(FoodProduct this.product) : status = FoodLookupStatus.found;
  const FoodLookupResult.notFound()
      : status = FoodLookupStatus.notFound,
        product = null;
  const FoodLookupResult.failed()
      : status = FoodLookupStatus.failed,
        product = null;

  final FoodLookupStatus status;
  final FoodProduct? product;
}

abstract interface class FoodLookup {
  Future<FoodLookupResult> byBarcode(String barcode);
}

/// Open Food Facts API v2. [preferLang] — 'ru'/'tr': сначала локализованное название.
class OpenFoodFactsLookup implements FoodLookup {
  OpenFoodFactsLookup(this._client, {this.preferLang, this.timeout = const Duration(seconds: 10)});

  final http.Client _client;
  final String? preferLang;
  final Duration timeout;

  /// OFF просит указывать приложение в User-Agent.
  static const userAgent = 'Sistema/1.0 (personal app)';
  static const fields = 'product_name,product_name_ru,product_name_tr,brands,nutriments,serving_size';

  static Uri uriFor(String barcode) => Uri.parse(
      'https://world.openfoodfacts.org/api/v2/product/${Uri.encodeComponent(barcode)}.json?fields=$fields');

  @override
  Future<FoodLookupResult> byBarcode(String barcode) async {
    final code = barcode.trim();
    if (code.isEmpty) return const FoodLookupResult.notFound();
    try {
      final res = await _client.get(uriFor(code), headers: const {'User-Agent': userAgent}).timeout(timeout);
      // OFF отвечает 404 со status 0 на неизвестный штрихкод.
      if (res.statusCode == 404) return const FoodLookupResult.notFound();
      if (res.statusCode != 200) return const FoodLookupResult.failed();
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      if (body is! Map<String, Object?>) return const FoodLookupResult.failed();
      return parse(code, body, preferLang: preferLang);
    } on Exception {
      // Нет сети (ClientException/SocketException), таймаут, битый JSON.
      return const FoodLookupResult.failed();
    }
  }

  /// Разбор ответа v2. Нет продукта (status 0) или нет калорий — «не найден»
  /// (пользователь введёт вручную); отсутствующие БЖУ — 0.
  @visibleForTesting
  static FoodLookupResult parse(String barcode, Map<String, Object?> body, {String? preferLang}) {
    final status = body['status'];
    final product = body['product'];
    if (status == 0 || status == '0' || product is! Map<String, Object?>) return const FoodLookupResult.notFound();
    final n = product['nutriments'];
    final nutr = n is Map<String, Object?> ? n : const <String, Object?>{};
    var kcal = _num(nutr['energy-kcal_100g']);
    if (kcal == null) {
      final kj = _num(nutr['energy-kj_100g']) ?? _num(nutr['energy_100g']);
      if (kj != null) kcal = kj / 4.184;
    }
    final name = _name(product, preferLang);
    if (kcal == null || name == null) return const FoodLookupResult.notFound();
    final brands = _str(product['brands']);
    return FoodLookupResult.found(FoodProduct(
      barcode: barcode,
      name: name,
      brand: brands?.split(',').first.trim(),
      kcal100: kcal,
      protein100: _num(nutr['proteins_100g']) ?? 0,
      fat100: _num(nutr['fat_100g']) ?? 0,
      carbs100: _num(nutr['carbohydrates_100g']) ?? 0,
      servingG: _servingGrams(_str(product['serving_size'])),
      source: FoodSource.openFoodFacts,
    ));
  }

  static String? _name(Map<String, Object?> p, String? lang) {
    final keys = [if (lang != null) 'product_name_$lang', 'product_name', 'product_name_ru', 'product_name_tr'];
    for (final k in keys) {
      final s = _str(p[k]);
      if (s != null) return s;
    }
    return null;
  }

  static String? _str(Object? v) {
    if (v is! String) return null;
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  static double? _num(Object? v) => switch (v) {
        final num n => n.toDouble(),
        final String s => double.tryParse(s.replaceAll(',', '.')),
        _ => null,
      };

  /// «30 g», «250 ml», «1 bar (45 g)» → граммы (мл считаем как граммы).
  static double? _servingGrams(String? s) {
    if (s == null) return null;
    final m = RegExp(r'(\d+(?:[.,]\d+)?)\s*(g|gr|г|ml|мл)\b', caseSensitive: false).firstMatch(s);
    if (m == null) return null;
    final v = double.tryParse(m.group(1)!.replaceAll(',', '.'));
    return v == null || v <= 0 ? null : v;
  }
}

/// Своя база продуктов на сервере (SPEC §8.2, §10).
// TODO(этап 5): GET /foods/barcode/{code} на сервере «Системы» (кэш найденного ИИ и пользователями).
class ServerFoodLookup implements FoodLookup {
  const ServerFoodLookup();

  @override
  Future<FoodLookupResult> byBarcode(String barcode) async => const FoodLookupResult.notFound();
}

/// Цепочка источников: первый найденный; если все «не найден», но был сбой — failed.
class ChainedFoodLookup implements FoodLookup {
  const ChainedFoodLookup(this.sources);

  final List<FoodLookup> sources;

  @override
  Future<FoodLookupResult> byBarcode(String barcode) async {
    var failed = false;
    for (final s in sources) {
      final r = await s.byBarcode(barcode);
      if (r.status == FoodLookupStatus.found) return r;
      if (r.status == FoodLookupStatus.failed) failed = true;
    }
    return failed ? const FoodLookupResult.failed() : const FoodLookupResult.notFound();
  }
}
