import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/data/questionnaire_repository.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/core/voice/tts_service.dart';
import 'package:sistema/domain/quests/section_hooks.dart';
import 'package:sistema/features/plan/data/plan_repository.dart';
import 'package:sistema/features/workouts/workouts_providers.dart';
import 'package:sistema/features/workouts/workouts_screen.dart';
import 'package:sistema/l10n/app_localizations.dart';

import '../../helpers/test_db.dart';
import 'fakes.dart';

class _Env {
  final db = memoryDb();
  final clock = FakeClock(DateTime(2026, 10, 19, 18)); // понедельник
  final ticker = ManualTicker();
  final tts = FakeTts();
  final hooks = FakeHooks();
  final wakelock = FakeWakelock();

  Widget app() => ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          acceptedPlanProvider.overrideWith((ref) => Stream.value(null)),
          workoutsClockProvider.overrideWithValue(clock.call),
          workoutTickerFactoryProvider.overrideWithValue(() => ticker),
          ttsServiceProvider.overrideWithValue(tts),
          sectionQuestHooksProvider.overrideWithValue(hooks),
          workoutWakelockProvider.overrideWithValue(wakelock),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ru'),
          home: const WorkoutsScreen(),
        ),
      );

  Future<void> setUpData(WidgetTester tester, {String? injuries}) => tester.runAsync(() async {
        final q = QuestionnaireRepository(db);
        await q.write(QuestionnaireSection.training, {
          'level': 'intermediate',
          'minutesPerDay': 20,
          'days': [1, 3, 5],
        });
        await q.write(QuestionnaireSection.health, {'injuries': ?injuries});
      });
}

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

Future<void> _tap(WidgetTester tester, Key key) async {
  await tester.ensureVisible(find.byKey(key));
  await tester.pump();
  await tester.tap(find.byKey(key));
  await tester.pump();
}

void main() {
  testWidgets('первое открытие: программа из шаблона, дни, история; пересоздание', (tester) async {
    final env = _Env();
    await env.setUpData(tester, injuries: 'спина');
    await tester.pumpWidget(env.app());
    await _settle(tester);

    expect(find.byKey(const Key('wrk-today')), findsOneWidget);
    expect(find.text('По программе — день A'), findsOneWidget);
    expect(find.byKey(const Key('wrk-start-today')), findsOneWidget);
    expect(find.byKey(const Key('wrk-gentle')), findsOneWidget);
    expect(find.text('Средний'), findsOneWidget);
    expect(find.text('Выполненных недель: 0'), findsOneWidget);
    for (final d in ['A', 'B', 'C']) {
      expect(find.byKey(Key('wrk-day-$d')), findsOneWidget);
    }
    expect(find.text('Ходьба на месте'), findsWidgets);
    expect(find.text('Тренировок пока нет.'), findsOneWidget);

    final first = await tester.runAsync(() => env.db.select(env.db.workoutPrograms).get());
    expect(first!.length, 1);

    await _tap(tester, const Key('wrk-regenerate'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('wrk-regenerate-ok')));
    await _settle(tester);
    final all = await tester.runAsync(() => env.db.select(env.db.workoutPrograms).get());
    expect(all!.length, 2);
    expect(all.where((r) => r.active).length, 1);

    await _dispose(tester, env.db);
  });

  testWidgets('тренировка: подход, пропуски, конец → сессия, хук, голос, wakelock', (tester) async {
    final env = _Env();
    await env.setUpData(tester);
    await tester.pumpWidget(env.app());
    await _settle(tester);

    await _tap(tester, const Key('wrk-start-today'));
    await _settle(tester);
    expect(env.wakelock.on, isTrue);
    expect(find.text('ПРИГОТОВЬТЕСЬ'), findsOneWidget);
    expect(find.text('Подход 1 из 1'), findsOneWidget);
    expect(find.byKey(const Key('wrk-timer')), findsOneWidget);

    // Подготовка 10 с → разминка (работа на время).
    for (var i = 0; i < 10; i++) {
      env.clock.advance(const Duration(seconds: 1));
      env.ticker.tick();
    }
    await tester.pump();
    expect(find.byKey(const Key('wrk-done-set')), findsOneWidget);
    env.clock.advance(const Duration(seconds: 30));
    env.ticker.tick();
    await _tap(tester, const Key('wrk-done-set'));
    expect(find.byKey(const Key('wrk-skip-rest')), findsOneWidget);

    // Пауза/продолжить.
    await _tap(tester, const Key('wrk-pause'));
    expect(find.text('ПАУЗА'), findsOneWidget);
    expect(find.text('ПРОДОЛЖИТЬ'), findsOneWidget);
    await _tap(tester, const Key('wrk-pause'));

    // Остальные упражнения — пропуском.
    var guard = 0;
    while (find.byKey(const Key('wrk-skip-exercise')).evaluate().isNotEmpty && guard++ < 20) {
      await _tap(tester, const Key('wrk-skip-exercise'));
    }
    await _settle(tester);
    expect(find.byKey(const Key('wrk-finished')), findsOneWidget);
    expect(find.byKey(const Key('wrk-weight-assumed')), findsOneWidget);
    expect(env.hooks.workouts, [1]);
    expect(env.tts.spoken.first, 'Приготовьтесь. Ходьба на месте.');
    expect(env.tts.spoken, contains('Тренировка завершена. Отличная работа!'));
    expect(env.tts.languages.toSet(), {'ru'});

    final rows = await tester.runAsync(() => env.db.select(env.db.workoutSessions).get());
    expect(rows!.single.finishedAt, isNotNull);
    expect(rows.single.dayKey, 'A');
    expect(rows.single.activeSeconds, 40);

    await _tap(tester, const Key('wrk-finish-done'));
    await _settle(tester);
    expect(env.wakelock.on, isFalse);
    expect(find.byKey(const Key('wrk-history')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('wrk-history')));
    expect(find.textContaining('завершена'), findsOneWidget);

    await _dispose(tester, env.db);
  });

  testWidgets('прерывание: подтверждение, частичное сохранение без finishedAt и без хука', (tester) async {
    final env = _Env();
    await env.setUpData(tester);
    await tester.pumpWidget(env.app());
    await _settle(tester);

    await _tap(tester, const Key('wrk-start-today'));
    await _settle(tester);
    env.clock.advance(const Duration(seconds: 6));
    env.ticker.tick();
    await tester.pump();

    await tester.tap(find.byTooltip('Назад'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const Key('wrk-stop-confirm')), findsOneWidget);
    await tester.tap(find.byKey(const Key('wrk-stop-ok')));
    await _settle(tester);

    expect(find.byKey(const Key('wrk-today')), findsOneWidget);
    expect(env.wakelock.on, isFalse);
    expect(env.hooks.workouts, isEmpty);
    final rows = await tester.runAsync(() => env.db.select(env.db.workoutSessions).get());
    expect(rows!.single.finishedAt, isNull);
    expect(rows.single.activeSeconds, 6);
    expect(env.ticker.active, isFalse);

    await _dispose(tester, env.db);
  });
}
