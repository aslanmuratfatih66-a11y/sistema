import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../models/home_view_data.dart';

/// Блок 8: две мини-сводки в ряд — калории и финансы на еду.
/// На узком экране или при крупном шрифте — друг под другом.
class SummariesRow extends StatelessWidget {
  const SummariesRow({super.key, required this.calories, required this.finance});

  final CaloriesSummary calories;
  final FoodFinance finance;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final nf = NumberFormat.decimalPattern(l.localeName);
    final money = NumberFormat.simpleCurrency(locale: l.localeName, name: finance.currencyCode, decimalDigits: 0);

    final kcal = SysPanel(
      title: l.homeCalories,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Line(label: l.homeEaten, value: l.homeKcalValue(nf.format(calories.eaten))),
          _Line(label: l.homeBurned, value: l.homeKcalValue(nf.format(calories.burned)), color: SysColors.calories),
          _Line(label: l.homeDeficit, value: l.homeKcalValue(nf.format(calories.deficit)), color: SysColors.success),
        ],
      ),
    );

    final fin = SysPanel(
      title: l.homeFinanceTitle,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Line(
            label: l.homeFoodSpent,
            value: money.format(finance.spent),
            color: finance.spent > finance.limit ? SysColors.danger : SysColors.textPrimary,
          ),
          _Line(label: l.homeLimit, value: money.format(finance.limit)),
          _Line(label: l.homeUntilStipend, value: l.homeDaysCount(finance.daysToStipend), color: SysColors.gold),
        ],
      ),
    );

    return LayoutBuilder(builder: (context, c) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      if (c.maxWidth / scale < 330) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [kcal, const SizedBox(height: 12), fin],
        );
      }
      // Без IntrinsicHeight: панели дизайн-системы могут содержать LayoutBuilder.
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: kcal),
          const SizedBox(width: 10),
          Expanded(child: fin),
        ],
      );
    });
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, this.color = SysColors.textPrimary});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          Text(label, style: SysText.caption),
          Text(value, style: SysText.mono.copyWith(fontSize: 12.5, color: color)),
        ],
      ),
    );
  }
}
