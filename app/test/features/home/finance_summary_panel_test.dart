import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/features/home/models/home_view_data.dart';
import 'package:sistema/features/home/widgets/finance_summary_panel.dart';
import 'package:sistema/l10n/app_localizations.dart';
import 'package:sistema/ui/ui.dart';

import 'tab_test_utils.dart';

void main() {
  testWidgets('сводка финансов: демо-данные из homeDataProvider', (tester) async {
    await pumpTab(tester, const SingleChildScrollView(child: FinanceSummaryPanel()), const Locale('ru'));
    final l = await AppLocalizations.delegate.load(const Locale('ru'));

    expect(panelTitles(tester), {l.hqFinanceFoodTitle});
    expect(find.text(l.homeFoodSpent), findsOneWidget);
    expect(find.text(l.homeLimit), findsOneWidget);
    expect(find.text(l.homeDaysCount(9)), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('перерасход подсвечивается красной панелью', (tester) async {
    const over = FoodFinance(spent: 4000, limit: 3500, currencyCode: 'RUB', daysToStipend: 2);
    await pumpTab(tester, const SingleChildScrollView(child: FinanceSummaryPanel(finance: over)), const Locale('tr'));
    expect(tester.widget<SysPanel>(find.byType(SysPanel)).tone, PanelTone.danger);
  });

  testWidgets('крупный шрифт (×2) без переполнений', (tester) async {
    await expectNoOverflowAtLargeText(
      tester,
      const SingleChildScrollView(key: Key('fin-scroll'), child: FinanceSummaryPanel()),
      const Key('fin-scroll'),
    );
  });
}
