// Настройки → «Режимы дня» (SPEC §8.13): автоплан (с 8-го уровня, сам — в дисциплине), занятость по расписанию,
// адаптивная сложность (с текущим шагом), итоги дня перед отбоем.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/day_modes/day_modes.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../quests/data/quest_providers.dart';

class DayModesPanel extends ConsumerWidget {
  const DayModesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final prefs = ref.watch(dayModesPrefsProvider).value ?? const DayModesPrefs();
    final adaptive = ref.watch(dayAdaptiveProvider).value ?? const AdaptiveState();
    final level = ref.watch(questPlayerProvider).value?.level ?? 1;
    final unlocked = level >= autoplanUnlockLevel;
    final service = ref.read(dayModesServiceProvider);
    void save(DayModesPrefs p) => service.savePrefs(p);

    final rate = adaptive.rate;
    final adaptiveStatus = rate == null
        ? l.dmAdaptiveCollecting
        : l.dmAdaptiveStatus('${adaptive.percent >= 0 ? '+' : ''}${adaptive.percent}', (rate * 100).round());

    return SysPanel(
      key: const Key('day-modes-panel'),
      title: l.dmTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysSwitchRow(
            key: const Key('dm-autoplan'),
            label: l.dmAutoplan,
            hint: unlocked ? l.dmAutoplanHint : l.dmAutoplanLocked(autoplanUnlockLevel),
            value: unlocked && prefs.autoplan,
            onChanged: (v) {
              if (!unlocked) {
                ScaffoldMessenger.maybeOf(context)
                  ?..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(l.dmAutoplanLocked(autoplanUnlockLevel))));
                return;
              }
              save(prefs.copyWith(autoplan: v));
            },
          ),
          SysSwitchRow(
            key: const Key('dm-autoplan-discipline'),
            label: l.dmAutoplanDiscipline,
            value: prefs.autoplanInDiscipline,
            onChanged: (v) => save(prefs.copyWith(autoplanInDiscipline: v)),
          ),
          SysSwitchRow(
            key: const Key('dm-busy-schedule'),
            label: l.dmBusySchedule,
            hint: l.dmBusyScheduleHint,
            value: prefs.busyFromSchedule,
            onChanged: (v) => save(prefs.copyWith(busyFromSchedule: v)),
          ),
          SysSwitchRow(
            key: const Key('dm-adaptive'),
            label: l.dmAdaptive,
            hint: prefs.adaptive ? adaptiveStatus : l.dmAdaptiveHint,
            value: prefs.adaptive,
            onChanged: (v) => save(prefs.copyWith(adaptive: v)),
          ),
          SysSwitchRow(
            key: const Key('dm-summary'),
            label: l.dmSummary,
            hint: l.dmSummaryHint,
            value: prefs.daySummary,
            onChanged: (v) => save(prefs.copyWith(daySummary: v)),
          ),
        ],
      ),
    );
  }
}
