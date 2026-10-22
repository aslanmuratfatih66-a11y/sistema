// Анализ фото через сервер (/api/v1/vision/..., SPEC §9.4). Все ответы — «оценка» (estimate: true).
// Ходим только через aiGatewayProvider. Фото — JPEG ≤1600px (image_picker уже сжимает); если файл всё же
// велик — уменьшаем средствами dart:ui (PNG), чтобы base64 уложился в лимит тела 4 МБ.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_api.dart';

/// Сырые байты картинки ≤ этого размера шлём как есть (base64 ×4/3 + JSON < 4 МБ).
const _maxRawBytes = 2900 * 1024;
const _maxSide = 1600;

double _n(Object? v) => v is num ? v.toDouble() : (v is String ? double.tryParse(v) ?? 0 : 0);
String _s(Object? v) => v is String ? v : '';
List<Map<String, dynamic>> _list(Object? v) => [
      if (v is List)
        for (final e in v)
          if (e is Map<String, dynamic>) e,
    ];

/// Готовит фото к отправке: base64 (JPEG/PNG), ≤ ~2.9 МБ.
Future<String> encodeVisionImage(String path) async => base64Encode(await prepareVisionImage(await File(path).readAsBytes()));

Future<Uint8List> prepareVisionImage(Uint8List bytes) async {
  if (bytes.length <= _maxRawBytes) return bytes;
  final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  final desc = await ui.ImageDescriptor.encoded(buffer);
  try {
    var side = _maxSide;
    while (true) {
      final landscape = desc.width >= desc.height;
      final codec = await desc.instantiateCodec(
        targetWidth: landscape ? (desc.width > side ? side : null) : null,
        targetHeight: landscape ? null : (desc.height > side ? side : null),
      );
      final frame = await codec.getNextFrame();
      final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      frame.image.dispose();
      codec.dispose();
      final out = data!.buffer.asUint8List();
      if (out.length <= _maxRawBytes || side <= 400) return out;
      side = (side * 0.7).round();
    }
  } finally {
    desc.dispose();
    buffer.dispose();
  }
}

// ---------- модели ответов ----------

@immutable
class BodyVisionResult {
  const BodyVisionResult({
    required this.fatMin,
    required this.fatMax,
    required this.muscle,
    required this.posture,
    required this.swelling,
    required this.notes,
    this.comparison,
  });

  factory BodyVisionResult.fromJson(Map<String, dynamic> j) {
    final f = j['body_fat_pct'];
    final fm = f is Map ? f : const {};
    final c = _s(j['comparison']);
    return BodyVisionResult(
      fatMin: _n(fm['min']),
      fatMax: _n(fm['max']),
      muscle: _s(j['muscle']),
      posture: [for (final p in (j['posture'] is List ? j['posture'] as List : const [])) if (p is String) p],
      swelling: _s(j['swelling']),
      notes: _s(j['notes']),
      comparison: c.isEmpty ? null : c,
    );
  }

  final double fatMin;
  final double fatMax;

  /// low / medium / high
  final String muscle;
  final List<String> posture;

  /// none / mild / noticeable
  final String swelling;
  final String notes;
  final String? comparison;

  /// Короткая сводка для сравнения на сервере (не локализуется — для модели).
  String get summary => 'body fat ${fatMin.round()}-${fatMax.round()}%, muscle $muscle, swelling $swelling'
      '${posture.isEmpty ? '' : ', posture: ${posture.join('; ')}'}';
}

@immutable
class SkinVisionResult {
  const SkinVisionResult({required this.skinType, required this.acneScore, required this.acneLabel, required this.notes});

  factory SkinVisionResult.fromJson(Map<String, dynamic> j) {
    final a = j['acne'];
    final am = a is Map ? a : const {};
    return SkinVisionResult(
      skinType: _s(j['skin_type']),
      acneScore: _n(am['score']),
      acneLabel: _s(am['label']),
      notes: _s(j['notes']),
    );
  }

  /// dry / normal / oily / combination / sensitive
  final String skinType;
  final double acneScore;
  final String acneLabel;
  final String notes;

  String get summary => 'skin $skinType, acne ${acneScore.toStringAsFixed(1)}/10';
}

@immutable
class FoodGuess {
  const FoodGuess({required this.name, required this.grams});

  final String name;
  final double grams;
}

@immutable
class FoodVisionResult {
  const FoodVisionResult({required this.items, required this.description});

  factory FoodVisionResult.fromJson(Map<String, dynamic> j) => FoodVisionResult(
        items: [
          for (final i in _list(j['items']))
            if (_s(i['name']).trim().isNotEmpty) FoodGuess(name: _s(i['name']).trim(), grams: _n(i['grams_est'])),
        ],
        description: _s(j['description']),
      );

  final List<FoodGuess> items;
  final String description;
}

/// КБЖУ (на 100 г, на позицию или итог — по месту).
@immutable
class VisionMacros {
  const VisionMacros({this.kcal = 0, this.protein = 0, this.fat = 0, this.carbs = 0});

  factory VisionMacros.fromJson(Object? j) {
    final m = j is Map ? j : const {};
    return VisionMacros(kcal: _n(m['kcal']), protein: _n(m['protein']), fat: _n(m['fat']), carbs: _n(m['carbs']));
  }

  final double kcal;
  final double protein;
  final double fat;
  final double carbs;

  VisionMacros scale(double k) => VisionMacros(kcal: kcal * k, protein: protein * k, fat: fat * k, carbs: carbs * k);
  VisionMacros operator +(VisionMacros o) =>
      VisionMacros(kcal: kcal + o.kcal, protein: protein + o.protein, fat: fat + o.fat, carbs: carbs + o.carbs);
}

@immutable
class FoodLookupResult {
  const FoodLookupResult({
    required this.name,
    required this.per100,
    this.servingGrams,
    this.servingLabel,
    required this.sourceTitle,
    required this.sourceUrl,
    required this.cached,
  });

  factory FoodLookupResult.fromJson(Map<String, dynamic> j) {
    final sv = j['serving'];
    final src = j['source'];
    final srcM = src is Map ? src : const {};
    final g = sv is Map ? _n(sv['grams']) : 0.0;
    return FoodLookupResult(
      name: _s(j['name']),
      per100: VisionMacros.fromJson(j['per100']),
      servingGrams: g > 0 ? g : null,
      servingLabel: sv is Map && _s(sv['label']).isNotEmpty ? _s(sv['label']) : null,
      sourceTitle: _s(srcM['title']),
      sourceUrl: _s(srcM['url']),
      cached: j['cached'] == true,
    );
  }

  final String name;
  final VisionMacros per100;
  final double? servingGrams;
  final String? servingLabel;
  final String sourceTitle;
  final String sourceUrl;
  final bool cached;
}

@immutable
class EstimatedItem {
  const EstimatedItem({required this.name, required this.grams, required this.macros});

  final String name;
  final double grams;

  /// На [grams] целиком.
  final VisionMacros macros;

  /// Пересчёт на другие граммы (пропорционально оценке).
  EstimatedItem withGrams(double g) =>
      EstimatedItem(name: name, grams: g, macros: grams > 0 ? macros.scale(g / grams) : macros);
}

@immutable
class FoodEstimateResult {
  const FoodEstimateResult({required this.items});

  factory FoodEstimateResult.fromJson(Map<String, dynamic> j) => FoodEstimateResult(items: [
        for (final i in _list(j['items']))
          EstimatedItem(name: _s(i['name']), grams: _n(i['grams']), macros: VisionMacros.fromJson(i)),
      ]);

  final List<EstimatedItem> items;
}

@immutable
class ReceiptLine {
  const ReceiptLine({required this.name, required this.qty, required this.price});

  final String name;
  final double qty;
  final double price;
}

@immutable
class ReceiptResult {
  const ReceiptResult({
    required this.store,
    this.date,
    required this.currency,
    required this.items,
    required this.total,
    this.photoId,
  });

  factory ReceiptResult.fromJson(Map<String, dynamic> j) => ReceiptResult(
        store: _s(j['store']),
        date: DateTime.tryParse(_s(j['date'])),
        currency: _s(j['currency']).isEmpty ? 'RUB' : _s(j['currency']),
        items: [for (final i in _list(j['items'])) ReceiptLine(name: _s(i['name']), qty: _n(i['qty']), price: _n(i['price']))],
        total: _n(j['total']),
      );

  final String store;
  final DateTime? date;
  final String currency;
  final List<ReceiptLine> items;
  final double total;

  /// Photos.id сохранённого фото чека (заполняет showReceiptFlow).
  final String? photoId;

  ReceiptResult withPhoto(String? id) =>
      ReceiptResult(store: store, date: date, currency: currency, items: items, total: total, photoId: id);
}

/// Ответ с исходным JSON (сохраняется в PhotoAnalyses.result).
@immutable
class VisionReply<T> {
  const VisionReply(this.value, this.raw);

  final T value;
  final Map<String, dynamic> raw;
}

// ---------- клиент ----------

class VisionApi {
  VisionApi(this._gw);

  final AiGateway _gw;

  Future<VisionReply<T>> _post<T>(String path, Map<String, Object?> body, T Function(Map<String, dynamic>) parse) async {
    final raw = await _gw.json('POST', '/api/v1/vision/$path', body: body);
    return VisionReply(parse(raw), raw);
  }

  Future<VisionReply<BodyVisionResult>> body(String imageB64, String lang,
          {List<({DateTime at, String summary})> previous = const []}) =>
      _post('body', {
        'image': imageB64,
        'lang': lang,
        if (previous.isNotEmpty)
          'previous': [
            for (final p in previous) {'at': p.at.toUtc().toIso8601String().substring(0, 10), 'summary': p.summary},
          ],
      }, BodyVisionResult.fromJson);

  Future<VisionReply<SkinVisionResult>> skin(String imageB64, String lang) =>
      _post('skin', {'image': imageB64, 'lang': lang}, SkinVisionResult.fromJson);

  Future<VisionReply<FoodVisionResult>> food(String imageB64, String lang) =>
      _post('food', {'image': imageB64, 'lang': lang}, FoodVisionResult.fromJson);

  Future<VisionReply<FoodLookupResult>> lookup(String name, String lang, {String? place}) => _post(
      'food/lookup',
      {'name': name, 'lang': lang, if (place != null && place.trim().isNotEmpty) 'place': place.trim()},
      FoodLookupResult.fromJson);

  Future<VisionReply<FoodEstimateResult>> estimate(List<FoodGuess> items, String lang, {String? imageB64}) => _post(
      'food/estimate',
      {
        'image': ?imageB64,
        'items': [for (final i in items) {'name': i.name, 'grams': i.grams}],
        'lang': lang,
      },
      FoodEstimateResult.fromJson);

  Future<VisionReply<ReceiptResult>> receipt(String imageB64, String lang) =>
      _post('receipt', {'image': imageB64, 'lang': lang}, ReceiptResult.fromJson);
}

final visionApiProvider = Provider<VisionApi>((ref) => VisionApi(ref.watch(aiGatewayProvider)));
