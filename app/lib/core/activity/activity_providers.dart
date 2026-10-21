// Провайдеры шагов и расхода энергии (контракт — activity_api.dart).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/quests/section_hooks.dart';
import '../data/profile_repository.dart';
import '../db/database.dart';
import '../models/daily.dart';
import 'activity_api.dart';
import 'energy.dart';
import 'step_repository.dart';
import 'step_sync.dart';

/// Часы раздела (в тестах — фиксированное время).
final activityClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Цель шагов за день.
/// TODO(этап 3+): брать из плана/настроек, когда там появится цель шагов.
const kDefaultStepGoal = 8000;

final stepRepositoryProvider = Provider<StepRepository>((ref) => StepRepository(ref.watch(databaseProvider)));

final energyRepositoryProvider = Provider<EnergyRepository>((ref) => EnergyRepository(ref.watch(databaseProvider)));

/// Синхронизация шагов. В main: `container.read(stepSyncProvider).start()` (dispose — вместе с контейнером).
final stepSyncProvider = Provider<StepSync>((ref) {
  final sync = StepSync(
    counter: ref.watch(stepCounterProvider),
    repository: ref.watch(stepRepositoryProvider),
    hooks: ref.watch(sectionQuestHooksProvider),
    clock: ref.watch(activityClockProvider),
  );
  ref.onDispose(sync.dispose);
  return sync;
});

/// Шаги за день (ключ — любая дата этого дня; лучше передавать локальную полночь). null — записей нет.
final stepsDayProvider = StreamProvider.family<StepDay?, DateTime>(
  (ref, day) => ref.watch(stepRepositoryProvider).watchDay(localDay(day)),
);

/// Шаги за последние [days] дней, включая сегодня (по часам раздела), по возрастанию даты; пропуски — 0.
final stepsHistoryProvider = StreamProvider.family<List<StepDay>, int>((ref, days) {
  final today = localDay(ref.watch(activityClockProvider)());
  final from = DateTime(today.year, today.month, today.day - (days - 1));
  return ref.watch(stepRepositoryProvider).watchHistory(from, nextLocalDay(today));
});

final _weightOnProvider = StreamProvider.family<double?, DateTime>(
  (ref, day) => ref.watch(energyRepositoryProvider).watchWeightOn(day),
);

final _workoutKcalProvider = StreamProvider.family<double, DateTime>(
  (ref, day) => ref.watch(energyRepositoryProvider).watchWorkoutKcal(day),
);

/// Расход энергии за день: BMR + шаги + тренировки. Пересчитывается при изменении любой части.
final dailyEnergyProvider = StreamProvider.family<DailyEnergy, DateTime>((ref, day) async* {
  final d = localDay(day);
  // Все зависимости подписываем синхронно, до первого await.
  final profile = ref.watch(profileProvider.future);
  final weight = ref.watch(_weightOnProvider(d).future);
  final steps = ref.watch(stepsDayProvider(d).future);
  final workouts = ref.watch(_workoutKcalProvider(d).future);
  yield EnergyCalc.daily(
    day: d,
    profile: await profile,
    weightKg: await weight,
    steps: await steps,
    workoutKcal: await workouts,
  );
});

/// Состояние доступа к счётчику шагов.
enum StepAccess { unavailable, needsPermission, granted }

/// Есть ли счётчик и доступ к нему; заодно синхронизирует «сегодня». Обновить — `ref.invalidate`.
final stepAccessProvider = FutureProvider<StepAccess>((ref) async {
  final counter = ref.watch(stepCounterProvider);
  if (!await counter.isAvailable()) return StepAccess.unavailable;
  final today = await ref.watch(stepSyncProvider).syncToday();
  return today == null ? StepAccess.needsPermission : StepAccess.granted;
});
