// Честные отметки дня (гулял / алкоголь / сорвался) и пауза (болезнь, каникулы, отпуск).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/enums.dart';
import '../../../domain/quests/quest_api.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../home/data/home_providers.dart';
import '../quest_actions.dart';
import '../quest_labels.dart';

/// Отметки дня: подтверждение с пояснением → QuestService.markDay.
class DayMarksPanel extends ConsumerWidget {
  const DayMarksPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    Future<void> mark(DayMark m) async {
      final ok = await confirmSystem(
        context,
        title: l.qstMarkConfirmTitle(dayMarkLabel(l, m)),
        message: l.qstMarkConfirmMessage,
        confirmLabel: l.qstMarkConfirm,
      );
      if (ok && context.mounted) await runQuestAction(context, ref, (s, now) => s.markDay(m, at: now));
    }

    return SysPanel(
      title: l.qstMarksTitle,
      tone: PanelTone.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.qstMarksHint, style: SysText.secondary),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in DayMark.values)
                SysButton.secondary(key: ValueKey('mark-${m.name}'), label: dayMarkLabel(l, m), onPressed: () => mark(m)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Пауза: статус и снятие, или постановка (причина, до даты / до снятия).
class PausePanel extends ConsumerWidget {
  const PausePanel({super.key, required this.pause});

  final ActivePause? pause;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final p = pause;
    return SysPanel(
      key: const Key('pause-panel'),
      title: l.qstPauseTitle,
      tone: p == null ? PanelTone.accent : PanelTone.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (p == null) ...[
            Text(l.qstPauseHint, style: SysText.secondary),
            const SizedBox(height: 10),
            SysButton.secondary(
              key: const Key('pause-start'),
              label: l.qstPauseStart,
              icon: SysGlyph.moon,
              expand: true,
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => const PauseSheet(),
              ),
            ),
          ] else ...[
            Text(
              '${l.qstPauseActive(pauseReasonLabel(l, p.reason))} · '
              '${p.endsAt == null ? l.qstPauseUntilRemoved : l.qstPauseUntil(SysDateField.format(_lastDay(p.endsAt!)))}',
              key: const Key('pause-active'),
              style: SysText.body.copyWith(color: SysColors.success),
            ),
            const SizedBox(height: 4),
            Text(l.qstPauseHint, style: SysText.caption),
            const SizedBox(height: 10),
            SysButton.primary(
              key: const Key('pause-end'),
              label: l.qstPauseEnd,
              expand: true,
              onPressed: () => runQuestAction(context, ref, (s, now) => s.endPause(at: now)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Последний день паузы: конец в полночь относится к предыдущему дню.
DateTime _lastDay(DateTime end) =>
    end.hour == 0 && end.minute == 0 ? DateTime(end.year, end.month, end.day - 1) : end;

/// Лист постановки паузы.
class PauseSheet extends ConsumerStatefulWidget {
  const PauseSheet({super.key});

  @override
  ConsumerState<PauseSheet> createState() => _PauseSheetState();
}

class _PauseSheetState extends ConsumerState<PauseSheet> {
  PauseReason _reason = PauseReason.illness;
  bool _untilDate = false;
  DateTime? _until;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = ref.read(homeNowSourceProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final canStart = !_untilDate || _until != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanelHeader(title: l.qstPauseTitle, tone: PanelTone.success),
          const SizedBox(height: 12),
          SysFieldLabel(l.qstPauseReason),
          SysChoiceChips<PauseReason>(
            choices: [for (final r in PauseReason.values) SysChoice(r, pauseReasonLabel(l, r))],
            selected: {_reason},
            allowEmpty: false,
            onChanged: (s) => setState(() => _reason = s.first),
          ),
          const SysFieldGap(),
          SysSegmented<bool>(
            choices: [SysChoice(false, l.qstPauseUntilRemoved), SysChoice(true, l.qstPauseUntilDate)],
            value: _untilDate,
            onChanged: (v) => setState(() => _untilDate = v),
          ),
          if (_untilDate) ...[
            const SysFieldGap(),
            SysDateField(
              label: l.qstPauseEndDate,
              date: _until,
              firstDate: today,
              lastDate: today.add(const Duration(days: 366)),
              initialDate: today.add(const Duration(days: 7)),
              onChanged: (d) => setState(() => _until = d),
            ),
          ],
          const SizedBox(height: 18),
          SysButton.primary(
            key: const Key('pause-confirm'),
            label: l.qstPauseConfirm,
            expand: true,
            onPressed: !canStart
                ? null
                : () async {
                    final nav = Navigator.of(context);
                    // «До даты» — включительно: до полуночи следующего дня.
                    final u = _until;
                    final until = _untilDate && u != null ? DateTime(u.year, u.month, u.day + 1) : null;
                    final ok = await runQuestAction(
                      context,
                      ref,
                      (s, at) => s.startPause(_reason, until: until, at: at),
                    );
                    if (ok && nav.mounted) nav.pop();
                  },
          ),
        ],
      ),
    );
  }
}
