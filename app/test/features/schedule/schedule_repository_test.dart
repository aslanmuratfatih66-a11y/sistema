import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/schedule/data/schedule_repository.dart';
import 'package:sistema/features/schedule/schedule_logic.dart';

import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late ScheduleRepository repo;
  final now = DateTime(2026, 10, 21, 10, 46); // среда

  setUp(() {
    db = memoryDb();
    repo = ScheduleRepository(db, clock: () => now);
  });
  tearDown(() => db.close());

  test('без строки — дефолтный конфиг', () async {
    final c = await repo.getConfig();
    expect(c.alternationEnabled, isFalse);
    expect(c.weekendDays, {6, 7});
  });

  test('включение чередования записывает якорь = понедельник текущей недели', () async {
    await repo.setAlternation(true);
    final row = (await repo.getSettings())!;
    expect(row.id, ScheduleRepository.settingsId);
    expect(row.alternationEnabled, isTrue);
    expect(row.week1Anchor, DateTime(2026, 10, 19));
    expect(row.version, 1);
    expect(row.deviceId, isNotEmpty);
    expect(ScheduleLogic.weekNumber(now, await repo.getConfig()), 1);

    // Выключение/включение не трогает существующий якорь; версия растёт.
    await repo.setAlternation(false);
    await repo.setAlternation(true);
    final row2 = (await repo.getSettings())!;
    expect(row2.week1Anchor, DateTime(2026, 10, 19));
    expect(row2.version, 3);
  });

  test('переключение недели', () async {
    await repo.setAlternation(true);
    await repo.switchWeek();
    expect(ScheduleLogic.weekNumber(now, await repo.getConfig()), 2);
    await repo.switchWeek();
    expect(ScheduleLogic.weekNumber(now, await repo.getConfig()), 1);
  });

  test('частичное обновление настроек', () async {
    await repo.updateSettings(const ScheduleSettingsCompanion(
      commuteMinutes: Value(35),
      weekendDays: Value('7'),
      institutionType: Value('university'),
    ));
    final c = await repo.getConfig();
    expect(c.commuteMinutes, 35);
    expect(c.weekendDays, {7});
    expect(c.institutionType, InstitutionType.university);
    expect(c.wakeMinute, 420);
  });

  test('пункты: создание, правка (version+1), мягкое удаление', () async {
    final id = await repo.saveEntry(const ScheduleEntry(
      id: '',
      kind: ScheduleItemKind.lesson,
      title: ' Матанализ ',
      weekday: DateTime.monday,
      startMinute: 540,
      durationMinutes: 90,
      location: '  ',
    ));
    var list = await repo.getEntries();
    expect(list, hasLength(1));
    expect(list.single.title, 'Матанализ');
    expect(list.single.location, isNull);

    await repo.saveEntry(list.single.copyWith(startMinute: 600, weekParity: 2));
    var row = await (db.select(db.scheduleItems)..where((t) => t.id.equals(id))).getSingle();
    expect(row.version, 2);
    expect(row.startMinute, 600);
    expect(row.weekParity, 2);

    await repo.deleteEntry(id);
    expect(await repo.getEntries(), isEmpty);
    row = await (db.select(db.scheduleItems)..where((t) => t.id.equals(id))).getSingle();
    expect(row.deletedAt, isNotNull);
    expect(row.version, 3);

    // Повторное удаление — без изменений.
    await repo.deleteEntry(id);
    row = await (db.select(db.scheduleItems)..where((t) => t.id.equals(id))).getSingle();
    expect(row.version, 3);
  });

  test('копирование дня', () async {
    for (final s in [540, 650]) {
      await repo.saveEntry(ScheduleEntry(
        id: '',
        kind: ScheduleItemKind.lesson,
        title: 'P$s',
        weekday: DateTime.monday,
        startMinute: s,
        durationMinutes: 90,
      ));
    }
    expect(await repo.copyDay(DateTime.monday, DateTime.thursday), 2);
    final list = await repo.getEntries();
    expect(list.where((e) => e.weekday == DateTime.thursday).map((e) => e.startMinute), [540, 650]);
    expect(list.map((e) => e.id).toSet(), hasLength(4));
  });

  test('стримы провайдеров отдают изменения', () async {
    final configs = repo.watchConfig();
    final first = await configs.first;
    expect(first.commuteMinutes, 0);
    await repo.updateSettings(const ScheduleSettingsCompanion(commuteMinutes: Value(20)));
    expect((await repo.watchConfig().first).commuteMinutes, 20);
  });
}
