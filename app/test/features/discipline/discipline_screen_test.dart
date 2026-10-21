import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/data/questionnaire_repository.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/quests/quest_api.dart';
import 'package:sistema/features/discipline/discipline_providers.dart';
import 'package:sistema/features/discipline/discipline_screen.dart';
import 'package:sistema/l10n/app_localizations.dart';

import '../../helpers/test_db.dart';
import '../shop/fake_quest_service.dart';

final _now = DateTime(2026, 10, 21, 12);

Widget _app(AppDatabase db, FakeQuestService service) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        questServiceProvider.overrideWithValue(service),
        disciplineClockProvider.overrideWithValue(() => _now),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ru'),
        home: const DisciplineScreen(),
      ),
    );

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

/// Снять экран и закрыть БД в реальном времени: отписка drift-потоков завершается таймерами,
/// и db.close в tearDown (под fake async) иначе ждёт вечно.
Future<void> _dispose(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(db.close);
}

void main() {
  testWidgets('выключен: правила на сегодня и ручное включение', (tester) async {
    final db = memoryDb();
    final service = FakeQuestService(db: db, diamonds: 50);
    await tester.pumpWidget(_app(db, service));
    await _settle(tester);

    expect(find.text('ВЫКЛЮЧЕН'), findsOneWidget);
    expect(find.text('Подъём в 06:00'), findsOneWidget);
    expect(find.text('Доп. тренировка: 10 мин'), findsOneWidget);
    expect(find.text('Отбой в 22:00'), findsOneWidget);
    expect(find.byKey(const Key('dsc-blocker')), findsOneWidget);
    expect(find.byKey(const Key('dsc-disable')), findsNothing);

    await tester.tap(find.byKey(const Key('dsc-enable')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('dsc-confirm-enable')));
    await _settle(tester);

    expect(service.disciplineCalls.single, (active: true, reasonKey: 'manual'));
    expect(find.text('ВКЛЮЧЁН'), findsOneWidget);
    expect(find.textContaining('включён вручную'), findsOneWidget);
    expect(find.textContaining('вручную, когда баланс не отрицательный'), findsOneWidget);

    await tester.tap(find.byKey(const Key('dsc-disable')));
    await _settle(tester);
    expect(service.disciplineCalls.last, (active: false, reasonKey: null));
    expect(find.text('ВЫКЛЮЧЕН'), findsOneWidget);
    await _dispose(tester, db);
  });

  testWidgets('включён из-за минуса: выключить нельзя, выключится при плюсе', (tester) async {
    final db = memoryDb();
    final service = FakeQuestService(db: db, diamonds: -10, discipline: true);
    await tester.pumpWidget(_app(db, service));
    await _settle(tester);

    expect(find.text('ВКЛЮЧЁН'), findsOneWidget);
    expect(find.text('-10 ◆'), findsOneWidget);
    expect(find.textContaining('отрицательный баланс'), findsOneWidget);
    expect(find.textContaining('когда баланс станет положительным'), findsOneWidget);
    expect(find.byKey(const Key('dsc-disable-locked')), findsOneWidget);
    expect(find.byKey(const Key('dsc-disable')), findsNothing);
    expect(find.byKey(const Key('dsc-enable')), findsNothing);
    await _dispose(tester, db);
  });

  testWidgets('нагрузка по уровню из анкеты, при травмах — прогулка', (tester) async {
    final db = memoryDb();
    await tester.runAsync(
      () => QuestionnaireRepository(db).write(QuestionnaireSection.training, {'level': 'advanced'}),
    );
    await tester.pumpWidget(_app(db, FakeQuestService(db: db, diamonds: 5)));
    await _settle(tester);
    expect(find.text('Доп. тренировка: 20 мин'), findsOneWidget);

    await tester.runAsync(() => QuestionnaireRepository(db).write(QuestionnaireSection.health, {'injuries': 'колено'}));
    await _settle(tester);
    expect(find.text('Спокойная прогулка: 20 мин'), findsOneWidget);
    expect(find.textContaining('Доп. тренировка'), findsNothing);
    await _dispose(tester, db);
  });
}
