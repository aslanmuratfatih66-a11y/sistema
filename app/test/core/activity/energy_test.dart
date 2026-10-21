import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/activity/activity_providers.dart';
import 'package:sistema/core/activity/energy.dart';
import 'package:sistema/core/activity/step_repository.dart';
import 'package:sistema/core/data/profile_repository.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/daily.dart';
import 'package:sistema/core/models/enums.dart';

import '../../helpers/test_db.dart';

final _day = DateTime(2026, 10, 21);

void main() {
  group('EnergyCalc', () {
    test('шаги без дистанции: длина шага от роста, 0.5 ккал/кг/км', () {
      // 8000 × 0.415 × 1.80 м = 5976 м; × 0.0005 × 80 = 239.04
      expect(EnergyCalc.stepsKcal(steps: 8000, weightKg: 80, heightCm: 180), closeTo(239.04, 1e-6));
    });

    test('дистанция от счётчика важнее оценки по шагам; этажи добавляют подъём', () {
      expect(EnergyCalc.stepsKcal(steps: 8000, distanceM: 6000, weightKg: 70), closeTo(210, 1e-6));
      // 10 этажей × 0.027 × 70 = 18.9
      expect(EnergyCalc.stepsKcal(steps: 8000, distanceM: 6000, floors: 10, weightKg: 70), closeTo(228.9, 1e-6));
    });

    test('без веса и роста — 70 кг и шаг 0.75 м; ноль шагов — ноль', () {
      expect(EnergyCalc.stepsKcal(steps: 1000), closeTo(1000 * 0.75 * 0.0005 * 70, 1e-6));
      expect(EnergyCalc.stepsKcal(steps: 0, weightKg: 80), 0);
    });

    test('BMR Миффлина через PlanCalculator; возраст на дату; без данных — null', () {
      // 10×80 + 6.25×180 − 5×36 + 5 = 1750
      expect(
        EnergyCalc.bmr(sex: Sex.male, birthDate: DateTime(1990, 1, 1), heightCm: 180, weightKg: 80, day: _day),
        1750,
      );
      // День рождения ещё не наступил — 35 лет: 10×60 + 6.25×165 − 5×35 − 161 = 1295.25
      expect(
        EnergyCalc.bmr(sex: Sex.female, birthDate: DateTime(1990, 12, 1), heightCm: 165, weightKg: 60, day: _day),
        closeTo(1295.25, 1e-6),
      );
      expect(EnergyCalc.bmr(sex: Sex.male, birthDate: DateTime(1990), heightCm: 180, day: _day), isNull);
      expect(EnergyCalc.bmr(birthDate: DateTime(1990), heightCm: 180, weightKg: 80, day: _day), isNull);
    });
  });

  group('dailyEnergyProvider', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() {
      db = memoryDb();
      container = ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(db),
        activityClockProvider.overrideWithValue(() => DateTime(2026, 10, 21, 18)),
      ]);
    });

    /// В Riverpod 3 провайдер без слушателей приостанавливается — держим подписку.
    Future<DailyEnergy> energy() {
      container.listen(dailyEnergyProvider(_day), (_, _) {});
      return container.read(dailyEnergyProvider(_day).future);
    }

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    Future<void> weight(DateTime at, double kg) async => db.into(db.bodyMeasurements).insert(
          BodyMeasurementsCompanion.insert(
            id: newId(),
            updatedAt: DateTime.now(),
            deviceId: 'd',
            measuredAt: at,
            weightKg: Value(kg),
          ),
        );

    Future<void> workout(DateTime start, {DateTime? finished, double? kcal}) async =>
        db.into(db.workoutSessions).insert(WorkoutSessionsCompanion.insert(
              id: newId(),
              updatedAt: DateTime.now(),
              deviceId: 'd',
              startedAt: start,
              finishedAt: Value(finished),
              kcal: Value(kcal),
            ));

    test('нет профиля — bmr null, шаги всё равно считаются', () async {
      await StepRepository(db).upsert(StepDay(day: _day, steps: 2000, distanceM: 1000), StepSourceKind.coreMotion);
      final e = await energy();
      expect(e.bmr, isNull);
      expect(e.totalKcal, isNull);
      expect(e.stepsKcal, closeTo(1000 * 0.0005 * 70, 1e-6));
    });

    test('BMR + шаги + тренировки дня (и прерванные); вес — последний до конца дня', () async {
      await ProfileRepository(db).update(ProfilesCompanion(
        sex: const Value('male'),
        birthDate: Value(DateTime(1990, 1, 1)),
        heightCm: const Value(180),
      ));
      await weight(DateTime(2026, 10, 1), 82);
      await weight(DateTime(2026, 10, 21, 7), 80);
      await weight(DateTime(2026, 10, 22, 7), 79); // после дня — не учитывается
      await StepRepository(db).upsert(StepDay(day: _day, steps: 8000, distanceM: 6000), StepSourceKind.healthConnect);
      await workout(DateTime(2026, 10, 21, 8), finished: DateTime(2026, 10, 21, 8, 30), kcal: 150);
      await workout(DateTime(2026, 10, 21, 19), finished: DateTime(2026, 10, 21, 19, 20), kcal: 50);
      await workout(DateTime(2026, 10, 21, 20), kcal: 30); // прервана — сделанное считается
      await workout(DateTime(2026, 10, 20, 20), finished: DateTime(2026, 10, 20, 21), kcal: 999); // другой день

      final e = await energy();
      expect(e.bmr, 1750);
      expect(e.stepsKcal, closeTo(6000 * 0.0005 * 80, 1e-6));
      expect(e.workoutKcal, 230);
      expect(e.totalKcal, closeTo(1750 + 240 + 230, 1e-6));
    });

    test('пересчитывается при новых данных', () async {
      expect((await energy()).workoutKcal, 0);
      await workout(DateTime(2026, 10, 21, 9), finished: DateTime(2026, 10, 21, 10), kcal: 120);
      await StepRepository(db).upsert(StepDay(day: _day, steps: 1000, distanceM: 700), StepSourceKind.manual);
      for (var i = 0; i < 20; i++) {
        await pumpEventQueue();
        final v = container.read(dailyEnergyProvider(_day)).value;
        if (v != null && v.workoutKcal == 120 && v.stepsKcal > 0) break;
      }
      final v = container.read(dailyEnergyProvider(_day)).value!;
      expect(v.workoutKcal, 120);
      expect(v.stepsKcal, closeTo(700 * 0.0005 * 70, 1e-6));
    });

    test('вес только после даты — берётся самый ранний', () async {
      await weight(DateTime(2026, 11, 1), 90);
      await weight(DateTime(2026, 12, 1), 88);
      final w = await container.read(energyRepositoryProvider).watchWeightOn(_day).first;
      expect(w, 90);
    });
  });
}
