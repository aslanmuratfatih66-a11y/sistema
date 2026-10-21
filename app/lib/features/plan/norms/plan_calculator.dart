// Расчёт норм чернового плана (SPEC §5, §8.3, §9.1: «расчёты делает код»). Чистый Dart, без Flutter.
//
// Принятые правила (то, что не зафиксировано в SPEC):
// - Возраст — полных лет на дату [today].
// - Workload: physical поднимает уровень активности на одну ступень (не выше veryActive);
//   standing поднимает sedentary до light; sitting/mixed не меняют уровень.
//   Нет уровня активности — считаем sedentary (предупреждение activityDefaulted).
// - Цель калорий: weightLoss и muscle одновременно — побеждает меньший priority (1 — высший);
//   при равенстве — weightLoss (безопаснее для здоровья).
// - Дефицит: 20% при priority 1, иначе 15%; но никогда не ниже max(BMR, 1200 ж / 1500 м) (SPEC §6).
// - Профицит для мышц — 10%.
// - Калории округляются до 10 ккал, вода — до 50 мл.
import 'dart:math' as math;

import '../../../core/models/enums.dart';

/// Режим калорий.
enum CalorieMode { deficit, surplus, maintenance }

/// Каких данных не хватает для норм.
enum MissingField { sex, birthDate, heightCm, weightKg }

/// Цель для расчёта (вид + приоритет 1..3).
class PlanGoal {
  const PlanGoal(this.kind, {this.priority = 2});
  final GoalKind kind;
  final int priority;
}

class EnergyNorms {
  const EnergyNorms({
    required this.bmr,
    required this.tdee,
    required this.calories,
    required this.mode,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.effectiveActivity,
    required this.floorApplied,
  });

  final int bmr;
  final int tdee;
  final int calories;
  final CalorieMode mode;
  final int proteinG;
  final int fatG;
  final int carbsG;
  final ActivityLevel effectiveActivity;

  /// Дефицит упёрся в безопасный минимум.
  final bool floorApplied;
}

class WaterNorm {
  const WaterNorm({required this.baseMl, required this.trainingDayMl});
  final int baseMl;
  final int trainingDayMl;
}

class SleepNorm {
  const SleepNorm({
    required this.targetMinutes,
    required this.wakeMinute,
    required this.recommendedBedMinute,
    required this.scheduledBedMinute,
    required this.scheduledMinutes,
  });

  final int targetMinutes;
  final int wakeMinute;
  final int recommendedBedMinute;
  final int scheduledBedMinute;

  /// Длительность сна по расписанию (отбой → подъём).
  final int scheduledMinutes;

  bool get isShort => scheduledMinutes < targetMinutes;
  int get shortByMinutes => math.max(0, targetMinutes - scheduledMinutes);
}

/// Итог расчёта норм. null-нормы — данных не хватает, причина в [missing].
class NormsResult {
  const NormsResult({
    required this.energy,
    required this.water,
    required this.sleep,
    required this.missing,
    required this.activityDefaulted,
  });

  final EnergyNorms? energy;
  final WaterNorm? water;
  final SleepNorm sleep;
  final List<MissingField> missing;
  final bool activityDefaulted;
}

abstract final class PlanCalculator {
  static const activityFactor = {
    ActivityLevel.sedentary: 1.2,
    ActivityLevel.light: 1.375,
    ActivityLevel.moderate: 1.55,
    ActivityLevel.active: 1.725,
    ActivityLevel.veryActive: 1.9,
  };

  static const waterMlPerKg = 33;
  static const waterTrainingBonusMl = 500;
  static const waterMinMl = 1500;

  /// Полных лет на дату.
  static int ageOn(DateTime birthDate, DateTime today) {
    var age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) age--;
    return age;
  }

  /// BMR Миффлина–Сан Жеора, ккал.
  static double bmr({required Sex sex, required double weightKg, required double heightCm, required int age}) {
    final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
    return sex == Sex.male ? base + 5 : base - 161;
  }

  /// Уровень активности с учётом характера нагрузки (см. правила в шапке файла).
  static ActivityLevel effectiveActivity(ActivityLevel level, Workload? workload) {
    final i = level.index;
    return switch (workload) {
      Workload.physical => ActivityLevel.values[math.min(i + 1, ActivityLevel.values.length - 1)],
      Workload.standing when level == ActivityLevel.sedentary => ActivityLevel.light,
      _ => level,
    };
  }

  static double tdee(double bmr, ActivityLevel level, Workload? workload) =>
      bmr * activityFactor[effectiveActivity(level, workload)]!;

  /// Какая из целей по весу активна: weightLoss / muscle / null.
  static GoalKind? weightGoal(List<PlanGoal> goals) {
    PlanGoal? best;
    for (final g in goals) {
      if (g.kind != GoalKind.weightLoss && g.kind != GoalKind.muscle) continue;
      if (best == null ||
          g.priority < best.priority ||
          (g.priority == best.priority && g.kind == GoalKind.weightLoss)) {
        best = g;
      }
    }
    return best?.kind;
  }

  /// Безопасный минимум калорий: max(BMR, 1200 ж / 1500 м).
  static double safeFloor(Sex sex, double bmr) => math.max(bmr, sex == Sex.male ? 1500 : 1200);

  static int _round10(double v) => (v / 10).round() * 10;

  static EnergyNorms energy({
    required Sex sex,
    required double weightKg,
    required double heightCm,
    required int age,
    required ActivityLevel activity,
    Workload? workload,
    List<PlanGoal> goals = const [],
  }) {
    final b = bmr(sex: sex, weightKg: weightKg, heightCm: heightCm, age: age);
    final eff = effectiveActivity(activity, workload);
    final t = b * activityFactor[eff]!;
    final goal = weightGoal(goals);
    var floorApplied = false;
    double cal;
    CalorieMode mode;
    switch (goal) {
      case GoalKind.weightLoss:
        mode = CalorieMode.deficit;
        final priority = goals.where((g) => g.kind == GoalKind.weightLoss).map((g) => g.priority).reduce(math.min);
        final deficit = priority == 1 ? 0.20 : 0.15;
        cal = t * (1 - deficit);
        final floor = safeFloor(sex, b);
        if (cal < floor) {
          cal = floor;
          floorApplied = true;
        }
      case GoalKind.muscle:
        mode = CalorieMode.surplus;
        cal = t * 1.10;
      default:
        mode = CalorieMode.maintenance;
        cal = t;
    }
    // Округление не должно опустить ниже минимума.
    var calories = _round10(cal);
    if (mode == CalorieMode.deficit) {
      final floor = safeFloor(sex, b);
      while (calories < floor) {
        calories += 10;
      }
    }

    final proteinPerKg = switch (mode) {
      CalorieMode.surplus => 2.0,
      CalorieMode.deficit => 1.8,
      CalorieMode.maintenance => 1.6,
    };
    final protein = (proteinPerKg * weightKg).round();
    final fat = math.max(0.9 * weightKg, 0.20 * calories / 9).round();
    final carbs = math.max(0, ((calories - protein * 4 - fat * 9) / 4).round());
    return EnergyNorms(
      bmr: b.round(),
      tdee: t.round(),
      calories: calories,
      mode: mode,
      proteinG: protein,
      fatG: fat,
      carbsG: carbs,
      effectiveActivity: eff,
      floorApplied: floorApplied,
    );
  }

  static int _round50(double v) => (v / 50).round() * 50;

  static WaterNorm water(double weightKg) {
    final base = math.max(waterMinMl, _round50(weightKg * waterMlPerKg));
    return WaterNorm(baseMl: base, trainingDayMl: base + waterTrainingBonusMl);
  }

  /// Цель сна по возрасту, минуты. Возраст неизвестен — 8 ч.
  static int sleepTargetMinutes(int? age) {
    if (age == null) return 8 * 60;
    if (age < 18) return 9 * 60;
    if (age >= 65) return 450;
    return 8 * 60;
  }

  static const _day = 24 * 60;

  static SleepNorm sleep({int? age, required int wakeMinute, required int bedMinute}) {
    final target = sleepTargetMinutes(age);
    var scheduled = (wakeMinute - bedMinute) % _day;
    if (scheduled == 0) scheduled = _day;
    return SleepNorm(
      targetMinutes: target,
      wakeMinute: wakeMinute,
      recommendedBedMinute: (wakeMinute - target) % _day,
      scheduledBedMinute: bedMinute,
      scheduledMinutes: scheduled,
    );
  }

  /// Все нормы. Если не хватает пола/даты рождения/роста/веса — energy = null (и water = null без веса).
  static NormsResult compute({
    Sex? sex,
    DateTime? birthDate,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activity,
    Workload? workload,
    List<PlanGoal> goals = const [],
    required int wakeMinute,
    required int bedMinute,
    required DateTime today,
  }) {
    final missing = <MissingField>[
      if (sex == null) MissingField.sex,
      if (birthDate == null) MissingField.birthDate,
      if (heightCm == null || heightCm <= 0) MissingField.heightCm,
      if (weightKg == null || weightKg <= 0) MissingField.weightKg,
    ];
    final age = birthDate == null ? null : ageOn(birthDate, today);
    final energyNorms = missing.isEmpty
        ? energy(
            sex: sex!,
            weightKg: weightKg!,
            heightCm: heightCm!,
            age: age!,
            activity: activity ?? ActivityLevel.sedentary,
            workload: workload,
            goals: goals,
          )
        : null;
    return NormsResult(
      energy: energyNorms,
      water: weightKg != null && weightKg > 0 ? water(weightKg) : null,
      sleep: sleep(age: age, wakeMinute: wakeMinute, bedMinute: bedMinute),
      missing: missing,
      activityDefaulted: activity == null,
    );
  }
}
