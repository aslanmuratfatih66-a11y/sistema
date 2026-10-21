import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../data/demo_home_data.dart';
import '../models/home_view_data.dart';
import 'summary_line.dart';

/// Сводка финансов на еду: траты / лимит / до стипендии. Показывается первой
/// панелью во вкладке «Ещё». Без [finance] берёт данные из homeDataProvider
/// (пока демо, реальные — этап 2).
class FinanceSummaryPanel extends ConsumerWidget {
  const FinanceSummaryPanel({super.key, this.finance});

  final FoodFinance? finance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final f = finance ?? ref.watch(homeDataProvider).finance;
    final money = NumberFormat.simpleCurrency(locale: l.localeName, name: f.currencyCode, decimalDigits: 0);
    final over = f.spent > f.limit;

    return SysPanel(
      title: l.hqFinanceFoodTitle,
      tone: over ? PanelTone.danger : PanelTone.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysBar(
            value: f.limit <= 0 ? 0 : (f.spent / f.limit).clamp(0.0, 1.0),
            color: over ? SysColors.danger : SysColors.gold,
          ),
          const SizedBox(height: 8),
          SummaryLine(
            label: l.homeFoodSpent,
            value: money.format(f.spent),
            color: over ? SysColors.danger : SysColors.textPrimary,
          ),
          SummaryLine(label: l.homeLimit, value: money.format(f.limit)),
          SummaryLine(label: l.homeUntilStipend, value: l.homeDaysCount(f.daysToStipend), color: SysColors.gold),
        ],
      ),
    );
  }
}
