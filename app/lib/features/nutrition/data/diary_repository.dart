// Дневник питания (таблица MealEntries). КБЖУ копируются в запись (правка продукта не меняет прошлое).
// Удаление — мягкое (deletedAt), поля синхронизации: updatedAt (UTC), deviceId, version+1.
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../domain/quests/section_hooks.dart';
import '../domain/nutrition_math.dart';

/// Черновик записи дневника.
@immutable
class MealDraft {
  const MealDraft({
    required this.eatenAt,
    required this.mealType,
    required this.title,
    required this.macros,
    this.grams,
    this.foodItemId,
    this.recipeId,
    this.photoId,
  });

  final DateTime eatenAt;
  final MealType mealType;
  final String title;
  final Macros macros;

  /// null — ввод «порцией» без веса.
  final double? grams;
  final String? foodItemId;
  final String? recipeId;
  final String? photoId;
}

extension MealEntryMacros on MealEntryRow {
  Macros get macros => Macros(kcal: kcal, protein: protein, fat: fat, carbs: carbs);
  MealType get type => enumByName(MealType.values, mealType) ?? MealType.snack;
}

class DiaryRepository {
  DiaryRepository(this._db, {DateTime Function()? clock, this.hooks = const NoopSectionQuestHooks()})
      : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;
  /// Связь с движком квестов (ошибки движка не пробрасываются).
  final SectionQuestHooks hooks;

  SimpleSelectStatement<$MealEntriesTable, MealEntryRow> _day(DateTime day) => _db.select(_db.mealEntries)
    ..where((t) =>
        t.deletedAt.isNull() &
        t.eatenAt.isBiggerOrEqualValue(dayStart(day)) &
        t.eatenAt.isSmallerThanValue(nextDayStart(day)))
    ..orderBy([(t) => OrderingTerm.asc(t.eatenAt)]);

  /// Записи дня [day] (любой момент дня), по времени.
  Stream<List<MealEntryRow>> watchDay(DateTime day) => _day(day).watch();

  Future<List<MealEntryRow>> getDay(DateTime day) => _day(day).get();

  Future<MealEntryRow?> byId(String id) =>
      (_db.select(_db.mealEntries)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();

  Future<String> add(MealDraft d) async {
    final id = newId();
    final m = d.macros.rounded();
    await _db.into(_db.mealEntries).insert(MealEntriesCompanion.insert(
          id: id,
          updatedAt: _clock().toUtc(),
          deviceId: await _db.deviceId(),
          eatenAt: d.eatenAt,
          mealType: d.mealType.name,
          title: d.title.trim(),
          foodItemId: Value(d.foodItemId),
          recipeId: Value(d.recipeId),
          grams: Value(d.grams),
          kcal: m.kcal,
          protein: Value(m.protein),
          fat: Value(m.fat),
          carbs: Value(m.carbs),
          photoId: Value(d.photoId),
        ));
    final now = _clock();
    if (sameDay(d.eatenAt, now)) {
      try {
        final types = (await getDay(now)).map((r) => r.mealType).toSet();
        await hooks.mealLogged(mealsToday: types.length, at: d.eatenAt);
      } catch (e) {
        debugPrint('DiaryRepository: хук квестов: $e');
      }
    }
    return id;
  }

  Future<void> update(String id, MealDraft d) {
    final m = d.macros.rounded();
    return _patch(
      id,
      MealEntriesCompanion(
        eatenAt: Value(d.eatenAt),
        mealType: Value(d.mealType.name),
        title: Value(d.title.trim()),
        foodItemId: Value(d.foodItemId),
        recipeId: Value(d.recipeId),
        grams: Value(d.grams),
        kcal: Value(m.kcal),
        protein: Value(m.protein),
        fat: Value(m.fat),
        carbs: Value(m.carbs),
        photoId: Value(d.photoId),
      ),
    );
  }

  Future<void> softDelete(String id) => _patch(id, MealEntriesCompanion(deletedAt: Value(_clock().toUtc())));

  Future<void> _patch(String id, MealEntriesCompanion patch) async {
    final deviceId = await _db.deviceId();
    await _db.transaction(() async {
      final row = await (_db.select(_db.mealEntries)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null) return;
      await (_db.update(_db.mealEntries)..where((t) => t.id.equals(id))).write(patch.copyWith(
            updatedAt: Value(_clock().toUtc()),
            deviceId: Value(deviceId),
            version: Value(row.version + 1),
          ));
    });
  }
}
