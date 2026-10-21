// Тренировки (SPEC §8.4): программа под уровень/время/ограничения, дни, история; запуск тренировки.
// Программа создаётся из шаблона при первом открытии; программа от ИИ — этап 5 (TODO, тот же формат).
// Подсчёт повторов камерой (оценка позы) — опционально по SPEC, не делаем (TODO).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'domain/program_generator.dart';
import 'model/workout_program.dart';
import 'widgets/workout_common.dart';
import 'workout_session_screen.dart';
import 'workouts_providers.dart';
import 'wrk_l10n.dart';

class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen> {
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ensureProgram();
    });
  }

  /// Первое открытие: программы нет — собрать из шаблона.
  void _ensureProgram() {
    final program = ref.read(activeWorkoutProgramProvider);
    final profile = ref.read(trainingProfileProvider);
    if (_creating || !program.hasValue || program.value != null || profile == null) return;
    _create();
  }

  Future<void> _create() async {
    final profile = ref.read(trainingProfileProvider);
    if (profile == null || _creating) return;
    setState(() => _creating = true);
    try {
      await ref.read(workoutRepositoryProvider).saveProgram(generateTemplateProgram(profile));
    } catch (e) {
      debugPrint('Workouts: create program: $e');
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _regenerate() async {
    final l = AppLocalizations.of(context);
    final ok = await showSystemWindow<bool>(
      context,
      window: SystemWindow(
        key: const Key('wrk-regenerate-confirm'),
        kind: SystemWindowKind.warning,
        label: l.shpWarningLabel,
        title: l.wrkRegenerateTitle,
        message: l.wrkRegenerateText,
        actions: [
          Builder(
            builder: (c) => SysButton.secondary(label: l.commonCancel, onPressed: () => Navigator.of(c).pop(false)),
          ),
          Builder(
            builder: (c) => SysButton.primary(
              key: const Key('wrk-regenerate-ok'),
              label: l.wrkRegenerate,
              onPressed: () => Navigator.of(c).pop(true),
            ),
          ),
        ],
      ),
    );
    if (ok == true) await _create();
  }

  void _start(String? programId, ProgramDay day) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => WorkoutSessionScreen(programId: programId, day: day),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    ref.listen(activeWorkoutProgramProvider, (_, _) => _ensureProgram());
    ref.listen(trainingProfileProvider, (_, _) => _ensureProgram());

    final stored = ref.watch(activeWorkoutProgramProvider).value;
    final program = ref.watch(effectiveWorkoutProgramProvider);
    final weeks = ref.watch(workoutCompletedWeeksProvider).value ?? 0;
    final profile = ref.watch(trainingProfileProvider);
    final sessions = ref.watch(workoutSessionsProvider).value ?? const [];
    final now = ref.watch(workoutsClockProvider)();

    if (stored == null || program == null) {
      return WorkoutPage(
        title: l.wrkTitle,
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Center(child: Text(l.wrkPreparing, key: const Key('wrk-preparing'), style: SysText.secondary)),
        ),
      );
    }

    final today = program.dayFor(now);
    return WorkoutPage(
      title: l.wrkTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TodayPanel(day: today, onStart: today == null ? null : () => _start(stored.id, today)),
          const SizedBox(height: 16),
          SysPanel(
            key: const Key('wrk-program'),
            title: l.wrkProgram,
            trailing: SysPill(label: levelLabel(l, program.level)),
            appearDelay: const Duration(milliseconds: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const SysIcon(SysGlyph.timer, size: 18),
                    const SizedBox(width: 8),
                    Text(l.wrkMinutesShort(program.minutesPerSession), style: SysText.mono),
                    const Spacer(),
                    SysPill(label: '${l.wrkAiProgram} · ${l.wrkSoon}', tone: PanelTone.boss),
                  ],
                ),
                if (profile != null && !profile.levelKnown) ...[
                  const SizedBox(height: 8),
                  Text(l.wrkLevelUnknown, key: const Key('wrk-level-unknown'), style: SysText.caption),
                ],
                if (program.gentle) ...[
                  const SizedBox(height: 8),
                  Text(l.wrkGentle, key: const Key('wrk-gentle'), style: SysText.secondary.copyWith(color: SysColors.success)),
                ],
                const SizedBox(height: 8),
                Text(l.wrkProgressionWeeks(weeks), key: const Key('wrk-weeks'), style: SysText.body),
                const SizedBox(height: 2),
                Text(l.wrkProgressionNote, style: SysText.caption),
                const SizedBox(height: 6),
                Text(l.wrkSafetyNote, style: SysText.caption),
              ],
            ),
          ),
          for (final d in program.days) ...[
            const SizedBox(height: 16),
            _DayPanel(day: d, onStart: () => _start(stored.id, d)),
          ],
          const SizedBox(height: 16),
          SysButton.secondary(
            key: const Key('wrk-regenerate'),
            label: l.wrkRegenerate,
            expand: true,
            onPressed: _creating || profile == null ? null : _regenerate,
          ),
          const SizedBox(height: 16),
          _HistoryPanel(sessions: sessions),
        ],
      ),
    );
  }
}

class _TodayPanel extends StatelessWidget {
  const _TodayPanel({required this.day, required this.onStart});

  final ProgramDay? day;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = day;
    return SysPanel(
      key: const Key('wrk-today'),
      title: l.wrkToday,
      child: d == null
          ? Text(l.wrkRestDay, key: const Key('wrk-rest-day'), style: SysText.secondary)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.wrkTodayDay(d.key), style: SysText.title),
                const SizedBox(height: 4),
                Text(
                  '${l.wrkExerciseCount(d.exercises.length)} · ${l.wrkEstimate((estimateSeconds(d.exercises) / 60).round())}',
                  style: SysText.caption,
                ),
                const SizedBox(height: 12),
                SysButton.primary(
                  key: const Key('wrk-start-today'),
                  label: l.wrkStart,
                  icon: SysGlyph.bolt,
                  expand: true,
                  onPressed: onStart,
                ),
              ],
            ),
    );
  }
}

class _DayPanel extends StatelessWidget {
  const _DayPanel({required this.day, required this.onStart});

  final ProgramDay day;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SysPanel(
      key: Key('wrk-day-${day.key}'),
      title: l.wrkDayTitle(day.key),
      trailing: Text(
        [for (final w in day.weekdays) weekdayShort(l, w)].join(' '),
        style: SysText.monoSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final e in day.exercises)
            InkWell(
              onTap: () => showTechnique(context, e.exerciseKey),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: SysDims.minTap),
                child: Row(
                  children: [
                    SysIcon(categoryGlyph(e.exercise?.category), size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(exerciseName(l, e.exerciseKey), style: SysText.body)),
                    Text(loadLabel(l, e), style: SysText.mono),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(l.wrkEstimate((estimateSeconds(day.exercises) / 60).round()), style: SysText.caption),
          const SizedBox(height: 8),
          SysButton.secondary(
            key: Key('wrk-start-${day.key}'),
            label: l.wrkStartDay(day.key),
            expand: true,
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({required this.sessions});

  final List<WorkoutSessionRow> sessions;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loc = MaterialLocalizations.of(context);
    return SysPanel(
      key: const Key('wrk-history'),
      title: l.wrkHistory,
      child: sessions.isEmpty
          ? Text(l.wrkHistoryEmpty, style: SysText.secondary)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final s in sessions)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SysIcon(
                          s.finishedAt != null ? SysGlyph.check : SysGlyph.close,
                          size: 16,
                          color: s.finishedAt != null ? SysColors.success : SysColors.textInactive,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            [
                              loc.formatShortDate(s.startedAt.toLocal()),
                              if (s.dayKey != null) l.wrkDayTitle(s.dayKey!),
                              s.finishedAt != null ? l.wrkSessionDone : l.wrkSessionInterrupted,
                            ].join(' · '),
                            style: SysText.secondary,
                          ),
                        ),
                        Text(
                          l.wrkSessionStats((s.activeSeconds / 60).round(), (s.kcal ?? 0).round()),
                          style: SysText.monoSmall,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
