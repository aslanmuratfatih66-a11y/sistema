import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../data/schedule_repository.dart';
import '../schedule_logic.dart';
import 'schedule_common.dart';

/// Экран добавления/редактирования пункта расписания (открывается через Navigator).
/// Сохраняет по кнопке «Сохранить»; удаление — мягкое, с подтверждением.
class ScheduleItemScreen extends ConsumerStatefulWidget {
  const ScheduleItemScreen({super.key, required this.initial, required this.alternationEnabled});

  /// id пустой — новый пункт.
  final ScheduleEntry initial;
  final bool alternationEnabled;

  static Future<void> open(BuildContext context, ScheduleEntry initial, {required bool alternationEnabled}) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => ScheduleItemScreen(initial: initial, alternationEnabled: alternationEnabled),
      ));

  /// Заготовка нового пункта на день [weekday].
  static ScheduleEntry draft(int weekday, {int startMinute = 9 * 60}) => ScheduleEntry(
        id: '',
        kind: ScheduleItemKind.lesson,
        title: '',
        weekday: weekday,
        startMinute: startMinute,
        durationMinutes: 90,
      );

  @override
  ConsumerState<ScheduleItemScreen> createState() => _ScheduleItemScreenState();
}

class _ScheduleItemScreenState extends ConsumerState<ScheduleItemScreen> {
  late ScheduleEntry _e = widget.initial;
  bool _triedSave = false;

  bool get _isNew => widget.initial.id.isEmpty;
  bool get _valid => _e.title.trim().isNotEmpty && _e.durationMinutes > 0;

  Future<void> _save() async {
    setState(() => _triedSave = true);
    if (!_valid) return;
    await ref.read(scheduleRepositoryProvider).saveEntry(_e);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: SysColors.barrier,
      builder: (c) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: SystemWindow(
          kind: SystemWindowKind.warning,
          warningTone: PanelTone.danger,
          label: l.schWarningLabel,
          message: l.schDeleteConfirm,
          actions: [
            SysButton.secondary(label: l.commonCancel, onPressed: () => Navigator.of(c).pop(false)),
            SysButton.danger(label: l.commonDelete, onPressed: () => Navigator.of(c).pop(true)),
          ],
        ),
      ),
    );
    if (ok != true) return;
    await ref.read(scheduleRepositoryProvider).deleteEntry(_e.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final titleError = _triedSave && _e.title.trim().isEmpty ? l.commonRequired : null;
    return ScheduleSubPage(
      title: _isNew ? l.schItemNew : l.schItemEdit,
      onBack: () => Navigator.of(context).maybePop(),
      bottom: Row(
        children: [
          if (!_isNew) ...[
            Expanded(child: SysButton.danger(label: l.commonDelete, expand: true, onPressed: _delete)),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 2,
            child: SysButton.primary(
              key: const Key('sch-item-save'),
              label: l.commonSave,
              expand: true,
              icon: SysGlyph.check,
              onPressed: _save,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysFieldLabel(l.schKind),
          SysSegmented<ScheduleItemKind>(
            choices: [for (final k in ScheduleItemKind.values) SysChoice(k, kindLabel(l, k))],
            value: _e.kind,
            onChanged: (k) => setState(() => _e = _e.copyWith(kind: k)),
          ),
          const SysFieldGap(),
          SysTextField(
            key: const Key('sch-item-title'),
            value: _e.title,
            label: l.schItemTitle,
            hint: l.schItemTitleHint,
            errorText: titleError,
            onChanged: (s) => setState(() => _e = _e.copyWith(title: s)),
          ),
          const SysFieldGap(),
          SysFieldLabel(l.schDay),
          SysChoiceChips<int>(
            choices: [for (final d in allWeekdays) SysChoice(d, weekdayShort(l, d))],
            selected: {_e.weekday},
            allowEmpty: false,
            onChanged: (s) => setState(() => _e = _e.copyWith(weekday: s.first)),
          ),
          const SysFieldGap(),
          SysTimeField(
            label: l.schStart,
            minute: _e.startMinute,
            onChanged: (m) => setState(() => _e = _e.copyWith(startMinute: m)),
          ),
          const SysFieldGap(),
          SysNumberField(
            label: l.schDuration,
            value: _e.durationMinutes,
            decimal: false,
            min: 5,
            max: 16 * 60,
            unit: l.schMinutesUnit,
            outOfRangeText: l.commonOutOfRange,
            onChanged: (v) => setState(() => _e = _e.copyWith(durationMinutes: (v ?? 0).toInt())),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final m in const [45, 90])
                SysButton.secondary(
                  label: l.schMinutes(m),
                  onPressed: () => setState(() => _e = _e.copyWith(durationMinutes: m)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l.schEndsAt(formatMinuteOfDay(_e.endMinute)),
            style: SysText.secondary,
          ),
          if (widget.alternationEnabled || _e.weekParity != 0) ...[
            const SysFieldGap(),
            SysFieldLabel(l.schParity),
            SysSegmented<int>(
              choices: [
                SysChoice(0, l.schParityEvery),
                SysChoice(1, l.schWeekN(1)),
                SysChoice(2, l.schWeekN(2)),
              ],
              value: _e.weekParity,
              onChanged: (p) => setState(() => _e = _e.copyWith(weekParity: p)),
            ),
          ],
          const SysFieldGap(),
          SysTextField(
            value: _e.location ?? '',
            label: l.schLocation,
            hint: l.schLocationHint,
            onChanged: (s) => setState(() => _e = _e.copyWith(location: () => s)),
          ),
          const SysFieldGap(),
          SysSwitchRow(
            label: l.schRequiresCommute,
            hint: l.schRequiresCommuteHint,
            value: _e.requiresCommute,
            onChanged: (v) => setState(() => _e = _e.copyWith(requiresCommute: v)),
          ),
        ],
      ),
    );
  }
}
