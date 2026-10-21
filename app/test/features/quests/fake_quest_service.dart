// Фейковый движок квестов для виджет-тестов: данные в памяти, стримы обновляются при действиях,
// вызовы записываются в [calls], последствия уходят в [outcomes].
import 'dart:async';

import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/quests/quest_api.dart';

QuestItem copyQuest(
  QuestItem q, {
  QuestStatus? status,
  DateTime? deadlineAt,
  List<Subtask>? subtasks,
  int? progress,
}) =>
    QuestItem(
      instanceId: q.instanceId,
      questId: q.questId,
      kind: q.kind,
      title: q.title,
      day: q.day,
      deadlineAt: deadlineAt ?? q.deadlineAt,
      status: status ?? q.status,
      reward: q.reward,
      penaltyDiamonds: q.penaltyDiamonds,
      refusePenaltyDiamonds: q.refusePenaltyDiamonds,
      stat: q.stat,
      startsAt: q.startsAt,
      snoozedUntil: q.snoozedUntil,
      subtasks: subtasks ?? q.subtasks,
      progress: progress ?? q.progress,
      target: q.target,
      confirm: q.confirm,
      nag: q.nag,
      cancellable: q.cancellable,
      source: q.source,
    );

PlayerSnapshot copyPlayer(
  PlayerSnapshot p, {
  Map<StatKind, int>? stats,
  int? freeStatPoints,
  ActivePause? pause,
  bool clearPause = false,
}) =>
    PlayerSnapshot(
      diamonds: p.diamonds,
      xp: p.xp,
      level: p.level,
      xpIntoLevel: p.xpIntoLevel,
      xpForNextLevel: p.xpForNextLevel,
      rank: p.rank,
      stats: stats ?? p.stats,
      statDeltaToday: p.statDeltaToday,
      freeStatPoints: freeStatPoints ?? p.freeStatPoints,
      streakDays: p.streakDays,
      effects: p.effects,
      titleKey: p.titleKey,
      pause: clearPause ? null : (pause ?? p.pause),
      disciplineActive: p.disciplineActive,
    );

DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);

/// Квест дня [today] с началом в [startMin] и дедлайном в [endMin] (минуты суток).
QuestItem fakeQuest(
  String id,
  DateTime today, {
  String? text,
  QuestTitle? title,
  QuestKind kind = QuestKind.daily,
  StatKind? stat,
  int? startMin,
  int endMin = 23 * 60 + 59,
  QuestStatus status = QuestStatus.pending,
  int diamonds = 10,
  int xp = 15,
  int penalty = 10,
  int refusePenalty = 6,
  List<Subtask> subtasks = const [],
  int progress = 0,
  int? target,
  bool cancellable = true,
  QuestSource source = QuestSource.plan,
}) {
  final d = _day(today);
  return QuestItem(
    instanceId: id,
    questId: 'q-$id',
    kind: kind,
    title: title ?? QuestTitle(text: text ?? id),
    day: d,
    startsAt: startMin == null ? null : d.add(Duration(minutes: startMin)),
    deadlineAt: d.add(Duration(minutes: endMin)),
    status: status,
    reward: GameReward(diamonds: diamonds, xp: xp),
    penaltyDiamonds: penalty,
    refusePenaltyDiamonds: refusePenalty,
    stat: stat,
    subtasks: subtasks,
    progress: progress,
    target: target,
    cancellable: cancellable,
    source: source,
  );
}

/// Набор «утро первого дня» относительно [now] (по смыслу — как демо этапа 0).
List<QuestItem> fakeDayQuests(DateTime now) {
  final m = now.hour * 60 + now.minute;
  return [
    fakeQuest('wake', now, text: 'Подъём до 07:00', stat: StatKind.discipline, startMin: 6 * 60 + 30, endMin: 7 * 60,
        status: QuestStatus.done),
    fakeQuest('breakfast', now, text: 'Завтрак с белком', stat: StatKind.health, startMin: 7 * 60 + 20,
        endMin: 7 * 60 + 40, diamonds: 5, penalty: 5),
    fakeQuest('next', now, title: const QuestTitle(key: 'water', params: {'ml': 500}), stat: StatKind.health,
        startMin: m - 22, endMin: m + 38, penalty: 15),
    fakeQuest('punish', now, text: 'Штрафной: 30 приседаний', kind: QuestKind.penalty, stat: StatKind.endurance,
        startMin: m - 10, endMin: m + 74, diamonds: 0, xp: 5, penalty: 20, cancellable: false,
        source: QuestSource.system),
    fakeQuest('water', now, text: 'Выпить 2,5 л воды', stat: StatKind.health, penalty: 15, progress: 1200, target: 2500),
    fakeQuest('workout', now, text: 'Тренировка дома', stat: StatKind.strength, startMin: 18 * 60, endMin: 19 * 60,
        diamonds: 20, penalty: 20, source: QuestSource.user,
        subtasks: const [
          Subtask(title: 'Разминка 5 мин', done: true),
          Subtask(title: 'Отжимания 3×15', done: false),
          Subtask(title: 'Планка 3×45 с', done: false),
        ]),
    fakeQuest('lesson', now, text: 'Пара: матанализ', kind: QuestKind.schedule, stat: StatKind.intellect,
        startMin: 12 * 60, endMin: 13 * 60 + 30),
  ];
}

QuestItem fakeBoss(DateTime now) {
  final d = _day(now);
  final monday = DateTime(d.year, d.month, d.day - (d.weekday - 1));
  return QuestItem(
    instanceId: 'boss',
    questId: 'q-boss',
    kind: QuestKind.boss,
    title: const QuestTitle(text: 'Провести 5 тренировок за неделю'),
    day: monday,
    deadlineAt: DateTime(monday.year, monday.month, monday.day + 7),
    status: QuestStatus.pending,
    reward: const GameReward(diamonds: 150, xp: 200),
    penaltyDiamonds: 0,
    refusePenaltyDiamonds: 0,
    stat: StatKind.strength,
    progress: 2,
    target: 5,
    cancellable: false,
    source: QuestSource.system,
  );
}

PlayerSnapshot fakePlayer(DateTime now) => PlayerSnapshot(
      diamonds: 340,
      xp: 9240,
      level: 7,
      xpIntoLevel: 1240,
      xpForNextLevel: 2000,
      rank: PlayerRank.e,
      titleKey: 'awakened',
      stats: const {
        StatKind.strength: 14,
        StatKind.endurance: 11,
        StatKind.discipline: 17,
        StatKind.intellect: 19,
        StatKind.health: 13,
        StatKind.looks: 10,
      },
      statDeltaToday: const {StatKind.strength: 1, StatKind.discipline: 1, StatKind.health: -1},
      freeStatPoints: 3,
      streakDays: 12,
      effects: [
        ActiveEffect(
          id: 'e1',
          kind: 'vigor',
          isBuff: true,
          startsAt: now.subtract(const Duration(minutes: 30)),
          expiresAt: now.add(const Duration(hours: 1, minutes: 24)),
        ),
      ],
    );

class FakeQuestService implements QuestService {
  FakeQuestService({required DateTime now, List<QuestItem>? quests, PlayerSnapshot? player, List<HistoryEntry>? history})
      : quests = quests ?? [...fakeDayQuests(now), fakeBoss(now)],
        player = player ?? fakePlayer(now),
        history = history ?? const [];

  List<QuestItem> quests;
  PlayerSnapshot player;
  List<HistoryEntry> history;

  /// Последствие, которое добавится к выполнению (например, LevelUp).
  GameOutcome? extraOnComplete;

  final List<String> calls = [];
  final List<QuestInput> created = [];
  final List<DayMark> marks = [];
  final _changes = StreamController<void>.broadcast();
  final _outcomes = StreamController<GameOutcome>.broadcast();

  void _changed() => _changes.add(null);

  /// Выпустить последствие в стрим (как из tick).
  void emit(GameOutcome o) => _outcomes.add(o);

  Stream<T> _watch<T>(T Function() get) async* {
    yield get();
    await for (final _ in _changes.stream) {
      yield get();
    }
  }

  QuestItem _find(String id) => quests.firstWhere((q) => q.instanceId == id);

  void _replace(QuestItem q) => quests = [for (final x in quests) x.instanceId == q.instanceId ? q : x];

  @override
  Stream<PlayerSnapshot> watchPlayer() => _watch(() => player);

  @override
  Stream<List<QuestItem>> watchDay(DateTime day) =>
      _watch(() => [for (final q in quests) if (q.kind != QuestKind.boss && _day(q.day) == _day(day)) q]);

  @override
  Stream<List<QuestItem>> watchWeek(DateTime weekStart) => _watch(() {
        final end = weekStart.add(const Duration(days: 7));
        return [for (final q in quests) if (!q.day.isBefore(weekStart) && q.day.isBefore(end)) q];
      });

  @override
  Stream<QuestItem?> watchNext(DateTime now) => _watch(() {
        final list = [
          for (final q in quests)
            if (q.isPending && q.kind != QuestKind.boss && q.deadlineAt.isAfter(now)) q,
        ]..sort((a, b) => a.deadlineAt.compareTo(b.deadlineAt));
        return list.isEmpty ? null : list.first;
      });

  @override
  Stream<List<HistoryEntry>> watchHistory({int limit = 100}) => _watch(() => history);

  @override
  Future<List<QuestItem>> upcoming(DateTime now, Duration horizon) async => const [];

  @override
  Stream<GameOutcome> get outcomes => _outcomes.stream;

  @override
  Future<List<GameOutcome>> complete(String instanceId, {DateTime? at}) async {
    calls.add('complete:$instanceId');
    final q = copyQuest(_find(instanceId), status: QuestStatus.done);
    _replace(q);
    _changed();
    final res = [QuestCompleted(q, q.reward), ?extraOnComplete];
    res.forEach(_outcomes.add);
    return res;
  }

  @override
  Future<void> snooze(String instanceId, {Duration by = const Duration(minutes: 10), DateTime? at}) async {
    calls.add('snooze:$instanceId');
    final q = _find(instanceId);
    _replace(copyQuest(q, deadlineAt: q.deadlineAt.add(by)));
    _changed();
  }

  @override
  Future<List<GameOutcome>> refuse(String instanceId, {DateTime? at}) async {
    final q = _find(instanceId);
    if (!q.cancellable) throw StateError('Штрафной квест нельзя отменить');
    calls.add('refuse:$instanceId');
    final done = copyQuest(q, status: QuestStatus.refused);
    _replace(done);
    _changed();
    final o = QuestRefused(done, q.refusePenaltyDiamonds);
    _outcomes.add(o);
    return [o];
  }

  @override
  Future<void> toggleSubtask(String instanceId, int index, bool done) async {
    calls.add('subtask:$instanceId:$index:$done');
    final q = _find(instanceId);
    final subs = [...q.subtasks];
    subs[index] = Subtask(title: subs[index].title, done: done);
    _replace(copyQuest(q, subtasks: subs));
    _changed();
  }

  @override
  Future<List<GameOutcome>> addProgress(String instanceId, int delta, {DateTime? at}) async {
    calls.add('progress:$instanceId:$delta');
    final q = _find(instanceId);
    _replace(copyQuest(q, progress: q.progress + delta));
    _changed();
    return const [];
  }

  @override
  Future<String> createQuest(QuestInput input) async {
    calls.add('create');
    created.add(input);
    return 'new-${created.length}';
  }

  @override
  Future<void> updateQuest(String questId, QuestInput input) async {
    calls.add('update:$questId');
    created.add(input);
  }

  @override
  Future<void> archiveQuest(String questId) async {
    calls.add('archive:$questId');
    quests = [for (final q in quests) if (q.questId != questId) q];
    _changed();
  }

  @override
  Future<void> importPlanQuests({required String planId, required List<Map<String, Object?>> drafts}) async {}

  @override
  Future<List<GameOutcome>> markDay(DayMark mark, {DateTime? at}) async {
    calls.add('mark:${mark.name}');
    marks.add(mark);
    const o = PenaltyApplied(reasonKey: 'mark', diamonds: 5);
    _outcomes.add(o);
    return const [o];
  }

  @override
  Future<void> startPause(PauseReason reason, {DateTime? until, DateTime? at}) async {
    calls.add('pause:${reason.name}:${until?.toIso8601String()}');
    player = copyPlayer(player, pause: ActivePause(id: 'p1', reason: reason, startsAt: at ?? DateTime.now(), endsAt: until));
    _changed();
  }

  @override
  Future<void> endPause({DateTime? at}) async {
    calls.add('endPause');
    player = copyPlayer(player, clearPause: true);
    _changed();
  }

  @override
  Future<void> spendStatPoint(StatKind stat) async {
    calls.add('stat:${stat.name}');
    player = copyPlayer(
      player,
      stats: {...player.stats, stat: (player.stats[stat] ?? 0) + 1},
      freeStatPoints: player.freeStatPoints - 1,
    );
    _changed();
  }

  @override
  Future<bool> purchase({required String rewardId, required String title, required int price, DateTime? at}) async =>
      false;

  @override
  Future<void> setDiscipline({required bool active, String? reasonKey, DateTime? at}) async {}

  @override
  Future<List<GameOutcome>> tick(DateTime now) async => const [];
}
