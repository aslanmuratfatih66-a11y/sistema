// Вкладка «Питание»: сводка калорий и воды за день (SPEC §4, уточнение 2026-10-21).
// Данные — демо из homeDataProvider; дневник питания — этап 3.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../home/data/demo_home_data.dart';
import '../home/widgets/tab_section_view.dart';
import 'widgets/calories_summary_panel.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(homeDataProvider);
    final p = data.player;
    final oneDec = NumberFormat('0.0', l.localeName);

    return TabSectionView(
      scrollKey: const Key('nutrition-scroll'),
      title: l.navNutrition,
      glyph: SysGlyph.nutrition,
      children: [
        CaloriesSummaryPanel(calories: data.calories, kcalGoal: p.kcalGoal),
        SysPanel(
          title: l.homeWater,
          child: StatBar(
            label: l.homeWater,
            value: p.waterMl.toDouble(),
            max: p.waterGoalMl.toDouble(),
            color: SysColors.water,
            icon: SysGlyph.water,
            valueText: l.homeLitersProgress(
              oneDec.format(p.waterMl / 1000),
              oneDec.format(p.waterGoalMl / 1000),
            ),
            height: 8,
          ),
        ),
        SysPanel(
          title: l.hqNutritionDiaryTitle,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SysIcon(SysGlyph.book, size: 22),
              const SizedBox(width: 10),
              Expanded(child: Text(l.hqNutritionDiarySoon, style: SysText.secondary)),
            ],
          ),
        ),
      ],
    );
  }
}
