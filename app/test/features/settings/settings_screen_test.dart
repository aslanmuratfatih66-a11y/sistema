import 'dart:convert';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/domain/quests/quest_api.dart';
import 'package:sistema/core/capabilities/capability_service.dart';
import 'package:sistema/core/data/profile_repository.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/features/onboarding/onboarding_progress.dart';
import 'package:sistema/features/onboarding/onboarding_step.dart';
import 'package:sistema/features/settings/backup/backup_platform.dart';
import 'package:sistema/features/settings/backup/backup_service.dart';
import 'package:sistema/features/settings/settings_screen.dart';
import 'package:sistema/l10n/app_localizations.dart';
import 'package:sistema/ui/ui.dart';

import '../../helpers/test_db.dart';
import '../quests/fake_quest_service.dart';

class _FakeSaver implements BackupSaver {
  String? name;
  Uint8List? bytes;

  @override
  Future<void> save(String fileName, Uint8List bytes, {Rect? origin}) async {
    name = fileName;
    this.bytes = bytes;
  }
}

class _FakePicker implements BackupPicker {
  _FakePicker(this.bytes);
  Uint8List? bytes;

  @override
  Future<Uint8List?> pick() async => bytes;
}

void main() {
  late AppDatabase db;
  late _FakeSaver saver;
  late _FakePicker picker;
  late OnboardingProgress progress;

  setUp(() {
    db = memoryDb();
    saver = _FakeSaver();
    picker = _FakePicker(null);
    progress = OnboardingProgress.memory(completed: true, stepIndex: 11, introSeen: true);
  });
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        deviceCapabilitiesProvider.overrideWith(
          (ref) async => DeviceCapabilities(
            platform: 'ios',
            available: const {},
            provisioningExpiresAt: DateTime(2026, 10, 28),
          ),
        ),
        backupServiceProvider.overrideWith((ref) => BackupService(db)),
        backupSaverProvider.overrideWithValue(saver),
        backupPickerProvider.overrideWithValue(picker),
        onboardingProgressProvider.overrideWithValue(progress),
        questServiceProvider.overrideWithValue(FakeQuestService(now: DateTime(2026, 10, 21, 10, 46))),
      ],
      child: MaterialApp(
        theme: buildSystemTheme(),
        locale: const Locale('ru'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const Scaffold(body: SettingsScreen()),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  Future<void> tapVisible(WidgetTester tester, Finder f) async {
    await tester.scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(f);
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('все 12 разделов анкеты и итоги', (tester) async {
    await ProfileRepository(db).update(const ProfilesCompanion(name: Value('Мурат'), heightCm: Value(178)));
    final dev = await db.deviceId();
    for (final id in ['a', 'b', 'c']) {
      await db.into(db.goals).insert(GoalsCompanion.insert(id: id, updatedAt: DateTime.utc(2026), deviceId: dev, kind: 'study'));
    }
    await pump(tester);
    for (final step in OnboardingStep.values) {
      expect(find.byKey(Key('settings-step-${step.name}'), skipOffstage: false), findsOneWidget);
    }
    expect(find.text('Мурат'), findsOneWidget);
    expect(find.text('178 см'), findsOneWidget);
    expect(find.text('3 цели'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('смена языка пишет Profiles.locale', (tester) async {
    await pump(tester);
    await tapVisible(tester, find.text('TÜRKÇE'));
    expect((await ProfileRepository(db).get())?.locale, 'tr');

    await tapVisible(tester, find.text('КАК В СИСТЕМЕ'));
    final p = await ProfileRepository(db).get();
    expect(p, isNotNull);
    expect(p!.locale, isNull);

    await tapVisible(tester, find.text('РУССКИЙ'));
    expect((await ProfileRepository(db).get())?.locale, 'ru');
    await finish(tester);
  });

  testWidgets('экспорт отдаёт файл резервной копии', (tester) async {
    await ProfileRepository(db).update(const ProfilesCompanion(name: Value('Мурат')));
    await pump(tester);
    await tester.runAsync(() async {
      await tapVisible(tester, find.byKey(const Key('settings-export')));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    expect(saver.name, startsWith('sistema-backup-'));
    final json = jsonDecode(utf8.decode(saver.bytes!)) as Map;
    expect(json['format'], 'sistema-backup');
    expect(((json['tables'] as Map)['profiles'] as List).single['name'], 'Мурат');
    await finish(tester);
  });

  testWidgets('импорт: неверный файл — сообщение об ошибке', (tester) async {
    picker.bytes = utf8.encode('{"hello": 1}');
    await pump(tester);
    await tapVisible(tester, find.byKey(const Key('settings-import')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Это не резервная копия Системы.'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('импорт: предпросмотр и замена удержанием', (tester) async {
    // Готовим файл из другой БД.
    final other = memoryDb();
    addTearDown(other.close);
    await ProfileRepository(other).update(const ProfilesCompanion(name: Value('Импорт'), locale: Value('ru')));
    picker.bytes = await BackupService(other).exportBytes();

    await pump(tester);
    await tapVisible(tester, find.byKey(const Key('settings-import')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('settings-import-preview')), findsOneWidget);
    expect(find.textContaining('Профиль: 1'), findsOneWidget);
    expect(find.textContaining('Фото в файле нет'), findsOneWidget);

    final gesture = await tester.startGesture(tester.getCenter(find.byKey(const Key('settings-import-confirm'))));
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await gesture.up();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect((await ProfileRepository(db).get())?.name, 'Импорт');
    expect(find.text('Данные импортированы'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('пройти анкету заново — после подтверждения', (tester) async {
    await pump(tester);
    await tapVisible(tester, find.byKey(const Key('settings-restart')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(progress.completed, isTrue);
    await tester.tap(find.byKey(const Key('settings-restart-confirm')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(progress.completed, isFalse);
    expect(progress.stepIndex, 0);
    await finish(tester);
  });
}
