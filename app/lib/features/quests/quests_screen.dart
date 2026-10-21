// Вкладка «Квесты»: ежедневные квесты и босс недели (SPEC §4, уточнение 2026-10-21).
// Данные — демо из homeDataProvider; реальные — этап 2.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../home/data/demo_home_data.dart';
import '../home/widgets/tab_section_view.dart';
import 'widgets/daily_quests_panel.dart';
import 'widgets/weekly_boss_panel.dart';

class QuestsScreen extends ConsumerWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(homeDataProvider);
    return TabSectionView(
      scrollKey: const Key('quests-scroll'),
      title: l.navQuests,
      glyph: SysGlyph.quests,
      children: [
        DailyQuestsPanel(quests: data.dailyQuests),
        if (data.boss != null) WeeklyBossPanel(boss: data.boss!),
      ],
    );
  }
}
