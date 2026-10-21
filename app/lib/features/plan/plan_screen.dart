// Экран «План» (SPEC §5): «Системное окно» с нормами, распорядком, квестами и кнопкой «Принять».
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/routes.dart';
import '../../domain/quests/quest_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../onboarding/onboarding_step.dart';
import '../schedule/data/schedule_repository.dart';
import '../schedule/schedule_logic.dart';
import 'data/plan_repository.dart';
import 'model/plan.dart';
import 'norms/plan_calculator.dart';
import 'plan_l10n.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  StoredPlan? _plan;
  bool _loading = true;
  bool _busy = false;
  Object? _error;

  /// Разделы, которые влияют на план.
  static const _editableSteps = [
    OnboardingStep.profile,
    OnboardingStep.body,
    OnboardingStep.goals,
    OnboardingStep.schedule,
    OnboardingStep.nutrition,
    OnboardingStep.training,
    OnboardingStep.health,
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _run(() async {
      final accepted = await ref.read(planRepositoryProvider).latestAccepted();
      return accepted ?? await ref.read(planDraftServiceProvider).recalculate();
    });
  }

  Future<void> _recalculate() => _run(() => ref.read(planDraftServiceProvider).recalculate());

  Future<void> _run(Future<StoredPlan> Function() action) async {
    setState(() {
      _loading = _plan == null;
      _busy = true;
      _error = null;
    });
    try {
      final plan = await action();
      if (!mounted) return;
      setState(() => _plan = plan);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _busy = false;
        });
      }
    }
  }

  Future<void> _accept() async {
    final plan = _plan;
    if (plan == null || _busy) return;
    setState(() => _busy = true);
    await ref.read(planRepositoryProvider).accept(plan.id);
    await ref.read(questServiceProvider).importPlanQuests(
      planId: plan.id,
      drafts: [for (final q in plan.plan.quests) q.toJson()],
    );
    if (!mounted) return;
    context.go(Routes.status);
  }

  Future<void> _edit(OnboardingStep step) async {
    await context.push(Routes.editStep(step));
    if (mounted) await _recalculate();
  }

  Future<void> _chooseSection() async {
    final l = AppLocalizations.of(context);
    final step = await showModalBottomSheet<OnboardingStep>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(l.planChooseSection.toUpperCase(), style: SysText.title),
            const SizedBox(height: 12),
            for (final s in _editableSteps)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SysButton.secondary(
                  label: s.title(l),
                  icon: s.glyph,
                  expand: true,
                  onPressed: () => Navigator.of(ctx).pop(s),
                ),
              ),
          ],
        ),
      ),
    );
    if (step != null && mounted) await _edit(step);
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;
    return Scaffold(
      backgroundColor: SysColors.background,
      body: SystemBackground(
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : plan == null
                  ? _ErrorView(onRetry: _load)
                  : _PlanBody(
                      stored: plan,
                      busy: _busy,
                      error: _error != null,
                      onAccept: _accept,
                      onEditData: _chooseSection,
                      onRecalculate: _recalculate,
                      onFill: _edit,
                    ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SystemWindow(
          kind: SystemWindowKind.warning,
          label: l.planNoticeLabel,
          message: l.planLoadError,
          actions: [SysButton.primary(label: l.planRetry, onPressed: onRetry)],
        ),
      ),
    );
  }
}

class _PlanBody extends StatelessWidget {
  const _PlanBody({
    required this.stored,
    required this.busy,
    required this.error,
    required this.onAccept,
    required this.onEditData,
    required this.onRecalculate,
    required this.onFill,
  });

  final StoredPlan stored;
  final bool busy;
  final bool error;
  final VoidCallback onAccept;
  final VoidCallback onEditData;
  final VoidCallback onRecalculate;
  final ValueChanged<OnboardingStep> onFill;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final plan = stored.plan;
    final acceptedAt = stored.acceptedAt;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final message = [
      if (acceptedAt != null) l.planAcceptedAt(DateFormat('dd.MM.yyyy HH:mm', locale).format(acceptedAt.toLocal())),
      l.planDraftNote,
    ].join('\n');

    return ListView(
      key: const Key('plan-scroll'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (context.canPop())
          Align(
            alignment: Alignment.centerLeft,
            child: SysButton.secondary(label: l.commonBack, onPressed: () => context.pop()),
          ),
        if (context.canPop()) const SizedBox(height: 12),
        SystemWindow(
          kind: SystemWindowKind.notice,
          label: l.planNoticeLabel,
          title: l.planTitle,
          message: message,
        ),
        const SizedBox(height: 14),
        if (plan.missing.isNotEmpty || plan.warnings.isNotEmpty) ...[
          _WarningsPanel(plan: plan, onFill: onFill),
          const SizedBox(height: 14),
        ],
        _NormsPanel(norms: plan.norms),
        const SizedBox(height: 14),
        _RoutinePanel(plan: plan),
        const SizedBox(height: 14),
        _QuestsPanel(quests: plan.quests),
        const SizedBox(height: 20),
        if (error)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(l.planLoadError, style: SysText.secondary.copyWith(color: SysColors.dangerLight)),
          ),
        if (!stored.accepted) ...[
          SysButton.primary(label: l.planAccept, icon: SysGlyph.check, expand: true, onPressed: busy ? null : onAccept),
          const SizedBox(height: 10),
        ] else ...[
          SysButton.primary(label: l.planRecalculate, expand: true, onPressed: busy ? null : onRecalculate),
          const SizedBox(height: 10),
        ],
        SysButton.secondary(label: l.planEditData, expand: true, onPressed: busy ? null : onEditData),
      ],
    );
  }
}

class _WarningsPanel extends StatelessWidget {
  const _WarningsPanel({required this.plan, required this.onFill});
  final Plan plan;
  final ValueChanged<OnboardingStep> onFill;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final steps = {for (final m in plan.missing) planMissingStep(m)};
    Widget line(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(padding: EdgeInsets.only(top: 1), child: SysIcon(SysGlyph.warning, size: 16, color: SysColors.gold)),
              const SizedBox(width: 8),
              Expanded(child: Text(text, style: SysText.body)),
            ],
          ),
        );
    return SysPanel(
      title: l.planWarningsTitle,
      tone: PanelTone.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (plan.missing.isNotEmpty) line(l.planMissingMessage(plan.missing.map((m) => planMissingLabel(l, m)).join(', '))),
          for (final w in plan.warnings) line(planWarningText(l, w)),
          for (final s in steps)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SysButton.secondary(
                label: l.planFillSection(s.title(l)),
                icon: s.glyph,
                expand: true,
                onPressed: () => onFill(s),
              ),
            ),
        ],
      ),
    );
  }
}

class _NormsPanel extends StatelessWidget {
  const _NormsPanel({required this.norms});
  final PlanNorms norms;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cal = norms.calories;
    final mode = norms.calorieMode;
    const gap = SizedBox(height: 12);
    return SysPanel(
      title: l.planNormsTitle,
      trailing: mode == null
          ? null
          : SysPill(
              label: switch (mode) {
                CalorieMode.deficit => l.planModeDeficit,
                CalorieMode.surplus => l.planModeSurplus,
                CalorieMode.maintenance => l.planModeMaintenance,
              },
              tone: PanelTone.gold,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (cal != null) ...[
            StatBar(
              label: l.planCalories,
              icon: SysGlyph.flame,
              color: SysColors.calories,
              value: cal.toDouble(),
              max: cal.toDouble(),
              valueText: l.planKcal('$cal'),
            ),
            if (norms.bmr != null && norms.tdee != null) ...[
              const SizedBox(height: 4),
              Text(l.planBmrTdee('${norms.bmr}', '${norms.tdee}'), style: SysText.caption),
            ],
            gap,
            _macro(l, l.planProtein, norms.proteinG ?? 0, 4, cal, SysColors.success),
            gap,
            _macro(l, l.planFat, norms.fatG ?? 0, 9, cal, SysColors.gold),
            gap,
            _macro(l, l.planCarbs, norms.carbsG ?? 0, 4, cal, SysColors.accentLight),
            gap,
          ],
          if (norms.waterMl != null) ...[
            StatBar(
              label: l.planWater,
              icon: SysGlyph.water,
              color: SysColors.water,
              value: norms.waterMl!.toDouble(),
              max: (norms.waterTrainingDayMl ?? norms.waterMl!).toDouble(),
              valueText: l.planMl('${norms.waterMl}'),
            ),
            if (norms.waterTrainingDayMl != null) ...[
              const SizedBox(height: 4),
              Text(l.planWaterTrainingDay('${norms.waterTrainingDayMl}'), style: SysText.caption),
            ],
            gap,
          ],
          StatBar(
            label: l.planSleep,
            icon: SysGlyph.moon,
            color: SysColors.energy,
            value: norms.sleepTargetMinutes.toDouble(),
            max: norms.sleepTargetMinutes.toDouble(),
            valueText: planDuration(l, norms.sleepTargetMinutes),
          ),
          const SizedBox(height: 6),
          Text(
            l.planWakeBed(formatMinuteOfDay(norms.wakeMinute), formatMinuteOfDay(norms.recommendedBedMinute)),
            style: SysText.monoSmall,
          ),
        ],
      ),
    );
  }

  Widget _macro(AppLocalizations l, String label, int grams, int kcalPerGram, int calories, Color color) => StatBar(
        label: label,
        color: color,
        value: (grams * kcalPerGram).toDouble(),
        max: calories.toDouble(),
        valueText: l.planGrams('$grams'),
      );
}

class _RoutinePanel extends ConsumerStatefulWidget {
  const _RoutinePanel({required this.plan});
  final Plan plan;

  @override
  ConsumerState<_RoutinePanel> createState() => _RoutinePanelState();
}

class _RoutinePanelState extends ConsumerState<_RoutinePanel> {
  /// null — пользователь не выбирал: показываем текущую неделю по расписанию.
  int? _pickedWeek;
  int _weekday = DateTime.now().weekday;

  int get _week {
    final picked = _pickedWeek;
    if (picked != null) return picked;
    final config = ref.watch(scheduleConfigProvider).value;
    return config == null ? 1 : ScheduleLogic.weekNumber(DateTime.now(), config);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final plan = widget.plan;
    final week = plan.weeks.where((w) => w.number == _week).firstOrNull ?? plan.weeks.firstOrNull;
    final items = week?.day(_weekday)?.items ?? const <RoutineItem>[];
    return SysPanel(
      title: l.planRoutineTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (plan.alternation) ...[
            SysSegmented<int>(
              choices: [for (final w in plan.weeks) SysChoice(w.number, l.planWeek('${w.number}'))],
              value: week?.number,
              onChanged: (v) => setState(() => _pickedWeek = v),
            ),
            const SizedBox(height: 10),
          ],
          SysChoiceChips<int>(
            choices: [for (var d = DateTime.monday; d <= DateTime.sunday; d++) SysChoice(d, planWeekdayShort(l, d))],
            selected: {_weekday},
            allowEmpty: false,
            onChanged: (s) {
              if (s.isNotEmpty) setState(() => _weekday = s.first);
            },
          ),
          const SizedBox(height: 12),
          for (final i in items) _RoutineRow(item: i),
        ],
      ),
    );
  }
}

class _RoutineRow extends StatelessWidget {
  const _RoutineRow({required this.item});
  final RoutineItem item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final time = item.durationMinutes > 0
        ? '${formatMinuteOfDay(item.startMinute)}–${formatMinuteOfDay(item.endMinute)}'
        : formatMinuteOfDay(item.startMinute);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 92, child: Text(time, style: SysText.monoSmall)),
          SysIcon(planRoutineGlyph(item.kind), size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(planRoutineLabel(l, item), style: SysText.body)),
        ],
      ),
    );
  }
}

class _QuestsPanel extends StatelessWidget {
  const _QuestsPanel({required this.quests});
  final List<QuestDraft> quests;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SysPanel(
      title: l.planQuestsTitle,
      tone: PanelTone.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final q in quests)
            _QuestDraftRow(
              title: planQuestTitle(l, q),
              when: planQuestWhen(l, q),
              reward: l.planQuestReward('${q.diamonds}', '${q.xp}'),
            ),
          const SizedBox(height: 8),
          Text(l.planQuestsNote, style: SysText.caption),
        ],
      ),
    );
  }
}

/// Строка квеста-черновика (без отметки выполнения — движок квестов на этапе 2).
class _QuestDraftRow extends StatelessWidget {
  const _QuestDraftRow({required this.title, required this.when, required this.reward});
  final String title;
  final String when;
  final String reward;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: SysDiamond(color: SysColors.gold, size: 6),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: SysText.body),
                  const SizedBox(height: 2),
                  Text(when, style: SysText.monoSmall.copyWith(color: SysColors.textCaption)),
                  Text(reward, style: SysText.monoSmall.copyWith(color: SysColors.gold)),
                ],
              ),
            ),
          ],
        ),
      );
}
