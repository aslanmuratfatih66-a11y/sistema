import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/activity/step_repository.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/daily.dart';
import 'package:sistema/core/models/enums.dart';

import '../../helpers/test_db.dart';

final _day = DateTime(2026, 10, 21);

StepLogRow _row(int steps, StepSourceKind source, {DateTime? deletedAt, double? distanceM}) => StepLogRow(
      id: '${source.name}-$steps',
      updatedAt: DateTime(2026),
      deviceId: 'd',
      version: 1,
      deletedAt: deletedAt,
      day: _day,
      steps: steps,
      distanceM: distanceM,
      source: source.name,
    );

void main() {
  group('bestStepDay', () {
    test('нет записей — null', () => expect(bestStepDay(const []), isNull));

    test('больше шагов — лучше', () {
      final best = bestStepDay([_row(5000, StepSourceKind.coreMotion), _row(7000, StepSourceKind.manual)]);
      expect(best!.steps, 7000);
    });

    test('при равенстве устройство важнее ручного ввода', () {
      final best = bestStepDay([
        _row(5000, StepSourceKind.manual),
        _row(5000, StepSourceKind.sensor, distanceM: 3500),
      ]);
      expect(best!.distanceM, 3500);
    });

    test('удалённые не учитываются', () {
      expect(bestStepDay([_row(9000, StepSourceKind.manual, deletedAt: DateTime(2026))]), isNull);
    });
  });

  group('StepRepository', () {
    late AppDatabase db;
    late StepRepository repo;

    setUp(() {
      db = memoryDb();
      repo = StepRepository(db);
    });
    tearDown(() => db.close());

    test('upsert: одна строка на день и источник, версия растёт только при изменении', () async {
      await repo.upsert(StepDay(day: DateTime(2026, 10, 21, 15, 30), steps: 100), StepSourceKind.coreMotion);
      await repo.upsert(StepDay(day: _day, steps: 2500, distanceM: 1800, floors: 3), StepSourceKind.coreMotion);
      await repo.upsert(StepDay(day: _day, steps: 2500, distanceM: 1800, floors: 3), StepSourceKind.coreMotion);
      await repo.upsert(StepDay(day: _day, steps: 1000), StepSourceKind.manual);

      final rows = await db.select(db.stepLogs).get();
      expect(rows, hasLength(2));
      final device = rows.firstWhere((r) => r.source == 'coreMotion');
      expect(device.day, _day);
      expect(device.steps, 2500);
      expect(device.distanceM, 1800);
      expect(device.floors, 3);
      expect(device.version, 2);

      expect((await repo.bestOf(_day))!.steps, 2500);
    });

    test('upsert восстанавливает удалённую строку', () async {
      await repo.upsert(StepDay(day: _day, steps: 10), StepSourceKind.manual);
      await db.update(db.stepLogs).write(StepLogsCompanion(deletedAt: Value(DateTime(2026))));
      expect(await repo.bestOf(_day), isNull);
      await repo.upsert(StepDay(day: _day, steps: 10), StepSourceKind.manual);
      expect((await repo.bestOf(_day))!.steps, 10);
    });

    test('история: по дню, лучший источник, пропуски — 0', () async {
      await repo.upsert(StepDay(day: DateTime(2026, 10, 19), steps: 3000), StepSourceKind.coreMotion);
      await repo.upsert(StepDay(day: _day, steps: 9000), StepSourceKind.coreMotion);
      await repo.upsert(StepDay(day: _day, steps: 9500), StepSourceKind.manual);
      await repo.upsert(StepDay(day: DateTime(2026, 10, 10), steps: 1), StepSourceKind.manual);

      final h = await repo.watchHistory(DateTime(2026, 10, 18), DateTime(2026, 10, 22)).first;
      expect(h.map((d) => d.day.day), [18, 19, 20, 21]);
      expect(h.map((d) => d.steps), [0, 3000, 0, 9500]);
    });

    test('watchDay обновляется после записи', () async {
      final values = <int?>[];
      final sub = repo.watchDay(_day).listen((d) => values.add(d?.steps));
      await pumpEventQueue();
      await repo.upsert(StepDay(day: _day, steps: 42), StepSourceKind.manual);
      await pumpEventQueue();
      await sub.cancel();
      expect(values, [null, 42]);
    });
  });
}
