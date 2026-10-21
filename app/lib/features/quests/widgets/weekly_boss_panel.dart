import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/quests/quest_api.dart';
import '../../../domain/quests/quest_l10n.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../home/data/home_providers.dart';
import '../../home/utils/home_format.dart';
import 'quest_sheet.dart';

/// «3 д 13:14» до конца недели.
String bossTimeLeft(AppLocalizations l, Duration left) {
  if (left.isNegative) left = Duration.zero;
  final days = left.inDays;
  return l.homeBossTimeLeft('$days', formatHoursMinutes(left - Duration(days: days)));
}

/// Босс недели (фиолетовая тема): цель, прогресс, таймер, награда. Тап — карточка квеста.
class WeeklyBossPanel extends ConsumerWidget {
  const WeeklyBossPanel({super.key, required this.boss});

  final QuestItem boss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final nf = NumberFormat.decimalPattern(l.localeName);
    final now = ref.watch(homeClockProvider);
    final left = bossTimeLeft(l, boss.deadlineAt.difference(now));
    final total = boss.target ?? 1;
    final current = boss.progress.clamp(0, total);

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
      child: InkWell(
        onTap: () => showQuestSheet(context, boss),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StatBar(
              label: questTitleText(l, boss.title),
              value: current.toDouble(),
              max: total.toDouble(),
              color: SysColors.boss,
              icon: SysGlyph.sword,
              valueText: l.homeBossProgress(current, total),
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
                    l.qstBossReward(nf.format(boss.reward.diamonds), nf.format(boss.reward.xp)),
                    style: SysText.mono.copyWith(fontSize: 12.5, color: SysColors.gold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
