// Режим дисциплины (SPEC §6): статус и причина, когда выключится, правила на сегодня, ручное включение.
// Блокировка приложений после отбоя — этап 7 (AppBlocker), здесь только пометка.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/discipline/discipline_l10n.dart';
import '../../domain/discipline/discipline_rules.dart';
import '../../domain/quests/quest_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../schedule/widgets/schedule_common.dart' show ScheduleSubPage;
import 'discipline_providers.dart';

/// Окно «режим включён/выключен» (на исход DisciplineChanged движка).
Future<void> showDisciplineChangedWindow(BuildContext context, {required bool active}) {
  final l = AppLocalizations.of(context);
  return showSystemWindow<void>(
    context,
    window: SystemWindow(
      key: const Key('dsc-changed'),
      kind: active ? SystemWindowKind.warning : SystemWindowKind.notice,
      warningTone: PanelTone.danger,
      label: active ? l.shpWarningLabel : l.shpNoticeLabel,
      title: l.dscTitle,
      message: active ? l.dscChangedOnMessage : l.dscChangedOffMessage,
      actions: [
        Builder(builder: (c) => SysButton.primary(label: l.commonDone, onPressed: () => Navigator.of(c).pop())),
      ],
    ),
  );
}

/// Название квеста дисциплины для предпросмотра.
String _questTitle(AppLocalizations l, QuestTitle t) => disciplineQuestTitle(l, t.key ?? '', t.params) ?? t.text ?? '';

class DisciplineScreen extends ConsumerStatefulWidget {
  const DisciplineScreen({super.key});

  @override
  ConsumerState<DisciplineScreen> createState() => _DisciplineScreenState();
}

class _DisciplineScreenState extends ConsumerState<DisciplineScreen> {
  bool _busy = false;

  Future<void> _enable() async {
    final l = AppLocalizations.of(context);
    final ok = await showSystemWindow<bool>(
      context,
      window: SystemWindow(
        key: const Key('dsc-confirm'),
        kind: SystemWindowKind.warning,
        warningTone: PanelTone.danger,
        label: l.shpWarningLabel,
        title: l.dscEnable,
        message: l.dscEnableConfirmMessage,
        actions: [
          Builder(
            builder: (c) => SysButton.secondary(label: l.commonCancel, onPressed: () => Navigator.of(c).pop(false)),
          ),
          Builder(
            builder: (c) => SysButton.danger(
              key: const Key('dsc-confirm-enable'),
              label: l.dscEnable,
              onPressed: () => Navigator.of(c).pop(true),
            ),
          ),
        ],
      ),
    );
    if (ok == true) await _set(true);
  }

  Future<void> _set(bool active) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(questServiceProvider).setDiscipline(
            active: active,
            reasonKey: active ? DisciplineReasonKeys.manual : null,
            at: ref.read(disciplineClockProvider)(),
          );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final status = ref.watch(disciplineStatusProvider).value;
    final today = ref.watch(disciplineTodayProvider);
    final active = status?.active ?? false;

    Widget? bottom;
    if (status != null) {
      if (status.canEnable) {
        bottom = SysButton.danger(
          key: const Key('dsc-enable'),
          label: l.dscEnable,
          expand: true,
          onPressed: _busy ? null : _enable,
        );
      } else if (status.canDisable) {
        bottom = SysButton.secondary(
          key: const Key('dsc-disable'),
          label: l.dscDisable,
          expand: true,
          onPressed: _busy ? null : () => _set(false),
        );
      } else {
        bottom = Text(
          l.dscDisableLocked,
          key: const Key('dsc-disable-locked'),
          textAlign: TextAlign.center,
          style: SysText.secondary.copyWith(color: SysColors.dangerLight),
        );
      }
    }

    return ScheduleSubPage(
      title: l.dscTitle,
      onBack: () => Navigator.of(context).maybePop(),
      bottom: bottom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusPanel(status: status),
          const SizedBox(height: 16),
          SysPanel(
            key: const Key('dsc-rules'),
            title: l.dscToday,
            tone: active ? PanelTone.danger : PanelTone.accent,
            appearDelay: const Duration(milliseconds: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!active) ...[Text(l.dscPreviewNote, style: SysText.caption), const SizedBox(height: 8)],
                for (final q in today) _RuleRow(quest: q, active: active),
                const SizedBox(height: 10),
                Text(l.dscCannotRefuse, style: SysText.caption),
                const SizedBox(height: 4),
                Text(l.dscRulesNote, style: SysText.caption),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SysPanel(
            key: const Key('dsc-blocker'),
            title: l.dscBlockerTitle,
            trailing: SysPill(label: l.dscBlockerSoon),
            appearDelay: const Duration(milliseconds: 80),
            child: Text(l.dscBlockerText, style: SysText.secondary),
          ),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.status});

  final DisciplineStatus? status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = status;
    final active = s?.active ?? false;
    final color = active ? SysColors.dangerLight : SysColors.accentLight;
    final reason = s?.reason;
    final exit = s?.exit;
    final since = s?.since?.toLocal();
    return SysPanel(
      key: const Key('dsc-status'),
      title: l.dscStatus,
      tone: active ? PanelTone.danger : PanelTone.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SysIcon(active ? SysGlyph.warning : SysGlyph.shield, size: 24, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  (active ? l.dscOn : l.dscOff).toUpperCase(),
                  key: const Key('dsc-state'),
                  style: SysText.heading.copyWith(
                    color: color,
                    shadows: [Shadow(color: color.withValues(alpha: .6), blurRadius: 10)],
                  ),
                ),
              ),
              if (s != null)
                Text(
                  '${s.balance} ◆',
                  semanticsLabel: '${l.dscBalance}: ${s.balance} ◆',
                  style: SysText.mono.copyWith(color: s.inDebt ? SysColors.dangerLight : SysColors.gold, fontSize: 15),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (!active)
            Text(l.dscOffText, style: SysText.secondary)
          else ...[
            if (reason != null) _InfoLine(label: l.dscReasonLabel, value: disciplineReasonLabel(l, reason)),
            if (since != null)
              _InfoLine(
                label: l.dscSinceLabel,
                value: '${since.day.toString().padLeft(2, '0')}.${since.month.toString().padLeft(2, '0')} '
                    '${formatMinuteOfDay(since.hour * 60 + since.minute)}',
                mono: true,
              ),
            if (exit != null) _InfoLine(label: l.dscExitLabel, value: disciplineExitLabel(l, exit)),
          ],
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value, this.mono = false});

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Text.rich(
          TextSpan(children: [
            TextSpan(text: '${label.toUpperCase()}  ', style: SysText.label.copyWith(color: SysColors.textCaption)),
            TextSpan(text: value, style: mono ? SysText.mono : SysText.body),
          ]),
        ),
      );
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.quest, required this.active});

  final QuestInput quest;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Время события (подъём/отбой — из params.minute; квест отбоя начинается раньше).
    final at = quest.title.params['minute'];
    final minute = at is int ? at : quest.minute;
    final glyph = switch (quest.title.key) {
      DisciplineQuestKeys.wake => SysGlyph.bolt,
      DisciplineQuestKeys.bed => SysGlyph.moon,
      DisciplineQuestKeys.walk => SysGlyph.walk,
      _ => SysGlyph.dumbbell,
    };
    final tone = active ? SysColors.dangerLight : SysColors.accentLight;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: SysDims.minTap),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SysIcon(glyph, size: 20, color: tone),
            const SizedBox(width: 10),
            if (minute != null) ...[
              Text(formatMinuteOfDay(minute), style: SysText.mono.copyWith(color: tone)),
              const SizedBox(width: 10),
            ],
            Expanded(child: Text(_questTitle(l, quest.title), style: SysText.body)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('+${quest.reward.diamonds} ◆', style: SysText.monoSmall.copyWith(color: SysColors.gold)),
                Text('−${quest.penaltyDiamonds} ◆', style: SysText.monoSmall.copyWith(color: SysColors.dangerLight)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
