// Экран тренировки: упражнение, подход N из M, повторы или таймер работы, отдых (пауза/пропуск),
// прогресс всей тренировки, голосовые подсказки, экран не гаснет. Прерывание — частичное сохранение.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/voice/tts_service.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'data/workout_recorder.dart';
import 'domain/workout_runner.dart';
import 'domain/workout_voice.dart';
import 'model/workout_program.dart';
import 'widgets/workout_common.dart';
import 'workouts_providers.dart';
import 'wrk_l10n.dart';

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  const WorkoutSessionScreen({super.key, required this.day, this.programId});

  final ProgramDay day;
  final String? programId;

  @override
  ConsumerState<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  late final WorkoutRunner _runner;
  late final WorkoutRecorder _recorder;
  late final WorkoutWakelock _wakelock;
  WorkoutVoice? _voice;
  Future<String>? _sessionId;
  SavedWorkout? _saved;
  bool _saving = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _recorder = ref.read(workoutRecorderProvider);
    _wakelock = ref.read(workoutWakelockProvider);
    _runner = WorkoutRunner(
      exercises: widget.day.exercises,
      clock: ref.read(workoutsClockProvider),
      ticker: ref.read(workoutTickerFactoryProvider)(),
      onCue: (c) => _voice?.onCue(c),
    );
    unawaited(_wakelock.enable().catchError((Object e) => debugPrint('Workout wakelock: $e')));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_voice != null) return;
    _voice = WorkoutVoice(
      tts: ref.read(ttsServiceProvider),
      phrases: L10nWorkoutPhrases(AppLocalizations.of(context)),
      languageCode: Localizations.localeOf(context).languageCode,
      voice: ref.read(workoutVoiceProfileProvider),
    );
    _loadVoiceSetting();
    _sessionId = _recorder.begin(programId: widget.programId, dayKey: widget.day.key);
    _runner
      ..start()
      ..addListener(_onRunner);
    // Пустой день завершается сразу — сохранить после первого кадра.
    if (_runner.phase == WorkoutPhase.finished) WidgetsBinding.instance.addPostFrameCallback((_) => _onRunner());
  }

  Future<void> _loadVoiceSetting() async {
    try {
      final v = await ref.read(databaseProvider).getSetting(workoutVoiceSettingKey);
      if (v == 'off' && mounted) setState(() => _voice?.enabled = false);
    } catch (e) {
      debugPrint('Workout voice setting: $e');
    }
  }

  Future<void> _toggleVoice() async {
    final v = _voice;
    if (v == null) return;
    setState(() => v.enabled = !v.enabled);
    if (!v.enabled) await v.silence();
    try {
      await ref.read(databaseProvider).setSetting(workoutVoiceSettingKey, v.enabled ? 'on' : 'off');
    } catch (e) {
      debugPrint('Workout voice setting: $e');
    }
  }

  void _onRunner() {
    if (_runner.phase == WorkoutPhase.finished && _saved == null && !_saving) {
      unawaited(_save());
    }
    if (mounted) setState(() {});
  }

  Future<SavedWorkout?> _save() async {
    if (_saving) return null;
    _saving = true;
    try {
      final id = await _sessionId!;
      final saved = await _recorder.save(id, _runner.result, dayKey: widget.day.key);
      if (mounted) setState(() => _saved = saved);
      return saved;
    } catch (e) {
      debugPrint('Workout save: $e');
      return null;
    } finally {
      _saving = false;
    }
  }

  Future<void> _confirmStop() async {
    final l = AppLocalizations.of(context);
    _runner.pause();
    final ok = await showSystemWindow<bool>(
      context,
      window: SystemWindow(
        key: const Key('wrk-stop-confirm'),
        kind: SystemWindowKind.warning,
        warningTone: PanelTone.danger,
        label: l.shpWarningLabel,
        title: l.wrkStopTitle,
        message: l.wrkStopText,
        actions: [
          Builder(
            builder: (c) => SysButton.secondary(
              key: const Key('wrk-stop-cancel'),
              label: l.wrkResume,
              onPressed: () => Navigator.of(c).pop(false),
            ),
          ),
          Builder(
            builder: (c) => SysButton.danger(
              key: const Key('wrk-stop-ok'),
              label: l.wrkStop,
              onPressed: () => Navigator.of(c).pop(true),
            ),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (ok != true) {
      _runner.resume();
      return;
    }
    _runner.abort();
    await _voice?.silence();
    await _save();
    _close();
  }

  void _close() {
    if (_closing || !mounted) return;
    _closing = true;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _runner
      ..removeListener(_onRunner)
      ..dispose();
    unawaited(_voice?.silence());
    unawaited(_wakelock.disable().catchError((Object e) => debugPrint('Workout wakelock: $e')));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final finished = _runner.phase == WorkoutPhase.finished;
    final voiceOn = _voice?.enabled ?? true;
    return PopScope(
      canPop: finished || _closing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmStop();
      },
      child: WorkoutPage(
        title: l.wrkDayTitle(widget.day.key),
        onBack: finished ? _close : _confirmStop,
        actions: [
          IconButton(
            key: const Key('wrk-voice'),
            onPressed: _toggleVoice,
            tooltip: l.wrkVoice,
            isSelected: voiceOn,
            constraints: const BoxConstraints(minWidth: SysDims.minTap, minHeight: SysDims.minTap),
            icon: SysIcon(SysGlyph.mic, size: 22, color: voiceOn ? SysColors.accentLight : SysColors.textInactive),
          ),
        ],
        bottom: finished ? _finishedActions(l) : _controls(l),
        child: finished ? _FinishedPanel(saved: _saved) : _RunnerView(runner: _runner),
      ),
    );
  }

  Widget _finishedActions(AppLocalizations l) =>
      SysButton.primary(key: const Key('wrk-finish-done'), label: l.commonDone, expand: true, onPressed: _close);

  Widget _controls(AppLocalizations l) {
    final r = _runner;
    final paused = r.paused;
    final inWork = r.phase == WorkoutPhase.work;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (inWork)
          SysButton.primary(
            key: const Key('wrk-done-set'),
            label: l.wrkDoneSet,
            icon: SysGlyph.check,
            expand: true,
            onPressed: r.completeSet,
          )
        else
          SysButton.primary(
            key: const Key('wrk-skip-rest'),
            label: l.wrkSkipRest,
            expand: true,
            onPressed: r.running ? r.skipRest : null,
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SysButton.secondary(
                key: const Key('wrk-pause'),
                label: paused ? l.wrkResume : l.wrkPause,
                onPressed: !r.running ? null : (paused ? r.resume : r.pause),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SysButton.secondary(
                key: const Key('wrk-skip-exercise'),
                label: l.wrkSkipExercise,
                onPressed: r.running ? r.skipExercise : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RunnerView extends StatelessWidget {
  const _RunnerView({required this.runner});

  final WorkoutRunner runner;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final r = runner;
    final step = r.current;
    if (step == null) return const SizedBox.shrink();
    final phase = r.phase;
    final inRest = phase == WorkoutPhase.rest;
    final tone = inRest ? PanelTone.success : PanelTone.accent;
    final phaseLabel = r.paused
        ? l.wrkPaused
        : switch (phase) {
            WorkoutPhase.prepare => l.wrkPhasePrepare,
            WorkoutPhase.rest => l.wrkPhaseRest,
            _ => l.wrkPhaseWork,
          };
    final remaining = r.remaining;
    final target = r.phaseTarget;
    final nextBlock = _nextBlockStep(r);

    final Widget meter;
    if (remaining != null && target != null) {
      final frac = target.inMilliseconds == 0 ? 1.0 : 1 - remaining.inMilliseconds / target.inMilliseconds;
      meter = ProgressRing(
        key: const Key('wrk-timer'),
        progress: frac.clamp(0.0, 1.0),
        size: 168,
        strokeWidth: 8,
        color: inRest ? SysColors.success : SysColors.accent,
        semanticLabel: phaseLabel,
        semanticValue: mmss(remaining),
        center: Text(mmss(remaining + const Duration(milliseconds: 999)), style: SysText.monoLarge),
      );
    } else {
      meter = Column(
        key: const Key('wrk-reps'),
        children: [
          Text(l.wrkRepsTarget(step.item.reps ?? 0), style: SysText.display),
          const SizedBox(height: 4),
          Text(mmss(r.phaseElapsed), style: SysText.mono.copyWith(color: SysColors.textCaption)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatBar(
          key: const Key('wrk-progress'),
          label: l.wrkProgressLabel,
          value: r.progress * 100,
          max: 100,
          valueText: '${r.index}/${r.steps.length}',
        ),
        const SizedBox(height: 16),
        SysPanel(
          key: const Key('wrk-current'),
          title: phaseLabel,
          tone: r.paused ? PanelTone.gold : tone,
          animateIn: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (inRest) Text(l.commonNext, style: SysText.caption),
              Row(
                children: [
                  SysIcon(categoryGlyph(step.item.exercise?.category), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(exerciseName(l, step.exerciseKey), key: const Key('wrk-exercise'), style: SysText.title),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(l.wrkSetOf(step.set, step.sets), key: const Key('wrk-set'), style: SysText.mono),
              const SizedBox(height: 16),
              Center(child: meter),
              const SizedBox(height: 16),
              Text(l.wrkTechnique, style: SysText.label),
              const SizedBox(height: 6),
              TechniqueSteps(exerciseKey: step.exerciseKey),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          nextBlock == null ? l.wrkLastExercise : l.wrkNext(exerciseName(l, nextBlock.exerciseKey)),
          style: SysText.caption,
        ),
      ],
    );
  }

  /// Первый подход следующего упражнения.
  static WorkoutStep? _nextBlockStep(WorkoutRunner r) {
    final cur = r.current;
    if (cur == null) return null;
    for (var i = r.index + 1; i < r.steps.length; i++) {
      if (r.steps[i].block != cur.block) return r.steps[i];
    }
    return null;
  }
}

class _FinishedPanel extends StatelessWidget {
  const _FinishedPanel({required this.saved});

  final SavedWorkout? saved;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = saved;
    return SysPanel(
      key: const Key('wrk-finished'),
      title: l.wrkFinishedTitle,
      tone: PanelTone.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: SysIcon(SysGlyph.check, size: 48, color: SysColors.success)),
          const SizedBox(height: 12),
          if (s != null) ...[
            Text(
              l.wrkFinishedStats(s.activeMinutes, s.kcal.round(), s.doneSets),
              key: const Key('wrk-finished-stats'),
              style: SysText.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (s.weightAssumed) Text(l.wrkWeightAssumed, key: const Key('wrk-weight-assumed'), style: SysText.caption),
            Text(l.wrkKcalNote, style: SysText.caption),
          ],
        ],
      ),
    );
  }
}
