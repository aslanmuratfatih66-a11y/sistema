import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../home/data/home_providers.dart';
import '../../home/models/home_view_data.dart';
import '../../home/utils/home_format.dart';

/// «3 д 13:14» до конца недели.
String bossTimeLeft(AppLocalizations l, Duration left) {
  if (left.isNegative) left = Duration.zero;
  final days = left.inDays;
  return l.homeBossTimeLeft('$days', formatHoursMinutes(left - Duration(days: days)));
}

/// Блок 7: босс недели (фиолетовая тема).
class WeeklyBossPanel extends ConsumerWidget {
  const WeeklyBossPanel({super.key, required this.boss});

  final WeeklyBoss boss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final nf = NumberFormat.decimalPattern(l.localeName);
    final now = ref.watch(homeClockProvider);
    final left = bossTimeLeft(l, boss.endsAt.difference(now));

    return SysPanel(
      title: l.homeBossTitle,
      tone: PanelTone.boss,
      trailing: Semantics(
        label: l.homeTimeLeftSemantics(left),
        excludeSemantics: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SysIcon(SysGlyph.timer, size: 14, color: SysColors.bossLight),
            const SizedBox(width: 4),
            Text(left, style: SysText.mono.copyWith(fontSize: 12, color: SysColors.bossLight)),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatBar(
            label: boss.goal.of(l),
            value: boss.current.toDouble(),
            max: boss.total.toDouble(),
            color: SysColors.boss,
            icon: SysGlyph.sword,
            valueText: l.homeBossProgress(boss.current, boss.total),
            height: 8,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SysIcon(SysGlyph.crown, size: 18, color: SysColors.gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.homeBossReward(nf.format(boss.rewardPoints), boss.rewardTitle.of(l)),
                  style: SysText.secondary.copyWith(color: SysColors.gold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
