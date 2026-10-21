import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/data/profile_repository.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/features/settings/backup/backup_service.dart';

import '../../helpers/test_db.dart';

class _FakePhotos implements BackupPhotoStore {
  final files = <String, Uint8List>{};

  @override
  Future<Uint8List?> read(String relPath) async => files[relPath];

  @override
  Future<void> write(String relPath, Uint8List bytes) async => files[relPath] = bytes;
}

Future<Map<String, List<Map<String, Object?>>>> _dump(AppDatabase db) async => {
      for (final t in db.allTables)
        t.actualTableName: [
          for (final r in await db.customSelect('SELECT * FROM "${t.actualTableName}" ORDER BY rowid').get()) r.data,
        ],
    };

Future<void> _fill(AppDatabase db) async {
  final dev = await db.deviceId();
  final now = DateTime.utc(2026, 10, 21, 8, 30);
  await ProfileRepository(db).update(ProfilesCompanion(
    name: const Value('Мурат'),
    locale: const Value('tr'),
    birthDate: Value(DateTime.utc(2004, 3, 5)),
    heightCm: const Value(178.5),
  ));
  await db.into(db.goals).insert(GoalsCompanion.insert(
      id: 'g1', updatedAt: now, deviceId: dev, kind: 'weightLoss', deadline: Value(DateTime.utc(2027, 1, 1))));
  await db.into(db.goals).insert(GoalsCompanion.insert(
      id: 'g2', updatedAt: now, deviceId: dev, kind: 'custom', title: const Value('Шпагат'), priority: const Value(1)));
  await db.into(db.scheduleItems).insert(ScheduleItemsCompanion.insert(
        id: 's1',
        updatedAt: now,
        deviceId: dev,
        kind: 'lesson',
        title: 'Матан',
        weekday: 1,
        startMinute: 9 * 60,
        durationMinutes: 90,
        weekParity: const Value(2),
        requiresCommute: const Value(false),
      ));
  await db.into(db.questionnaireSections).insert(QuestionnaireSectionsCompanion.insert(
      id: 'health', updatedAt: now, deviceId: dev, payload: jsonEncode({'sleepQuality': 4, 'chronic': ''})));
  await db.into(db.photos).insert(PhotosCompanion.insert(
      id: 'p1', updatedAt: now, deviceId: dev, kind: 'body', pose: 'bodyFront', localPath: 'photos/p1.jpg', takenAt: now));
  await db.into(db.photos).insert(PhotosCompanion.insert(
      id: 'p2',
      updatedAt: now,
      deviceId: dev,
      kind: 'body',
      pose: 'bodySide',
      localPath: 'photos/p2.jpg',
      takenAt: now,
      deletedAt: Value(now)));
  await db.into(db.photos).insert(PhotosCompanion.insert(
      id: 'p3', updatedAt: now, deviceId: dev, kind: 'skin', pose: 'bodyFront', localPath: 'photos/missing.jpg', takenAt: now));
  await db.setSetting('onboarding.completed', '1');
  await db.setSetting('onboarding.step', '11');
}

void main() {
  late AppDatabase src;
  late AppDatabase dst;
  late _FakePhotos srcPhotos;
  late _FakePhotos dstPhotos;

  setUp(() {
    src = memoryDb();
    dst = memoryDb();
    srcPhotos = _FakePhotos();
    dstPhotos = _FakePhotos();
  });
  tearDown(() async {
    await src.close();
    await dst.close();
  });

  BackupService service(AppDatabase db, _FakePhotos photos) =>
      BackupService(db, photoStore: photos, now: () => DateTime(2026, 10, 21, 9, 5));

  test('экспорт → импорт в другую БД даёт те же данные; device.id не переносится', () async {
    await _fill(src);
    srcPhotos.files['photos/p1.jpg'] = Uint8List.fromList([1, 2, 3, 250]);
    srcPhotos.files['photos/p2.jpg'] = Uint8List.fromList([9]); // удалённое фото — не экспортируется
    final dstDevice = await dst.deviceId();
    await dst.setSetting('onboarding.introSeen', '1'); // будет заменено

    final bytes = await service(src, srcPhotos).exportBytes();
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, Object?>;
    expect(json['format'], 'sistema-backup');
    expect(json['formatVersion'], 1);
    expect(json['schemaVersion'], src.schemaVersion);
    final settingsRows = ((json['tables'] as Map)['app_settings'] as List).cast<Map>();
    expect(settingsRows.map((r) => r['key']), isNot(contains('device.id')));
    expect((json['photos'] as Map).keys, ['photos/p1.jpg']);

    final restore = service(dst, dstPhotos);
    final preview = restore.parse(bytes);
    expect(preview.rowCounts['goals'], 2);
    expect(preview.rowCounts['photos'], 3);
    expect(preview.photoCount, 1);
    await restore.importData(preview);

    final a = await _dump(src);
    final b = await _dump(dst);
    for (final table in a.keys.where((t) => t != 'app_settings')) {
      expect(b[table], a[table], reason: table);
    }
    expect(b['profiles'], isNotEmpty);

    // AppSettings: всё, кроме device.id, перенесено; свой device.id сохранён; лишнее удалено.
    expect(await dst.getSetting('device.id'), dstDevice);
    expect(await dst.getSetting('onboarding.completed'), '1');
    expect(await dst.getSetting('onboarding.step'), '11');
    expect(await dst.getSetting('onboarding.introSeen'), isNull);

    // Даты и булевы — без искажений.
    final profile = await ProfileRepository(dst).get();
    expect(profile!.birthDate!.toUtc(), DateTime.utc(2004, 3, 5));
    expect(profile.heightCm, 178.5);
    expect(profile.locale, 'tr');
    final item = await (dst.select(dst.scheduleItems)).getSingle();
    expect(item.requiresCommute, isFalse);
    expect(item.weekParity, 2);

    expect(dstPhotos.files['photos/p1.jpg'], [1, 2, 3, 250]);
    expect(dstPhotos.files, hasLength(1));
  });

  test('без фото: includePhotos=false и photoStore=null', () async {
    await _fill(src);
    srcPhotos.files['photos/p1.jpg'] = Uint8List.fromList([1]);
    final noPhotos = jsonDecode(utf8.decode(await service(src, srcPhotos).exportBytes(includePhotos: false))) as Map;
    expect(noPhotos['photos'], isEmpty);
    final web = jsonDecode(utf8.decode(await BackupService(src).exportBytes())) as Map;
    expect(web['photos'], isEmpty);
  });

  test('импорт полностью заменяет данные', () async {
    final dev = await dst.deviceId();
    await dst.into(dst.goals).insert(GoalsCompanion.insert(
        id: 'old', updatedAt: DateTime.utc(2025), deviceId: dev, kind: 'study'));
    final empty = await service(src, srcPhotos).exportBytes();
    final restore = service(dst, dstPhotos);
    await restore.importData(restore.parse(empty));
    expect(await dst.select(dst.goals).get(), isEmpty);
    expect(await dst.getSetting('device.id'), dev);
  });

  test('импорт обновляет стримы Drift', () async {
    await _fill(src);
    final bytes = await service(src, srcPhotos).exportBytes();
    final stream = dst.select(dst.goals).watch();
    final seen = <int>[];
    final sub = stream.listen((rows) => seen.add(rows.length));
    await pumpEventQueue();
    final restore = service(dst, dstPhotos);
    await restore.importData(restore.parse(bytes));
    await pumpEventQueue();
    await sub.cancel();
    expect(seen.first, 0);
    expect(seen.last, 2);
  });

  group('проверка файла', () {
    Uint8List enc(Object? json) => utf8.encode(jsonEncode(json));
    BackupError? err(Uint8List bytes) {
      try {
        service(dst, dstPhotos).parse(bytes);
        return null;
      } on BackupException catch (e) {
        return e.error;
      }
    }

    Map<String, Object?> valid() => {
          'format': 'sistema-backup',
          'formatVersion': 1,
          'schemaVersion': dst.schemaVersion,
          'tables': <String, Object?>{},
        };

    test('не JSON', () => expect(err(Uint8List.fromList([0xff, 0xfe, 0x00])), BackupError.notJson));
    test('чужой JSON', () {
      expect(err(enc({'hello': 1})), BackupError.wrongFormat);
      expect(err(enc([1, 2])), BackupError.wrongFormat);
    });
    test('версия формата', () => expect(err(enc({...valid(), 'formatVersion': 2})), BackupError.unsupportedFormatVersion));
    test('схема новее текущей', () {
      expect(err(enc({...valid(), 'schemaVersion': dst.schemaVersion + 1})), BackupError.newerSchema);
    });
    test('битые таблицы/фото', () {
      expect(err(enc({...valid(), 'tables': []})), BackupError.invalid);
      expect(err(enc({...valid(), 'tables': {'goals': 5}})), BackupError.invalid);
      expect(err(enc({...valid(), 'tables': {'goals': [1]}})), BackupError.invalid);
      expect(err(enc({...valid(), 'photos': {'../evil.jpg': 'AA=='}})), BackupError.invalid);
      expect(err(enc({...valid(), 'photos': {'/abs.jpg': 'AA=='}})), BackupError.invalid);
      expect(err(enc({...valid(), 'photos': {'a.jpg': '%%%'}})), BackupError.invalid);
    });
    test('корректный файл', () => expect(err(enc(valid())), isNull));
  });

  test('неизвестные таблицы и колонки игнорируются, старая схема принимается', () async {
    final now = DateTime.utc(2026, 1, 2).millisecondsSinceEpoch ~/ 1000;
    final bytes = utf8.encode(jsonEncode({
      'format': 'sistema-backup',
      'formatVersion': 1,
      'schemaVersion': 1,
      'tables': {
        'future_table': [
          {'x': 1},
        ],
        'goals': [
          {
            'id': 'g9',
            'updated_at': now,
            'device_id': 'other-device',
            'kind': 'sleep',
            'mood': 'excellent', // колонки нет в схеме
            'sort_order': 3,
          },
        ],
        'app_settings': [
          {'key': 'device.id', 'value': 'stolen'},
          {'key': 'onboarding.step', 'value': '4'},
        ],
      },
    }));
    final myDevice = await dst.deviceId();
    final restore = service(dst, dstPhotos);
    final preview = restore.parse(bytes);
    expect(preview.rowCounts.keys, isNot(contains('future_table')));
    await restore.importData(preview);
    final goal = await dst.select(dst.goals).getSingle();
    expect(goal.id, 'g9');
    expect(goal.sortOrder, 3);
    expect(goal.priority, 2); // значение по умолчанию
    expect(goal.version, 1);
    expect(goal.updatedAt.toUtc(), DateTime.utc(2026, 1, 2));
    expect(await dst.getSetting('device.id'), myDevice);
    expect(await dst.getSetting('onboarding.step'), '4');
  });

  test('ошибка вставки откатывает транзакцию', () async {
    final dev = await dst.deviceId();
    await dst.into(dst.goals).insert(GoalsCompanion.insert(
        id: 'keep', updatedAt: DateTime.utc(2025), deviceId: dev, kind: 'study'));
    final bytes = utf8.encode(jsonEncode({
      'format': 'sistema-backup',
      'formatVersion': 1,
      'schemaVersion': dst.schemaVersion,
      'tables': {
        'goals': [
          {'id': 'broken'}, // нет обязательных колонок
        ],
      },
    }));
    final restore = service(dst, dstPhotos);
    await expectLater(restore.importData(restore.parse(bytes)), throwsA(anything));
    expect((await dst.select(dst.goals).get()).map((g) => g.id), ['keep']);
  });

  test('имя файла', () {
    expect(BackupService.fileName(DateTime(2026, 3, 7, 9, 5)), 'sistema-backup-20260307-0905.json');
  });
}
