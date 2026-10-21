import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/activity/activity_api.dart';
import 'package:sistema/core/activity/activity_providers.dart';
import 'package:sistema/core/activity/step_repository.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/daily.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/quests/section_hooks.dart';
import 'package:sistema/features/activity/steps_panel.dart';
import 'package:sistema/features/activity/steps_week_chart.dart';
import 'package:sistema/l10n/app_localizations.dart';

import '../../core/activity/fakes.dart';
import '../../helpers/test_db.dart';

final _now = DateTime(2026, 10, 21, 12);

Widget _app(AppDatabase db, FakeStepCounter counter, RecordingHooks hooks) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        stepCounterProvider.overrideWithValue(counter),
        sectionQuestHooksProvider.overrideWithValue(hooks),
        activityClockProvider.overrideWithValue(() => _now),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ru'),
        home: const Scaffold(body: SingleChildScrollView(child: StepsPanel(animateIn: false))),
      ),
    );

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
  }
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _dispose(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(db.close);
}

String _stepsText(WidgetTester tester) => tester.widget<Text>(find.byKey(const Key('act-steps'))).data!;

/// Цифры без разделителей групп (в ru — неразрывный пробел).
String _digits(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

void main() {
  testWidgets('доступ есть: шаги, дистанция, этажи, график; кнопок доступа нет', (tester) async {
    final db = memoryDb();
    final counter = FakeStepCounter(steps: 5321)
      ..distanceM = 3870
      ..floors = 4;
    final hooks = RecordingHooks();
    await tester.runAsync(() =>
        StepRepository(db).upsert(StepDay(day: DateTime(2026, 10, 19), steps: 9000), StepSourceKind.coreMotion));
    await tester.pumpWidget(_app(db, counter, hooks));
    await _settle(tester);

    expect(_digits(_stepsText(tester)), '5321');
    expect(find.textContaining('3,87 км'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('67%'), findsOneWidget);
    expect(find.byType(StepsWeekChart), findsOneWidget);
    expect(find.byKey(const Key('act-allow')), findsNothing);
    expect(find.byKey(const Key('act-manual')), findsNothing);
    expect(hooks.steps, [5321]);
    await _dispose(tester, db);
  });

  testWidgets('нет доступа: «Разрешить» → запрос → шаги появляются', (tester) async {
    final db = memoryDb();
    final counter = FakeStepCounter(steps: 1200, granted: false);
    await tester.pumpWidget(_app(db, counter, RecordingHooks()));
    await _settle(tester);

    expect(_stepsText(tester), '0');
    expect(find.text('Разрешите доступ к датчикам движения — шаги будут считаться сами.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('act-allow')));
    await _settle(tester);

    expect(counter.permissionRequests, 1);
    expect(_digits(_stepsText(tester)), '1200');
    expect(find.byKey(const Key('act-allow')), findsNothing);
    await _dispose(tester, db);
  });

  testWidgets('счётчика нет: ручной ввод сохраняется как manual', (tester) async {
    final db = memoryDb();
    final counter = FakeStepCounter(available: false);
    final hooks = RecordingHooks();
    await tester.pumpWidget(_app(db, counter, hooks));
    await _settle(tester);

    expect(find.byKey(const Key('act-allow')), findsNothing);
    expect(find.text('Счётчика шагов на устройстве нет — введите шаги вручную.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('act-manual')));
    await tester.pump();
    await tester.enterText(find.descendant(of: find.byKey(const Key('act-manual-field')), matching: find.byType(EditableText)), '7000');
    await tester.pump();
    await tester.tap(find.byKey(const Key('act-manual-save')));
    await _settle(tester);

    expect(_digits(_stepsText(tester)), '7000');
    expect(find.byKey(const Key('act-manual-field')), findsNothing);
    final rows = await tester.runAsync(() => db.select(db.stepLogs).get());
    expect(rows!.single.source, 'manual');
    expect(rows.single.day, DateTime(2026, 10, 21));
    expect(hooks.steps, [7000]);
    await _dispose(tester, db);
  });
}
