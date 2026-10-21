import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../home/models/home_view_data.dart';
import '../../home/widgets/summary_line.dart';

/// Сводка калорий за день: съедено / норма, сожжено, дефицит.
class CaloriesSummaryPanel extends StatelessWidget {
  const CaloriesSummaryPanel({super.key, required this.calories, required this.kcalGoal});

  final CaloriesSummary calories;
  final int kcalGoal;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final nf = NumberFormat.decimalPattern(l.localeName);
    return SysPanel(
      title: l.hqCaloriesTodayTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatBar(
            label: l.homeCalories,
            value: calories.eaten.toDouble(),
            max: kcalGoal.toDouble(),
            color: SysColors.calories,
            icon: SysGlyph.flame,
            valueText: l.homeKcalProgress(nf.format(calories.eaten), nf.format(kcalGoal)),
          ),
          const SizedBox(height: 8),
          SummaryLine(label: l.homeEaten, value: l.homeKcalValue(nf.format(calories.eaten))),
          SummaryLine(
            label: l.homeBurned,
            value: l.homeKcalValue(nf.format(calories.burned)),
            color: SysColors.calories,
          ),
          SummaryLine(
            label: l.homeDeficit,
            value: l.homeKcalValue(nf.format(calories.deficit)),
            color: SysColors.success,
          ),
        ],
      ),
    );
  }
}
