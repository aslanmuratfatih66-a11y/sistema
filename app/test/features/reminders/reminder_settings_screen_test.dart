import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/notifications/local_reminder_scheduler.dart';
import 'package:sistema/core/notifications/notification_api.dart';
import 'package:sistema/core/notifications/reminder_prefs_repository.dart';
import 'package:sistema/features/reminders/reminder_settings_screen.dart';
import 'package:sistema/l10n/app_localizations.dart';
import 'package:sistema/ui/ui.dart';

import '../../helpers/test_db.dart';

class _FakeScheduler implements ReminderScheduler, ReminderPermissionProbe {
  bool granted = false;
  int requests = 0;
  final shown = <String>[];

  @override
  Future<ReminderPermissionState> permissionState() async =>
      ReminderPermissionState(notifications: granted, exactAlarms: true);

  @override
  Future<bool> requestPermission() async {
    requests++;
    return granted = true;
  }

  @override
  Future<void> showNow({required String title, required String body}) async => shown.add(title);

  @override
  Future<void> init({required Future<void> Function(ReminderResponse) onResponse}) async {}

  @override
  Future<void> sync(List<ReminderRequest> upcoming, ReminderPrefs prefs, {required DateTime now}) async {}

  @override
  Future<void> cancelInstance(String instanceId) async {}
}

void main() {
  final l = lookupAppLocalizations(const Locale('ru'));

  Future<void> pump(WidgetTester tester, AppDatabase db, ReminderScheduler scheduler) async {
    tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        reminderSchedulerProvider.overrideWithValue(scheduler),
      ],
      child: MaterialApp(
        theme: buildSystemTheme(),
        locale: const Locale('ru'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const ReminderSettingsScreen(),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600)); // данные пришли — панели появляются
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  testWidgets('переключатели сохраняются, тихие часы, разрешение и проверка', (tester) async {
    final db = memoryDb();
    final scheduler = _FakeScheduler();
    await pump(tester, db, scheduler);

    expect(find.text(l.ntfNag), findsOneWidget);
    expect(find.text(l.ntfVoiceHint), findsOneWidget);
    expect(find.text(l.ntfPermDenied), findsOneWidget);

    await tester.tap(find.text(l.ntfNag));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text(l.ntfQuietEnabled));
    await tester.pump(const Duration(milliseconds: 300));
    final saved = await tester.runAsync(() => ReminderPrefsRepository(db).load());
    expect(saved!.nag, isFalse);
    expect(saved.quiet?.startMinute, 23 * 60);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('23:00'), findsOneWidget);
    expect(find.text('07:00'), findsOneWidget);

    await tester.tap(find.text(l.ntfPermRequest.toUpperCase()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(scheduler.requests, 1);
    expect(find.text(l.ntfPermGranted), findsOneWidget);

    await tester.tap(find.text(l.ntfTest.toUpperCase()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(scheduler.shown, [l.ntfTestTitle]);
    expect(find.text(l.ntfTestSent), findsOneWidget);

    await finish(tester);
    await db.close();
  });
}
