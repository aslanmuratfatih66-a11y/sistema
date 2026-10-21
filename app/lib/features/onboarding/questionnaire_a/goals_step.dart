import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../step_scope.dart';
import 'data/goal_repository.dart';
import 'data/serial_writer.dart';

/// Стандартные цели (порядок показа).
const _standardGoals = [
  GoalKind.acne,
  GoalKind.blackheads,
  GoalKind.swelling,
  GoalKind.weightLoss,
  GoalKind.muscle,
  GoalKind.discipline,
  GoalKind.study,
  GoalKind.money,
];

String goalKindLabel(AppLocalizations l, GoalKind k) => switch (k) {
      GoalKind.acne => l.qaGoalAcne,
      GoalKind.blackheads => l.qaGoalBlackheads,
      GoalKind.swelling => l.qaGoalSwelling,
      GoalKind.weightLoss => l.qaGoalWeightLoss,
      GoalKind.muscle => l.qaGoalMuscle,
      GoalKind.discipline => l.qaGoalDiscipline,
      GoalKind.study => l.qaGoalStudy,
      GoalKind.money => l.qaGoalMoney,
      GoalKind.custom => l.qaGoalCustom,
    };

/// Этап 6 «Цели»: мультивыбор + свои; для каждой — приоритет и срок. Хотя бы одна цель обязательна.
class GoalsStep extends ConsumerStatefulWidget {
  const GoalsStep({super.key});

  @override
  ConsumerState<GoalsStep> createState() => _GoalsStepState();
}

class _GoalsStepState extends ConsumerState<GoalsStep> {
  final _writer = SerialWriter();
  final _custom = TextEditingController();

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  GoalRepository get _repo => ref.read(goalRepositoryProvider);

  void _onKindsChanged(Set<GoalKind> before, Set<GoalKind> after) {
    for (final k in after.difference(before)) {
      _writer.run(() => _repo.select(k));
    }
    for (final k in before.difference(after)) {
      _writer.run(() => _repo.unselect(k));
    }
  }

  void _addCustom() {
    final t = _custom.text.trim();
    if (t.isEmpty) return;
    _custom.clear();
    setState(() {});
    _writer.run(() => _repo.addCustom(t));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scope = StepScope.maybeOf(context);
    final goalsAsync = ref.watch(activeGoalsProvider);
    final goals = goalsAsync.value ?? const <GoalRow>[];
    scope?.setCanProceed(goals.isNotEmpty);

    final selected = {
      for (final g in goals)
        if (enumByName(GoalKind.values, g.kind) case final k? when k != GoalKind.custom) k,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (scope?.editing != true) ...[
          Text(l.qaGoalsIntro, style: SysText.secondary),
          const SysFieldGap(),
        ],
        SysFieldLabel(l.qaGoalsPick, hint: l.qaGoalsPickHint),
        SysChoiceChips<GoalKind>(
          multi: true,
          choices: [for (final k in _standardGoals) SysChoice(k, goalKindLabel(l, k))],
          selected: selected,
          onChanged: (s) => _onKindsChanged(selected, s),
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qaGoalsOwn),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _custom,
                style: SysText.body,
                cursorColor: SysColors.accentLight,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(hintText: l.qaGoalsOwnHint),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _addCustom(),
              ),
            ),
            const SizedBox(width: 10),
            SysButton.secondary(
              label: l.commonAdd,
              icon: SysGlyph.plus,
              onPressed: _custom.text.trim().isEmpty ? null : _addCustom,
            ),
          ],
        ),
        const SysFieldGap(),
        if (goalsAsync.hasValue && goals.isEmpty)
          Text(l.qaGoalsEmpty, style: SysText.caption.copyWith(color: SysColors.dangerLight)),
        for (final g in goals) ...[
          _GoalCard(
            key: ValueKey(g.id),
            goal: g,
            onPriority: (p) => _writer.run(() => _repo.setPriority(g.id, p)),
            onDeadline: (d) => _writer.run(() => _repo.setDeadline(g.id, d)),
            onRemove: () => _writer.run(() => _repo.remove(g.id)),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    super.key,
    required this.goal,
    required this.onPriority,
    required this.onDeadline,
    required this.onRemove,
  });

  final GoalRow goal;
  final ValueChanged<int> onPriority;
  final ValueChanged<DateTime?> onDeadline;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final kind = enumByName(GoalKind.values, goal.kind) ?? GoalKind.custom;
    final title = kind == GoalKind.custom ? (goal.title ?? '') : goalKindLabel(l, kind);
    final today = DateTime.now();
    final deadline = goal.deadline;
    return SysPanel(
      title: title,
      animateIn: false,
      trailing: IconButton(
        tooltip: l.commonDelete,
        onPressed: onRemove,
        icon: const SysIcon(SysGlyph.close, size: 16, color: SysColors.textCaption),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysFieldLabel(l.qaGoalPriority),
          SysSegmented<int>(
            choices: [
              SysChoice(goalPriorityHigh, l.qaGoalPriorityHigh),
              SysChoice(goalPriorityMedium, l.qaGoalPriorityMedium),
              SysChoice(goalPriorityLow, l.qaGoalPriorityLow),
            ],
            value: goal.priority,
            onChanged: onPriority,
          ),
          const SizedBox(height: 12),
          SysFieldLabel(l.qaGoalDeadline, optional: true, optionalLabel: l.commonOptional),
          Row(
            children: [
              Expanded(
                child: SysDateField(
                  date: deadline,
                  // Срок в прошлом (старая цель) не должен ломать календарь.
                  firstDate: deadline != null && deadline.isBefore(today)
                      ? DateTime(deadline.year, deadline.month, deadline.day)
                      : DateTime(today.year, today.month, today.day),
                  lastDate: DateTime(today.year + 10, 12, 31),
                  initialDate: DateTime(today.year, today.month + 3, today.day),
                  onChanged: (d) => onDeadline(DateTime(d.year, d.month, d.day)),
                ),
              ),
              if (deadline != null)
                IconButton(
                  tooltip: l.qaGoalDeadlineClear,
                  onPressed: () => onDeadline(null),
                  icon: const SysIcon(SysGlyph.close, size: 16, color: SysColors.textCaption),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
