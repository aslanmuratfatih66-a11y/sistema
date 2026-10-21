import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/onboarding/questionnaire_a/data/measurement_repository.dart';

import '../../../helpers/test_db.dart';

void main() {
  test('замер онбординга: создаётся одна запись и дальше обновляется она же', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final repo = OnboardingMeasurementRepository(db);

    expect(await repo.get(), isNull);
    await repo.patch(const BodyMeasurementsCompanion(weightKg: Value(72.5)));
    final first = await repo.get();
    expect(first, isNotNull);
    expect(await db.getSetting(OnboardingMeasurementRepository.settingKey), first!.id);
    expect(first.version, 1);
    expect(first.source, MeasurementSource.manual.name);

    await repo.patch(const BodyMeasurementsCompanion(waistCm: Value(80)));
    await repo.patch(const BodyMeasurementsCompanion(bodyFatPct: Value(18)));

    final all = await db.select(db.bodyMeasurements).get();
    expect(all, hasLength(1));
    final row = all.single;
    expect(row.id, first.id);
    expect(row.weightKg, 72.5);
    expect(row.waistCm, 80);
    expect(row.bodyFatPct, 18);
    expect(row.version, 3);
  });
}
