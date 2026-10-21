import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/activity/step_repository.dart';
import 'package:sistema/core/activity/step_sync.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';

import '../../helpers/test_db.dart';
import 'fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late StepRepository repo;
  late FakeStepCounter counter;
  late RecordingHooks hooks;
  var now = DateTime(2026, 10, 21, 15, 30);

  StepSync make() => StepSync(counter: counter, repository: repo, hooks: hooks, clock: () => now);

  setUp(() {
    db = memoryDb();
    repo = StepRepository(db);
    counter = FakeStepCounter(steps: 4200)
      ..distanceM = 3000
      ..floors = 2;
    hooks = RecordingHooks();
    now = DateTime(2026, 10, 21, 15, 30);
  });
  tearDown(() => db.close());

  test('опрос [полночь, сейчас) → StepLogs → хуки', () async {
    final sync = make();
    final res = await sync.syncToday();
    expect(res!.steps, 4200);
    expect(counter.queries.single, (DateTime(2026, 10, 21), now));

    final row = (await db.select(db.stepLogs).get()).single;
    expect(row.source, StepSourceKind.coreMotion.name);
    expect(row.steps, 4200);
    expect(row.distanceM, 3000);
    expect(row.floors, 2);
    expect(hooks.steps, [4200]);
  });

  test('без изменений хуки не вызываются повторно; новые шаги — вызываются', () async {
    final sync = make();
    await sync.syncToday();
    await sync.syncToday();
    counter.steps = 5000;
    await sync.syncToday();
    expect(hooks.steps, [4200, 5000]);
  });

  test('новый день — отдельная строка и снова хуки', () async {
    final sync = make();
    await sync.syncToday();
    now = DateTime(2026, 10, 22, 0, 10);
    counter.steps = 4200;
    await sync.syncToday();
    expect(await db.select(db.stepLogs).get(), hasLength(2));
    expect(hooks.steps, [4200, 4200]);
  });

  test('нет счётчика или доступа — null, ничего не пишется', () async {
    counter.available = false;
    expect(await make().syncToday(), isNull);
    counter
      ..available = true
      ..granted = false;
    expect(await make().syncToday(), isNull);
    expect(await db.select(db.stepLogs).get(), isEmpty);
    expect(hooks.steps, isEmpty);
  });

  test('ручной ввод: источник manual, в квесты — лучшее значение за день', () async {
    final sync = make();
    await sync.syncToday(); // 4200 от устройства
    await sync.saveManual(3000);
    expect(hooks.steps, [4200]); // лучшее не изменилось
    await sync.saveManual(9000);
    expect(hooks.steps, [4200, 9000]);
    final manual = (await db.select(db.stepLogs).get()).where((r) => r.source == 'manual').single;
    expect(manual.steps, 9000);

    await sync.saveManual(100, day: DateTime(2026, 10, 20));
    expect(hooks.steps, [4200, 9000]); // прошлый день квестам не сообщается
  });

  test('параллельные вызовы объединяются', () async {
    final sync = make();
    await Future.wait([sync.syncToday(), sync.syncToday(), sync.syncToday()]);
    expect(counter.queries, hasLength(1));
  });

  testWidgets('start: опрос сразу, по таймеру и при возврате на передний план', (tester) async {
    await tester.runAsync(() async {
      final sync = StepSync(
        counter: counter,
        repository: repo,
        hooks: hooks,
        clock: () => now,
        interval: const Duration(milliseconds: 100),
      );
      sync.start();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(counter.queries.length, greaterThanOrEqualTo(2));

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final paused = counter.queries.length;
      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(counter.queries.length, paused);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(counter.queries.length, paused + 1);
      sync.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      expect(counter.queries.length, paused + 1);
    });
  });
}
