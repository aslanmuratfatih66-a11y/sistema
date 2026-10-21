// Карточка квеста (нижний лист): подробности, подзадачи, прогресс, действия.
// «Выполнено», «+10 мин», отказ удержанием 5 с (у штрафных отказа нет), правка/архив своих квестов.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/enums.dart';
import '../../../domain/quests/quest_api.dart';
import '../../../domain/quests/quest_l10n.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../home/data/home_providers.dart';
import '../../home/widgets/status_panel.dart' show statLabel, statShortLabel;
import '../data/quest_providers.dart';
import '../quest_actions.dart';
import '../quest_format.dart';
import '../quest_labels.dart';
import 'quest_editor_screen.dart';

Future<void> showQuestSheet(BuildContext context, QuestItem quest) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => QuestSheet(initial: quest),
    );

class QuestSheet extends ConsumerWidget {
  const QuestSheet({super.key, required this.initial});

  final QuestItem initial;

  /// Актуальная версия экземпляра из стримов дня/недели.
  QuestItem _live(WidgetRef ref) {
    final id = initial.instanceId;
    final list = initial.kind == QuestKind.boss
        ? ref.watch(questWeekProvider(weekStartOf(initial.day))).value
        : ref.watch(questDayProvider(dayOf(initial.day))).value;
    for (final q in list ?? const <QuestItem>[]) {
      if (q.instanceId == id) return q;
    }
    return initial;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final nf = NumberFormat.decimalPattern(l.localeName);
    final q = _live(ref);
    final now = ref.watch(homeClockProvider);
    final red = questIsRed(q, now);
    final time = questTimeOf(q);
    final hm = DateFormat.Hm(l.localeName);
    final stat = q.stat;
    final progress = questProgressOf(q);
    final target = q.target;

    Future<void> act(Future<void> Function(QuestService s, DateTime now) f, {bool close = false}) async {
      final nav = Navigator.of(context);
      final ok = await runQuestAction(context, ref, f);
      if (ok && close && nav.mounted) nav.pop();
    }

    final pills = <Widget>[
      SysPill(label: kindFilterLabel(l, kindFilterOf(q.kind)), tone: _kindTone(q.kind)),
      if (stat != null) SysPill(label: statLabel(l, stat), icon: SysGlyph.star),
      SysPill(
        label: time == null ? l.qstAllDay : hm.format(time),
        icon: SysGlyph.clock,
        tone: red ? PanelTone.danger : PanelTone.accent,
        trailing: l.homeQuestDeadline(hm.format(q.deadlineAt)),
      ),
      if (!q.isPending)
        SysPill(label: questStatusLabel(l, q.status), tone: q.status == QuestStatus.done ? PanelTone.success : PanelTone.danger),
    ];

    final rewardParts = [
      if (q.reward.diamonds != 0) l.homeRewardPoints(nf.format(q.reward.diamonds)),
      if (q.reward.xp != 0) l.homeRewardXp(nf.format(q.reward.xp)),
      for (final e in q.reward.stats.entries)
        if (e.value != 0) '+${e.value} ${statShortLabel(l, e.key)}',
    ];

    return SingleChildScrollView(
      key: const Key('quest-sheet'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.only(top: 6), child: SysDiamond(color: _kindTone(q.kind).palette.light)),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    questTitleText(l, q.title),
                    style: SysText.body.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: red ? SysColors.dangerLight : SysColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 6, runSpacing: 6, children: pills),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (rewardParts.isNotEmpty)
                Semantics(
                  label: l.homeRewardLabel,
                  child: SysPill(label: rewardParts.join('  '), tone: PanelTone.gold, icon: SysGlyph.diamond),
                ),
              if (q.penaltyDiamonds > 0)
                Semantics(
                  label: l.homePenaltyLabel,
                  child: SysPill(
                    label: l.homePenaltyPoints(nf.format(q.penaltyDiamonds)),
                    tone: PanelTone.danger,
                    icon: SysGlyph.warning,
                  ),
                ),
              if (q.cancellable && q.refusePenaltyDiamonds > 0)
                SysPill(label: l.qstRefusePenalty(nf.format(q.refusePenaltyDiamonds)), tone: PanelTone.danger),
            ],
          ),
          if (q.subtasks.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(l.qstSubtasks.toUpperCase(), style: SysText.title.copyWith(color: SysColors.textCaption)),
            const SizedBox(height: 4),
            for (final (i, s) in q.subtasks.indexed)
              _SubtaskTile(
                key: ValueKey('subtask-$i'),
                title: s.title,
                done: s.done,
                onChanged: q.isPending ? (v) => act((svc, _) => svc.toggleSubtask(q.instanceId, i, v)) : null,
              ),
          ],
          if (target != null && target > 0) ...[
            const SizedBox(height: 14),
            StatBar(
              label: l.qstProgress,
              value: q.progress.toDouble().clamp(0, target.toDouble()),
              max: target.toDouble(),
              color: q.kind == QuestKind.boss ? SysColors.boss : SysColors.accent,
              icon: SysGlyph.arrowUp,
              valueText: l.homeBossProgress(q.progress, target),
            ),
            if (q.isPending) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Semantics(
                  label: l.qstProgressAddLabel(nf.format(progressStepOf(q))),
                  excludeSemantics: true,
                  child: SysButton.secondary(
                    key: const Key('quest-progress-add'),
                    label: '+${nf.format(progressStepOf(q))}',
                    icon: SysGlyph.plus,
                    onPressed: () => act((svc, now) => svc.addProgress(q.instanceId, progressStepOf(q), at: now)),
                  ),
                ),
              ),
            ],
          ] else if (progress != null && q.subtasks.isEmpty) ...[
            const SizedBox(height: 10),
            SysBar(value: progress),
          ],
          if (q.isPending) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: SysButton.primary(
                    key: const Key('quest-done'),
                    label: l.homeActionDone,
                    icon: SysGlyph.check,
                    expand: true,
                    onPressed: () => act((svc, now) => svc.complete(q.instanceId, at: now), close: true),
                  ),
                ),
                const SizedBox(width: 8),
                SysButton.secondary(
                  key: const Key('quest-snooze'),
                  label: l.homeActionSnooze,
                  icon: SysGlyph.clock,
                  onPressed: () => act((svc, now) => svc.snooze(q.instanceId, at: now)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (q.cancellable) ...[
              HoldButton(
                key: const Key('quest-refuse'),
                label: l.homeActionRefuse,
                semanticHint: l.homeRefuseHint,
                tone: PanelTone.danger,
                expand: true,
                onCompleted: () => act((svc, now) => svc.refuse(q.instanceId, at: now), close: true),
              ),
              const SizedBox(height: 4),
              Text(
                l.homeRefuseHint,
                textAlign: TextAlign.right,
                style: SysText.caption.copyWith(color: SysColors.dangerLight, fontSize: 11.5),
              ),
            ] else
              Text(
                l.qstNoRefuse,
                key: const Key('quest-no-refuse'),
                style: SysText.secondary.copyWith(color: SysColors.dangerLight),
              ),
          ],
          if (questEditable(q)) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SysButton.secondary(
                    label: l.commonEdit,
                    expand: true,
                    onPressed: () {
                      final nav = Navigator.of(context)..pop();
                      QuestEditorScreen.open(nav, questId: q.questId, initial: questInputFromItem(q));
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SysButton.danger(
                    label: l.qstArchive,
                    expand: true,
                    onPressed: () async {
                      final ok = await confirmSystem(
                        context,
                        title: questTitleText(l, q.title),
                        message: l.qstArchiveConfirm,
                        confirmLabel: l.qstArchive,
                        tone: PanelTone.danger,
                        danger: true,
                      );
                      if (ok && context.mounted) await act((svc, _) => svc.archiveQuest(q.questId), close: true);
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

PanelTone _kindTone(QuestKind k) => switch (k) {
      QuestKind.penalty => PanelTone.danger,
      QuestKind.boss => PanelTone.boss,
      _ => PanelTone.accent,
    };

/// Подзадача: строка-чекбокс ≥44px.
class _SubtaskTile extends StatelessWidget {
  const _SubtaskTile({super.key, required this.title, required this.done, this.onChanged});

  final String title;
  final bool done;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final cb = onChanged;
    final color = done ? SysColors.success : SysColors.accent;
    return Semantics(
      checked: done,
      enabled: cb != null,
      label: title,
      excludeSemantics: true,
      onTap: cb == null ? null : () => cb(!done),
      child: InkWell(
        onTap: cb == null ? null : () => cb(!done),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: SysDims.minTap),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: done ? color.withValues(alpha: .22) : null,
                  border: Border.all(color: color, width: 1.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: done ? SysIcon(SysGlyph.check, size: 14, color: color) : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: SysText.body.copyWith(
                    color: done ? SysColors.textInactive : SysColors.textSecondary,
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: SysColors.textInactive,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
