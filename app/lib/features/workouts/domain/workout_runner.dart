// Машина состояний тренировки (без виджетов): подготовка → работа → отдых → … → конец.
// Время — только через инжектируемые часы и тикер (тесты двигают часы вручную).
//
// Фазы:
// - prepare — отсчёт перед новым упражнением без отдыха (начало, после пропуска);
// - work — подход: на повторы ждёт [completeSet], на время — таймер, по нулю сам переходит дальше;
// - rest — отдых после подхода (пауза, пропуск); после последнего подхода тренировки отдыха нет.
// Активное время — сумма фаз без пауз (работа на время — не больше заданного, на повторы — не больше [maxRepsSetSeconds]).
// Голосовые подсказки — события [WorkoutCue]; озвучка решает сама (WorkoutVoice), runner TTS не знает.
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../model/workout_program.dart';

typedef WorkoutClock = DateTime Function();

/// Источник тиков (в приложении — Timer.periodic, в тестах — ручной).
abstract interface class WorkoutTicker {
  void start(void Function() onTick);
  void stop();
}

class PeriodicWorkoutTicker implements WorkoutTicker {
  PeriodicWorkoutTicker([this.interval = const Duration(milliseconds: 200)]);

  final Duration interval;
  Timer? _timer;

  @override
  void start(void Function() onTick) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => onTick());
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}

enum WorkoutPhase { ready, prepare, work, rest, finished }

/// Один подход.
class WorkoutStep {
  const WorkoutStep({required this.block, required this.item, required this.set});

  /// Номер упражнения в дне (0..).
  final int block;
  final ProgramExercise item;

  /// 1..sets
  final int set;

  int get sets => item.sets;
  String get exerciseKey => item.exerciseKey;
  bool get timed => item.timed;
}

List<WorkoutStep> stepsOf(List<ProgramExercise> exercises) => [
      for (var b = 0; b < exercises.length; b++)
        for (var s = 1; s <= exercises[b].sets; s++) WorkoutStep(block: b, item: exercises[b], set: s),
    ];

/// Событие для голосовой подсказки.
sealed class WorkoutCue {
  const WorkoutCue();
}

/// Приготовиться к упражнению.
class CuePrepare extends WorkoutCue {
  const CuePrepare(this.exerciseKey);
  final String exerciseKey;
}

/// Старт подхода.
class CueWorkStart extends WorkoutCue {
  const CueWorkStart(this.step);
  final WorkoutStep step;
}

/// «3», «2», «1» перед концом таймера.
class CueCountdown extends WorkoutCue {
  const CueCountdown(this.seconds);
  final int seconds;
}

/// Отдых; [nextExerciseKey] — если дальше другое упражнение.
class CueRest extends WorkoutCue {
  const CueRest(this.seconds, {this.nextExerciseKey});
  final int seconds;
  final String? nextExerciseKey;
}

class CueFinished extends WorkoutCue {
  const CueFinished();
}

/// Выполненный (или пропущенный) подход.
class SetRecord {
  const SetRecord({required this.exerciseKey, required this.set, this.reps, required this.seconds, this.skipped = false});

  final String exerciseKey;
  final int set;
  final int? reps;
  final int seconds;
  final bool skipped;

  Map<String, Object?> toJson() => {
        'ex': exerciseKey,
        'set': set,
        if (reps != null) 'reps': reps,
        'sec': seconds,
        if (skipped) 'skipped': true,
      };
}

/// Итог (в т.ч. частичный — для прерванной тренировки).
class WorkoutResult {
  const WorkoutResult({
    required this.completed,
    required this.activeSeconds,
    required this.restSeconds,
    required this.workSecondsByExercise,
    required this.sets,
  });

  /// Пройдены все подходы (выполнены или пропущены).
  final bool completed;
  final int activeSeconds;
  final int restSeconds;
  final Map<String, int> workSecondsByExercise;
  final List<SetRecord> sets;

  int get doneSets => sets.where((s) => !s.skipped).length;
}

class WorkoutRunner extends ChangeNotifier {
  WorkoutRunner({
    required List<ProgramExercise> exercises,
    required this.clock,
    required this.ticker,
    this.onCue,
    this.prepareSeconds = 10,
    this.countdownFrom = 3,
  }) : steps = stepsOf(exercises);

  final List<WorkoutStep> steps;
  final WorkoutClock clock;
  final WorkoutTicker ticker;
  final void Function(WorkoutCue cue)? onCue;
  final int prepareSeconds;
  final int countdownFrom;

  /// Потолок учёта одного подхода на повторы (забыли нажать «Готово»).
  static const maxRepsSetSeconds = 180;

  WorkoutPhase _phase = WorkoutPhase.ready;
  int _index = 0;
  bool _paused = false;
  bool _ended = false;
  DateTime? _phaseStartedAt;
  Duration _phaseAccum = Duration.zero;
  int _lastCountdown = 0;

  final List<SetRecord> _records = [];
  final Map<String, int> _workSeconds = {};
  int _restSeconds = 0;
  int _activeSeconds = 0;

  WorkoutPhase get phase => _phase;
  bool get paused => _paused;
  bool get running => _phase != WorkoutPhase.ready && _phase != WorkoutPhase.finished && !_ended;
  int get index => _index;
  List<SetRecord> get records => List.unmodifiable(_records);

  /// Текущий подход (в отдыхе — следующий).
  WorkoutStep? get current => _index < steps.length ? steps[_index] : null;

  /// Следующий после текущего подход.
  WorkoutStep? get next => _index + 1 < steps.length ? steps[_index + 1] : null;

  Duration get phaseElapsed {
    final s = _phaseStartedAt;
    if (_paused || s == null) return _phaseAccum;
    final d = clock().difference(s);
    return _phaseAccum + (d.isNegative ? Duration.zero : d);
  }

  /// Длительность фазы с таймером (null — фаза без таймера: подход на повторы).
  Duration? get phaseTarget => switch (_phase) {
        WorkoutPhase.prepare => Duration(seconds: prepareSeconds),
        WorkoutPhase.rest => Duration(seconds: _restTargetSeconds),
        WorkoutPhase.work => current?.timed == true ? Duration(seconds: current!.item.seconds!) : null,
        _ => null,
      };

  /// Осталось в фазе с таймером.
  Duration? get remaining {
    final t = phaseTarget;
    if (t == null) return null;
    final r = t - phaseElapsed;
    return r.isNegative ? Duration.zero : r;
  }

  int get _restTargetSeconds => _index > 0 ? steps[_index - 1].item.restSeconds : 0;

  /// Прогресс всей тренировки 0..1.
  double get progress {
    if (steps.isEmpty || _phase == WorkoutPhase.finished) return 1;
    var p = _index.toDouble();
    final t = phaseTarget;
    if (_phase == WorkoutPhase.work && t != null && t.inMilliseconds > 0) {
      p += (phaseElapsed.inMilliseconds / t.inMilliseconds).clamp(0.0, 1.0);
    }
    return (p / steps.length).clamp(0.0, 1.0);
  }

  /// Активное время с учётом идущей фазы (для частичного сохранения).
  int get activeSeconds => _activeSeconds + (_ended ? 0 : _cappedPhaseSeconds());

  // ---- Управление ----

  void start() {
    if (_phase != WorkoutPhase.ready) return;
    if (steps.isEmpty) {
      _finish();
      return;
    }
    ticker.start(tick);
    _enter(WorkoutPhase.prepare);
    _cue(CuePrepare(steps.first.exerciseKey));
    notifyListeners();
  }

  void pause() {
    if (!running || _paused) return;
    _phaseAccum = phaseElapsed;
    _paused = true;
    notifyListeners();
  }

  void resume() {
    if (!running || !_paused) return;
    _paused = false;
    _phaseStartedAt = clock();
    notifyListeners();
  }

  /// Подход выполнен (на повторы — единственный способ; на время — досрочно).
  void completeSet({int? reps}) {
    if (_phase != WorkoutPhase.work || _ended) return;
    if (_paused) resume();
    _completeWork(reps: reps);
    notifyListeners();
  }

  /// Пропустить отдых или подготовку.
  void skipRest() {
    if (_ended || (_phase != WorkoutPhase.rest && _phase != WorkoutPhase.prepare)) return;
    if (_paused) resume();
    _closePhase();
    _startWork();
    notifyListeners();
  }

  /// Пропустить оставшиеся подходы текущего (в отдыхе — следующего) упражнения.
  void skipExercise() {
    if (!running) return;
    if (_paused) resume();
    final step = current;
    if (step == null) return;
    _closePhase();
    while (_index < steps.length && steps[_index].block == step.block) {
      final s = steps[_index];
      _records.add(SetRecord(exerciseKey: s.exerciseKey, set: s.set, seconds: 0, skipped: true));
      _index++;
    }
    if (_index >= steps.length) {
      _finish();
    } else {
      _enter(WorkoutPhase.prepare);
      _cue(CuePrepare(steps[_index].exerciseKey));
    }
    notifyListeners();
  }

  /// Прервать: зафиксировать сделанное (сохраняется как незавершённая тренировка).
  WorkoutResult abort() {
    if (!_ended) {
      _closePhase();
      _ended = true;
      ticker.stop();
      notifyListeners();
    }
    return result;
  }

  WorkoutResult get result => WorkoutResult(
        completed: _phase == WorkoutPhase.finished,
        activeSeconds: activeSeconds,
        restSeconds: _restSeconds,
        workSecondsByExercise: Map.unmodifiable(_workSeconds),
        sets: List.unmodifiable(_records),
      );

  /// Тик тикера: таймеры фаз, отсчёт 3-2-1, автопереход.
  void tick() {
    if (!running || _paused) return;
    final rem = remaining;
    if (rem != null) {
      final left = (rem.inMilliseconds / 1000).ceil();
      if (left >= 1 && left < _lastCountdown) {
        _lastCountdown = left;
        _cue(CueCountdown(left));
      }
      if (rem <= Duration.zero) {
        switch (_phase) {
          case WorkoutPhase.work:
            _completeWork();
          case WorkoutPhase.rest || WorkoutPhase.prepare:
            _closePhase();
            _startWork();
          default:
            break;
        }
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    ticker.stop();
    super.dispose();
  }

  // ---- Внутреннее ----

  void _enter(WorkoutPhase p) {
    _phase = p;
    _phaseAccum = Duration.zero;
    _phaseStartedAt = clock();
    final t = phaseTarget;
    // Отсчёт — только если фаза длиннее отсчёта (иначе «3» наложится на объявление фазы).
    _lastCountdown = t != null && t.inSeconds > countdownFrom + 1 ? countdownFrom + 1 : 0;
  }

  int _cappedPhaseSeconds() {
    if (_phase == WorkoutPhase.ready || _phase == WorkoutPhase.finished) return 0;
    var sec = phaseElapsed.inMilliseconds / 1000;
    final t = phaseTarget;
    if (t != null && sec > t.inSeconds) sec = t.inSeconds.toDouble();
    if (t == null && sec > maxRepsSetSeconds) sec = maxRepsSetSeconds.toDouble();
    return sec.round();
  }

  /// Закрыть идущую фазу: учесть время (работа — в упражнение, остальное — в отдых).
  int _closePhase() {
    final sec = _cappedPhaseSeconds();
    if (_phase == WorkoutPhase.work) {
      final key = current!.exerciseKey;
      _workSeconds[key] = (_workSeconds[key] ?? 0) + sec;
    } else if (_phase == WorkoutPhase.rest || _phase == WorkoutPhase.prepare) {
      _restSeconds += sec;
    }
    _activeSeconds += sec;
    _phaseAccum = Duration.zero;
    _phaseStartedAt = clock();
    return sec;
  }

  void _startWork() {
    _enter(WorkoutPhase.work);
    _cue(CueWorkStart(current!));
  }

  void _completeWork({int? reps}) {
    final step = current!;
    final sec = _closePhase();
    _records.add(SetRecord(
      exerciseKey: step.exerciseKey,
      set: step.set,
      reps: step.timed ? null : (reps ?? step.item.reps),
      seconds: sec,
    ));
    _index++;
    if (_index >= steps.length) {
      _finish();
      return;
    }
    final nextStep = steps[_index];
    final rest = step.item.restSeconds;
    if (rest > 0) {
      _enter(WorkoutPhase.rest);
      _cue(CueRest(rest, nextExerciseKey: nextStep.block != step.block ? nextStep.exerciseKey : null));
    } else if (nextStep.block != step.block) {
      _enter(WorkoutPhase.prepare);
      _cue(CuePrepare(nextStep.exerciseKey));
    } else {
      _startWork();
    }
  }

  void _finish() {
    _phase = WorkoutPhase.finished;
    _ended = true;
    ticker.stop();
    _cue(const CueFinished());
  }

  void _cue(WorkoutCue c) => onCue?.call(c);
}
