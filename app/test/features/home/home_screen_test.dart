import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/features/home/home_screen.dart';
import 'package:sistema/features/home/widgets/day_timeline_panel.dart';
import 'package:sistema/features/home/widgets/next_quest_panel.dart';
import 'package:sistema/features/home/widgets/status_panel.dart';
import 'package:sistema/l10n/app_localizations.dart';
import 'package:sistema/ui/ui.dart';

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

  testWidgets('отказ удержанием показывает окно «Квест провален»', (tester) async {
    await pumpTab(tester, const HomeScreen(), const Locale('ru'));
    final l = await AppLocalizations.delegate.load(const Locale('ru'));

    tester.widget<HoldButton>(find.byType(HoldButton)).onCompleted();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final window = tester.widget<SystemWindow>(find.byType(SystemWindow));
    expect(window.kind, SystemWindowKind.failed);
    expect(window.title, l.homeQuestFailedTitle);
    expect(window.message, contains(l.homeDemoNextQuest));
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
