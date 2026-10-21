// Шаги и расход энергии (SPEC §8.3, §12). КОНТРАКТ каркаса (правит главный агент); реализация — сабагент B.
//
// Нативный канал `sistema/steps` (ios/Runner/StepCounterChannel.swift, android/.../StepCounterChannel.kt):
//   isAvailable → bool
//   requestPermission → bool
//   query {from: int ms, to: int ms} → {steps: int, distanceM: double?, floors: int?} | null
//
// B также даёт (в core/activity/activity_providers.dart):
//   stepsDayProvider      : StreamProvider.family<StepDay?, DateTime>  — шаги за день из StepLogs
//   dailyEnergyProvider   : StreamProvider.family<DailyEnergy, DateTime> — BMR + шаги + тренировки (WorkoutSessions.kcal)
//   StepSync.syncToday()  — опрос счётчика → StepLogs → SectionQuestHooks.stepsUpdated
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily.dart';
import '../models/enums.dart';

/// Источник шагов устройства.
abstract interface class StepCounter {
  StepSourceKind get kind;

  Future<bool> isAvailable();

  /// Запрос доступа (Motion & Fitness / Health Connect). true — доступ есть.
  Future<bool> requestPermission();

  /// Шаги за [from, to). null — нет данных/доступа.
  Future<StepDay?> query(DateTime from, DateTime to);
}

/// Нет счётчика (тесты, предпросмотр, веб).
class UnavailableStepCounter implements StepCounter {
  const UnavailableStepCounter();

  @override
  StepSourceKind get kind => StepSourceKind.manual;

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<StepDay?> query(DateTime from, DateTime to) async => null;
}

/// Переопределяется в main реализацией B (канал `sistema/steps`).
final stepCounterProvider = Provider<StepCounter>((ref) => const UnavailableStepCounter());
