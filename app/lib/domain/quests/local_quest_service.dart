// Движок квестов поверх локальной БД (SPEC §6, §10). ◆/опыт/характеристики — только сумма журнала QuestEvents.
// Экземпляры на день создаются лениво по шаблонам. Ид экземпляров и системных событий детерминированы
// (UUID v5 от ключа) — повторный tick, второй isolate или синхронизация не дублируют записи.
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../features/plan/model/plan.dart' show QuestDraft, QuestKey;
import '../../features/schedule/schedule_logic.dart';
import 'game_rules.dart';
import 'quest_api.dart';
import 'system_quests.dart';

final localQuestServiceProvider = Provider<QuestService>((ref) {
  final service = LocalQuestService(ref.watch(databaseProvider));
  ref.onDispose(service.dispose);
  return service;
});

class LocalQuestService implements QuestService {
  LocalQuestService(
    this._db, {
    DateTime Function()? clock,
    List<QuestInput> Function(DateTime day)? disciplineQuests,
    GameConfig config = GameConfig.standard,
  })  : _clock = clock ?? DateTime.now,
        _disciplineQuests = disciplineQuests ?? _noQuests,
        rules = GameRules(config);

  static List<QuestInput> _noQuests(DateTime _) => const [];

  /// Локальная настройка: последний день, обработанный tick (догон пропущенных дней).
  static const lastTickKey = 'quests.lastTickDay';

  final AppDatabase _db;
  final DateTime Function() _clock;
  final List<QuestInput> Function(DateTime day) _disciplineQuests;
  final GameRules rules;
  GameConfig get config => rules.config;

  final _outcomes = StreamController<GameOutcome>.broadcast();
  Future<void> _tail = Future.value();
  String? _dev;

  Future<void> dispose() => _outcomes.close();

  @override
  Stream<GameOutcome> get outcomes => _outcomes.stream;

  // ================= Чтение =================

  @override
  Stream<PlayerSnapshot> watchPlayer() =>
      // Пустой запрос-наблюдатель: первое значение сразу, дальше — при изменении таблиц.
      // (async* поверх tableUpdates не отменялся: sub.cancel() зависал.)
      _db
          .customSelect('SELECT 1', readsFrom: {_db.questEvents, _db.effects, _db.pauses, _db.questInstances})
          .watch()
          .asyncMap((_) => snapshot());

  @override
  Stream<List<QuestItem>> watchDay(DateTime day) async* {
    final d = _dayOf(day);
    await _locked(() => _ensureDay(d));
    final q = _joined()
      ..where(_db.questInstances.day.equals(d) &
          _db.questInstances.deletedAt.isNull() &
          _db.quests.kind.equals(QuestKind.boss.name).not());
    yield* q.watch().map((rows) => _sorted(rows.map(_itemOf)));
  }

  @override
  Stream<List<QuestItem>> watchWeek(DateTime weekStart) async* {
    final monday = ScheduleLogic.mondayOf(weekStart);
    final next = _addDays(monday, 7);
    await _locked(() async {
      for (var d = monday; d.isBefore(next); d = _addDays(d, 1)) {
        await _ensureDay(d);
      }
      await _ensureBoss(monday);
    });
    final q = _joined()
      ..where(_db.questInstances.day.isBiggerOrEqualValue(monday) &
          _db.questInstances.day.isSmallerThanValue(next) &
          _db.questInstances.deletedAt.isNull());
    yield* q.watch().map((rows) => _sorted(rows.map(_itemOf)));
  }

  @override
  Stream<QuestItem?> watchNext(DateTime now) async* {
    final today = _dayOf(now);
    await _locked(() => _ensureDay(today));
    final q = _joined()
      ..where(_db.questInstances.day.equals(today) &
          _db.questInstances.deletedAt.isNull() &
          _db.questInstances.status.equals(QuestStatus.pending.name) &
          _db.quests.kind.equals(QuestKind.boss.name).not());
    yield* q.watch().map((rows) {
      final items = [for (final r in rows) _itemOf(r)].where((i) => !i.deadlineAt.isBefore(now)).toList()
        ..sort((a, b) => _nextAt(a).compareTo(_nextAt(b)));
      return items.firstOrNull;
    });
  }

  @override
  Stream<List<HistoryEntry>> watchHistory({int limit = 100}) {
    final q = _db.select(_db.questEvents).join([
      leftOuterJoin(_db.quests, _db.quests.id.equalsExp(_db.questEvents.questId)),
    ])
      ..where(_db.questEvents.deletedAt.isNull())
      ..orderBy([OrderingTerm.desc(_db.questEvents.occurredAt)])
      ..limit(limit);
    return q.watch().map((rows) => [for (final r in rows) _historyOf(r)]);
  }

  HistoryEntry _historyOf(TypedResult r) {
    final e = r.readTable(_db.questEvents);
    final quest = r.readTableOrNull(_db.quests);
    return HistoryEntry(
      id: e.id,
      type: enumByName(QuestEventType.values, e.type) ?? QuestEventType.adjustment,
      occurredAt: e.occurredAt,
      title: quest == null ? null : _titleOf(quest),
      delta: GameReward(diamonds: e.diamonds, xp: e.xp, stats: _decodeStats(e.stats)),
      payload: _decodeMap(e.payload),
    );
  }

  @override
  Future<List<QuestItem>> upcoming(DateTime now, Duration horizon) async {
    final end = now.add(horizon);
    final today = _dayOf(now);
    final lastDay = _dayOf(end);
    await _locked(() async {
      for (var d = today, i = 0; !d.isAfter(lastDay) && i < 3; d = _addDays(d, 1), i++) {
        await _ensureDay(d);
      }
      await _ensureBoss(ScheduleLogic.mondayOf(today));
    });
    final q = _joined()
      ..where(_db.questInstances.deletedAt.isNull() &
          _db.questInstances.status.equals(QuestStatus.pending.name) &
          _db.questInstances.deadlineAt.isBiggerOrEqualValue(now));
    bool inWindow(DateTime? t) => t != null && !t.isBefore(now) && !t.isAfter(end);
    final items = [
      for (final r in await q.get())
        if (_itemOf(r) case final i when inWindow(i.snoozedUntil ?? i.startsAt) || inWindow(i.deadlineAt)) i,
    ]..sort((a, b) => _nextAt(a).compareTo(_nextAt(b)));
    return items;
  }

  /// Снимок игрока из журнала на момент [at].
  Future<PlayerSnapshot> snapshot([DateTime? at]) async {
    final now = at ?? _clock();
    final today = _dayOf(now);
    final tomorrow = _addDays(today, 1);
    final events = await (_db.select(_db.questEvents)..where((t) => t.deletedAt.isNull())).get();
    var diamonds = 0;
    var xp = 0;
    var spent = 0;
    final stats = <StatKind, int>{};
    final delta = <StatKind, int>{};
    String? titleKey;
    DateTime? titleAt;
    for (final e in events) {
      diamonds += e.diamonds;
      xp += e.xp;
      if (e.type == QuestEventType.statPointSpent.name) spent++;
      if (e.stats != '{}') {
        final s = _decodeStats(e.stats);
        final isToday = !e.occurredAt.isBefore(today) && e.occurredAt.isBefore(tomorrow);
        s.forEach((k, v) {
          stats[k] = (stats[k] ?? 0) + v;
          if (isToday) delta[k] = (delta[k] ?? 0) + v;
        });
      }
      if (e.type == QuestEventType.bonus.name && e.payload.contains('"title"')) {
        final title = _decodeMap(e.payload)['title'];
        if (title is String && (titleAt == null || !e.occurredAt.isBefore(titleAt))) {
          titleKey = title;
          titleAt = e.occurredAt;
        }
      }
    }
    final level = rules.levelFor(xp);
    final pauses = await _pauses();
    final pause = pauses.where((p) => _pauseCovers(p, now)).firstOrNull;
    return PlayerSnapshot(
      diamonds: diamonds,
      xp: xp,
      level: level.level,
      xpIntoLevel: level.xpIntoLevel,
      xpForNextLevel: level.xpForNextLevel,
      rank: rules.rankFor(level.level),
      titleKey: titleKey,
      stats: {for (final k in StatKind.values) k: config.baseStat + (stats[k] ?? 0)},
      statDeltaToday: {for (final k in StatKind.values) k: delta[k] ?? 0},
      freeStatPoints: rules.freeStatPoints(level.level, spent),
      streakDays: await _streak(today, pauses),
      effects: await _activeEffects(now),
      pause: pause == null
          ? null
          : ActivePause(
              id: pause.id,
              reason: enumByName(PauseReason.values, pause.reason) ?? PauseReason.other,
              startsAt: pause.startsAt,
              endsAt: pause.endsAt,
            ),
      disciplineActive: _discipline(events).active,
    );
  }

  // ================= Действия =================

  @override
  Future<List<GameOutcome>> complete(String instanceId, {DateTime? at}) =>
      _act(() => _complete(instanceId, at ?? _clock()));

  @override
  Future<void> snooze(String instanceId, {Duration by = const Duration(minutes: 10), DateTime? at}) =>
      _locked(() async {
        final now = at ?? _clock();
        final inst = await _instance(instanceId);
        // Сверх лимита откладываний — тихо игнорируется (кнопка в уведомлении не должна падать).
        if (inst == null || inst.status != QuestStatus.pending.name || inst.snoozeCount >= config.maxSnoozes) return;
        await _updateInstance(
          instanceId,
          QuestInstancesCompanion(
            deadlineAt: Value(inst.deadlineAt.add(by)),
            snoozedUntil: Value(now.add(by)),
            snoozeCount: Value(inst.snoozeCount + 1),
          ),
          version: inst.version,
        );
      });

  @override
  Future<List<GameOutcome>> refuse(String instanceId, {DateTime? at}) => _act(() async {
        final now = at ?? _clock();
        final inst = await _requireInstance(instanceId);
        final quest = await _requireQuest(inst.questId);
        if (!quest.cancellable) throw StateError('Штрафной квест нельзя отменить');
        if (inst.status != QuestStatus.pending.name) return const [];
        final penalty = await _pausedAt(now) ? 0 : inst.refusePenaltyDiamonds;
        final out = <GameOutcome>[];
        await _db.transaction(() async {
          if (!await _resolve(inst, QuestStatus.refused, now)) return;
          await _addEvent(
            id: _sid('refused:$instanceId'),
            type: QuestEventType.refused,
            at: now,
            questId: quest.id,
            instanceId: instanceId,
            diamonds: -penalty,
          );
          out.add(QuestRefused(await _item(instanceId), penalty));
        });
        out.addAll(await _checkDiscipline(now));
        return out;
      });

  @override
  Future<void> toggleSubtask(String instanceId, int index, bool done) => _locked(() async {
        final inst = await _requireInstance(instanceId);
        final set = {for (final i in _decodeList(inst.subtasksDone)) ?(i is num ? i.toInt() : null)};
        done ? set.add(index) : set.remove(index);
        await _updateInstance(
          instanceId,
          QuestInstancesCompanion(subtasksDone: Value(jsonEncode(set.toList()..sort()))),
          version: inst.version,
        );
      });

  @override
  Future<List<GameOutcome>> addProgress(String instanceId, int delta, {DateTime? at}) => _act(() async {
        final now = at ?? _clock();
        final inst = await _requireInstance(instanceId);
        if (inst.status != QuestStatus.pending.name) return const [];
        final quest = await _requireQuest(inst.questId);
        final progress = math.max(0, inst.progress + delta);
        await _updateInstance(instanceId, QuestInstancesCompanion(progress: Value(progress)), version: inst.version);
        final target = quest.target;
        if (target == null || progress < target) return const [];
        if (quest.kind == QuestKind.boss.name) return _winBoss(instanceId, now);
        return _complete(instanceId, now);
      });

  @override
  Future<String> createQuest(QuestInput input) => _locked(() async {
        final id = newId();
        await _insertQuest(id, input);
        await _ensureDay(_dayOf(_clock()));
        return id;
      });

  @override
  Future<void> updateQuest(String questId, QuestInput input) => _locked(() async {
        final old = await _requireQuest(questId);
        await (_db.update(_db.quests)..where((t) => t.id.equals(questId))).write(
          _questCompanion(input).copyWith(
            updatedAt: Value(_clock().toUtc()),
            deviceId: Value(await _deviceId()),
            version: Value(old.version + 1),
          ),
        );
        // Прошлое не меняется; незакрытые экземпляры с сегодняшнего дня пересчитываются по новому шаблону.
        final quest = await _requireQuest(questId);
        final pending = await (_db.select(_db.questInstances)
              ..where((t) =>
                  t.questId.equals(questId) &
                  t.status.equals(QuestStatus.pending.name) &
                  t.deletedAt.isNull() &
                  t.day.isBiggerOrEqualValue(_dayOf(_clock()))))
            .get();
        for (final inst in pending) {
          final (starts, deadline) = GameRules.instanceTimes(inst.day, quest.minute, quest.windowMinutes);
          final fail = quest.penaltyDiamonds;
          await _updateInstance(
            inst.id,
            QuestInstancesCompanion(
              startsAt: Value(starts),
              deadlineAt: Value(deadline),
              rewardDiamonds: Value(quest.rewardDiamonds),
              rewardXp: Value(quest.rewardXp),
              rewardStats: Value(_instanceStatsJson(quest)),
              penaltyDiamonds: Value(fail),
              refusePenaltyDiamonds: Value(rules.refusePenalty(fail, quest.refusePenaltyDiamonds)),
            ),
            version: inst.version,
          );
        }
        await _ensureDay(_dayOf(_clock()));
      });

  @override
  Future<void> archiveQuest(String questId) => _locked(() => _archive([questId]));

  @override
  Future<void> importPlanQuests({required String planId, required List<Map<String, Object?>> drafts}) =>
      _locked(() async {
        await _db.transaction(() async {
          final old = await (_db.select(_db.quests)
                ..where((t) => t.source.equals(QuestSource.plan.name) & t.active & t.deletedAt.isNull()))
              .get();
          await _archive([for (final q in old) q.id]);
          for (final j in drafts) {
            final draft = QuestDraft.fromJson(j);
            if (draft == null) continue;
            await _insertQuest(newId(), SystemQuests.fromDraft(draft, rules: rules), planId: planId);
          }
        });
        await _ensureDay(_dayOf(_clock()));
      });

  @override
  Future<List<GameOutcome>> markDay(DayMark mark, {DateTime? at}) => _act(() async {
        final now = at ?? _clock();
        final today = _dayOf(now);
        final eventId = _sid('mark:${mark.name}:${_dayKey(today)}');
        if (await _eventExists(eventId)) return const [];
        final penalty = await _pausedAt(now) ? 0 : rules.markPenalty(mark);
        final tomorrow = _addDays(today, 1);
        final schedule = await _scheduleConfig();
        final out = <GameOutcome>[];
        await _db.transaction(() async {
          await _addEvent(
            id: eventId,
            type: QuestEventType.mark,
            at: now,
            diamonds: -penalty,
            payload: {'mark': mark.name},
          );
          final boost = SystemQuests.boostFor(mark, tomorrow, bedMinute: schedule.bedMinute, config: config);
          for (var i = 0; i < boost.length; i++) {
            await _insertQuest(_sid('boost:${mark.name}:${_dayKey(tomorrow)}:$i'), boost[i], ignoreExisting: true);
          }
          out.add(PenaltyApplied(reasonKey: PenaltyReasons.forMark(mark), diamonds: penalty));
        });
        out.addAll(await _checkDiscipline(now));
        return out;
      });

  @override
  Future<List<GameOutcome>> award({
    required int diamonds,
    int xp = 0,
    Map<StatKind, int> stats = const {},
    required String reasonKey,
    required String ref,
    DateTime? at,
  }) =>
      _act(() async {
        final now = at ?? _clock();
        final eventId = _sid('award:$ref');
        if (await _eventExists(eventId)) return const [];
        final penalty = diamonds < 0;
        if (penalty && await _pausedAt(now)) return const [];
        await _addEvent(
          id: eventId,
          type: penalty ? QuestEventType.penalty : QuestEventType.bonus,
          at: now,
          diamonds: diamonds,
          xp: xp,
          stats: stats,
          payload: {'reason': reasonKey, 'ref': ref},
        );
        if (!penalty) return const [];
        return [PenaltyApplied(reasonKey: reasonKey, diamonds: -diamonds), ...await _checkDiscipline(now)];
      });

  @override
  Future<void> startPause(PauseReason reason, {DateTime? until, DateTime? at}) => _locked(() async {
        final now = at ?? _clock();
        await _db.transaction(() async {
          await _closePauses(now);
          await _db.into(_db.pauses).insert(PausesCompanion.insert(
                id: newId(),
                updatedAt: now.toUtc(),
                deviceId: await _deviceId(),
                reason: reason.name,
                startsAt: now,
                endsAt: Value(until),
              ));
          await _addEvent(
            type: QuestEventType.pauseStarted,
            at: now,
            payload: {'reason': reason.name, if (until != null) 'until': until.toUtc().toIso8601String()},
          );
        });
      });

  @override
  Future<void> endPause({DateTime? at}) => _locked(() async {
        final now = at ?? _clock();
        await _db.transaction(() async {
          if (await _closePauses(now) > 0) await _addEvent(type: QuestEventType.pauseEnded, at: now);
        });
      });

  @override
  Future<void> spendStatPoint(StatKind stat) => _locked(() async {
        final snap = await snapshot();
        if (snap.freeStatPoints <= 0) throw StateError('Нет свободных очков характеристик');
        await _addEvent(
          type: QuestEventType.statPointSpent,
          at: _clock(),
          stats: {stat: 1},
          payload: {'stat': stat.name},
        );
      });

  @override
  Future<bool> purchase({required String rewardId, required String title, required int price, DateTime? at}) =>
      _locked(() async {
        final balance = await _balance();
        if (balance < 0 || balance < price) return false;
        await _addEvent(
          type: QuestEventType.purchase,
          at: at ?? _clock(),
          diamonds: -price,
          payload: {'rewardId': rewardId, 'title': title, 'price': price},
        );
        return true;
      });

  @override
  Future<void> setDiscipline({required bool active, String? reasonKey, DateTime? at}) => _act(() async {
        final now = at ?? _clock();
        final state = _discipline(await _events());
        if (state.active == active) return const <GameOutcome>[];
        await _addEvent(
          type: active ? QuestEventType.disciplineOn : QuestEventType.disciplineOff,
          at: now,
          payload: active ? {'reason': reasonKey ?? 'manual'} : {'exit': reasonKey ?? 'manual'},
        );
        if (active) await _ensureDay(_dayOf(now));
        return [DisciplineChanged(active: active)];
      });

  @override
  Future<List<GameOutcome>> tick(DateTime now) => _act(() async {
        final today = _dayOf(now);
        final lastRaw = await _db.getSetting(lastTickKey);
        final last = lastRaw == null ? null : DateTime.tryParse(lastRaw);
        var start = last == null || last.isAfter(today) ? today : _dayOf(last);
        final earliest = _addDays(today, -config.backfillDays);
        if (start.isBefore(earliest)) start = earliest;

        for (var d = start; !d.isAfter(today); d = _addDays(d, 1)) {
          await _ensureDay(d, allowPast: true);
        }
        final out = <GameOutcome>[];
        out.addAll(await _failOverdue(now));
        for (var d = start; d.isBefore(today); d = _addDays(d, 1)) {
          out.addAll(await _closeDay(d, today, now));
        }
        await _ensureBoss(ScheduleLogic.mondayOf(today));
        await _expireEffects(now);
        out.addAll(await _checkDiscipline(now));
        await _db.setSetting(lastTickKey, _dayKey(today));
        return out;
      });

  // ================= Внутреннее: действия =================

  /// Действие под замком: уровни (LevelUp) после него и рассылка в [outcomes].
  Future<List<GameOutcome>> _act(Future<List<GameOutcome>> Function() body) => _locked(() async {
        final before = await _levelState();
        final out = [...await body()];
        if (out.whereType<LevelUp>().isEmpty) out.addAll(await _afterXp(before, _clock()));
        for (final o in out) {
          if (!_outcomes.isClosed) _outcomes.add(o);
        }
        return out;
      });

  Future<T> _locked<T>(Future<T> Function() body) {
    final result = _tail.then((_) => body());
    _tail = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  Future<List<GameOutcome>> _complete(String instanceId, DateTime now) async {
    final inst = await _requireInstance(instanceId);
    if (inst.status != QuestStatus.pending.name) return const [];
    final quest = await _requireQuest(inst.questId);
    if (quest.kind == QuestKind.boss.name) {
      if ((quest.target ?? 0) > inst.progress) throw StateError('Босс побеждается прогрессом');
      return _winBoss(instanceId, now);
    }
    final base = GameReward(diamonds: inst.rewardDiamonds, xp: inst.rewardXp, stats: _decodeStats(inst.rewardStats));
    final reward = rules.applyEffects(base, await _activeEffectDefs(now));
    final out = <GameOutcome>[];
    await _db.transaction(() async {
      if (!await _resolve(inst, QuestStatus.done, now)) return;
      await _addEvent(
        id: _sid('completed:$instanceId'),
        type: QuestEventType.completed,
        at: now,
        questId: quest.id,
        instanceId: instanceId,
        diamonds: reward.diamonds,
        xp: reward.xp,
        stats: reward.stats,
      );
      out.add(QuestCompleted(await _item(instanceId), reward));
    });
    if (out.isNotEmpty) out.addAll(await _bossProgress(quest, inst.day, now));
    return out;
  }

  /// +1 к боссу недели за выполненный квест его характеристики (или любой, если у босса её нет).
  Future<List<GameOutcome>> _bossProgress(QuestRow quest, DateTime day, DateTime now) async {
    final boss = await _bossInstance(ScheduleLogic.mondayOf(day));
    if (boss == null || boss.$1.status != QuestStatus.pending.name) return const [];
    final (inst, bq) = boss;
    final stat = enumByName(StatKind.values, bq.stat);
    if (stat != null && quest.stat != stat.name && !_decodeStats(quest.rewardStats).containsKey(stat)) {
      return const [];
    }
    final progress = inst.progress + 1;
    await _updateInstance(inst.id, QuestInstancesCompanion(progress: Value(progress)), version: inst.version);
    if (progress >= (bq.target ?? 1 << 30)) return _winBoss(inst.id, now);
    return const [];
  }

  Future<List<GameOutcome>> _winBoss(String instanceId, DateTime now) async {
    final inst = await _requireInstance(instanceId);
    final reward = rules.applyEffects(
      GameReward(diamonds: inst.rewardDiamonds, xp: inst.rewardXp, stats: _decodeStats(inst.rewardStats)),
      await _activeEffectDefs(now),
    );
    final out = <GameOutcome>[];
    await _db.transaction(() async {
      if (!await _resolve(inst, QuestStatus.done, now)) return;
      final eventId = _sid('bossCompleted:$instanceId');
      await _addEvent(
        id: eventId,
        type: QuestEventType.bossCompleted,
        at: now,
        questId: inst.questId,
        instanceId: instanceId,
        diamonds: reward.diamonds,
        xp: reward.xp,
        stats: reward.stats,
      );
      await _addEffect(_sid('aura:$instanceId'), EffectKinds.bossAura, now, sourceEventId: eventId);
      final wins = await _countEvents(QuestEventType.bossCompleted);
      String? title;
      if (wins >= 1 && await _awardTitle(GameTitles.bossSlayer, now)) title = GameTitles.bossSlayer;
      if (wins >= config.bossHunterWins && await _awardTitle(GameTitles.bossHunter, now)) {
        title = GameTitles.bossHunter;
      }
      out.add(BossResult(quest: await _item(instanceId), won: true, reward: reward, titleKey: title));
    });
    return out;
  }

  /// Просроченные pending → failed (+штраф) или excused (дедлайн в паузе). Босс недели → итог.
  Future<List<GameOutcome>> _failOverdue(DateTime now) async {
    final rows = await (_db.select(_db.questInstances).join([
      innerJoin(_db.quests, _db.quests.id.equalsExp(_db.questInstances.questId)),
    ])
          ..where(_db.questInstances.status.equals(QuestStatus.pending.name) &
              _db.questInstances.deletedAt.isNull() &
              _db.questInstances.deadlineAt.isSmallerThanValue(now)))
        .get();
    final pauses = await _pauses();
    final out = <GameOutcome>[];
    for (final r in rows) {
      final inst = r.readTable(_db.questInstances);
      final quest = r.readTable(_db.quests);
      final isBoss = quest.kind == QuestKind.boss.name;
      // Пауза пересекла окно квеста (для босса — неделю) → без штрафа.
      final excused = pauses.any((p) => _pauseOverlaps(p, inst.startsAt ?? inst.day, inst.deadlineAt));
      await _db.transaction(() async {
        if (excused) {
          await _resolve(inst, QuestStatus.excused, now);
          return;
        }
        if (!await _resolve(inst, QuestStatus.failed, now)) return;
        final penalty = inst.penaltyDiamonds;
        final eventId = _sid('failed:${inst.id}');
        await _addEvent(
          id: eventId,
          type: isBoss ? QuestEventType.bossFailed : QuestEventType.failed,
          at: now,
          questId: quest.id,
          instanceId: inst.id,
          diamonds: -penalty,
        );
        final item = await _item(inst.id);
        if (isBoss) {
          out.add(BossResult(quest: item, won: false, reward: GameReward(diamonds: -penalty)));
        } else {
          out.add(QuestFailed(item, penalty));
          if (quest.titleKey == QuestKey.water.name) {
            await _addEffect(_sid('dehydration:${inst.id}'), EffectKinds.dehydration, now, sourceEventId: eventId);
          }
        }
      });
    }
    return out;
  }

  /// Итог прошедшего дня [day]: серия (бонус, «Бодрость», титулы) и штрафной квест на [today].
  Future<List<GameOutcome>> _closeDay(DateTime day, DateTime today, DateTime now) async {
    final pauses = await _pauses();
    final tallies = await _tallies(_addDays(day, -400), _addDays(day, 1));
    final tally = tallies[day];
    final paused = _dayPaused(pauses, day);
    final out = <GameOutcome>[];
    final next = _addDays(day, 1);

    if (!paused && tally != null && tally.failed >= config.penaltyQuestAfterFails && next == today) {
      final questId = _sid('penalty:${_dayKey(next)}');
      if (await _quest(questId) == null) {
        final level = (await _levelState()).level;
        await _insertQuest(questId, SystemQuests.penaltyFor(next, level: level, config: config));
        await _ensureDay(next);
        final inst = await _instance(_instanceId(questId, next));
        out.add(PenaltyApplied(
          reasonKey: PenaltyReasons.failedQuests,
          diamonds: 0,
          penaltyQuest: inst == null ? null : await _item(inst.id),
        ));
      }
    }

    if (tally == null || rules.dayCounted(tally) != true) return out;
    final streak = rules.streakDays(today: day, tallies: tallies, isPaused: (d) => _dayPaused(pauses, d));
    if (streak >= config.vigorStreak) {
      final starts = next;
      final expires = _addDays(next, config.effects[EffectKinds.vigor]?.duration.inDays ?? 1);
      if (expires.isAfter(now)) {
        await _addEffect(_sid('vigor:${_dayKey(day)}'), EffectKinds.vigor, starts, expiresAt: expires);
      }
    }
    if (config.streakBonusEvery > 0 && streak % config.streakBonusEvery == 0) {
      await _addEvent(
        id: _sid('streakBonus:${_dayKey(day)}'),
        type: QuestEventType.bonus,
        at: now,
        diamonds: config.streakBonusDiamonds,
        payload: {'reason': 'streak', 'days': streak},
      );
    }
    for (final e in config.streakTitles.entries) {
      if (streak >= e.key) await _awardTitle(e.value, now);
    }
    return out;
  }

  /// Автодисциплина: баланс < 0 → вкл.; авто — выкл. при ≥ 0; ручная — при > 0 и не раньше срока.
  Future<List<GameOutcome>> _checkDiscipline(DateTime now) async {
    final events = await _events();
    final state = _discipline(events);
    final balance = events.fold<int>(0, (s, e) => s + e.diamonds);
    if (!state.active && balance < 0) {
      await _addEvent(type: QuestEventType.disciplineOn, at: now, payload: {'reason': 'debt', 'auto': true});
      await _ensureDay(_dayOf(now));
      return const [DisciplineChanged(active: true)];
    }
    if (state.active) {
      final since = state.since ?? now;
      final off = state.auto
          ? balance >= 0
          : balance > 0 && now.difference(since) >= config.manualDisciplineMin;
      if (off) {
        await _addEvent(
          type: QuestEventType.disciplineOff,
          at: now,
          payload: {'exit': 'balancePositive', 'auto': true},
        );
        return const [DisciplineChanged(active: false)];
      }
    }
    return const [];
  }

  /// Рост уровня после начислений → LevelUp (ранг и титул, если сменились).
  Future<List<GameOutcome>> _afterXp(({int level, PlayerRank rank}) before, DateTime now) async {
    final after = await _levelState();
    if (after.level <= before.level) return const [];
    String? title;
    for (final t in rules.levelTitlesBetween(before.level, after.level)) {
      if (await _awardTitle(t, now)) title = t;
    }
    final spent = await _countEvents(QuestEventType.statPointSpent);
    return [
      LevelUp(
        level: after.level,
        freeStatPoints: rules.freeStatPoints(after.level, spent),
        rank: after.rank != before.rank ? after.rank : null,
        titleKey: title,
      ),
    ];
  }

  // ================= Внутреннее: шаблоны и экземпляры =================

  /// Экземпляры дня по шаблонам. Прошлые дни — только из tick ([allowPast]), чтобы просмотр
  /// истории не создавал «провалы» за дни до установки.
  Future<void> _ensureDay(DateTime day, {bool allowPast = false}) async {
    final today = _dayOf(_clock());
    if (day.isBefore(today) && !allowPast) return;
    if (!day.isAfter(today) && _discipline(await _events()).active) {
      final list = _disciplineQuests(day);
      for (var i = 0; i < list.length; i++) {
        await _insertQuest(_sid('disc:${_dayKey(day)}:$i'), list[i], ignoreExisting: true);
      }
    }
    final schedule = await _scheduleConfig();
    final week = ScheduleLogic.weekNumber(day, schedule);
    final templates = await (_db.select(_db.quests)
          ..where((t) => t.active & t.deletedAt.isNull() & t.kind.equals(QuestKind.boss.name).not()))
        .get();
    for (final q in templates) {
      if (_occurs(q, day, week)) await _insertInstance(q, day);
    }
  }

  bool _occurs(QuestRow q, DateTime day, int week) => GameRules.occursOn(
        day: day,
        weekNumber: week,
        weekdays: _parseWeekdays(q.weekdays),
        weekParity: q.weekParity,
        activeFrom: q.activeFrom,
        activeUntil: q.activeUntil,
      );

  /// Босс недели: если на неделю его нет — из главной цели (Goals) или «закрой N квестов».
  Future<void> _ensureBoss(DateTime monday) async {
    final questId = _sid('boss:${_dayKey(monday)}');
    var quest = await _quest(questId);
    if (quest == null) {
      final goals = await (_db.select(_db.goals)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.priority), (t) => OrderingTerm(expression: t.sortOrder)]))
          .get();
      final schedule = await _scheduleConfig();
      final templates = await (_db.select(_db.quests)
            ..where((t) =>
                t.active &
                t.deletedAt.isNull() &
                t.kind.isNotIn([QuestKind.boss.name, QuestKind.penalty.name, QuestKind.discipline.name])))
          .get();
      int expected(StatKind? stat) {
        var n = 0;
        for (var d = monday; d.isBefore(_addDays(monday, 7)); d = _addDays(d, 1)) {
          final week = ScheduleLogic.weekNumber(d, schedule);
          for (final q in templates) {
            final matches = stat == null || q.stat == stat.name || _decodeStats(q.rewardStats).containsKey(stat);
            if (matches && _occurs(q, d, week)) n++;
          }
        }
        return n;
      }

      var stat = SystemQuests.bossStatForGoal(enumByName(GoalKind.values, goals.firstOrNull?.kind));
      var n = expected(stat);
      if (n == 0 && stat != null) {
        stat = null;
        n = expected(null);
      }
      if (n == 0) return; // квестов нет — босса не из чего собрать, попробуем при следующей проверке
      await _insertQuest(
        questId,
        SystemQuests.boss(monday, stat: stat, target: SystemQuests.bossTarget(n, config: config), config: config),
      );
      quest = await _quest(questId);
    }
    if (quest == null || !quest.active || quest.deletedAt != null) return;
    final (_, deadline) = GameRules.instanceTimes(_addDays(monday, 6), null, 0);
    await _insertInstance(quest, monday, deadline: deadline);
  }

  Future<(QuestInstanceRow, QuestRow)?> _bossInstance(DateTime monday) async {
    final r = await (_joined()
          ..where(_db.questInstances.day.equals(monday) &
              _db.questInstances.deletedAt.isNull() &
              _db.quests.kind.equals(QuestKind.boss.name)))
        .get();
    final first = r.firstOrNull;
    return first == null ? null : (first.readTable(_db.questInstances), first.readTable(_db.quests));
  }

  Future<void> _insertInstance(QuestRow q, DateTime day, {DateTime? deadline}) async {
    final (starts, dl) = GameRules.instanceTimes(day, q.minute, q.windowMinutes);
    final fail = q.penaltyDiamonds;
    await _db.into(_db.questInstances).insert(
          QuestInstancesCompanion.insert(
            id: _instanceId(q.id, day),
            updatedAt: _clock().toUtc(),
            deviceId: await _deviceId(),
            questId: q.id,
            day: day,
            startsAt: Value(starts),
            deadlineAt: deadline ?? dl,
            rewardDiamonds: Value(q.rewardDiamonds),
            rewardXp: Value(q.rewardXp),
            rewardStats: Value(_instanceStatsJson(q)),
            penaltyDiamonds: Value(fail),
            refusePenaltyDiamonds: Value(rules.refusePenalty(fail, q.refusePenaltyDiamonds)),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  String _instanceStatsJson(QuestRow q) =>
      _encodeStats(rules.questStats(enumByName(StatKind.values, q.stat), _decodeStats(q.rewardStats)));

  Future<void> _insertQuest(String id, QuestInput input, {String? planId, bool ignoreExisting = false}) async {
    await _db.into(_db.quests).insert(
          _questCompanion(input).copyWith(
            id: Value(id),
            updatedAt: Value(_clock().toUtc()),
            deviceId: Value(await _deviceId()),
            version: const Value(1),
            planId: Value(planId),
          ),
          mode: ignoreExisting ? InsertMode.insertOrIgnore : InsertMode.insert,
        );
  }

  QuestsCompanion _questCompanion(QuestInput i) => QuestsCompanion(
        kind: Value(i.kind.name),
        stat: Value(i.stat?.name),
        titleKey: Value(i.title.key),
        title: Value(i.title.text),
        params: Value(jsonEncode(i.title.params)),
        subtasks: Value(jsonEncode(i.subtasks)),
        minute: Value(i.minute),
        windowMinutes: Value(i.windowMinutes),
        weekdays: Value(i.weekdays.join(',')),
        weekParity: Value(i.weekParity),
        activeFrom: Value(i.activeFrom == null ? null : _dayOf(i.activeFrom!)),
        activeUntil: Value(i.activeUntil == null ? null : _dayOf(i.activeUntil!)),
        rewardDiamonds: Value(i.reward.diamonds),
        rewardXp: Value(i.reward.xp),
        rewardStats: Value(_encodeStats(i.reward.stats)),
        penaltyDiamonds: Value(i.penaltyDiamonds),
        refusePenaltyDiamonds: Value(i.refusePenaltyDiamonds),
        confirm: Value(i.confirm.name),
        target: Value(i.target),
        nag: Value(i.nag),
        cancellable: Value(i.cancellable),
        source: Value(i.source.name),
        active: const Value(true),
      );

  /// Архив шаблонов: неактивны, незакрытые экземпляры с сегодняшнего дня мягко удаляются.
  Future<void> _archive(List<String> ids) async {
    if (ids.isEmpty) return;
    final now = _clock();
    final dev = await _deviceId();
    await (_db.update(_db.quests)..where((t) => t.id.isIn(ids))).write(QuestsCompanion.custom(
      active: const Constant(false),
      updatedAt: Variable(now.toUtc()),
      deviceId: Variable(dev),
      version: _db.quests.version + const Constant(1),
    ));
    await (_db.update(_db.questInstances)
          ..where((t) =>
              t.questId.isIn(ids) &
              t.status.equals(QuestStatus.pending.name) &
              t.deletedAt.isNull() &
              t.day.isBiggerOrEqualValue(_dayOf(now))))
        .write(QuestInstancesCompanion.custom(
      deletedAt: Variable(now.toUtc()),
      updatedAt: Variable(now.toUtc()),
      deviceId: Variable(dev),
      version: _db.questInstances.version + const Constant(1),
    ));
  }

  /// pending → [status]. false — уже закрыт (другим вызовом или isolate).
  Future<bool> _resolve(QuestInstanceRow inst, QuestStatus status, DateTime now) async {
    final n = await (_db.update(_db.questInstances)
          ..where((t) => t.id.equals(inst.id) & t.status.equals(QuestStatus.pending.name)))
        .write(QuestInstancesCompanion.custom(
      status: Variable(status.name),
      resolvedAt: Variable(now),
      updatedAt: Variable(_clock().toUtc()),
      deviceId: Variable(await _deviceId()),
      version: _db.questInstances.version + const Constant(1),
    ));
    return n > 0;
  }

  Future<void> _updateInstance(String id, QuestInstancesCompanion patch, {required int version}) async {
    await (_db.update(_db.questInstances)..where((t) => t.id.equals(id))).write(patch.copyWith(
      updatedAt: Value(_clock().toUtc()),
      deviceId: Value(await _deviceId()),
      version: Value(version + 1),
    ));
  }

  // ================= Внутреннее: журнал, эффекты, паузы =================

  Future<bool> _addEvent({
    String? id,
    required QuestEventType type,
    required DateTime at,
    String? questId,
    String? instanceId,
    int diamonds = 0,
    int xp = 0,
    Map<StatKind, int> stats = const {},
    Map<String, Object?> payload = const {},
  }) async {
    if (id != null && await _eventExists(id)) return false;
    await _db.into(_db.questEvents).insert(
          QuestEventsCompanion.insert(
            id: id ?? newId(),
            updatedAt: _clock().toUtc(),
            deviceId: await _deviceId(),
            type: type.name,
            occurredAt: at,
            questId: Value(questId),
            instanceId: Value(instanceId),
            diamonds: Value(diamonds),
            xp: Value(math.max(0, xp)),
            stats: Value(_encodeStats(stats)),
            payload: Value(jsonEncode(payload)),
          ),
          mode: id != null ? InsertMode.insertOrIgnore : InsertMode.insert,
        );
    return true;
  }

  Future<bool> _eventExists(String id) async =>
      await (_db.select(_db.questEvents)..where((t) => t.id.equals(id))).getSingleOrNull() != null;

  Future<int> _countEvents(QuestEventType type) async {
    final c = _db.questEvents.id.count();
    final q = _db.selectOnly(_db.questEvents)
      ..addColumns([c])
      ..where(_db.questEvents.type.equals(type.name) & _db.questEvents.deletedAt.isNull());
    return (await q.getSingle()).read(c) ?? 0;
  }

  /// Титул выдаётся один раз (детерминированный id события). true — выдан сейчас.
  Future<bool> _awardTitle(String key, DateTime now) =>
      _addEvent(id: _sid('title:$key'), type: QuestEventType.bonus, at: now, payload: {'title': key});

  Future<List<QuestEventRow>> _events() =>
      (_db.select(_db.questEvents)..where((t) => t.deletedAt.isNull())).get();

  Future<int> _balance() async {
    final s = _db.questEvents.diamonds.sum();
    final q = _db.selectOnly(_db.questEvents)
      ..addColumns([s])
      ..where(_db.questEvents.deletedAt.isNull());
    return (await q.getSingle()).read(s) ?? 0;
  }

  Future<({int level, PlayerRank rank})> _levelState() async {
    final s = _db.questEvents.xp.sum();
    final q = _db.selectOnly(_db.questEvents)
      ..addColumns([s])
      ..where(_db.questEvents.deletedAt.isNull());
    final level = rules.levelFor((await q.getSingle()).read(s) ?? 0).level;
    return (level: level, rank: rules.rankFor(level));
  }

  ({bool active, bool auto, DateTime? since}) _discipline(List<QuestEventRow> events) {
    final list = events
        .where((e) => e.type == QuestEventType.disciplineOn.name || e.type == QuestEventType.disciplineOff.name)
        .toList()
      ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    final last = list.lastOrNull;
    if (last == null || last.type == QuestEventType.disciplineOff.name) {
      return (active: false, auto: false, since: null);
    }
    return (active: true, auto: _decodeMap(last.payload)['auto'] == true, since: last.occurredAt);
  }

  Future<void> _addEffect(
    String id,
    String kind,
    DateTime startsAt, {
    DateTime? expiresAt,
    String? sourceEventId,
  }) async {
    final def = config.effects[kind];
    if (def == null) return;
    await _db.into(_db.effects).insert(
          EffectsCompanion.insert(
            id: id,
            updatedAt: _clock().toUtc(),
            deviceId: await _deviceId(),
            kind: kind,
            startsAt: startsAt,
            expiresAt: expiresAt ?? startsAt.add(def.duration),
            sourceEventId: Value(sourceEventId),
            payload: Value(jsonEncode(def.params)),
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<List<EffectRow>> _effectRows(DateTime now) => (_db.select(_db.effects)
        ..where((t) =>
            t.deletedAt.isNull() & t.startsAt.isSmallerOrEqualValue(now) & t.expiresAt.isBiggerThanValue(now)))
      .get();

  /// Активные эффекты (по одному на вид — с самым поздним окончанием).
  Future<List<ActiveEffect>> _activeEffects(DateTime now) async {
    final byKind = <String, EffectRow>{};
    for (final e in await _effectRows(now)) {
      final prev = byKind[e.kind];
      if (prev == null || e.expiresAt.isAfter(prev.expiresAt)) byKind[e.kind] = e;
    }
    return [
      for (final e in byKind.values)
        ActiveEffect(
          id: e.id,
          kind: e.kind,
          isBuff: config.effects[e.kind]?.isBuff ?? true,
          startsAt: e.startsAt,
          expiresAt: e.expiresAt,
          params: {...config.effects[e.kind]?.params ?? const {}, ..._decodeMap(e.payload)},
        ),
    ]..sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
  }

  Future<List<EffectDef>> _activeEffectDefs(DateTime now) async =>
      [for (final e in await _activeEffects(now)) ?config.effects[e.kind]];

  Future<void> _expireEffects(DateTime now) async {
    await (_db.update(_db.effects)..where((t) => t.deletedAt.isNull() & t.expiresAt.isSmallerOrEqualValue(now)))
        .write(EffectsCompanion.custom(
      deletedAt: Variable(now.toUtc()),
      updatedAt: Variable(now.toUtc()),
      deviceId: Variable(await _deviceId()),
      version: _db.effects.version + const Constant(1),
    ));
  }

  Future<List<PauseRow>> _pauses() => (_db.select(_db.pauses)..where((t) => t.deletedAt.isNull())).get();

  static bool _pauseCovers(PauseRow p, DateTime t) =>
      !p.startsAt.isAfter(t) && (p.endsAt == null || t.isBefore(p.endsAt!));

  static bool _pauseOverlaps(PauseRow p, DateTime from, DateTime to) =>
      p.startsAt.isBefore(to) && (p.endsAt == null || p.endsAt!.isAfter(from));

  bool _dayPaused(List<PauseRow> pauses, DateTime day) =>
      pauses.any((p) => _pauseOverlaps(p, day, _addDays(day, 1)));

  Future<bool> _pausedAt(DateTime t) async => (await _pauses()).any((p) => _pauseCovers(p, t));

  /// Закрыть активные паузы моментом [now]. Возвращает число закрытых.
  Future<int> _closePauses(DateTime now) async {
    final active = (await _pauses()).where((p) => _pauseCovers(p, now)).toList();
    for (final p in active) {
      await (_db.update(_db.pauses)..where((t) => t.id.equals(p.id))).write(PausesCompanion(
        endsAt: Value(now),
        updatedAt: Value(now.toUtc()),
        deviceId: Value(await _deviceId()),
        version: Value(p.version + 1),
      ));
    }
    return active.length;
  }

  /// Итоги дней [from, to) по экземплярам (босс не считается).
  Future<Map<DateTime, DayTally>> _tallies(DateTime from, DateTime to) async {
    final rows = await (_joined()
          ..where(_db.questInstances.deletedAt.isNull() &
              _db.questInstances.day.isBiggerOrEqualValue(from) &
              _db.questInstances.day.isSmallerThanValue(to) &
              _db.quests.kind.equals(QuestKind.boss.name).not()))
        .get();
    final raw = <DateTime, List<int>>{};
    for (final r in rows) {
      final i = r.readTable(_db.questInstances);
      final t = raw.putIfAbsent(_dayOf(i.day), () => [0, 0, 0, 0]);
      t[0]++;
      if (i.status == QuestStatus.done.name) t[1]++;
      if (i.status == QuestStatus.failed.name) t[2]++;
      if (i.status == QuestStatus.excused.name) t[3]++;
    }
    return {
      for (final e in raw.entries)
        e.key: DayTally(total: e.value[0], done: e.value[1], failed: e.value[2], excused: e.value[3]),
    };
  }

  Future<int> _streak(DateTime today, List<PauseRow> pauses) async {
    final tallies = await _tallies(_addDays(today, -400), _addDays(today, 1));
    return rules.streakDays(today: today, tallies: tallies, isPaused: (d) => _dayPaused(pauses, d));
  }

  Future<ScheduleConfig> _scheduleConfig() async => ScheduleConfig.fromRow(await (_db.select(_db.scheduleSettings)
        ..where((t) => t.id.equals('main') & t.deletedAt.isNull()))
      .getSingleOrNull());

  // ================= Внутреннее: чтение строк =================

  JoinedSelectStatement<HasResultSet, dynamic> _joined() => _db.select(_db.questInstances).join([
        innerJoin(_db.quests, _db.quests.id.equalsExp(_db.questInstances.questId)),
      ]);

  Future<QuestInstanceRow?> _instance(String id) =>
      (_db.select(_db.questInstances)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();

  Future<QuestInstanceRow> _requireInstance(String id) async =>
      await _instance(id) ?? (throw StateError('Нет экземпляра квеста $id'));

  Future<QuestRow?> _quest(String id) => (_db.select(_db.quests)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<QuestRow> _requireQuest(String id) async => await _quest(id) ?? (throw StateError('Нет квеста $id'));

  Future<QuestItem> _item(String instanceId) async {
    final inst = await _requireInstance(instanceId);
    return _toItem(inst, await _requireQuest(inst.questId));
  }

  QuestItem _itemOf(TypedResult r) => _toItem(r.readTable(_db.questInstances), r.readTable(_db.quests));

  QuestItem _toItem(QuestInstanceRow i, QuestRow q) {
    final names = [for (final s in _decodeList(q.subtasks)) '$s'];
    final done = {for (final d in _decodeList(i.subtasksDone)) ?(d is num ? d.toInt() : null)};
    return QuestItem(
      instanceId: i.id,
      questId: q.id,
      kind: enumByName(QuestKind.values, q.kind) ?? QuestKind.custom,
      stat: enumByName(StatKind.values, q.stat),
      title: _titleOf(q),
      day: i.day,
      startsAt: i.startsAt,
      deadlineAt: i.deadlineAt,
      snoozedUntil: i.snoozedUntil,
      status: enumByName(QuestStatus.values, i.status) ?? QuestStatus.pending,
      reward: GameReward(diamonds: i.rewardDiamonds, xp: i.rewardXp, stats: _decodeStats(i.rewardStats)),
      penaltyDiamonds: i.penaltyDiamonds,
      refusePenaltyDiamonds: i.refusePenaltyDiamonds,
      subtasks: [for (var k = 0; k < names.length; k++) Subtask(title: names[k], done: done.contains(k))],
      progress: i.progress,
      target: q.target,
      confirm: enumByName(ConfirmMethod.values, q.confirm) ?? ConfirmMethod.button,
      nag: q.nag,
      cancellable: q.cancellable,
      source: enumByName(QuestSource.values, q.source) ?? QuestSource.user,
    );
  }

  QuestTitle _titleOf(QuestRow q) => QuestTitle(key: q.titleKey, text: q.title, params: _decodeMap(q.params));

  static DateTime _nextAt(QuestItem i) => i.snoozedUntil ?? i.startsAt ?? i.deadlineAt;

  static List<QuestItem> _sorted(Iterable<QuestItem> items) => items.toList()
    ..sort((a, b) {
      final c = a.day.compareTo(b.day);
      if (c != 0) return c;
      // Со временем — по началу, «в течение дня» — в конце.
      final sa = a.startsAt;
      final sb = b.startsAt;
      if (sa != null && sb != null) return sa.compareTo(sb);
      if (sa != null) return -1;
      if (sb != null) return 1;
      return a.deadlineAt.compareTo(b.deadlineAt);
    });

  Future<String> _deviceId() async => _dev ??= await _db.deviceId();

  // ================= Утилиты =================

  static const _uuid = Uuid();

  /// Детерминированный UUID записи по ключу (одинаков на всех устройствах).
  static String _sid(String key) => _uuid.v5(Namespace.url.value, 'sistema:quests:$key');

  static String _instanceId(String questId, DateTime day) => _sid('inst:$questId:${_dayKey(day)}');

  static DateTime _dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

  static DateTime _addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

  static String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static List<int> _parseWeekdays(String raw) => [
        for (final p in raw.split(','))
          if (int.tryParse(p.trim()) case final d? when d >= 1 && d <= 7) d,
      ];

  static Map<String, Object?> _decodeMap(String raw) {
    try {
      final v = jsonDecode(raw);
      return v is Map<String, Object?> ? v : const {};
    } on FormatException {
      return const {};
    }
  }

  static List<Object?> _decodeList(String raw) {
    try {
      final v = jsonDecode(raw);
      return v is List ? v.cast<Object?>() : const [];
    } on FormatException {
      return const [];
    }
  }

  static Map<StatKind, int> _decodeStats(String raw) => {
        for (final e in _decodeMap(raw).entries)
          if (enumByName(StatKind.values, e.key) case final k? when e.value is num) k: (e.value! as num).toInt(),
      };

  static String _encodeStats(Map<StatKind, int> stats) =>
      jsonEncode({for (final e in stats.entries) if (e.value != 0) e.key.name: e.value});
}
