// Провайдеры раздела «Тренировки». Публичное API для других разделов — [workoutsDayProvider].
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/data/questionnaire_repository.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../core/voice/tts_service.dart';
import '../../domain/quests/section_hooks.dart';
import '../character/model/character_profile.dart';
import '../plan/data/plan_repository.dart';
import '../plan/model/plan.dart';
import 'data/workout_recorder.dart';
import 'data/workout_repository.dart';
import 'domain/progression.dart';
import 'domain/training_profile.dart';
import 'domain/workout_runner.dart';
import 'model/workout_program.dart';

export 'data/workout_repository.dart' show WorkoutsDay;

/// Экран не гаснет во время тренировки. За интерфейсом — чтобы тесты не трогали плагин.
abstract interface class WorkoutWakelock {
  Future<void> enable();
  Future<void> disable();
}

class PluginWorkoutWakelock implements WorkoutWakelock {
  const PluginWorkoutWakelock();

  @override
  Future<void> enable() => WakelockPlus.enable();

  @override
  Future<void> disable() => WakelockPlus.disable();
}

final workoutWakelockProvider = Provider<WorkoutWakelock>((ref) => const PluginWorkoutWakelock());

/// Часы раздела (в тестах — свои).
final workoutsClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Тикер экрана тренировки (в тестах — ручной).
final workoutTickerFactoryProvider = Provider<WorkoutTicker Function()>((ref) => PeriodicWorkoutTicker.new);

final workoutRepositoryProvider =
    Provider<WorkoutRepository>((ref) => WorkoutRepository(ref.watch(databaseProvider)));

final workoutRecorderProvider = Provider<WorkoutRecorder>((ref) => WorkoutRecorder(
      repository: ref.watch(workoutRepositoryProvider),
      hooks: ref.watch(sectionQuestHooksProvider),
      clock: ref.watch(workoutsClockProvider),
    ));

/// Анкета (тренировки, здоровье) + квест training принятого плана. null — данные ещё грузятся.
final trainingProfileProvider = Provider<TrainingProfile?>((ref) {
  final training = ref.watch(questionnaireSectionProvider(QuestionnaireSection.training));
  final health = ref.watch(questionnaireSectionProvider(QuestionnaireSection.health));
  final plan = ref.watch(acceptedPlanProvider);
  if (!training.hasValue || !health.hasValue || (plan.isLoading && !plan.hasValue)) return null;
  final quest = plan.value?.plan.quests.where((q) => q.key == QuestKey.training).firstOrNull;
  final minutes = quest?.params['minutes'];
  return TrainingProfile.fromSources(
    training: training.value!,
    health: health.value!,
    planMinutes: minutes is num ? minutes.round() : null,
    planWeekdays: quest?.weekdays ?? const [],
  );
});

final activeWorkoutProgramProvider =
    StreamProvider<StoredWorkoutProgram?>((ref) => ref.watch(workoutRepositoryProvider).watchActiveProgram());

/// Выполненных недель по активной программе (прогрессия).
final workoutCompletedWeeksProvider = StreamProvider<int>((ref) {
  final p = ref.watch(activeWorkoutProgramProvider).value;
  if (p == null) return Stream.value(0);
  return ref.watch(workoutRepositoryProvider).watchCompletedWeeks(p);
});

/// Программа с прогрессией — то, что выполняем сегодня.
final effectiveWorkoutProgramProvider = Provider<WorkoutProgram?>((ref) {
  final p = ref.watch(activeWorkoutProgramProvider).value;
  if (p == null) return null;
  return applyProgression(p.program, ref.watch(workoutCompletedWeeksProvider).value ?? 0);
});

final workoutSessionsProvider =
    StreamProvider<List<WorkoutSessionRow>>((ref) => ref.watch(workoutRepositoryProvider).watchSessions());

/// Тренировки за день (локальная дата): активные минуты и ккал, включая прерванные. Для «Статуса» и расхода.
final workoutsDayProvider = StreamProvider.family<WorkoutsDay, DateTime>((ref, day) =>
    ref.watch(workoutRepositoryProvider).watchDay(DateTime(day.year, day.month, day.day)));

/// Голос ассистента, выбранного в анкете (null — голос по умолчанию).
final workoutVoiceProfileProvider = Provider<VoiceProfile?>((ref) {
  final character = ref.watch(questionnaireSectionProvider(QuestionnaireSection.character)).value ?? const {};
  final archetype = archetypeFromName(character['archetype']);
  return archetype == null ? null : CharacterProfile.of(archetype).voiceById(character['voice'] as String?);
});

/// Голосовые подсказки включены (локальная настройка).
const workoutVoiceSettingKey = 'workouts.voice';
