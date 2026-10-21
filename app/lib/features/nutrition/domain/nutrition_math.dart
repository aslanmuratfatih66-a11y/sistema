// Расчёты питания (SPEC §8.2): КБЖУ по граммам, рецепты на порцию, итоги дня, норма воды.
// Чистые функции — без БД и Flutter, покрыты юнит-тестами.
import 'package:flutter/foundation.dart';

import '../../../core/models/daily.dart';

/// Калории и БЖУ (граммы).
@immutable
class Macros {
  const Macros({this.kcal = 0, this.protein = 0, this.fat = 0, this.carbs = 0});

  final double kcal;
  final double protein;
  final double fat;
  final double carbs;

  static const zero = Macros();

  Macros operator +(Macros o) =>
      Macros(kcal: kcal + o.kcal, protein: protein + o.protein, fat: fat + o.fat, carbs: carbs + o.carbs);

  Macros scale(double k) => Macros(kcal: kcal * k, protein: protein * k, fat: fat * k, carbs: carbs * k);

  /// Значения на 100 г × [grams].
  Macros forGrams(double grams) => scale(grams / 100);

  /// Пересчёт «на всю порцию [grams] г» → «на 100 г». grams ≤ 0 — как есть.
  Macros per100From(double grams) => grams > 0 ? scale(100 / grams) : this;

  /// Округление до 0.1 (для хранения и показа).
  Macros rounded() => Macros(kcal: round1(kcal), protein: round1(protein), fat: round1(fat), carbs: round1(carbs));

  static Macros sum(Iterable<Macros> items) => items.fold(zero, (a, b) => a + b);

  @override
  bool operator ==(Object other) =>
      other is Macros && other.kcal == kcal && other.protein == protein && other.fat == fat && other.carbs == carbs;

  @override
  int get hashCode => Object.hash(kcal, protein, fat, carbs);

  @override
  String toString() => 'Macros($kcal ккал, Б $protein, Ж $fat, У $carbs)';
}

double round1(double v) => (v * 10).roundToDouble() / 10;

/// Локальная полночь даты (ключ дня).
DateTime dayStart(DateTime t) => DateTime(t.year, t.month, t.day);

/// Следующая локальная полночь (корректно при переходе на летнее время).
DateTime nextDayStart(DateTime t) => DateTime(t.year, t.month, t.day + 1);

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// Рецепт: [total] на всё блюдо из [servings] порций → [portions] порций.
Macros recipePortion(Macros total, int servings, double portions) =>
    total.scale(portions / (servings <= 0 ? 1 : servings));

/// Сводка дня по записям дневника и воды. [mealTypes] — типы приёмов пищи записей.
/// «Приёмов пищи» = число разных типов (завтрак/обед/ужин/перекус), а не записей.
NutritionDay buildNutritionDay({
  required Iterable<Macros> entries,
  required Iterable<String> mealTypes,
  required Iterable<int> waterMl,
}) {
  final m = Macros.sum(entries);
  return NutritionDay(
    kcal: m.kcal,
    protein: m.protein,
    fat: m.fat,
    carbs: m.carbs,
    waterMl: waterMl.fold(0, (a, b) => a + b),
    meals: mealTypes.toSet().length,
  );
}

/// Норма воды на день: в день тренировки — [trainingDayMl], если задана; иначе [baseMl].
int? waterGoalMl({int? baseMl, int? trainingDayMl, required bool trainingDay}) =>
    trainingDay ? (trainingDayMl ?? baseMl) : baseMl;

/// Доля выполнения (0..1); норма неизвестна — null.
double? progressOf(num value, num? goal) => goal == null || goal <= 0 ? null : (value / goal).clamp(0, 1).toDouble();
