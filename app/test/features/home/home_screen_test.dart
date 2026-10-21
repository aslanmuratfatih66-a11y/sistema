import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/home/home_screen.dart';
import 'package:sistema/features/home/widgets/day_timeline_panel.dart';
import 'package:sistema/features/home/widgets/next_quest_panel.dart';
import 'package:sistema/features/home/widgets/status_panel.dart';
import 'package:sistema/l10n/app_localizations.dart';
import 'package:sistema/ui/ui.dart';

import '../quests/fake_quest_service.dart';
import 'tab_test_utils.dart';

const _scrollKey = Key('home-scroll');

void main() {
  testWidgets('ru: только шапка, статус, эффекты, следующий квест, день', (tester) async {
    await pumpTab(tester, const HomeScreen(), const Locale('ru'));
    final l = await AppLocalizations.delegate.load(const Locale('ru'));

    expect(find.text('СИСТЕМА · ОНЛАЙН'), findsOneWidget);
    expect(find.text('НЕДЕЛЯ 1 · ДЕНЬ 1'), findsOneWidget);
    expect(find.bySemanticsLabel(l.homeSettingsLabel), findsOneWidget);
    expect(panelTitles(tester), {
      l.homeStatusTitle,
      l.homeEffectsTitle,
      l.homeNextQuestTitle,
      l.homeDayTitle,
    });
    // Перенесено в другие вкладки / убрано.
    expect(find.text(l.homeDailyTitle.toUpperCase()), findsNothing);
    expect(find.byType(QuestRow), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(HoldButton), findsOneWidget);
    expect(find.text(l.homeRefuseHint), findsOneWidget);
    expect(find.text(l.homeStatPointsButton(3)), findsOneWidget);
    expect(find.text(l.hqStatStrengthShort), findsOneWidget);

    await scrollToBottom(tester, _scrollKey);
    expect(tester.takeException(), isNull);
  });

  testWidgets('статус и следующий квест — из снимка движка', (tester) async {
    await pumpTab(tester, const HomeScreen(), const Locale('ru'));
    final l = await AppLocalizations.delegate.load(const Locale('ru'));

    final player = tester.widget<StatusPanel>(find.byType(StatusPanel)).player;
    expect(player.level, 7);
    expect(player.points, 340);
    expect(player.xp, 1240);
    expect(player.xpForNextLevel, 2000);
    expect(player.streakDays, 12);
    expect(player.rank, PlayerRank.e);
    expect(player.stats.firstWhere((s) => s.kind == StatKind.health).deltaToday, -1);
    // Нормы — из плана, текущих значений ещё нет (этап 3), энергии нет.
    expect(player.waterGoalMl, 2500);
    expect(player.waterMl, 0);
    expect(player.energyPercent, isNull);

    expect(find.text(l.homePointsValue('340')), findsOneWidget);
    expect(find.textContaining('МУРАТ'), findsOneWidget);
    expect(find.text(l.homeStreakDays(12)), findsOneWidget);
    // Ближайший квест — «Выпить 500 мл воды» (ключ плана), с кнопкой «Нет воды».
    expect(find.text(l.planQuestWater('500')), findsOneWidget);
    expect(find.text(l.homeActionNoWater.toUpperCase()), findsOneWidget);
    expect(find.text(l.homePenaltyPoints('15')), findsOneWidget);
  });

  testWidgets('iPhone 15 Pro: статус, эффекты и следующий квест видны без прокрутки', (tester) async {
    await pumpTab(tester, const HomeScreen(), const Locale('ru'));

    final status = tester.getRect(find.byType(StatusPanel));
    final next = tester.getRect(find.byType(NextQuestPanel));
    expect(status.top, greaterThanOrEqualTo(iphoneTopInset));
    expect(next.bottom, lessThanOrEqualTo(visibleTabBottom),
        reason: 'Низ «Следующего квеста» ${next.bottom} ниже видимой области $visibleTabBottom');
    // Лента дня — ниже, прокрутка короткая.
    final day = tester.getRect(find.byType(DayTimelinePanel));
    expect(day.top, greaterThan(next.bottom));
    final scrollable = tester.state<ScrollableState>(
      find.descendant(of: find.byKey(_scrollKey), matching: find.byType(Scrollable)).first,
    );
    expect(scrollable.position.maxScrollExtent, lessThan(300));
  });

  testWidgets('короткое нажатие «Отказ» не отказывается, удержание 5 с — отказ и окно', (tester) async {
    final service = FakeQuestService(now: fixedNow);
    await pumpTab(tester, const HomeScreen(), const Locale('ru'), service: service);
    final l = await AppLocalizations.delegate.load(const Locale('ru'));
    final refuse = find.byKey(const Key('next-quest-refuse'));

    await holdFor(tester, refuse, const Duration(seconds: 2));
    expect(service.calls.where((c) => c.startsWith('refuse')), isEmpty);
    expect(find.byType(SystemWindow), findsNothing);

    await holdFor(tester, refuse, const Duration(milliseconds: 5300));
    expect(service.calls, contains('refuse:next'));
    final window = tester.widget<SystemWindow>(find.byKey(const Key('window-refused')));
    expect(window.warningTone, PanelTone.danger);
    expect(window.title, l.qstWindowRefusedTitle);
    expect(window.message, contains(l.planQuestWater('500')));
  });

  testWidgets('«Выполнено» и «+10 мин» уходят в движок, выполнение — плашкой', (tester) async {
    final service = FakeQuestService(now: fixedNow);
    await pumpTab(tester, const HomeScreen(), const Locale('ru'), service: service);
    final l = await AppLocalizations.delegate.load(const Locale('ru'));

    await tester.tap(find.text(l.homeActionSnooze.toUpperCase()));
    await tester.pump();
    expect(service.calls, contains('snooze:next'));

    await tester.tap(find.text(l.homeActionDone.toUpperCase()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(service.calls, contains('complete:next'));
    expect(find.byKey(const Key('toast-completed')), findsOneWidget);
    expect(find.byType(SystemWindow), findsNothing);
    // Следующим стал штрафной квест: отказа нет.
    expect(find.text('Штрафной: 30 приседаний'), findsOneWidget);
    expect(find.byType(HoldButton), findsNothing);
    expect(find.text(l.qstNoRefuse), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    expect(find.byKey(const Key('toast-completed')), findsNothing);
  });

  testWidgets('«Очки характ.» открывают распределение, +1 тратит очко', (tester) async {
    final service = FakeQuestService(now: fixedNow);
    await pumpTab(tester, const HomeScreen(), const Locale('ru'), service: service);
    final l = await AppLocalizations.delegate.load(const Locale('ru'));

    await tester.tap(find.text(l.homeStatPointsButton(3)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('stat-points-sheet')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('stat-add-strength')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(service.calls, contains('stat:strength'));
    expect(find.text(l.qstStatPointsLeft(2)), findsOneWidget);
  });

  testWidgets('tr: рендерится, следующий квест виден без прокрутки', (tester) async {
    await pumpTab(tester, const HomeScreen(), const Locale('tr'));
    final l = await AppLocalizations.delegate.load(const Locale('tr'));

    expect(find.text('SİSTEM · ÇEVRİMİÇİ'), findsOneWidget);
    expect(panelTitles(tester), containsAll(<String>[l.homeStatusTitle, l.homeNextQuestTitle]));
    expect(tester.getRect(find.byType(NextQuestPanel)).bottom, lessThanOrEqualTo(visibleTabBottom));
    await scrollToBottom(tester, _scrollKey);
    expect(tester.takeException(), isNull);
  });

  testWidgets('крупный шрифт (×2) не ломает вёрстку главного экрана', (tester) async {
    await expectNoOverflowAtLargeText(tester, const HomeScreen(), _scrollKey);
  });
}
