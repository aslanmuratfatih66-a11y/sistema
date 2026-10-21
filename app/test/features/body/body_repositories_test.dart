import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/body/data/measurement_repository.dart';
import 'package:sistema/features/body/data/sleep_repository.dart';

import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = memoryDb());
  tearDown(() => db.close());

  group('SleepRepository', () {
    test('одна запись на день подъёма: повторная перезаписывает', () async {
      final repo = SleepRepository(db);
      await repo.save(bedAt: DateTime(2026, 10, 20, 23), wakeAt: DateTime(2026, 10, 21, 7), quality: 3);
      await repo.save(bedAt: DateTime(2026, 10, 21, 0, 30), wakeAt: DateTime(2026, 10, 21, 8), quality: 4);
      final day = await repo.getDay(DateTime(2026, 10, 21));
      expect(day!.duration, const Duration(hours: 7, minutes: 30));
      expect(day.quality, 4);
      expect(day.day, DateTime(2026, 10, 21));
      final rows = await db.select(db.sleepLogs).get();
      expect(rows, hasLength(1));
      expect(rows.single.version, 2);
    });

    test('ночь относится к дню подъёма; удаление мягкое', () async {
      final repo = SleepRepository(db);
      await repo.save(bedAt: DateTime(2026, 10, 20, 23), wakeAt: DateTime(2026, 10, 21, 7));
      expect(await repo.getDay(DateTime(2026, 10, 20)), isNull);
      await repo.deleteDay(DateTime(2026, 10, 21));
      expect(await repo.getDay(DateTime(2026, 10, 21)), isNull);
      expect((await db.select(db.sleepLogs).get()).single.deletedAt, isNotNull);
    });

    test('некорректный сон отклоняется', () async {
      final repo = SleepRepository(db);
      expect(
        () => repo.save(bedAt: DateTime(2026, 10, 21, 8), wakeAt: DateTime(2026, 10, 21, 7)),
        throwsArgumentError,
      );
      expect(
        () => repo.save(bedAt: DateTime(2026, 10, 20), wakeAt: DateTime(2026, 10, 21, 7), quality: 6),
        throwsArgumentError,
      );
    });

    test('energyPercentProvider: null без сна, по формуле — со сном', () async {
      final container = ProviderContainer(overrides: [
        databaseProvider.overrideWithValue(db),
        bodyClockProvider.overrideWithValue(() => DateTime(2026, 10, 21, 12)),
      ]);
      addTearDown(container.dispose);
      final sub = container.listen(energyPercentProvider, (_, _) {});
      final today = DateTime(2026, 10, 21);
      await container.read(sleepDayProvider(today).future);
      expect(sub.read(), isNull);

      // 6 ч при цели 8 ч (плана нет — 480), отбой 01:00 при расписании 23:00 → 75 − 15 = 60.
      await SleepRepository(db).save(bedAt: DateTime(2026, 10, 21, 1), wakeAt: DateTime(2026, 10, 21, 7));
      await pumpEventQueue();
      expect(container.read(sleepDayProvider(today)).value?.duration, const Duration(hours: 6));
      expect(sub.read(), 60);
    });
  });

  group('BodyMeasurementRepository', () {
    test('добавление, ряд, изменение за период, удаление', () async {
      final repo = BodyMeasurementRepository(db);
      await repo.add(MeasurementInput(const {MeasureField.weight: 80, MeasureField.waist: 90}, measuredAt: DateTime(2026, 9, 1)));
      await repo.add(MeasurementInput(const {MeasureField.weight: 78.5}, measuredAt: DateTime(2026, 10, 1)));
      final lastId = await repo.add(MeasurementInput(const {MeasureField.weight: 77}, measuredAt: DateTime(2026, 10, 20)));

      final rows = await repo.all();
      expect(rows, hasLength(3));
      expect(rows.first.source, MeasurementSource.manual.name);
      expect(measureSeries(rows, MeasureField.weight).map((e) => e.value), [80, 78.5, 77]);
      expect(measureSeries(rows, MeasureField.waist), hasLength(1));
      expect(measureChange(rows, MeasureField.weight), -3);
      expect(measureChange(rows, MeasureField.weight, since: DateTime(2026, 9, 21)), -1.5);
      expect(measureChange(rows, MeasureField.waist), isNull);
      expect(measureLatest(rows, MeasureField.waist)?.value, 90);

      await repo.softDelete(lastId);
      final after = await repo.all();
      expect(after, hasLength(2));
      expect(measureLatest(after, MeasureField.weight)?.value, 78.5);
    });

    test('пустой замер и значения вне диапазона отклоняются', () async {
      final repo = BodyMeasurementRepository(db);
      expect(() => repo.add(const MeasurementInput({MeasureField.weight: null})), throwsArgumentError);
      expect(() => repo.add(const MeasurementInput({MeasureField.bodyFat: 90})), throwsArgumentError);
      expect(await repo.all(), isEmpty);
    });
  });
}
