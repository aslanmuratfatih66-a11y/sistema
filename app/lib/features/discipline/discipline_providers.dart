// Провайдеры экрана «Режим дисциплины».
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../domain/discipline/discipline_hook.dart';
import '../../domain/discipline/discipline_rules.dart';
import '../../domain/quests/quest_api.dart';

/// Часы экрана (в тестах — фиксированные).
final disciplineClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final disciplinePlayerProvider =
    StreamProvider<PlayerSnapshot>((ref) => ref.watch(questServiceProvider).watchPlayer());

/// Последнее событие включения/выключения дисциплины в журнале (причина, время).
final disciplineLastEventProvider = StreamProvider<HistoryEntry?>((ref) => ref
    .watch(questServiceProvider)
    .watchHistory()
    .map((h) => h.where((e) => e.type == QuestEventType.disciplineOn || e.type == QuestEventType.disciplineOff)
        .firstOrNull));

/// Статус режима: снимок игрока + причина из последнего disciplineOn (payload.reason / reasonKey).
final disciplineStatusProvider = Provider<AsyncValue<DisciplineStatus>>((ref) {
  final player = ref.watch(disciplinePlayerProvider);
  final last = ref.watch(disciplineLastEventProvider).value;
  return player.whenData((p) {
    final on = last != null && last.type == QuestEventType.disciplineOn ? last : null;
    final reason = on?.payload['reason'] ?? on?.payload['reasonKey'];
    return DisciplineStatus.resolve(
      active: p.disciplineActive,
      balance: p.diamonds,
      lastOnReasonKey: reason is String ? reason : null,
      lastOnAt: on?.occurredAt,
    );
  });
});

/// Контекст правил (анкета + расписание сна), обновляется при изменениях.
final disciplineContextProvider =
    StreamProvider<DisciplineContext>((ref) => DisciplineContextLoader(ref.watch(databaseProvider)).watch());

/// Квесты режима на сегодня (предпросмотр правил).
final disciplineTodayProvider = Provider<List<QuestInput>>((ref) {
  final now = ref.watch(disciplineClockProvider)();
  final ctx = ref.watch(disciplineContextProvider).value ?? DisciplineContext.fallback;
  return disciplineQuests(DateTime(now.year, now.month, now.day), ctx: ctx);
});
