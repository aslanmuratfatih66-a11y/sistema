import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/plan/norms/plan_calculator.dart';

void main() {
  group('BMR Миффлина–Сан Жеора', () {
    test('мужчина 80 кг, 180 см, 30 лет → 1780', () {
      expect(PlanCalculator.bmr(sex: Sex.male, weightKg: 80, heightCm: 180, age: 30), 1780);
    });
    test('женщина 60 кг, 165 см, 25 лет → 1345.25', () {
      expect(PlanCalculator.bmr(sex: Sex.female, weightKg: 60, heightCm: 165, age: 25), closeTo(1345.25, 1e-9));
    });
    test('возраст — полных лет на дату', () {
      expect(PlanCalculator.ageOn(DateTime(1996, 10, 22), DateTime(2026, 10, 21)), 29);
      expect(PlanCalculator.ageOn(DateTime(1996, 10, 21), DateTime(2026, 10, 21)), 30);
    });
  });

  group('TDEE', () {
    test('коэффициенты активности', () {
      expect(PlanCalculator.tdee(1780, ActivityLevel.moderate, null), closeTo(2759, 1e-9));
      expect(PlanCalculator.tdee(1000, ActivityLevel.sedentary, Workload.sitting), closeTo(1200, 1e-9));
      expect(PlanCalculator.tdee(1000, ActivityLevel.veryActive, null), closeTo(1900, 1e-9));
    });
    test('физическая работа — не выше следующего уровня', () {
      expect(PlanCalculator.effectiveActivity(ActivityLevel.moderate, Workload.physical), ActivityLevel.active);
      expect(PlanCalculator.effectiveActivity(ActivityLevel.veryActive, Workload.physical), ActivityLevel.veryActive);
      expect(PlanCalculator.effectiveActivity(ActivityLevel.sedentary, Workload.standing), ActivityLevel.light);
      expect(PlanCalculator.effectiveActivity(ActivityLevel.moderate, Workload.standing), ActivityLevel.moderate);
    });
  });

  group('калории по целям', () {
    EnergyNorms male(List<PlanGoal> goals) => PlanCalculator.energy(
          sex: Sex.male,
          weightKg: 80,
          heightCm: 180,
          age: 30,
          activity: ActivityLevel.moderate,
          goals: goals,
        );

    test('без целей по весу — поддержание', () {
      final e = male(const []);
      expect(e.mode, CalorieMode.maintenance);
      expect(e.calories, 2760);
    });
    test('похудение: дефицит 15% (priority 2) / 20% (priority 1)', () {
      expect(male(const [PlanGoal(GoalKind.weightLoss, priority: 2)]).calories, 2350);
      final e = male(const [PlanGoal(GoalKind.weightLoss, priority: 1)]);
      expect(e.mode, CalorieMode.deficit);
      expect(e.calories, 2210);
    });
    test('дефицит не ниже безопасного минимума', () {
      final e = PlanCalculator.energy(
        sex: Sex.female,
        weightKg: 45,
        heightCm: 150,
        age: 60,
        activity: ActivityLevel.sedentary,
        goals: const [PlanGoal(GoalKind.weightLoss, priority: 1)],
      );
      expect(e.calories, 1200);
      expect(e.floorApplied, isTrue);
      final m = PlanCalculator.energy(
        sex: Sex.male,
        weightKg: 50,
        heightCm: 160,
        age: 70,
        activity: ActivityLevel.sedentary,
        goals: const [PlanGoal(GoalKind.weightLoss, priority: 1)],
      );
      expect(m.calories, greaterThanOrEqualTo(1500));
      expect(m.calories, greaterThanOrEqualTo(m.bmr));
    });
    test('мышцы: профицит ~10%', () {
      final e = male(const [PlanGoal(GoalKind.muscle)]);
      expect(e.mode, CalorieMode.surplus);
      expect(e.calories, 3030);
    });
    test('обе цели — побеждает высший приоритет', () {
      expect(
        male(const [PlanGoal(GoalKind.weightLoss, priority: 2), PlanGoal(GoalKind.muscle, priority: 1)]).mode,
        CalorieMode.surplus,
      );
      expect(
        male(const [PlanGoal(GoalKind.weightLoss, priority: 1), PlanGoal(GoalKind.muscle, priority: 3)]).mode,
        CalorieMode.deficit,
      );
    });
  });

  group('БЖУ', () {
    test('поддержание: белок 1.6 г/кг, жиры 0.9 г/кг, углеводы — остаток', () {
      final e = PlanCalculator.energy(
          sex: Sex.male, weightKg: 80, heightCm: 180, age: 30, activity: ActivityLevel.moderate);
      expect(e.proteinG, 128);
      expect(e.fatG, 72);
      expect(e.carbsG, 400);
    });
    test('мышцы — белок 2.0, похудение — 1.8', () {
      final m = PlanCalculator.energy(
          sex: Sex.male, weightKg: 80, heightCm: 180, age: 30, activity: ActivityLevel.moderate,
          goals: const [PlanGoal(GoalKind.muscle)]);
      expect(m.proteinG, 160);
      final w = PlanCalculator.energy(
          sex: Sex.male, weightKg: 80, heightCm: 180, age: 30, activity: ActivityLevel.moderate,
          goals: const [PlanGoal(GoalKind.weightLoss)]);
      expect(w.proteinG, 144);
    });
    test('жиры не меньше 20% калорий, углеводы не меньше 0', () {
      final e = PlanCalculator.energy(
          sex: Sex.male, weightKg: 50, heightCm: 190, age: 20, activity: ActivityLevel.veryActive);
      expect(e.fatG * 9, greaterThanOrEqualTo(e.calories * 0.2 - 9));
      expect(e.carbsG, greaterThanOrEqualTo(0));
    });
  });

  group('вода', () {
    test('33 мл/кг, округление до 50, +500 в день тренировки', () {
      final w = PlanCalculator.water(80);
      expect(w.baseMl, 2650);
      expect(w.trainingDayMl, 3150);
    });
    test('минимум 1500', () {
      expect(PlanCalculator.water(40).baseMl, 1500);
    });
  });

  group('сон', () {
    test('цель по возрасту', () {
      expect(PlanCalculator.sleepTargetMinutes(16), 540);
      expect(PlanCalculator.sleepTargetMinutes(30), 480);
      expect(PlanCalculator.sleepTargetMinutes(70), 450);
    });
    test('рекомендуемый отбой и предупреждение о нехватке', () {
      final ok = PlanCalculator.sleep(age: 30, wakeMinute: 7 * 60, bedMinute: 23 * 60);
      expect(ok.isShort, isFalse);
      expect(ok.recommendedBedMinute, 23 * 60);
      final short = PlanCalculator.sleep(age: 30, wakeMinute: 7 * 60, bedMinute: 0);
      expect(short.scheduledMinutes, 420);
      expect(short.isShort, isTrue);
      expect(short.shortByMinutes, 60);
      final teen = PlanCalculator.sleep(age: 16, wakeMinute: 7 * 60, bedMinute: 23 * 60);
      expect(teen.recommendedBedMinute, 22 * 60);
      expect(teen.isShort, isTrue);
    });
  });

  test('не хватает данных → null-нормы с причиной', () {
    final r = PlanCalculator.compute(
      sex: Sex.male,
      heightCm: 180,
      wakeMinute: 420,
      bedMinute: 1380,
      today: DateTime(2026, 10, 21),
    );
    expect(r.energy, isNull);
    expect(r.water, isNull);
    expect(r.missing, [MissingField.birthDate, MissingField.weightKg]);
    expect(r.sleep.targetMinutes, 480);

    final full = PlanCalculator.compute(
      sex: Sex.male,
      birthDate: DateTime(1996, 1, 1),
      heightCm: 180,
      weightKg: 80,
      wakeMinute: 420,
      bedMinute: 1380,
      today: DateTime(2026, 10, 21),
    );
    expect(full.missing, isEmpty);
    expect(full.energy!.bmr, 1780);
    expect(full.activityDefaulted, isTrue);
  });
}
