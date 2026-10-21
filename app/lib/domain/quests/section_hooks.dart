// Связь разделов этапа 3 с движком квестов (SPEC §6, STAGES этап 3 п.4). КОНТРАКТ каркаса.
// Разделы сообщают факты; реализация (главный агент, интеграция) находит сегодняшние квесты
// по ключу (QuestKey плана: water, meals, training, skincareMorning/Evening, sleepOnTime; steps)
// и вызывает QuestService.addProgress / complete. Ошибки движка разделы не видят.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';

abstract interface class SectionQuestHooks {
  /// Выпито [ml] (итог за день — [totalTodayMl]).
  Future<void> waterAdded({required int ml, required int totalTodayMl, DateTime? at});

  /// Записан приём пищи (итог за день — [mealsToday]).
  Future<void> mealLogged({required int mealsToday, DateTime? at});

  /// Новые шаги за сегодня (абсолютное значение, не прирост).
  Future<void> stepsUpdated({required int stepsToday, DateTime? at});

  /// Тренировка завершена.
  Future<void> workoutFinished({required int activeMinutes, DateTime? at});

  /// Чек-лист ухода закрыт полностью.
  Future<void> careRoutineDone(CareRoutine routine, {DateTime? at});

  /// Записан сон (отбой/подъём).
  Future<void> sleepLogged({required DateTime bedAt, required DateTime wakeAt});
}

/// Ничего не делает (тесты разделов, предпросмотр).
class NoopSectionQuestHooks implements SectionQuestHooks {
  const NoopSectionQuestHooks();

  @override
  Future<void> waterAdded({required int ml, required int totalTodayMl, DateTime? at}) async {}

  @override
  Future<void> mealLogged({required int mealsToday, DateTime? at}) async {}

  @override
  Future<void> stepsUpdated({required int stepsToday, DateTime? at}) async {}

  @override
  Future<void> workoutFinished({required int activeMinutes, DateTime? at}) async {}

  @override
  Future<void> careRoutineDone(CareRoutine routine, {DateTime? at}) async {}

  @override
  Future<void> sleepLogged({required DateTime bedAt, required DateTime wakeAt}) async {}
}

/// Переопределяется в main реализацией поверх QuestService.
final sectionQuestHooksProvider = Provider<SectionQuestHooks>((ref) => const NoopSectionQuestHooks());
