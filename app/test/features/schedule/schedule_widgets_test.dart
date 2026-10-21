import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/schedule/data/schedule_repository.dart';
import 'package:sistema/features/schedule/schedule_editor.dart';
import 'package:sistema/features/schedule/schedule_logic.dart';
import 'package:sistema/features/schedule/schedule_screen.dart';
import 'package:sistema/l10n/app_localizations.dart';

import '../../helpers/test_db.dart';

final _now = DateTime(2026, 10, 21, 10, 46); // среда

Widget _app(AppDatabase db, Widget child) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        scheduleClockProvider.overrideWithValue(() => _now),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ru'),
        home: child,
      ),
    );

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}

void main() {
  testWidgets('редактор: включение чередования и переключение недели', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    final repo = ScheduleRepository(db, clock: () => _now);
    await tester.pumpWidget(_app(db, const Scaffold(body: SingleChildScrollView(child: ScheduleEditor()))));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    expect(find.text('Чередование недель (неделя 1/2)'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    expect(find.text('Сейчас: неделя 1'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('sch-switch-week')));
    await tester.tap(find.byKey(const Key('sch-switch-week')));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    expect(find.text('Сейчас: неделя 2'), findsOneWidget);
    await tester.runAsync(() async {
      expect(ScheduleLogic.weekNumber(_now, await repo.getConfig()), 2);
    });
    await _dispose(tester);
  });

  testWidgets('экран: заголовок недели, выход из дома, пункт в ленте', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    final repo = ScheduleRepository(db, clock: () => _now);
    await tester.runAsync(() async {
      await repo.setAlternation(true);
      await repo.updateSettings(const ScheduleSettingsCompanion(commuteMinutes: Value(40)));
      await repo.saveEntry(const ScheduleEntry(
        id: '',
        kind: ScheduleItemKind.lesson,
        title: 'Матанализ',
        weekday: DateTime.wednesday,
        startMinute: 9 * 60,
        durationMinutes: 90,
      ));
    });
    await tester.pumpWidget(_app(db, const ScheduleScreen()));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('НЕДЕЛЯ 1 · СР · 21.10'), findsOneWidget);
    expect(find.text('Выход из дома в 08:20'), findsOneWidget);
    expect(find.text('Матанализ'), findsOneWidget);

    // Четверг — пар нет.
    await tester.tap(find.bySemanticsLabel(RegExp('^Четверг 22.10')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('В этот день выходить не нужно'), findsOneWidget);
    await _dispose(tester);
  });
}
