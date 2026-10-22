// Провайдеры вкладки «Квесты» и главного экрана поверх QuestService (контракт движка A).
// Время — из инжектируемых часов главного экрана (homeClockProvider / homeNowSourceProvider).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/quests/quest_api.dart';
import '../../home/data/home_providers.dart';
import '../quest_format.dart';

/// Снимок игрока (◆, опыт, уровень, характеристики, эффекты, пауза).
final questPlayerProvider = StreamProvider<PlayerSnapshot>((ref) => ref.watch(questServiceProvider).watchPlayer());

/// Квесты дня (ключ — локальная полночь).
final questDayProvider = StreamProvider.family<List<QuestItem>, DateTime>(
  (ref, day) => ref.watch(questServiceProvider).watchDay(day),
);

/// Квесты недели с понедельника (включая босса).
final questWeekProvider = StreamProvider.family<List<QuestItem>, DateTime>(
  (ref, weekStart) => ref.watch(questServiceProvider).watchWeek(weekStart),
);

/// Журнал для «Истории».
final questHistoryProvider = StreamProvider<List<HistoryEntry>>(
  (ref) => ref.watch(questServiceProvider).watchHistory(),
);

/// Ближайший квест; переподписка раз в минуту вместе с часами.
final questNextProvider = StreamProvider<QuestItem?>((ref) {
  final now = ref.watch(homeClockProvider);
  return ref.watch(questServiceProvider).watchNext(now);
});

/// Сегодня (локальная полночь), меняется на границе суток.
final questTodayProvider = Provider<DateTime>((ref) => dayOf(ref.watch(homeClockProvider)));

/// Режим вкладки: сегодня / неделя / история.
enum QuestsView { today, week, history, habits }

final questsViewProvider = NotifierProvider<QuestsViewState, QuestsView>(QuestsViewState.new);

class QuestsViewState extends Notifier<QuestsView> {
  @override
  QuestsView build() => QuestsView.today;

  void set(QuestsView v) => state = v;
}

final questFilterProvider = NotifierProvider<QuestFilterState, QuestFilter>(QuestFilterState.new);

class QuestFilterState extends Notifier<QuestFilter> {
  @override
  QuestFilter build() => QuestFilter.none;

  void set(QuestFilter f) => state = f;
}
