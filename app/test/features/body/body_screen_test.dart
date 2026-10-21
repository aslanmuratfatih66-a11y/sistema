import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/quests/section_hooks.dart';
import 'package:sistema/features/body/body_screen.dart';
import 'package:sistema/features/body/data/body_photos.dart';
import 'package:sistema/features/body/data/sleep_repository.dart';
import 'package:sistema/features/onboarding/questionnaire_a/camera/capture_flow.dart';
import 'package:sistema/features/onboarding/questionnaire_a/data/photo_repository.dart';
import 'package:sistema/l10n/app_localizations.dart';

import '../../helpers/test_db.dart';

class _FakeHooks extends NoopSectionQuestHooks {
  final care = <CareRoutine>[];
  final sleep = <({DateTime bedAt, DateTime wakeAt})>[];

  @override
  Future<void> careRoutineDone(CareRoutine routine, {DateTime? at}) async => care.add(routine);

  @override
  Future<void> sleepLogged({required DateTime bedAt, required DateTime wakeAt}) async =>
      sleep.add((bedAt: bedAt, wakeAt: wakeAt));
}

class _FakePhotoSource implements BodyPhotoSource {
  _FakePhotoSource(this.path);

  final String path;

  @override
  Future<String?> capture(BuildContext context, {required PhotoPose pose, required String title, required String instruction}) async =>
      path;

  @override
  Future<String?> pickFromGallery() async => path;
}

final _now = DateTime(2026, 10, 21, 12);

Widget _app(AppDatabase db, _FakeHooks hooks, {List<Override> extra = const []}) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        bodyClockProvider.overrideWithValue(() => _now),
        sectionQuestHooksProvider.overrideWithValue(hooks),
        cameraAvailableProvider.overrideWithValue(false),
        photoRootProvider.overrideWith((ref) async => throw UnsupportedError('нет файлов в тесте')),
        ...extra,
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ru'),
        home: const BodyScreen(),
      ),
    );

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _dispose(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(db.close);
}

Future<void> _tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(Key(key));
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await _settle(tester);
}

void main() {
  testWidgets('панели, запись сна по расписанию → «Энергия» и хук', (tester) async {
    final db = memoryDb();
    final hooks = _FakeHooks();
    await tester.pumpWidget(_app(db, hooks));
    await _settle(tester);

    expect(find.text('ТЕЛО И ЗДОРОВЬЕ'), findsOneWidget);
    expect(find.text('Сон за прошлую ночь не записан.'), findsOneWidget);
    for (final k in ['bdy-panel-sleep', 'bdy-panel-measure', 'bdy-panel-photo', 'bdy-panel-care', 'bdy-panel-swelling']) {
      expect(find.byKey(Key(k)), findsOneWidget);
    }

    await _tapKey(tester, 'bdy-sleep-open-log');
    await _settle(tester);
    expect(find.text('23:00'), findsOneWidget);
    expect(find.text('07:00'), findsOneWidget);
    expect(find.text('8 ч 0 мин'), findsWidgets);
    await _tapKey(tester, 'bdy-sleep-save');
    await _settle(tester);

    expect(hooks.sleep.single, (bedAt: DateTime(2026, 10, 20, 23), wakeAt: DateTime(2026, 10, 21, 7)));
    expect(find.text('Сон за прошлую ночь не записан.'), findsNothing);
    expect(find.text('100%'), findsOneWidget);
    await _dispose(tester, db);
  });

  testWidgets('чек-лист ухода: закрытие утренней рутины вызывает хук', (tester) async {
    final db = memoryDb();
    final hooks = _FakeHooks();
    await tester.pumpWidget(_app(db, hooks));
    await _settle(tester);

    await _tapKey(tester, 'bdy-care-open');
    await _settle(tester);
    for (final item in ['cleanse', 'moisturize', 'sunscreen']) {
      final row = find.byKey(Key('bdy-care-morning-$item'));
      await tester.ensureVisible(row);
      await tester.pump();
      await tester.tap(find.descendant(of: row, matching: find.byType(GestureDetector)).first);
      await _settle(tester);
    }
    expect(hooks.care, [CareRoutine.morning]);
    expect(find.text('3/3'), findsOneWidget);
    await _dispose(tester, db);
  });

  testWidgets('замер: добавить вес → в панели', (tester) async {
    final db = memoryDb();
    await tester.pumpWidget(_app(db, _FakeHooks()));
    await _settle(tester);

    await _tapKey(tester, 'bdy-measure-open');
    await _tapKey(tester, 'bdy-measure-add');
    await tester.enterText(find.descendant(of: find.byKey(const Key('bdy-measure-weight')), matching: find.byType(EditableText)), '72,5');
    await tester.pump();
    await _tapKey(tester, 'bdy-measure-save');
    await _settle(tester);
    expect(find.textContaining('72.5'), findsWidgets);
    expect((await tester.runAsync(() => db.select(db.bodyMeasurements).get()))!.single.weightKg, 72.5);
    await _dispose(tester, db);
  });

  testWidgets('фото-дневник: фото из галереи сохраняется в серию дневника', (tester) async {
    final db = memoryDb();
    final dir = (await tester.runAsync(() => Directory.systemTemp.createTemp('bdy_photo_')))!;
    addTearDown(() => dir.delete(recursive: true));
    final src = File('${dir.path}${Platform.pathSeparator}src.jpg');
    await tester.runAsync(() => src.writeAsBytes(const [1, 2, 3]));

    await tester.pumpWidget(_app(db, _FakeHooks(), extra: [
      bodyPhotoSourceProvider.overrideWithValue(_FakePhotoSource(src.path)),
      photoStorageProvider.overrideWithValue(PhotoStorage(rootDir: () async => dir)),
    ]));
    await _settle(tester);

    await _tapKey(tester, 'bdy-photo-open');
    expect(find.byKey(const Key('bdy-photo-camera')), findsNothing, reason: 'камера недоступна');
    await tester.tap(find.byKey(const Key('bdy-photo-gallery')));
    // Копирование файла — настоящий ввод-вывод: даём ему завершиться порциями.
    for (var i = 0; i < 10; i++) {
      await _settle(tester);
    }

    final rows = (await tester.runAsync(() => db.select(db.photos).get()))!;
    expect(rows.single.kind, PhotoKind.body.name);
    expect(rows.single.pose, PhotoPose.bodyFront.name);
    expect(rows.single.sessionId, 'diary-20261021');
    expect(await tester.runAsync(() => src.exists()), isTrue, reason: 'файл галереи не удаляется');
    await _dispose(tester, db);
  });
}
