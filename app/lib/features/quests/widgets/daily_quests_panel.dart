import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../home/data/home_providers.dart';
import '../../home/models/home_view_data.dart';

/// Сумма штрафов по невыполненным квестам.
int pendingPenalty(List<DailyQuest> quests, Map<String, bool> checks) => quests
    .where((q) => !(checks[q.id] ?? q.done))
    .fold(0, (sum, q) => sum + q.penaltyPoints);

/// Блок 6: ежедневные квесты с локальными отметками.
class DailyQuestsPanel extends ConsumerWidget {
  const DailyQuestsPanel({super.key, required this.quests});

  final List<DailyQuest> quests;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final nf = NumberFormat.decimalPattern(l.localeName);
    final checks = ref.watch(dailyQuestChecksProvider);
    bool isDone(DailyQuest q) => checks[q.id] ?? q.done;
    final doneCount = quests.where(isDone).length;
    final penalty = pendingPenalty(quests, checks);

    return SysPanel(
      title: l.homeDailyTitle,
      trailing: Text(
        l.homeDailyCounter(doneCount, quests.length),
        style: SysText.mono.copyWith(fontSize: 12, color: SysColors.accentLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final q in quests)
            QuestRow(
              key: ValueKey('daily-${q.id}'),
              title: q.title.of(l),
              time: q.timeMinute == null ? null : formatMinuteOfDay(q.timeMinute!),
              done: isDone(q),
              overdue: q.overdue && !isDone(q),
              reward: q.rewardPoints > 0 ? l.homeRewardPoints(nf.format(q.rewardPoints)) : null,
              penalty: q.penaltyPoints > 0 ? l.homePenaltyPoints(nf.format(q.penaltyPoints)) : null,
              subtasks: [for (final s in q.subtasks) QuestSubtask(s.title.of(l), done: s.done)],
              progress: isDone(q) && q.progress != null ? 1 : q.progress,
              progressText: q.progressText?.of(l),
              onToggle: (v) => ref.read(dailyQuestChecksProvider.notifier).set(q.id, v),
            ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color.fromRGBO(255, 77, 94, .35))),
            ),
            child: Row(
              children: [
                SysIcon(SysGlyph.warning, size: 16, color: penalty > 0 ? SysColors.dangerLight : SysColors.textInactive),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l.homeDailyPenaltyTotal(nf.format(penalty)),
                    style: SysText.mono.copyWith(
                      fontSize: 12.5,
                      color: penalty > 0 ? SysColors.dangerLight : SysColors.textInactive,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
