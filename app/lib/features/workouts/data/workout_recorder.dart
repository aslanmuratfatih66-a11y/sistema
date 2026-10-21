// Запись тренировки: начало (строка с finishedAt = null), итог (ккал, подходы), хук квестов при завершении.
import '../../../domain/quests/section_hooks.dart';
import '../domain/kcal.dart';
import '../domain/workout_runner.dart';
import 'workout_repository.dart';

class SavedWorkout {
  const SavedWorkout({
    required this.sessionId,
    required this.completed,
    required this.activeSeconds,
    required this.kcal,
    required this.weightAssumed,
    required this.doneSets,
  });

  final String sessionId;
  final bool completed;
  final int activeSeconds;
  final double kcal;

  /// Вес не замерен — расчёт по [fallbackWeightKg].
  final bool weightAssumed;
  final int doneSets;

  int get activeMinutes => (activeSeconds / 60).round();
}

class WorkoutRecorder {
  WorkoutRecorder({required this.repository, required this.hooks, required this.clock});

  final WorkoutRepository repository;
  final SectionQuestHooks hooks;
  final DateTime Function() clock;

  Future<String> begin({String? programId, String? dayKey}) =>
      repository.startSession(programId: programId, dayKey: dayKey, startedAt: clock());

  /// Сохранить итог. Завершённая тренировка (пройдена до конца и есть хотя бы один выполненный подход) →
  /// finishedAt и хук квеста training; прерванная или целиком пропущенная — только сделанное, без finishedAt.
  Future<SavedWorkout> save(String sessionId, WorkoutResult r, {String? dayKey}) async {
    final completed = r.completed && r.doneSets > 0;
    final weight = await repository.weightForKcal();
    final kcal = workoutKcal(
      workSecondsByExercise: r.workSecondsByExercise,
      restSeconds: r.restSeconds,
      weightKg: weight.kg,
    );
    final rounded = (kcal * 10).round() / 10;
    final now = clock();
    await repository.saveSession(
      sessionId,
      activeSeconds: r.activeSeconds,
      kcal: rounded,
      finishedAt: completed ? now : null,
      payload: {
        'v': 1,
        'day': ?dayKey,
        'sets': [for (final s in r.sets) s.toJson()],
        'restSec': r.restSeconds,
        'weightKg': weight.kg,
        if (weight.assumed) 'weightAssumed': true,
      },
    );
    final saved = SavedWorkout(
      sessionId: sessionId,
      completed: completed,
      activeSeconds: r.activeSeconds,
      kcal: rounded,
      weightAssumed: weight.assumed,
      doneSets: r.doneSets,
    );
    if (completed) {
      final minutes = saved.activeMinutes < 1 ? 1 : saved.activeMinutes;
      try {
        await hooks.workoutFinished(activeMinutes: minutes, at: now);
      } catch (_) {
        // Ошибки движка разделы не видят (контракт SectionQuestHooks).
      }
    }
    return saved;
  }
}
