import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/enums.dart';
import '../../../domain/quests/quest_api.dart';
import '../../../domain/quests/quest_l10n.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../home/data/home_providers.dart';
import '../quest_actions.dart';
import '../quest_format.dart';
import 'quest_sheet.dart';

/// Строка квеста из движка: чекбокс — «Выполнено», тап по строке — карточка квеста.
class QuestItemRow extends ConsumerWidget {
  const QuestItemRow({super.key, required this.quest});

  final QuestItem quest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final nf = NumberFormat.decimalPattern(l.localeName);
    final now = ref.watch(homeClockProvider);
    final q = quest;
    final time = questTimeOf(q);
    final target = q.target;
    final done = q.status == QuestStatus.done;
    return InkWell(
      onTap: () => showQuestSheet(context, q),
      excludeFromSemantics: true,
      child: Semantics(
        onLongPress: () => showQuestSheet(context, q),
        onLongPressHint: l.qstOpenQuest,
        child: QuestRow(
          title: questTitleText(l, q.title),
          time: time == null ? null : DateFormat.Hm(l.localeName).format(time),
          done: done,
          overdue: questIsRed(q, now),
          reward: q.reward.diamonds > 0 ? l.homeRewardPoints(nf.format(q.reward.diamonds)) : null,
          penalty: q.penaltyDiamonds > 0 && q.status != QuestStatus.excused
              ? l.homePenaltyPoints(nf.format(q.penaltyDiamonds))
              : null,
          subtasks: [for (final s in q.subtasks) QuestSubtask(s.title, done: s.done)],
          progress: done && questProgressOf(q) != null ? 1 : questProgressOf(q),
          progressText: target != null && target > 0 ? l.homeBossProgress(q.progress, target) : null,
          // Снять отметку нельзя: журнал не откатывается.
          onToggle: q.isPending
              ? (v) {
                  if (v) runQuestAction(context, ref, (s, at) => s.complete(q.instanceId, at: at));
                }
              : null,
        ),
      ),
    );
  }
}

/// Ежедневные квесты дня: счётчик, строки, итоговый штраф за день.
class DailyQuestsPanel extends StatelessWidget {
  const DailyQuestsPanel({super.key, required this.quests, this.title, this.emptyText});

  final List<QuestItem> quests;
  final String? title;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final nf = NumberFormat.decimalPattern(l.localeName);
    final doneCount = quests.where((q) => q.status == QuestStatus.done).length;
    final penalty = dayPenaltyTotal(quests);

    return SysPanel(
      title: title ?? l.homeDailyTitle,
      trailing: Text(
        l.homeDailyCounter(doneCount, quests.length),
        style: SysText.mono.copyWith(fontSize: 12, color: SysColors.accentLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (quests.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(emptyText ?? l.qstEmptyDay, style: SysText.secondary),
            ),
          for (final q in quests) QuestItemRow(key: ValueKey('quest-${q.instanceId}'), quest: q),
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
                    key: const Key('daily-penalty-total'),
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
