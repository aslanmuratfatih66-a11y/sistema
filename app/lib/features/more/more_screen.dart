// Вкладка «Ещё» (docs/navigation.md): хаб разделов. Сверху — финансы (сводка и «+ Расход»),
// дальше — план, расписание, знания, будильники, блокировка, журнал ИИ и вход в настройки.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../common/nav_row.dart';
import '../finance/finance_summary.dart';
import '../finance/screens/tx_edit_screen.dart';
import '../home/widgets/tab_section_view.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TabSectionView(
      scrollKey: const Key('more-list'),
      title: l.navMore,
      glyph: SysGlyph.more,
      children: [
        const FinanceSummaryPanel(),
        SysButton.primary(
          key: const Key('more-add-expense'),
          label: l.moreAddExpense,
          icon: SysGlyph.plus,
          expand: true,
          onPressed: () => TxEditScreen.open(context),
        ),
        SysPanel(
          title: l.moreSections,
          appearDelay: const Duration(milliseconds: 40),
          child: Column(
            children: [
              NavRow(
                glyph: SysGlyph.wallet,
                title: l.int7Finance,
                hint: l.int7FinanceHint,
                onTap: () => context.push(Routes.finance),
              ),
              NavRow(
                glyph: SysGlyph.book,
                title: l.setPlan,
                hint: l.setPlanHint,
                onTap: () => context.push(Routes.plan),
              ),
              NavRow(
                glyph: SysGlyph.clock,
                title: l.setSchedule,
                hint: l.setScheduleHint,
                onTap: () => context.push(Routes.schedule),
              ),
              NavRow(
                glyph: SysGlyph.book,
                title: l.int6Learning,
                hint: l.int6LearningHint,
                onTap: () => context.push(Routes.learning),
              ),
              NavRow(
                glyph: SysGlyph.timer,
                title: l.int7Alarms,
                hint: l.int7AlarmsHint,
                onTap: () => context.push(Routes.alarms),
              ),
              NavRow(
                glyph: SysGlyph.lock,
                title: l.int7Blocker,
                hint: l.int7BlockerHint,
                onTap: () => context.push(Routes.blocker),
              ),
              NavRow(
                glyph: SysGlyph.sparkle,
                title: l.int6AiJournal,
                hint: l.int6AiJournalHint,
                onTap: () => context.push(Routes.aiJournal),
              ),
            ],
          ),
        ),
        SysPanel(
          title: l.navSettings,
          appearDelay: const Duration(milliseconds: 60),
          child: NavRow(
            key: const Key('more-settings'),
            glyph: SysGlyph.settings,
            title: l.navSettings,
            hint: l.moreSettingsHint,
            onTap: () => context.push(Routes.settings),
          ),
        ),
      ],
    );
  }
}
