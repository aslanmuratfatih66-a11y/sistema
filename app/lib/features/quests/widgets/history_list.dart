import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/enums.dart';
import '../../../domain/quests/quest_api.dart';
import '../../../domain/quests/quest_l10n.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../home/utils/home_format.dart';
import '../quest_format.dart';
import '../quest_labels.dart';

/// История: лента журнала по дням, у записи — ◆ и опыт со знаком.
class HistoryList extends StatelessWidget {
  const HistoryList({super.key, required this.entries});

  final List<HistoryEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (entries.isEmpty) {
      return SysPanel(title: l.qstViewHistory, child: Text(l.qstEmptyHistory, style: SysText.secondary));
    }
    final days = <DateTime, List<HistoryEntry>>{};
    for (final e in entries) {
      (days[dayOf(e.occurredAt)] ??= []).add(e);
    }
    final dateFmt = DateFormat.MMMMEEEEd(l.localeName);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, d) in days.entries.indexed) ...[
          if (i > 0) const SizedBox(height: 14),
          SysPanel(
            title: dateFmt.format(d.key),
            animateIn: i < 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (final e in d.value) _HistoryRow(entry: e)],
            ),
          ),
        ],
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final e = entry;
    final t = e.title;
    final d = e.delta;
    final (glyph, color) = _look(e.type);
    final typeLabel = historyTypeLabel(l, e.type);
    final title = t == null ? typeLabel : questTitleText(l, t);
    final time = DateFormat.Hm(l.localeName).format(e.occurredAt);
    return Semantics(
      container: true,
      child: Padding(
        key: ValueKey('history-${e.id}'),
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(top: 2), child: SysIcon(glyph, size: 16, color: color)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: SysText.body),
                  Text(
                    t == null ? time : '$time · $typeLabel',
                    style: SysText.monoSmall.copyWith(color: SysColors.textCaption),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (d.diamonds != 0)
                  Text(
                    l.qstDiamondsDelta(formatSigned(d.diamonds)),
                    style: SysText.mono.copyWith(
                      fontSize: 12.5,
                      color: d.diamonds > 0 ? SysColors.gold : SysColors.dangerLight,
                    ),
                  ),
                if (d.xp != 0)
                  Text(
                    l.qstXpDelta(formatSigned(d.xp)),
                    style: SysText.monoSmall.copyWith(color: d.xp > 0 ? SysColors.accentLight : SysColors.dangerLight),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static (SysGlyph, Color) _look(QuestEventType t) => switch (t) {
        QuestEventType.completed || QuestEventType.bonus => (SysGlyph.check, SysColors.success),
        QuestEventType.bossCompleted => (SysGlyph.crown, SysColors.bossLight),
        QuestEventType.failed || QuestEventType.bossFailed || QuestEventType.penalty => (SysGlyph.warning, SysColors.danger),
        QuestEventType.refused => (SysGlyph.close, SysColors.dangerLight),
        QuestEventType.purchase => (SysGlyph.shop, SysColors.gold),
        QuestEventType.mark => (SysGlyph.flame, SysColors.gold),
        QuestEventType.pauseStarted || QuestEventType.pauseEnded => (SysGlyph.moon, SysColors.textCaption),
        QuestEventType.statPointSpent => (SysGlyph.star, SysColors.accentLight),
        QuestEventType.disciplineOn || QuestEventType.disciplineOff => (SysGlyph.shield, SysColors.gold),
        QuestEventType.adjustment => (SysGlyph.info, SysColors.textCaption),
      };
}
