// «Мои рецепты» (таблица Recipes): состав JSON и итоги КБЖУ на всё блюдо; в дневник — порциями.
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../core/db/database.dart';
import '../domain/nutrition_math.dart';

/// Строка состава: продукт из «моих продуктов» с граммами или ручная строка (КБЖУ на строку целиком).
@immutable
class RecipeItem {
  const RecipeItem({this.foodItemId, required this.title, this.grams, required this.macros});

  final String? foodItemId;
  final String title;
  final double? grams;

  /// КБЖУ строки целиком (для продукта — уже × граммы).
  final Macros macros;

  Map<String, Object?> toJson() => {
        if (foodItemId != null) 'foodItemId': foodItemId,
        'title': title,
        if (grams != null) 'grams': grams,
        'kcal': macros.kcal,
        'protein': macros.protein,
        'fat': macros.fat,
        'carbs': macros.carbs,
      };

  static RecipeItem? fromJson(Object? j) {
    if (j is! Map<String, Object?>) return null;
    double n(Object? v) => v is num ? v.toDouble() : 0;
    return RecipeItem(
      foodItemId: j['foodItemId'] as String?,
      title: j['title'] as String? ?? '',
      grams: j['grams'] is num ? (j['grams'] as num).toDouble() : null,
      macros: Macros(kcal: n(j['kcal']), protein: n(j['protein']), fat: n(j['fat']), carbs: n(j['carbs'])),
    );
  }

  static List<RecipeItem> decodeList(String json) {
    try {
      final v = jsonDecode(json);
      if (v is! List) return const [];
      return [for (final e in v) ?fromJson(e)];
    } on FormatException {
      return const [];
    }
  }
}

/// Рецепт (модель экрана).
@immutable
class Recipe {
  const Recipe({required this.id, required this.title, required this.items, required this.servings, required this.total});

  factory Recipe.fromRow(RecipeRow r) => Recipe(
        id: r.id,
        title: r.title,
        items: RecipeItem.decodeList(r.items),
        servings: r.servings < 1 ? 1 : r.servings,
        total: Macros(kcal: r.kcal, protein: r.protein, fat: r.fat, carbs: r.carbs),
      );

  final String id;
  final String title;
  final List<RecipeItem> items;
  final int servings;

  /// На всё блюдо.
  final Macros total;

  Macros get perServing => recipePortion(total, servings, 1);
  Macros portions(double n) => recipePortion(total, servings, n);
}

class RecipeRepository {
  RecipeRepository(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  Stream<List<Recipe>> watchAll() => (_db.select(_db.recipes)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.title)]))
      .watch()
      .map((rows) => rows.map(Recipe.fromRow).toList());

  Future<Recipe?> byId(String id) async {
    final r = await (_db.select(_db.recipes)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    return r == null ? null : Recipe.fromRow(r);
  }

  /// Создать ([id] == null) или обновить. Итоги пересчитываются из состава.
  Future<String> save({String? id, required String title, required List<RecipeItem> items, required int servings}) async {
    final total = Macros.sum(items.map((i) => i.macros)).rounded();
    final json = jsonEncode([for (final i in items) i.toJson()]);
    final deviceId = await _db.deviceId();
    final now = _clock().toUtc();
    final s = servings < 1 ? 1 : servings;
    return _db.transaction(() async {
      final existing = id == null
          ? null
          : await (_db.select(_db.recipes)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing != null) {
        await (_db.update(_db.recipes)..where((t) => t.id.equals(existing.id))).write(RecipesCompanion(
              title: Value(title.trim()),
              items: Value(json),
              servings: Value(s),
              kcal: Value(total.kcal),
              protein: Value(total.protein),
              fat: Value(total.fat),
              carbs: Value(total.carbs),
              updatedAt: Value(now),
              deviceId: Value(deviceId),
              version: Value(existing.version + 1),
            ));
        return existing.id;
      }
      final maxOrder = _db.recipes.sortOrder.max();
      final row = await (_db.selectOnly(_db.recipes)..addColumns([maxOrder])).getSingle();
      final newRowId = newId();
      await _db.into(_db.recipes).insert(RecipesCompanion.insert(
            id: newRowId,
            updatedAt: now,
            deviceId: deviceId,
            title: title.trim(),
            items: Value(json),
            servings: Value(s),
            kcal: Value(total.kcal),
            protein: Value(total.protein),
            fat: Value(total.fat),
            carbs: Value(total.carbs),
            sortOrder: Value((row.read(maxOrder) ?? -1) + 1),
          ));
      return newRowId;
    });
  }

  Future<void> softDelete(String id) async {
    final deviceId = await _db.deviceId();
    final now = _clock().toUtc();
    await _db.transaction(() async {
      final row = await (_db.select(_db.recipes)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null) return;
      await (_db.update(_db.recipes)..where((t) => t.id.equals(id))).write(RecipesCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
            deviceId: Value(deviceId),
            version: Value(row.version + 1),
          ));
    });
  }
}
