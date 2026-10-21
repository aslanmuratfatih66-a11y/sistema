// Мои продукты (таблица FoodItems, значения на 100 г) и поиск по штрихкоду:
// локальная база (кэш) → внешние источники (Open Food Facts; сервер — этап 5) → сохранение в FoodItems.
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../domain/nutrition_math.dart';
import 'food_lookup.dart';

/// Черновик продукта (ручной ввод или из внешней базы).
@immutable
class FoodDraft {
  const FoodDraft({
    required this.name,
    this.brand,
    this.barcode,
    required this.per100,
    this.servingG,
    this.source = FoodSource.manual,
  });

  factory FoodDraft.fromProduct(FoodProduct p) => FoodDraft(
        name: p.name,
        brand: p.brand,
        barcode: p.barcode,
        per100: Macros(kcal: p.kcal100, protein: p.protein100, fat: p.fat100, carbs: p.carbs100),
        servingG: p.servingG,
        source: p.source,
      );

  final String name;
  final String? brand;
  final String? barcode;
  final Macros per100;
  final double? servingG;
  final FoodSource source;
}

extension FoodRowMacros on FoodItemRow {
  Macros get per100 => Macros(kcal: kcal100, protein: protein100, fat: fat100, carbs: carbs100);
}

class FoodRepository {
  FoodRepository(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  Future<FoodItemRow?> byId(String id) =>
      (_db.select(_db.foodItems)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();

  /// Последний сохранённый продукт с этим штрихкодом.
  Future<FoodItemRow?> byBarcode(String barcode) => (_db.select(_db.foodItems)
        ..where((t) => t.barcode.equals(barcode.trim()) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
        ..limit(1))
      .getSingleOrNull();

  /// Поиск по названию/бренду/штрихкоду (без учёта регистра); пустой запрос — все. Избранные сверху.
  /// Фильтр — в Dart: lower() в SQLite не понимает кириллицу и турецкие буквы (база личная, небольшая).
  Stream<List<FoodItemRow>> watchSearch(String query, {int limit = 100}) {
    final q = query.trim().toLowerCase();
    final sel = _db.select(_db.foodItems)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.favorite), (t) => OrderingTerm.asc(t.name)]);
    bool match(FoodItemRow f) =>
        q.isEmpty ||
        f.name.toLowerCase().contains(q) ||
        (f.brand?.toLowerCase().contains(q) ?? false) ||
        f.barcode == q;
    return sel.watch().map((rows) => rows.where(match).take(limit).toList());
  }

  Future<List<FoodItemRow>> search(String query, {int limit = 100}) => watchSearch(query, limit: limit).first;

  /// Новый продукт или обновление продукта с тем же штрихкодом.
  Future<String> save(FoodDraft d) async {
    final deviceId = await _db.deviceId();
    final now = _clock().toUtc();
    final per100 = d.per100.rounded();
    final barcode = d.barcode?.trim();
    return _db.transaction(() async {
      final existing = barcode == null || barcode.isEmpty ? null : await byBarcode(barcode);
      if (existing != null) {
        await (_db.update(_db.foodItems)..where((t) => t.id.equals(existing.id))).write(FoodItemsCompanion(
              name: Value(d.name.trim()),
              brand: Value(d.brand),
              kcal100: Value(per100.kcal),
              protein100: Value(per100.protein),
              fat100: Value(per100.fat),
              carbs100: Value(per100.carbs),
              servingG: Value(d.servingG),
              source: Value(d.source.name),
              updatedAt: Value(now),
              deviceId: Value(deviceId),
              version: Value(existing.version + 1),
            ));
        return existing.id;
      }
      final id = newId();
      await _db.into(_db.foodItems).insert(FoodItemsCompanion.insert(
            id: id,
            updatedAt: now,
            deviceId: deviceId,
            name: d.name.trim(),
            brand: Value(d.brand),
            barcode: Value(barcode == null || barcode.isEmpty ? null : barcode),
            kcal100: per100.kcal,
            protein100: Value(per100.protein),
            fat100: Value(per100.fat),
            carbs100: Value(per100.carbs),
            servingG: Value(d.servingG),
            source: Value(d.source.name),
          ));
      return id;
    });
  }

  Future<void> setFavorite(String id, bool favorite) => _patch(id, FoodItemsCompanion(favorite: Value(favorite)));

  Future<void> softDelete(String id) => _patch(id, FoodItemsCompanion(deletedAt: Value(_clock().toUtc())));

  Future<void> _patch(String id, FoodItemsCompanion patch) async {
    final deviceId = await _db.deviceId();
    await _db.transaction(() async {
      final row = await (_db.select(_db.foodItems)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null) return;
      await (_db.update(_db.foodItems)..where((t) => t.id.equals(id))).write(patch.copyWith(
            updatedAt: Value(_clock().toUtc()),
            deviceId: Value(deviceId),
            version: Value(row.version + 1),
          ));
    });
  }
}

enum BarcodeOutcome { cached, fetched, notFound, offline }

/// Итог сканирования: продукт есть ([food]) или нужен ручной ввод.
@immutable
class BarcodeResult {
  const BarcodeResult(this.outcome, {this.food});
  final BarcodeOutcome outcome;
  final FoodItemRow? food;
}

/// Штрихкод → продукт: сначала локальная FoodItems (кэш), затем [lookup]; найденное сохраняется.
class BarcodeFoodService {
  BarcodeFoodService(this._repo, this._lookup);

  final FoodRepository _repo;
  final FoodLookup _lookup;

  Future<BarcodeResult> resolve(String barcode) async {
    final code = barcode.trim();
    final cached = await _repo.byBarcode(code);
    if (cached != null) return BarcodeResult(BarcodeOutcome.cached, food: cached);
    final r = await _lookup.byBarcode(code);
    switch (r.status) {
      case FoodLookupStatus.found:
        final id = await _repo.save(FoodDraft.fromProduct(r.product!));
        return BarcodeResult(BarcodeOutcome.fetched, food: await _repo.byId(id));
      case FoodLookupStatus.notFound:
        return const BarcodeResult(BarcodeOutcome.notFound);
      case FoodLookupStatus.failed:
        return const BarcodeResult(BarcodeOutcome.offline);
    }
  }
}
