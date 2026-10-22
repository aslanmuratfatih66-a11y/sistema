// КОНТРАКТ каркаса этапа 2: движок квестов (SPEC §6). Правит главный агент.
// Реализует сабагент A (app/lib/domain/quests/), используют C (экраны), B (уведомления), D (магазин, дисциплина).
// Источник правды по ◆/опыту/характеристикам — журнал QuestEvents; всё здесь — вычисляемые снимки.
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';

/// Награда: баллы ◆, опыт, прирост характеристик.
@immutable
class GameReward {
  const GameReward({this.diamonds = 0, this.xp = 0, this.stats = const {}});

  final int diamonds;
  final int xp;
  final Map<StatKind, int> stats;

  static const none = GameReward();
}

/// Название квеста: ключ плана (локализуется по QuestKey из features/plan) или свой текст.
@immutable
class QuestTitle {
  const QuestTitle({this.key, this.text, this.params = const {}});

  /// QuestKey.name из плана (`planQuestTitle` в features/plan/plan_l10n.dart) или ключ системного квеста движка.
  final String? key;

  /// Свой текст (custom/ai). Если задан — показывается как есть.
  final String? text;
  final Map<String, Object?> params;
}

@immutable
class Subtask {
  const Subtask({required this.title, required this.done});
  final String title;
  final bool done;
}

/// Экземпляр квеста для экранов и уведомлений.
@immutable
class QuestItem {
  const QuestItem({
    required this.instanceId,
    required this.questId,
    required this.kind,
    required this.title,
    required this.day,
    required this.deadlineAt,
    required this.status,
    required this.reward,
    required this.penaltyDiamonds,
    required this.refusePenaltyDiamonds,
    this.stat,
    this.startsAt,
    this.snoozedUntil,
    this.subtasks = const [],
    this.progress = 0,
    this.target,
    this.confirm = ConfirmMethod.button,
    this.nag = true,
    this.cancellable = true,
    this.source = QuestSource.user,
  });

  final String instanceId;
  final String questId;
  final QuestKind kind;
  final StatKind? stat;
  final QuestTitle title;

  /// День экземпляра (локальная полночь; для босса — понедельник недели).
  final DateTime day;
  final DateTime? startsAt;
  final DateTime deadlineAt;
  final DateTime? snoozedUntil;
  final QuestStatus status;
  final GameReward reward;
  final int penaltyDiamonds;
  final int refusePenaltyDiamonds;
  final List<Subtask> subtasks;
  final int progress;
  final int? target;
  final ConfirmMethod confirm;
  final bool nag;

  /// false — штрафной квест: отказаться нельзя.
  final bool cancellable;
  final QuestSource source;

  bool get isPending => status == QuestStatus.pending;

  /// Просрочен ли на момент [now] (ещё не закрыт движком).
  bool overdueAt(DateTime now) => isPending && now.isAfter(deadlineAt);
}

/// Активный бафф/дебафф.
@immutable
class ActiveEffect {
  const ActiveEffect({
    required this.id,
    required this.kind,
    required this.isBuff,
    required this.startsAt,
    required this.expiresAt,
    this.params = const {},
  });

  final String id;

  /// Ключ эффекта движка (локализуется в A: `effectLabel(l, kind, params)`).
  final String kind;
  final bool isBuff;
  final DateTime startsAt;
  final DateTime expiresAt;
  final Map<String, Object?> params;
}

/// Снимок игрока, вычисленный из журнала.
@immutable
class PlayerSnapshot {
  const PlayerSnapshot({
    required this.diamonds,
    required this.xp,
    required this.level,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
    required this.rank,
    required this.stats,
    required this.statDeltaToday,
    required this.freeStatPoints,
    required this.streakDays,
    required this.effects,
    this.titleKey,
    this.pause,
    this.disciplineActive = false,
  });

  /// Баланс ◆ (может быть отрицательным).
  final int diamonds;
  final int xp;
  final int level;
  final int xpIntoLevel;
  final int xpForNextLevel;
  final PlayerRank rank;

  /// Ключ титула (локализуется в A: `titleLabel(l, key)`); null — без титула.
  final String? titleKey;
  final Map<StatKind, int> stats;
  final Map<StatKind, int> statDeltaToday;
  final int freeStatPoints;
  final int streakDays;
  final List<ActiveEffect> effects;

  /// Текущая пауза (null — нет).
  final ActivePause? pause;
  final bool disciplineActive;

  bool get inDebt => diamonds < 0;
}

@immutable
class ActivePause {
  const ActivePause({required this.id, required this.reason, required this.startsAt, this.endsAt});
  final String id;
  final PauseReason reason;
  final DateTime startsAt;
  final DateTime? endsAt;
}

/// Запись истории (журнал) для экрана «История».
@immutable
class HistoryEntry {
  const HistoryEntry({
    required this.id,
    required this.type,
    required this.occurredAt,
    this.title,
    this.delta = GameReward.none,
    this.payload = const {},
  });

  final String id;
  final QuestEventType type;
  final DateTime occurredAt;
  final QuestTitle? title;

  /// Изменение (◆ может быть отрицательным).
  final GameReward delta;
  final Map<String, Object?> payload;
}

/// Последствия действия/проверки — показываются системными окнами (C) и уведомлениями (B).
@immutable
sealed class GameOutcome {
  const GameOutcome();
}

class QuestCompleted extends GameOutcome {
  const QuestCompleted(this.quest, this.reward);
  final QuestItem quest;
  final GameReward reward;
}

/// «Квест провален» (игнор до дедлайна).
class QuestFailed extends GameOutcome {
  const QuestFailed(this.quest, this.penaltyDiamonds);
  final QuestItem quest;
  final int penaltyDiamonds;
}

class QuestRefused extends GameOutcome {
  const QuestRefused(this.quest, this.penaltyDiamonds);
  final QuestItem quest;
  final int penaltyDiamonds;
}

/// «Штраф» (отдельный: срыв, упрёк, штрафной квест назначен).
class PenaltyApplied extends GameOutcome {
  const PenaltyApplied({required this.reasonKey, required this.diamonds, this.penaltyQuest});
  final String reasonKey;
  final int diamonds;
  final QuestItem? penaltyQuest;
}

/// «Уровень повышен».
class LevelUp extends GameOutcome {
  const LevelUp({required this.level, required this.freeStatPoints, this.rank, this.titleKey});
  final int level;
  final int freeStatPoints;

  /// Новый ранг, если сменился.
  final PlayerRank? rank;

  /// Новый титул, если получен.
  final String? titleKey;
}

class BossResult extends GameOutcome {
  const BossResult({required this.quest, required this.won, required this.reward, this.titleKey});
  final QuestItem quest;
  final bool won;
  final GameReward reward;
  final String? titleKey;
}

/// Режим дисциплины включён/выключен (D показывает окно).
class DisciplineChanged extends GameOutcome {
  const DisciplineChanged({required this.active});
  final bool active;
}

/// Ввод для создания своего/системного квеста.
@immutable
class QuestInput {
  const QuestInput({
    required this.kind,
    required this.title,
    this.stat,
    this.subtasks = const [],
    this.minute,
    this.windowMinutes = 60,
    this.weekdays = const [],
    this.weekParity = 0,
    this.activeFrom,
    this.activeUntil,
    this.reward = GameReward.none,
    this.penaltyDiamonds = 0,
    this.refusePenaltyDiamonds,
    this.confirm = ConfirmMethod.button,
    this.target,
    this.nag = true,
    this.cancellable = true,
    this.source = QuestSource.user,
  });

  final QuestKind kind;
  final QuestTitle title;
  final StatKind? stat;
  final List<String> subtasks;
  final int? minute;
  final int windowMinutes;
  final List<int> weekdays;
  final int weekParity;
  final DateTime? activeFrom;
  final DateTime? activeUntil;
  final GameReward reward;
  final int penaltyDiamonds;
  final int? refusePenaltyDiamonds;
  final ConfirmMethod confirm;
  final int? target;
  final bool nag;
  final bool cancellable;
  final QuestSource source;
}

/// Движок квестов. Все методы идемпотентны по отношению к уже закрытым экземплярам.
abstract interface class QuestService {
  // ---- Чтение ----
  Stream<PlayerSnapshot> watchPlayer();

  /// Квесты дня [day] (экземпляры создаются по шаблонам при первом обращении).
  Stream<List<QuestItem>> watchDay(DateTime day);

  /// Квесты недели с понедельника [weekStart] (включая босса недели).
  Stream<List<QuestItem>> watchWeek(DateTime weekStart);

  /// Ближайший незакрытый квест на момент [now] (для «Следующего квеста» на «Статусе»).
  Stream<QuestItem?> watchNext(DateTime now);

  /// Журнал, новые сверху.
  Stream<List<HistoryEntry>> watchHistory({int limit = 100});

  /// Незакрытые экземпляры с началом/дедлайном в [now, now+horizon] — для планировщика уведомлений (B).
  Future<List<QuestItem>> upcoming(DateTime now, Duration horizon);

  /// Последствия, произошедшие в этом процессе (в т.ч. из [tick]) — для системных окон (C).
  Stream<GameOutcome> get outcomes;

  // ---- Действия ----
  Future<List<GameOutcome>> complete(String instanceId, {DateTime? at});

  /// «+10 мин»: сдвиг дедлайна, лимит откладываний — правило движка.
  Future<void> snooze(String instanceId, {Duration by = const Duration(minutes: 10), DateTime? at});

  /// Отказ (после удержания 5 с в UI). Дороже выполнения, мягче игнора. Штрафные — не отменяются (StateError).
  Future<List<GameOutcome>> refuse(String instanceId, {DateTime? at});

  Future<void> toggleSubtask(String instanceId, int index, bool done);

  /// Прогресс к цели (шаги, минуты, босс).
  Future<List<GameOutcome>> addProgress(String instanceId, int delta, {DateTime? at});

  Future<String> createQuest(QuestInput input);
  Future<void> updateQuest(String questId, QuestInput input);
  Future<void> archiveQuest(String questId);

  /// Квесты из принятого плана (features/plan, QuestDraft) — заменяет прежние квесты этого источника.
  Future<void> importPlanQuests({required String planId, required List<Map<String, Object?>> drafts});

  /// Честная отметка дня → небольшой штраф + усиленный план на завтра.
  Future<List<GameOutcome>> markDay(DayMark mark, {DateTime? at});

  Future<void> startPause(PauseReason reason, {DateTime? until, DateTime? at});
  Future<void> endPause({DateTime? at});

  Future<void> spendStatPoint(StatKind stat);

  /// Покупка в магазине: событие purchase (−price ◆). Возвращает false, если баланс < price или он отрицательный.
  Future<bool> purchase({required String rewardId, required String title, required int price, DateTime? at});

  /// Начисление или штраф ◆ вне квестов (этап 7: лимиты бюджета, «налог на фастфуд», будильник).
  /// [diamonds] < 0 — событие penalty (на паузе не начисляется), > 0 — bonus. [ref] — ключ идемпотентности:
  /// повтор с тем же ref ничего не делает. Штраф возвращает [PenaltyApplied] (+ возможное включение дисциплины).
  Future<List<GameOutcome>> award({
    required int diamonds,
    int xp = 0,
    Map<StatKind, int> stats = const {},
    required String reasonKey,
    required String ref,
    DateTime? at,
  });

  /// Ручное включение/выключение дисциплины (D): событие disciplineOn/Off.
  Future<void> setDiscipline({required bool active, String? reasonKey, DateTime? at});

  /// Проверка по времени: просрочки → провал/штраф, эффекты, конец недели (босс), серия, дисциплина.
  /// Вызывается при открытии, раз в минуту на переднем плане и из фоновой задачи.
  Future<List<GameOutcome>> tick(DateTime now);
}

/// Переопределяется реализацией A в main (и в тестах — фейком).
final questServiceProvider = Provider<QuestService>(
  (ref) => throw UnimplementedError('questServiceProvider: переопределите реализацией движка'),
);
