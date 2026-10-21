import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/features/workouts/domain/workout_runner.dart';
import 'package:sistema/features/workouts/model/workout_program.dart';

import 'fakes.dart';

const _squat = ProgramExercise(exerciseKey: 'squat', sets: 2, reps: 10, restSeconds: 30);
const _plank = ProgramExercise(exerciseKey: 'plank', sets: 2, seconds: 20, restSeconds: 15);
const _stretch = ProgramExercise(exerciseKey: 'fullBodyStretch', sets: 1, seconds: 10, restSeconds: 0);

class _Env {
  _Env(List<ProgramExercise> exercises) {
    runner = WorkoutRunner(exercises: exercises, clock: clock.call, ticker: ticker, onCue: cues.add, prepareSeconds: 5);
  }

  final clock = FakeClock(DateTime(2026, 10, 21, 18));
  final ticker = ManualTicker();
  final cues = <WorkoutCue>[];
  late final WorkoutRunner runner;

  /// Двигать время посекундно с тиком (как реальный тикер).
  void run(int seconds) {
    for (var i = 0; i < seconds; i++) {
      clock.advance(const Duration(seconds: 1));
      ticker.tick();
    }
  }

  List<String> get cueNames => [
        for (final c in cues)
          switch (c) {
            CuePrepare(:final exerciseKey) => 'prepare:$exerciseKey',
            CueWorkStart(:final step) => 'work:${step.exerciseKey}:${step.set}/${step.sets}',
            CueCountdown(:final seconds) => '$seconds',
            CueRest(:final seconds, :final nextExerciseKey) => 'rest:$seconds${nextExerciseKey == null ? '' : '>$nextExerciseKey'}',
            CueFinished() => 'finished',
          },
      ];
}

void main() {
  test('подходы, отдых, таймер работы и отсчёт 3-2-1, завершение', () {
    final e = _Env([_squat, _plank]);
    final r = e.runner;
    expect(r.steps.length, 4);
    expect(r.phase, WorkoutPhase.ready);

    r.start();
    expect(e.ticker.active, isTrue);
    expect(r.phase, WorkoutPhase.prepare);
    expect(r.remaining, const Duration(seconds: 5));

    e.run(5); // подготовка → подход 1 приседаний (повторы — ждём нажатия)
    expect(r.phase, WorkoutPhase.work);
    expect(r.current!.set, 1);
    expect(r.remaining, isNull);
    e.run(25);
    expect(r.phase, WorkoutPhase.work, reason: 'подход на повторы сам не заканчивается');
    expect(r.phaseElapsed, const Duration(seconds: 25));

    r.completeSet();
    expect(r.phase, WorkoutPhase.rest);
    expect(r.current!.set, 2, reason: 'в отдыхе current — следующий подход');
    expect(r.remaining, const Duration(seconds: 30));
    e.run(30);
    expect(r.phase, WorkoutPhase.work);
    e.run(30);
    r.completeSet(reps: 8);
    expect(r.phase, WorkoutPhase.rest);
    expect(r.current!.exerciseKey, 'plank');
    e.run(30);
    expect(r.phase, WorkoutPhase.work);
    expect(r.remaining, const Duration(seconds: 20));
    e.run(20); // таймер работы → отдых сам
    expect(r.phase, WorkoutPhase.rest);
    e.run(15);
    e.run(20); // последний подход → конец без отдыха
    expect(r.phase, WorkoutPhase.finished);
    expect(e.ticker.active, isFalse);
    expect(r.progress, 1);

    expect(e.cueNames, [
      'prepare:squat', '3', '2', '1',
      'work:squat:1/2',
      'rest:30', '3', '2', '1',
      'work:squat:2/2',
      'rest:30>plank', '3', '2', '1',
      'work:plank:1/2', '3', '2', '1',
      'rest:15', '3', '2', '1',
      'work:plank:2/2', '3', '2', '1',
      'finished',
    ]);

    final res = r.result;
    expect(res.completed, isTrue);
    expect(res.sets.map((s) => '${s.exerciseKey}${s.set}:${s.reps ?? s.seconds}'),
        ['squat1:10', 'squat2:8', 'plank1:20', 'plank2:20']);
    expect(res.workSecondsByExercise, {'squat': 25 + 30, 'plank': 40});
    expect(res.restSeconds, 5 + 30 + 30 + 15);
    expect(res.activeSeconds, 55 + 40 + 80);
  });

  test('пауза останавливает таймер и не идёт в активное время', () {
    final e = _Env([_plank]);
    final r = e.runner..start();
    e.run(5);
    e.run(5);
    expect(r.remaining, const Duration(seconds: 15));
    r.pause();
    expect(r.paused, isTrue);
    e.run(60);
    expect(r.remaining, const Duration(seconds: 15));
    expect(r.phase, WorkoutPhase.work);
    r.resume();
    e.run(5);
    expect(r.remaining, const Duration(seconds: 10));
    expect(r.activeSeconds, 5 + 10);
    expect(e.cueNames.where((c) => c == '3').length, 1, reason: 'отсчёт подготовки, на паузе — тишина');
  });

  test('пропуск отдыха и пропуск упражнения', () {
    final e = _Env([_squat, _plank, _stretch]);
    final r = e.runner..start();
    r.skipRest(); // подготовка тоже пропускается
    expect(r.phase, WorkoutPhase.work);
    r.completeSet();
    expect(r.phase, WorkoutPhase.rest);
    e.run(4);
    r.skipRest();
    expect(r.phase, WorkoutPhase.work);
    expect(r.current!.set, 2);

    r.skipExercise(); // оставшийся подход приседаний
    expect(r.phase, WorkoutPhase.prepare);
    expect(r.current!.exerciseKey, 'plank');
    r.skipExercise(); // планка целиком
    expect(r.current!.exerciseKey, 'fullBodyStretch');
    r.skipExercise();
    expect(r.phase, WorkoutPhase.finished);

    final res = r.result;
    expect(res.completed, isTrue);
    expect(res.doneSets, 1);
    expect(res.sets.where((s) => s.skipped).map((s) => '${s.exerciseKey}${s.set}'),
        ['squat2', 'plank1', 'plank2', 'fullBodyStretch1']);
    expect(res.restSeconds, 4);
    expect(e.cueNames.last, 'finished');
  });

  test('прерывание — частичный итог, тикер остановлен', () {
    final e = _Env([_squat, _plank]);
    final r = e.runner..start();
    e.run(5);
    e.run(20);
    r.completeSet();
    e.run(10);
    final res = r.abort();
    expect(res.completed, isFalse);
    expect(res.sets.length, 1);
    expect(res.activeSeconds, 5 + 20 + 10);
    expect(e.ticker.active, isFalse);
    expect(r.running, isFalse);
    e.run(30);
    expect(r.abort().activeSeconds, 35, reason: 'после прерывания время не идёт');
    r.completeSet();
    expect(r.result.sets.length, 1);
  });

  test('досрочное закрытие подхода на время и отдых 0 → сразу следующий', () {
    final e = _Env([const ProgramExercise(exerciseKey: 'plank', sets: 2, seconds: 30, restSeconds: 0), _stretch]);
    final r = e.runner..start();
    e.run(5);
    e.run(12);
    r.completeSet();
    expect(r.phase, WorkoutPhase.work);
    expect(r.current!.set, 2);
    r.completeSet();
    expect(r.phase, WorkoutPhase.prepare, reason: 'новое упражнение без отдыха — подготовка');
    expect(r.result.workSecondsByExercise['plank'], 12);
  });

  test('подход на повторы учитывается не дольше потолка', () {
    final e = _Env([_squat]);
    final r = e.runner..start();
    r.skipRest();
    e.run(1000);
    r.completeSet();
    expect(r.result.workSecondsByExercise['squat'], WorkoutRunner.maxRepsSetSeconds);
  });

  test('короткая фаза — без отсчёта (не накладывается на объявление)', () {
    final e = _Env([const ProgramExercise(exerciseKey: 'plank', sets: 1, seconds: 4, restSeconds: 0)]);
    e.runner.start();
    e.run(5);
    e.run(4);
    expect(e.cueNames, ['prepare:plank', '3', '2', '1', 'work:plank:1/1', 'finished']);
  });
}
