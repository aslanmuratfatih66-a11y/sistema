import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/features/nutrition/domain/nutrition_math.dart';
import 'package:sistema/features/nutrition/domain/shopping_plan.dart';

void main() {
  group('КБЖУ', () {
    test('граммы × значения на 100 г', () {
      const per100 = Macros(kcal: 350, protein: 12, fat: 6, carbs: 60);
      final m = per100.forGrams(150);
      expect(m.kcal, closeTo(525, 1e-9));
      expect(m.protein, closeTo(18, 1e-9));
      expect(m.fat, closeTo(9, 1e-9));
      expect(m.carbs, closeTo(90, 1e-9));
    });

    test('порция → на 100 г и обратно', () {
      const portion = Macros(kcal: 200, protein: 10, fat: 5, carbs: 30);
      final per100 = portion.per100From(250);
      expect(per100.kcal, closeTo(80, 1e-9));
      expect(per100.forGrams(250).kcal, closeTo(200, 1e-9));
      expect(portion.per100From(0), portion);
    });

    test('округление до 0.1', () {
      expect(const Macros(kcal: 123.456, protein: 1.04, fat: 0.05, carbs: 9.99).rounded(),
          const Macros(kcal: 123.5, protein: 1.0, fat: 0.1, carbs: 10.0));
    });

    test('рецепт: на порцию и несколько порций', () {
      const total = Macros(kcal: 1200, protein: 80, fat: 40, carbs: 120);
      expect(recipePortion(total, 4, 1), const Macros(kcal: 300, protein: 20, fat: 10, carbs: 30));
      expect(recipePortion(total, 4, 1.5).kcal, closeTo(450, 1e-9));
      expect(recipePortion(total, 0, 1), total); // защита от деления на 0
    });
  });

  group('сводка дня', () {
    test('сумма записей, вода, приёмы пищи — по разным типам', () {
      final d = buildNutritionDay(
        entries: const [
          Macros(kcal: 300, protein: 20, fat: 10, carbs: 30),
          Macros(kcal: 150, protein: 5, fat: 5, carbs: 20),
          Macros(kcal: 600, protein: 40, fat: 20, carbs: 60),
        ],
        mealTypes: const ['breakfast', 'breakfast', 'lunch'],
        waterMl: const [250, 500, 250],
      );
      expect(d.kcal, 1050);
      expect(d.protein, 65);
      expect(d.fat, 35);
      expect(d.carbs, 110);
      expect(d.waterMl, 1000);
      expect(d.meals, 2);
    });

    test('пустой день', () {
      final d = buildNutritionDay(entries: const [], mealTypes: const [], waterMl: const []);
      expect(d.kcal, 0);
      expect(d.meals, 0);
      expect(d.waterMl, 0);
    });
  });

  group('вода', () {
    test('норма: день тренировки — своя, если есть', () {
      expect(waterGoalMl(baseMl: 2500, trainingDayMl: 3000, trainingDay: true), 3000);
      expect(waterGoalMl(baseMl: 2500, trainingDayMl: 3000, trainingDay: false), 2500);
      expect(waterGoalMl(baseMl: 2500, trainingDay: true), 2500);
      expect(waterGoalMl(trainingDay: false), isNull);
    });

    test('прогресс к норме', () {
      expect(progressOf(1250, 2500), 0.5);
      expect(progressOf(3000, 2500), 1);
      expect(progressOf(100, null), isNull);
    });
  });

  test('границы дня (локальная полночь)', () {
    final t = DateTime(2026, 10, 21, 23, 59);
    expect(dayStart(t), DateTime(2026, 10, 21));
    expect(nextDayStart(t), DateTime(2026, 10, 22));
    expect(sameDay(t, DateTime(2026, 10, 21, 0, 1)), isTrue);
  });

  group('список покупок от плана', () {
    test('нормы → строки на неделю без цен', () {
      final lines = planShoppingList(proteinG: 120, fatG: 70, carbsG: 250, waterMl: 2500);
      final by = {for (final l in lines) l.item: l};
      expect(by.keys, containsAll(PlanGrocery.values));
      // 120 × 7 × 0.5 / 0.23 = 1826 г → 1.9 кг
      expect(by[PlanGrocery.chicken]!.quantity, 1.9);
      expect(by[PlanGrocery.chicken]!.unit, ShopUnit.kg);
      // 120 × 7 × 0.25 / 6 = 35 шт.
      expect(by[PlanGrocery.eggs]!.quantity, 35);
      expect(by[PlanGrocery.vegetables]!.quantity, 2.8);
      expect(by[PlanGrocery.fruits]!.quantity, 14);
      expect(by[PlanGrocery.water]!.quantity, 18); // 17.5 л → 18
      expect(by[PlanGrocery.oil]!.unit, ShopUnit.ml);
      expect(by[PlanGrocery.oil]!.quantity % 50, 0);
    });

    test('без норм БЖУ — только овощи и фрукты', () {
      final lines = planShoppingList();
      expect(lines.map((l) => l.item), [PlanGrocery.vegetables, PlanGrocery.fruits]);
    });
  });
}
