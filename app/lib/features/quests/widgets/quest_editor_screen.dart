// Создание и правка своего квеста: название, характеристика, время и окно, дни недели,
// чередование недель, подзадачи, награда/штраф (по правилам Системы или вручную), «надоедать».
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/enums.dart';
import '../../../domain/quests/quest_api.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../home/widgets/status_panel.dart' show statLabel;
import '../quest_actions.dart';

class QuestEditorScreen extends ConsumerStatefulWidget {
  const QuestEditorScreen({super.key, this.questId, this.initial});

  /// null — новый квест.
  final String? questId;
  final QuestInput? initial;

  static Future<void> open(NavigatorState nav, {String? questId, QuestInput? initial}) =>
      nav.push(MaterialPageRoute<void>(builder: (_) => QuestEditorScreen(questId: questId, initial: initial)));

  @override
  ConsumerState<QuestEditorScreen> createState() => _QuestEditorScreenState();
}

class _QuestEditorScreenState extends ConsumerState<QuestEditorScreen> {
  late final QuestInput? _init = widget.initial;
  late String _title = _init?.title.text ?? '';
  late StatKind? _stat = _init?.stat;
  late bool _timed = _init?.minute != null;
  late int _minute = _init?.minute ?? 9 * 60;
  late int _window = _init?.windowMinutes ?? 60;
  late Set<int> _weekdays = {...?_init?.weekdays};
  late int _parity = _init?.weekParity ?? 0;
  late final List<(int, String)> _subtasks = [for (final (i, s) in (_init?.subtasks ?? const []).indexed) (i, s)];
  late int _nextSubId = _subtasks.length;
  // Награда «по правилам Системы»: пустая награда и нулевой штраф — движок подставит свои значения.
  late bool _defaultReward = _isDefaultReward(widget.initial);
  late int _diamonds = _init?.reward.diamonds ?? 10;
  late int _xp = _init?.reward.xp ?? 15;
  late int _penalty = _init?.penaltyDiamonds ?? 10;
  late bool _nag = _init?.nag ?? true;
  bool _triedSave = false;

  static bool _isDefaultReward(QuestInput? i) =>
      i == null || (i.reward.diamonds == 0 && i.reward.xp == 0 && i.penaltyDiamonds == 0);

  bool get _isNew => widget.questId == null;
  bool get _valid => _title.trim().isNotEmpty && (!_timed || _window > 0);

  QuestInput _input() {
    final s = _stat;
    return QuestInput(
      kind: _init?.kind ?? QuestKind.custom,
      title: QuestTitle(text: _title.trim()),
      stat: s,
      subtasks: [for (final (_, t) in _subtasks) if (t.trim().isNotEmpty) t.trim()],
      minute: _timed ? _minute : null,
      windowMinutes: _timed ? _window : 60,
      weekdays: _weekdays.toList()..sort(),
      weekParity: _parity,
      reward: _defaultReward ? GameReward.none : GameReward(diamonds: _diamonds, xp: _xp, stats: {?s: 1}),
      penaltyDiamonds: _defaultReward ? 0 : _penalty,
      refusePenaltyDiamonds: _init?.refusePenaltyDiamonds,
      confirm: _init?.confirm ?? ConfirmMethod.button,
      target: _init?.target,
      nag: _nag,
      cancellable: true,
      source: QuestSource.user,
    );
  }

  Future<void> _save() async {
    setState(() => _triedSave = true);
    if (!_valid) return;
    final nav = Navigator.of(context);
    final id = widget.questId;
    final input = _input();
    final ok = await runQuestAction(
      context,
      ref,
      (s, _) => id == null ? s.createQuest(input) : s.updateQuest(id, input),
    );
    if (ok && nav.mounted) nav.pop();
  }

  Future<void> _archive() async {
    final l = AppLocalizations.of(context);
    final id = widget.questId;
    if (id == null) return;
    final ok = await confirmSystem(
      context,
      title: _title,
      message: l.qstArchiveConfirm,
      confirmLabel: l.qstArchive,
      tone: PanelTone.danger,
      danger: true,
    );
    if (!ok || !mounted) return;
    final nav = Navigator.of(context);
    if (await runQuestAction(context, ref, (s, _) => s.archiveQuest(id)) && nav.mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final weekdayFmt = DateFormat.E(l.localeName);
    // 2024-01-01 — понедельник: подписи дней недели в языке интерфейса.
    String dayName(int wd) => weekdayFmt.format(DateTime(2024, 1, wd));

    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SysTextField(
          key: const Key('quest-form-title'),
          value: _title,
          label: l.qstFormTitle,
          hint: l.qstFormTitleHint,
          errorText: _triedSave && _title.trim().isEmpty ? l.commonRequired : null,
          onChanged: (v) => setState(() => _title = v),
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qstFormStat, optional: true, optionalLabel: l.commonOptional),
        SysChoiceChips<StatKind>(
          choices: [for (final k in StatKind.values) SysChoice(k, statLabel(l, k))],
          selected: {?_stat},
          onChanged: (s) => setState(() => _stat = s.isEmpty ? null : s.first),
        ),
        const SysFieldGap(),
        SysSwitchRow(
          label: l.qstFormTimed,
          hint: l.qstFormTimedHint,
          value: _timed,
          onChanged: (v) => setState(() => _timed = v),
        ),
        if (_timed) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SysTimeField(label: l.qstFormTime, minute: _minute, onChanged: (m) => setState(() => _minute = m)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SysNumberField(
                  value: _window,
                  decimal: false,
                  min: 1,
                  max: 24 * 60,
                  label: l.qstFormWindow,
                  unit: l.qstMinutesUnit,
                  onChanged: (v) => setState(() => _window = v?.toInt() ?? 0),
                ),
              ),
            ],
          ),
        ],
        const SysFieldGap(),
        SysFieldLabel(l.qstFormWeekdays, hint: l.qstFormWeekdaysHint),
        SysChoiceChips<int>(
          key: const Key('quest-form-weekdays'),
          multi: true,
          choices: [for (var d = DateTime.monday; d <= DateTime.sunday; d++) SysChoice(d, dayName(d))],
          selected: _weekdays,
          onChanged: (s) => setState(() => _weekdays = s),
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qstFormWeekParity),
        SysSegmented<int>(
          choices: [SysChoice(0, l.qstWeekEvery), SysChoice(1, l.qstWeek1), SysChoice(2, l.qstWeek2)],
          value: _parity,
          onChanged: (v) => setState(() => _parity = v),
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qstFormSubtasks, optional: true, optionalLabel: l.commonOptional),
        for (final (i, (id, text)) in _subtasks.indexed)
          Padding(
            key: ValueKey('subtask-field-$id'),
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: SysTextField(
                    value: text,
                    hint: l.qstFormSubtaskHint(i + 1),
                    onChanged: (v) => setState(() => _subtasks[i] = (id, v)),
                  ),
                ),
                IconButton(
                  tooltip: l.qstFormRemoveSubtask,
                  constraints: const BoxConstraints(minWidth: SysDims.minTap, minHeight: SysDims.minTap),
                  onPressed: () => setState(() => _subtasks.removeAt(i)),
                  icon: const SysIcon(SysGlyph.close, size: 18, color: SysColors.dangerLight),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: SysButton.secondary(
            key: const Key('quest-form-add-subtask'),
            label: l.qstFormAddSubtask,
            icon: SysGlyph.plus,
            onPressed: () => setState(() => _subtasks.add((_nextSubId++, ''))),
          ),
        ),
        const SysFieldGap(),
        SysSwitchRow(
          label: l.qstFormDefaultReward,
          hint: l.qstFormDefaultRewardHint,
          value: _defaultReward,
          onChanged: (v) => setState(() => _defaultReward = v),
        ),
        if (!_defaultReward) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SysNumberField(
                  value: _diamonds,
                  decimal: false,
                  min: 0,
                  max: 1000,
                  label: l.qstFormRewardDiamonds,
                  onChanged: (v) => setState(() => _diamonds = v?.toInt() ?? 0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SysNumberField(
                  value: _xp,
                  decimal: false,
                  min: 0,
                  max: 1000,
                  label: l.qstFormRewardXp,
                  onChanged: (v) => setState(() => _xp = v?.toInt() ?? 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SysNumberField(
            value: _penalty,
            decimal: false,
            min: 0,
            max: 1000,
            label: l.qstFormPenalty,
            onChanged: (v) => setState(() => _penalty = v?.toInt() ?? 0),
          ),
        ],
        const SysFieldGap(),
        SysSwitchRow(
          label: l.qstFormNag,
          hint: l.qstFormNagHint,
          value: _nag,
          onChanged: (v) => setState(() => _nag = v),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: SysColors.background,
      body: SystemBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      tooltip: l.commonBack,
                      constraints: const BoxConstraints(minWidth: SysDims.minTap, minHeight: SysDims.minTap),
                      icon: const SysIcon(SysGlyph.arrowLeft, size: 22, color: SysColors.accentLight),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          (_isNew ? l.qstNewQuest : l.qstEditQuest).toUpperCase(),
                          style: SysText.heading,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  key: const Key('quest-form-scroll'),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: form,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    if (!_isNew) ...[
                      Expanded(
                        child: SysButton.danger(label: l.qstArchive, expand: true, onPressed: _archive),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: SysButton.primary(
                        key: const Key('quest-form-save'),
                        label: l.commonSave,
                        expand: true,
                        onPressed: _save,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
