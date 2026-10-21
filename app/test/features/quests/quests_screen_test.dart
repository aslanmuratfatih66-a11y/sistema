import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/features/quests/quests_screen.dart';
import 'package:sistema/features/quests/widgets/weekly_boss_panel.dart';
import 'package:sistema/l10n/app_localizations.dart';
import 'package:sistema/ui/ui.dart';

import '../home/tab_test_utils.dart';

const _scrollKey = Key('quests-scroll');

void main() {
  testWidgets('ru: заголовок, ежедневные квесты и босс недели', (tester) async {
    await pumpTab(tester, const QuestsScreen(), const Locale('ru'));
    final l = await AppLocalizations.delegate.load(const Locale('ru'));

    expect(find.text(l.navQuests.toUpperCase()), findsOneWidget);
    expect(panelTitles(tester), containsAll(<String>[l.homeDailyTitle]));
    expect(find.byType(QuestRow), findsNWidgets(7));

    await scrollToBottom(tester, _scrollKey);
    expect(find.byType(WeeklyBossPanel), findsOneWidget);
    expect(panelTitles(tester), contains(l.homeBossTitle));
    expect(tester.takeException(), isNull);
  });

  testWidgets('тап по чекбоксу квеста переключает его', (tester) async {
    await pumpTab(tester, const QuestsScreen(), const Locale('ru'));
    final l = await AppLocalizations.delegate.load(const Locale('ru'));
    QuestRow row() => tester.widget<QuestRow>(find.byKey(const ValueKey('daily-breakfast')));

    expect(row().done, isFalse);
    expect(row().overdue, isTrue);
    expect(find.text(l.homeDailyPenaltyTotal('75')), findsOneWidget);

    row().onToggle!(true);
    await tester.pump();
    expect(row().done, isTrue);
    expect(row().overdue, isFalse);
    expect(find.text(l.homeDailyPenaltyTotal('70')), findsOneWidget);

    row().onToggle!(false);
    await tester.pump();
    expect(row().done, isFalse);
  });

  testWidgets('tr: рендерится и прокручивается', (tester) async {
    await pumpTab(tester, const QuestsScreen(), const Locale('tr'));
    final l = await AppLocalizations.delegate.load(const Locale('tr'));
    expect(panelTitles(tester), contains(l.homeDailyTitle));
    await scrollToBottom(tester, _scrollKey);
    expect(tester.takeException(), isNull);
  });

  testWidgets('крупный шрифт (×2) не ломает вёрстку вкладки «Квесты»', (tester) async {
    await expectNoOverflowAtLargeText(tester, const QuestsScreen(), _scrollKey);
  });
}
