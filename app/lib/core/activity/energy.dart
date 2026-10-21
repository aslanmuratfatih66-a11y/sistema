// Расход энергии за день (SPEC §8.3): базовый обмен (Миффлин–Сан Жеор) + шаги + тренировки.
import 'package:drift/drift.dart';

import '../../features/plan/norms/plan_calculator.dart';
import '../db/database.dart';
import '../models/daily.dart';
import '../models/enums.dart';
import 'step_repository.dart';

/// Формулы расхода. Источник — уравнение ходьбы ACSM (Guidelines for Exercise Testing, гл. 7):
///   VO2 = 0.1·скорость (горизонталь) + 1.8·скорость·уклон (вертикаль) + 3.5 (покой), мл O2/кг/мин.
/// Покой (3.5) уже учтён в BMR, поэтому берём только «чистую» часть; 1 л O2 ≈ 5 ккал.
///   Горизонталь: 0.1 мл/кг на метр → 0.0005 ккал/кг/м = 0.5 ккал/кг/км.
///   Вертикаль:   1.8 мл/кг на метр подъёма → 0.009 ккал/кг/м; этаж ≈ 3 м → 0.027 ккал/кг.
/// Нет дистанции от счётчика — длина шага ≈ 0.415·рост (известная оценка для ходьбы), без роста — 0.75 м.
/// Пример: 8000 шагов, 70 кг, 175 см → шаг 0.73 м, 5.8 км → ≈ 203 ккал.
abstract final class EnergyCalc {
  static const double kcalPerKgPerMeter = 0.0005;
  static const double kcalPerKgPerFloor = 0.027;
  static const double strideHeightRatio = 0.415;
  static const double defaultStrideM = 0.75;

  /// Вес, если замеров нет (только для оценки шагов; BMR без веса не считается).
  static const double defaultWeightKg = 70;

  static double strideM(double? heightCm) =>
      heightCm == null || heightCm <= 0 ? defaultStrideM : heightCm / 100 * strideHeightRatio;

  /// Активный расход на ходьбу (сверх базового обмена), ккал.
  static double stepsKcal({required int steps, double? distanceM, int? floors, double? weightKg, double? heightCm}) {
    if (steps <= 0 && (distanceM ?? 0) <= 0) return 0;
    final kg = weightKg == null || weightKg <= 0 ? defaultWeightKg : weightKg;
    final meters = distanceM != null && distanceM > 0 ? distanceM : steps * strideM(heightCm);
    final vertical = (floors ?? 0) * kcalPerKgPerFloor * kg;
    return meters * kcalPerKgPerMeter * kg + vertical;
  }

  /// BMR на дату [day]; null — не хватает данных профиля или веса.
  static double? bmr({Sex? sex, DateTime? birthDate, double? heightCm, double? weightKg, required DateTime day}) {
    if (sex == null || birthDate == null || heightCm == null || weightKg == null) return null;
    if (heightCm <= 0 || weightKg <= 0) return null;
    final age = PlanCalculator.ageOn(birthDate, day);
    if (age <= 0) return null;
    return PlanCalculator.bmr(sex: sex, weightKg: weightKg, heightCm: heightCm, age: age);
  }

  static DailyEnergy daily({
    required DateTime day,
    ProfileRow? profile,
    double? weightKg,
    StepDay? steps,
    double workoutKcal = 0,
  }) {
    final sex = Sex.values.where((s) => s.name == profile?.sex).firstOrNull;
    final height = profile?.heightCm;
    return DailyEnergy(
      bmr: bmr(sex: sex, birthDate: profile?.birthDate, heightCm: height, weightKg: weightKg, day: day),
      stepsKcal: steps == null
          ? 0
          : stepsKcal(
              steps: steps.steps,
              distanceM: steps.distanceM,
              floors: steps.floors,
              weightKg: weightKg,
              heightCm: height,
            ),
      workoutKcal: workoutKcal,
    );
  }
}

/// Чтение данных для расхода: вес на дату и ккал тренировок за день.
class EnergyRepository {
  EnergyRepository(this._db);

  final AppDatabase _db;

  /// Вес на дату: последний замер с весом до конца дня; если таких нет — самый ранний после.
  Stream<double?> watchWeightOn(DateTime day) {
    final end = nextLocalDay(day);
    final q = _db.select(_db.bodyMeasurements)
      ..where((t) => t.deletedAt.isNull() & t.weightKg.isNotNull())
      ..orderBy([(t) => OrderingTerm.asc(t.measuredAt)]);
    return q.watch().map((rows) {
      if (rows.isEmpty) return null;
      final before = rows.where((r) => r.measuredAt.isBefore(end));
      return (before.isNotEmpty ? before.last : rows.first).weightKg;
    });
  }

  /// Сумма ккал тренировок, начатых в этот день (прерванные — тоже: kcal пишется за сделанное).
  Stream<double> watchWorkoutKcal(DateTime day) {
    final start = localDay(day);
    final end = nextLocalDay(day);
    final q = _db.select(_db.workoutSessions)
      ..where((t) =>
          t.deletedAt.isNull() &
          t.startedAt.isBiggerOrEqualValue(start) &
          t.startedAt.isSmallerThanValue(end));
    return q.watch().map((rows) => rows.fold<double>(0, (sum, r) => sum + (r.kcal ?? 0)));
  }
}
