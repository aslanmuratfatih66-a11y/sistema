// Редактор расписания: встраиваемый виджет без Scaffold и без своей прокрутки
// (шаг анкеты №7 и экран «Расписание»). Сохраняет сразу при каждом изменении.
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'data/schedule_repository.dart';
import 'schedule_logic.dart';
import 'widgets/schedule_common.dart';
import 'widgets/schedule_item_screen.dart';

class ScheduleEditor extends ConsumerWidget {
  const ScheduleEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final config = ref.watch(scheduleConfigProvider).value;
    final entries = ref.watch(scheduleEntriesProvider).value;
    if (config == null || entries == null) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: SysLoader()),
      );
    }
    final repo = ref.read(scheduleRepositoryProvider);
    void patch(ScheduleSettingsCompanion p) => repo.updateSettings(p);
    final now = ref.read(scheduleClockProvider)();
    final studies = config.institutionType != null && config.institutionType != InstitutionType.none;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SysFieldLabel(l.schInstitution),
        SysChoiceChips<InstitutionType>(
          choices: [for (final t in InstitutionType.values) SysChoice(t, institutionLabel(l, t))],
          selected: {?config.institutionType},
          onChanged: (s) => patch(ScheduleSettingsCompanion(institutionType: Value(s.isEmpty ? null : s.first.name))),
        ),
        if (studies) ...[
          const SysFieldGap(),
          SysTextField(
            value: config.institutionName ?? '',
            label: l.schInstitutionName,
            hint: l.schInstitutionNameHint,
            onChanged: (s) =>
                patch(ScheduleSettingsCompanion(institutionName: Value(s.trim().isEmpty ? null : s.trim()))),
          ),
        ],
        const SysFieldGap(),
        Row(
          children: [
            Expanded(
              child: SysTimeField(
                label: l.schWake,
                minute: config.wakeMinute,
                onChanged: (m) => patch(ScheduleSettingsCompanion(wakeMinute: Value(m))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SysTimeField(
                label: l.schBed,
                minute: config.bedMinute,
                onChanged: (m) => patch(ScheduleSettingsCompanion(bedMinute: Value(m))),
              ),
            ),
          ],
        ),
        const SysFieldGap(),
        SysFieldLabel(l.schCommute, hint: l.schCommuteHint),
        SysNumberField(
          value: config.commuteMinutes,
          decimal: false,
          max: 300,
          unit: l.schMinutesUnit,
          outOfRangeText: l.commonOutOfRange,
          onChanged: (v) {
            final m = (v ?? 0).toInt();
            if (m <= 300) patch(ScheduleSettingsCompanion(commuteMinutes: Value(m)));
          },
        ),
        const SysFieldGap(),
        SysFieldLabel(l.schWeekends),
        SysChoiceChips<int>(
          multi: true,
          choices: [for (final d in allWeekdays) SysChoice(d, weekdayShort(l, d))],
          selected: config.weekendDays,
          onChanged: (s) =>
              patch(ScheduleSettingsCompanion(weekendDays: Value(ScheduleConfig.formatWeekendDays(s)))),
        ),
        const SysFieldGap(),
        SysSwitchRow(
          label: l.schAlternation,
          hint: l.schAlternationHint,
          value: config.alternationEnabled,
          onChanged: repo.setAlternation,
        ),
        if (config.alternationEnabled) ...[
          const SizedBox(height: 8),
          WeekSwitchRow(week: ScheduleLogic.weekNumber(now, config), onSwitch: repo.switchWeek),
        ],
        const SizedBox(height: 22),
        SysPanelHeader(title: l.schItemsTitle),
        const SizedBox(height: 8),
        for (final wd in allWeekdays)
          _DayGroup(
            weekday: wd,
            weekend: config.weekendDays.contains(wd),
            alternation: config.alternationEnabled,
            entries: [for (final e in entries) if (e.weekday == wd) e]
              ..sort((a, b) => a.startMinute.compareTo(b.startMinute)),
          ),
        const SizedBox(height: 8),
        SysButton.secondary(
          key: const Key('sch-add-item'),
          label: l.schAddItem,
          icon: SysGlyph.plus,
          expand: true,
          onPressed: () => ScheduleItemScreen.open(
            context,
            ScheduleItemScreen.draft(now.weekday),
            alternationEnabled: config.alternationEnabled,
          ),
        ),
      ],
    );
  }
}

/// «Сейчас: неделя N» + кнопка «Переключить неделю».
class WeekSwitchRow extends StatelessWidget {
  const WeekSwitchRow({super.key, required this.week, required this.onSwitch});

  final int week;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(l.schCurrentWeek(week), style: SysText.mono.copyWith(color: SysColors.accentLighter)),
        SysButton.secondary(
          key: const Key('sch-switch-week'),
          label: l.schSwitchWeek,
          onPressed: onSwitch,
        ),
      ],
    );
  }
}

class _DayGroup extends ConsumerWidget {
  const _DayGroup({required this.weekday, required this.weekend, required this.alternation, required this.entries});

  final int weekday;
  final bool weekend;
  final bool alternation;
  final List<ScheduleEntry> entries;

  Future<void> _copy(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final target = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: SysColors.panelBottom,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SysFieldLabel(l.schCopyDayTo),
              SysChoiceChips<int>(
                choices: [
                  for (final d in allWeekdays)
                    if (d != weekday) SysChoice(d, weekdayFull(l, d)),
                ],
                selected: const {},
                onChanged: (s) => Navigator.of(c).pop(s.isEmpty ? null : s.first),
              ),
            ],
          ),
        ),
      ),
    );
    if (target == null) return;
    final n = await ref.read(scheduleRepositoryProvider).copyDay(weekday, target);
    if (context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l.schCopied(n))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: weekdayFull(l, weekday).toUpperCase(), style: SysText.label),
                    if (weekend)
                      TextSpan(
                        text: '  · ${l.schWeekend}',
                        style: SysText.caption.copyWith(color: SysColors.textInactive),
                      ),
                  ]),
                ),
              ),
              if (entries.isNotEmpty)
                IconButton(
                  tooltip: l.schCopyDayFrom(weekdayFull(l, weekday)),
                  onPressed: () => _copy(context, ref),
                  icon: const SysIcon(SysGlyph.arrowDown, size: 18, color: SysColors.accentLight),
                ),
              IconButton(
                key: Key('sch-add-$weekday'),
                tooltip: l.schAddItemTo(weekdayFull(l, weekday)),
                onPressed: () => ScheduleItemScreen.open(
                  context,
                  ScheduleItemScreen.draft(weekday,
                      startMinute: entries.isEmpty ? 9 * 60 : entries.last.endMinute.clamp(0, 23 * 60)),
                  alternationEnabled: alternation,
                ),
                icon: const SysIcon(SysGlyph.plus, size: 18, color: SysColors.accentLight),
              ),
            ],
          ),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(l.schDayEmpty, style: SysText.caption.copyWith(color: SysColors.textInactive)),
            )
          else
            for (final e in entries) EntryTile(entry: e, alternation: alternation),
        ],
      ),
    );
  }
}

/// Строка пункта: время, название, место, метка недели. Нажатие — редактирование.
class EntryTile extends StatelessWidget {
  const EntryTile({super.key, required this.entry, required this.alternation, this.dimmed = false});

  final ScheduleEntry entry;
  final bool alternation;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final e = entry;
    final loc = e.location;
    final color = dimmed ? SysColors.textInactive : SysColors.textPrimary;
    return InkWell(
      key: Key('sch-entry-${e.id}'),
      onTap: () => ScheduleItemScreen.open(context, e, alternationEnabled: alternation),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: SysDims.minTap),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: SysColors.accent.withValues(alpha: .06),
            border: Border(left: BorderSide(color: dimmed ? SysColors.textInactive : SysColors.accent, width: 2)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 92,
                child: Text(
                  l.schTimeRange(formatMinuteOfDay(e.startMinute), formatMinuteOfDay(e.endMinute)),
                  style: SysText.mono.copyWith(fontSize: 12, color: dimmed ? SysColors.textInactive : SysColors.accentLight),
                ),
              ),
              SysIcon(kindGlyph(e.kind), size: 16, color: color, semanticLabel: kindLabel(l, e.kind)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.title, style: SysText.body.copyWith(color: color)),
                    if (loc != null && loc.isNotEmpty) Text(loc, style: SysText.caption),
                  ],
                ),
              ),
              if (e.weekParity != 0) SysPill(label: l.schWeekN(e.weekParity)),
            ],
          ),
        ),
      ),
    );
  }
}
