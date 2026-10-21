import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/quests/quest_api.dart';
import 'package:sistema/features/quests/quests_screen.dart';
import 'package:sistema/features/quests/widgets/day_controls.dart';
import 'package:sistema/features/quests/widgets/quest_sheet.dart';
import 'package:sistema/features/quests/widgets/weekly_boss_panel.dart';
import 'package:sistema/l10n/app_localizations.dart';
import 'package:sistema/ui/ui.dart';

import '../home/tab_test_utils.dart';
import 'fake_quest_service.dart';

const _scrollKey = Key('quests-scroll');

QuestRow _row(WidgetTester tester, String id) =>
    tester.widget<QuestRow>(find.descendant(of: find.byKey(ValueKey('quest-$id')), matching: find.byType(QuestRow)));

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> _tapVisible(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await _settle(tester);
}

Future<void> _openSheet(WidgetTester tester, String text) async {
  await _tapVisible(tester, find.text(text));
  expect(find.byType(QuestSheet), findsOneWidget);
}

void main() {
  late AppLocalizations l;
  setUpAll(() async => l = await AppLocalizations.delegate.load(const Locale('ru')));

  testWidgets('ru: сегодня — ежедневные квесты, итоговый штраф, босс, отметки и пауза', (tester) async {
    await pumpTab(tester, const QuestsScreen(), const Locale('ru'));

    expect(find.text(l.navQuests.toUpperCase()), findsOneWidget);
    expect(panelTitles(tester), contains(l.homeDailyTitle));
    expect(find.byType(QuestRow), findsNWidgets(7));
    expect(find.text(l.homeDailyPenaltyTotal('85')), findsOneWidget);
    // Просроченный — красным, выполненный — отмечен.
    expect(_row(tester, 'breakfast').overdue, isTrue);
    expect(_row(tester, 'wake').done, isTrue);
    expect(_row(tester, 'workout').subtasks, hasLength(3));
    expect(_row(tester, 'water').progressText, l.homeBossProgress(1200, 2500));

    await scrollToBottom(tester, _scrollKey);
    expect(find.byType(WeeklyBossPanel), findsOneWidget);
    expect(tester.widget<SysPanel>(find.widgetWithText(SysPanel, l.homeBossTitle.toUpperCase())).tone, PanelTone.boss);
    expect(find.byType(DayMarksPanel), findsOneWidget);
    expect(find.byType(PausePanel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('чекбокс — «Выполнено» в движке, штраф дня пересчитывается', (tester) async {
    final service = FakeQuestService(now: fixedNow);
    await pumpTab(tester, const QuestsScreen(), const Locale('ru'), service: service);

    _row(tester, 'breakfast').onToggle!(true);
    await _settle(tester);
    expect(service.calls, contains('complete:breakfast'));
    expect(_row(tester, 'breakfast').done, isTrue);
    expect(_row(tester, 'breakfast').overdue, isFalse);
    expect(_row(tester, 'breakfast').onToggle, isNull);
    expect(find.text(l.homeDailyPenaltyTotal('80')), findsOneWidget);
  });

  testWidgets('вкладки: неделя — по дням и босс, история — журнал с ◆ и опытом', (tester) async {
    final service = FakeQuestService(
      now: fixedNow,
      history: [
        HistoryEntry(
          id: 'h1',
          type: QuestEventType.completed,
          occurredAt: fixedNow.subtract(const Duration(hours: 3)),
          title: const QuestTitle(text: 'Подъём до 07:00'),
          delta: const GameReward(diamonds: 10, xp: 15),
        ),
        HistoryEntry(
          id: 'h2',
          type: QuestEventType.failed,
          occurredAt: fixedNow.subtract(const Duration(days: 1)),
          title: const QuestTitle(text: 'Отбой до 23:00'),
          delta: const GameReward(diamonds: -15),
        ),
      ],
    );
    await pumpTab(tester, const QuestsScreen(), const Locale('ru'), service: service);

    await tester.tap(find.text(l.qstViewWeek.toUpperCase()));
    await _settle(tester);
    expect(find.byType(WeeklyBossPanel), findsOneWidget);
    expect(find.byKey(const ValueKey('week-day-2')), findsOneWidget); // среда
    expect(find.byType(QuestRow), findsNWidgets(7));

    await tester.tap(find.text(l.qstViewHistory.toUpperCase()));
    await _settle(tester);
    expect(find.byType(QuestRow), findsNothing);
    expect(find.text('Подъём до 07:00'), findsOneWidget);
    expect(find.text(l.qstDiamondsDelta('+10')), findsOneWidget);
    expect(find.text(l.qstXpDelta('+15')), findsOneWidget);
    expect(find.text(l.qstDiamondsDelta('−15')), findsOneWidget);
    expect(find.byKey(const ValueKey('history-h2')), findsOneWidget);
  });

  testWidgets('фильтры по виду и характеристике', (tester) async {
    await pumpTab(tester, const QuestsScreen(), const Locale('ru'));

    await tester.tap(find.byKey(const Key('quest-filters-toggle')));
    await _settle(tester);
    await tester.tap(find.bySemanticsLabel(l.qstKindPenalty));
    await _settle(tester);
    expect(find.byType(QuestRow), findsOneWidget);
    expect(find.text('Штрафной: 30 приседаний'), findsOneWidget);
    expect(find.byType(WeeklyBossPanel), findsNothing);

    await tester.tap(find.bySemanticsLabel(l.qstKindPenalty));
    await _settle(tester);
    await tester.tap(find.bySemanticsLabel(l.homeStatHealth));
    await _settle(tester);
    expect(find.byType(QuestRow), findsNWidgets(3)); // завтрак, 500 мл, 2,5 л

    await tester.tap(find.text(l.qstFilterReset.toUpperCase()));
    await _settle(tester);
    expect(find.byType(QuestRow), findsNWidgets(7));
  });

  testWidgets('карточка: подзадачи, отказ — только удержанием 5 с', (tester) async {
    final service = FakeQuestService(now: fixedNow);
    await pumpTab(tester, const QuestsScreen(), const Locale('ru'), service: service);
    await _openSheet(tester, 'Тренировка дома');

    await tester.tap(find.byKey(const ValueKey('subtask-1')));
    await _settle(tester);
    expect(service.calls, contains('subtask:workout:1:true'));

    final refuse = find.byKey(const Key('quest-refuse'));
    await tester.ensureVisible(refuse);
    await tester.pump();
    await holdFor(tester, refuse, const Duration(seconds: 1));
    expect(service.calls.where((c) => c.startsWith('refuse')), isEmpty);

    await holdFor(tester, refuse, const Duration(milliseconds: 5300));
    expect(service.calls, contains('refuse:workout'));
    await _settle(tester);
    expect(find.byType(QuestSheet), findsNothing);
    expect(find.byKey(const Key('window-refused')), findsOneWidget);
  });

  testWidgets('штрафной квест: отказа нет, «Выполнено» работает', (tester) async {
    final service = FakeQuestService(now: fixedNow);
    await pumpTab(tester, const QuestsScreen(), const Locale('ru'), service: service);
    await _openSheet(tester, 'Штрафной: 30 приседаний');

    expect(find.byType(HoldButton), findsNothing);
    expect(find.byKey(const Key('quest-no-refuse')), findsOneWidget);
    await _tapVisible(tester, find.byKey(const Key('quest-done')));
    expect(service.calls, contains('complete:punish'));
    expect(find.byType(QuestSheet), findsNothing);
  });

  testWidgets('прогресс к цели и «+10 мин» из карточки', (tester) async {
    final service = FakeQuestService(now: fixedNow);
    await pumpTab(tester, const QuestsScreen(), const Locale('ru'), service: service);
    await _openSheet(tester, 'Выпить 2,5 л воды');

    await _tapVisible(tester, find.byKey(const Key('quest-progress-add')));
    expect(service.calls, contains('progress:water:250'));
    await _tapVisible(tester, find.byKey(const Key('quest-snooze')));
    expect(service.calls, contains('snooze:water'));
  });

  testWidgets('честная отметка: подтверждение с пояснением → markDay и окно «Штраф»', (tester) async {
    final service = FakeQuestService(now: fixedNow);
    await pumpTab(tester, const QuestsScreen(), const Locale('ru'), service: service);

    await _tapVisible(tester, find.byKey(const ValueKey('mark-alcohol')));
    final confirm = tester.widget<SystemWindow>(find.byType(SystemWindow));
    expect(confirm.message, l.qstMarkConfirmMessage);
    await tester.tap(find.text(l.qstMarkConfirm.toUpperCase()));
    await _settle(tester);
    expect(service.marks, [DayMark.alcohol]);
    await _settle(tester);
    expect(find.byKey(const Key('window-penalty')), findsOneWidget);
  });

  testWidgets('пауза: поставить до снятия и снять', (tester) async {
    final service = FakeQuestService(now: fixedNow);
    await pumpTab(tester, const QuestsScreen(), const Locale('ru'), service: service);

    await _tapVisible(tester, find.byKey(const Key('pause-start')));
    await tester.tap(find.bySemanticsLabel(l.qstPauseReasonVacation));
    await _settle(tester);
    await _tapVisible(tester, find.byKey(const Key('pause-confirm')));
    expect(service.calls, contains('pause:vacation:null'));
    expect(find.byKey(const Key('pause-active')), findsOneWidget);

    await _tapVisible(tester, find.byKey(const Key('pause-end')));
    expect(service.calls, contains('endPause'));
    expect(find.byKey(const Key('pause-start')), findsOneWidget);
  });

  testWidgets('новый квест: форма → createQuest', (tester) async {
    final service = FakeQuestService(now: fixedNow);
    await pumpTab(tester, const QuestsScreen(), const Locale('ru'), service: service);

    await _tapVisible(tester, find.byKey(const Key('quest-new')));
    // Без названия не сохраняется.
    await tester.tap(find.byKey(const Key('quest-form-save')));
    await _settle(tester);
    expect(service.created, isEmpty);
    expect(find.text(l.commonRequired), findsOneWidget);

    await tester.enterText(find.descendant(of: find.byKey(const Key('quest-form-title')), matching: find.byType(TextField)),
        'Растяжка');
    await tester.tap(find.bySemanticsLabel(l.homeStatEndurance));
    await _tapVisible(tester, find.byKey(const Key('quest-form-add-subtask')));
    await tester.tap(find.byKey(const Key('quest-form-save')));
    await _settle(tester);

    expect(service.created, hasLength(1));
    final input = service.created.single;
    expect(input.title.text, 'Растяжка');
    expect(input.stat, StatKind.endurance);
    expect(input.kind, QuestKind.custom);
    expect(input.source, QuestSource.user);
    expect(input.subtasks, isEmpty); // пустая подзадача отброшена
    expect(input.reward, GameReward.none); // по правилам Системы
    expect(input.nag, isTrue);
  });

  testWidgets('свой квест: правка и архив из карточки', (tester) async {
    final service = FakeQuestService(now: fixedNow);
    await pumpTab(tester, const QuestsScreen(), const Locale('ru'), service: service);
    await _openSheet(tester, 'Тренировка дома');

    await _tapVisible(tester, find.text(l.qstArchive.toUpperCase()));
    await tester.tap(find.descendant(of: find.byType(SystemWindow), matching: find.text(l.qstArchive.toUpperCase())));
    await _settle(tester);
    expect(service.calls, contains('archive:q-workout'));
    expect(find.text('Тренировка дома'), findsNothing);
  });

  testWidgets('tr: рендерится и прокручивается', (tester) async {
    await pumpTab(tester, const QuestsScreen(), const Locale('tr'));
    final tl = await AppLocalizations.delegate.load(const Locale('tr'));
    expect(panelTitles(tester), contains(tl.homeDailyTitle));
    await scrollToBottom(tester, _scrollKey);
    expect(tester.takeException(), isNull);
  });

  testWidgets('крупный шрифт (×2) не ломает вёрстку вкладки «Квесты»', (tester) async {
    await expectNoOverflowAtLargeText(tester, const QuestsScreen(), _scrollKey);
  });
}
