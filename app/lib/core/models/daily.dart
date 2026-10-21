// Сводки дня, общие для разделов этапа 3 и «Статуса». КОНТРАКТ каркаса (правит главный агент).
// Кто считает: питание/вода — A (features/nutrition), шаги/расход — B (core/activity),
// сон — C (features/body), тренировки — D (features/workouts).
import 'package:flutter/foundation.dart';

/// Съеденное и выпитое за день (сумма дневника питания и WaterLogs).
@immutable
class NutritionDay {
  const NutritionDay({
    this.kcal = 0,
    this.protein = 0,
    this.fat = 0,
    this.carbs = 0,
    this.waterMl = 0,
    this.meals = 0,
  });

  final double kcal;
  final double protein;
  final double fat;
  final double carbs;
  final int waterMl;

  /// Сколько приёмов пищи записано (для квеста «meals»).
  final int meals;

  static const empty = NutritionDay();
}

/// Шаги за день (лучшее из источников).
@immutable
class StepDay {
  const StepDay({required this.day, required this.steps, this.distanceM, this.floors});

  /// Локальная полночь.
  final DateTime day;
  final int steps;
  final double? distanceM;
  final int? floors;
}

/// Потраченные калории за день (SPEC §8.3): базовый обмен (Миффлин–Сан Жеор) + шаги + тренировки.
@immutable
class DailyEnergy {
  const DailyEnergy({this.bmr, this.stepsKcal = 0, this.workoutKcal = 0});

  /// null — нет данных профиля (пол/возраст/рост/вес).
  final double? bmr;
  final double stepsKcal;
  final double workoutKcal;

  double get activeKcal => stepsKcal + workoutKcal;
  double? get totalKcal => bmr == null ? null : bmr! + activeKcal;
}

/// Сон за ночь, закончившуюся утром [day].
@immutable
class SleepDay {
  const SleepDay({required this.day, required this.bedAt, required this.wakeAt, this.quality});

  final DateTime day;
  final DateTime bedAt;
  final DateTime wakeAt;
  final int? quality;

  Duration get duration => wakeAt.difference(bedAt);
}
