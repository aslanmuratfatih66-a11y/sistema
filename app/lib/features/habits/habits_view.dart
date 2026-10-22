// Вкладка «Квесты» → «Привычки» (SPEC §8.17): счётчик дней без, лучшая серия, экономия, срыв с триггером,
// награды за серии, ненавязчивая ссылка на помощь при зависимостях.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../home/data/home_providers.dart';
import '../home/widgets/tab_section_view.dart';
import 'habit_repository.dart';

String habitTitle(AppLocalizations l, Habit h) {
  final t = h.title?.trim();
  if (t != null && t.isNotEmpty) return t;
  return habitKindLabel(l, h.kind);
}

String habitKindLabel(AppLocalizations l, String kind) => switch (kind) {
      HabitKinds.smoking => l.habSmoking,
      HabitKinds.vape => l.habVape,
      HabitKinds.alcohol => l.habAlcohol,
      HabitKinds.sweets => l.habSweets,
      HabitKinds.energy => l.habEnergy,
      HabitKinds.phone => l.habPhone,
      HabitKinds.lateSleep => l.habLateSleep,
      _ => l.habCustom,
    };

String habitTriggerLabel(AppLocalizations l, String t) => switch (t) {
      'stress' => l.habTrigStress,
      'boredom' => l.habTrigBoredom,
      'company' => l.habTrigCompany,
      'tired' => l.habTrigTired,
      'habitTime' => l.habTrigHabitTime,
      _ => l.habTrigOther,
    };

class HabitsView extends ConsumerStatefulWidget {
  const HabitsView({super.key});

  @override
  ConsumerState<HabitsView> createState() => _HabitsViewState();
}

class _HabitsViewState extends ConsumerState<HabitsView> {
  @override
  void initState() {
    super.initState();
    // Отметки серий проверяются и при открытии (основная проверка — перед tick).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(habitRepositoryProvider).checkMilestones().catchError((Object _) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final habits = ref.watch(habitsProvider);
    final now = ref.watch(homeClockProvider);
    final list = habits.value ?? const <Habit>[];
    final addictive = list.any((h) => HabitKinds.addictive.contains(h.kind));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (habits.isLoading && list.isEmpty)
          const SysSkeletonPanel(lines: 3)
        else if (list.isEmpty)
          SysPanel(
            title: l.habTitle,
            child: SysEmptyState.inline(l.habEmpty, glyph: SysGlyph.shield),
          )
        else
          for (final (i, h) in list.indexed) ...[
            if (i > 0) const SizedBox(height: TabSectionView.gap),
            _HabitCard(key: ValueKey('habit-${h.id}'), habit: h, now: now),
          ],
        const SizedBox(height: TabSectionView.gap),
        SysButton.secondary(
          key: const Key('habit-add'),
          label: l.habAdd,
          icon: SysGlyph.plus,
          expand: true,
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => const _AddHabitSheet(),
          ),
        ),
        const SizedBox(height: 10),
        Text(l.habRulesHint, style: SysText.caption, textAlign: TextAlign.center),
        if (addictive) ...[
          const SizedBox(height: 10),
          Text(l.habHelpHint, key: const Key('habit-help'), style: SysText.caption, textAlign: TextAlign.center),
        ],
      ],
    );
  }
}

class _HabitCard extends ConsumerWidget {
  const _HabitCard({super.key, required this.habit, required this.now});

  final Habit habit;
  final DateTime now;

  Future<void> _relapse(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final trigger = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      builder: (c) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SysPanelHeader(title: l.habRelapseTitle, tone: PanelTone.danger),
            const SizedBox(height: 8),
            Text(l.habRelapseHint(HabitRules.relapsePenalty), style: SysText.secondary),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in HabitKinds.triggers)
                  SysButton.secondary(
                    key: ValueKey('habit-trigger-$t'),
                    label: habitTriggerLabel(l, t),
                    onPressed: () => Navigator.of(c).pop(t),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
    if (trigger == null) return;
    await ref.read(habitRepositoryProvider).relapse(habit, trigger: trigger);
  }

  Future<void> _remove(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final ok = await showSystemWindow<bool>(
      context,
      window: SystemWindow(
        kind: SystemWindowKind.warning,
        label: l.habNoticeLabel,
        message: l.habRemoveConfirm(habitTitle(l, habit)),
        actions: [
          Builder(builder: (c) => SysButton.secondary(label: l.commonCancel, onPressed: () => Navigator.of(c).pop(false))),
          Builder(builder: (c) => SysButton.primary(label: l.habRemove, onPressed: () => Navigator.of(c).pop(true))),
        ],
      ),
    );
    if (ok == true) await ref.read(habitRepositoryProvider).remove(habit.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final days = habit.daysClean(now);
    final next = HabitRules.nextMilestone(days);
    final prev = HabitRules.milestones.keys.where((m) => m <= days).fold(0, (a, b) => b > a ? b : a);
    final saved = habit.saved(now);
    final lastTrigger = habit.relapses.firstOrNull?.trigger;

    return SysPanel(
      title: habitTitle(l, habit),
      tone: days >= 7 ? PanelTone.success : PanelTone.accent,
      trailing: SysIconButton(glyph: SysGlyph.trash, tooltip: l.habRemove, onPressed: () => _remove(context, ref)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$days',
                key: ValueKey('habit-days-${habit.id}'),
                style: SysText.mono.copyWith(fontSize: 34, fontWeight: FontWeight.w700, color: SysColors.success),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(l.habDaysWithout(days), style: SysText.secondary),
                ),
              ),
              Text(l.habBest(habit.best(now)), style: SysText.monoSmall.copyWith(color: SysColors.textCaption)),
            ],
          ),
          if (next != null) ...[
            const SizedBox(height: 8),
            SysBar(value: (days - prev) / (next - prev), color: SysColors.success),
            const SizedBox(height: 4),
            Text(l.habNext(next, HabitRules.milestones[next]!), style: SysText.caption),
          ],
          if (saved > 0) ...[
            const SizedBox(height: 6),
            Text(l.habSaved(saved), style: SysText.body.copyWith(color: SysColors.gold)),
          ],
          if (lastTrigger != null) ...[
            const SizedBox(height: 4),
            Text(l.habLastTrigger(habitTriggerLabel(l, lastTrigger)), style: SysText.caption),
          ],
          const SizedBox(height: 10),
          SysButton.secondary(
            key: ValueKey('habit-relapse-${habit.id}'),
            label: l.habRelapse,
            expand: true,
            onPressed: () => _relapse(context, ref),
          ),
        ],
      ),
    );
  }
}

class _AddHabitSheet extends ConsumerStatefulWidget {
  const _AddHabitSheet();

  @override
  ConsumerState<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends ConsumerState<_AddHabitSheet> {
  String _kind = HabitKinds.smoking;
  String _title = '';
  num? _cost;
  num? _daysAgo;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final custom = _kind == HabitKinds.custom;
    return SingleChildScrollView(
      key: const Key('habit-add-sheet'),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 20 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanelHeader(title: l.habAdd),
          const SizedBox(height: 12),
          SysChoiceChips<String>(
            choices: [
              for (final k in [...HabitKinds.presets, HabitKinds.custom]) SysChoice(k, habitKindLabel(l, k)),
            ],
            selected: {_kind},
            allowEmpty: false,
            onChanged: (v) => setState(() => _kind = v.first),
          ),
          if (custom) ...[
            const SizedBox(height: 12),
            SysTextField(label: l.habCustomTitle, value: _title, onChanged: (v) => setState(() => _title = v)),
          ],
          const SizedBox(height: 12),
          SysNumberField(
            label: l.habDailyCost,
            unit: '₽',
            decimal: false,
            min: 0,
            value: _cost,
            onChanged: (v) => _cost = v,
          ),
          const SizedBox(height: 12),
          SysNumberField(
            label: l.habAlreadyDays,
            decimal: false,
            min: 0,
            max: 3650,
            value: _daysAgo,
            onChanged: (v) => _daysAgo = v,
          ),
          const SizedBox(height: 16),
          SysButton.primary(
            key: const Key('habit-add-save'),
            label: l.habAddSave,
            expand: true,
            onPressed: () async {
              if (custom && _title.trim().isEmpty) return;
              final nav = Navigator.of(context);
              final days = _daysAgo?.round() ?? 0;
              await ref.read(habitRepositoryProvider).add(
                    kind: _kind,
                    title: custom ? _title.trim() : null,
                    dailyCost: _cost?.round() ?? 0,
                    cleanSince: DateTime.now().subtract(Duration(days: days)),
                  );
              nav.pop();
            },
          ),
        ],
      ),
    );
  }
}
