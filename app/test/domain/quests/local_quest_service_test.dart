import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/quests/game_rules.dart';
import 'package:sistema/domain/quests/local_quest_service.dart';
import 'package:sistema/domain/quests/quest_api.dart';
import 'package:sistema/domain/quests/system_quests.dart';
import 'package:sistema/features/plan/model/plan.dart';

import '../../helpers/test_db.dart';

/// Ср, 21.10.2026.
final _wed = DateTime(2026, 10, 21);

QuestInput _quest({
  int diamonds = 10,
  int xp = 10,
  int penalty = 10,
  int? minute,
  StatKind? stat = StatKind.discipline,
  QuestKind kind = QuestKind.daily,
  bool cancellable = true,
  int weekParity = 0,
  List<int> weekdays = const [],
  String text = 'Квест',
  int? target,
}) =>
    QuestInput(
      kind: kind,
      title: QuestTitle(text: text),
      stat: stat,
      minute: minute,
      reward: GameReward(diamonds: diamonds, xp: xp),
      penaltyDiamonds: penalty,
      cancellable: cancellable,
      weekParity: weekParity,
      weekdays: weekdays,
      target: target,
    );

void main() {
  late AppDatabase db;
  late DateTime now;
  late LocalQuestService s;
  var discipline = <QuestInput>[];

  LocalQuestService make() => LocalQuestService(db, clock: () => now, disciplineQuests: (_) => discipline);

  setUp(() {
    db = memoryDb();
    now = _wed.add(const Duration(hours: 8));
    discipline = [];
    s = make();
  });
  tearDown(() async {
    await s.dispose();
    await db.close();
  });

  Future<List<QuestItem>> day([DateTime? d]) => s.watchDay(d ?? now).first;
  Future<PlayerSnapshot> player() => s.snapshot();
  DateTime at(int dayOffset, int hour, [int minute = 0]) =>
      DateTime(_wed.year, _wed.month, _wed.day + dayOffset, hour, minute);

  test('выполнение: награда из журнала, повтор не начисляет', () async {
    await s.createQuest(_quest(diamonds: 12, xp: 30));
    final items = await day();
    expect(items, hasLength(1));
    final out = await s.complete(items.single.instanceId);
    expect(out.whereType<QuestCompleted>().single.reward.diamonds, 12);
    expect(await s.complete(items.single.instanceId), isEmpty);
    final p = await player();
    expect(p.diamonds, 12);
    expect(p.xp, 30);
    expect(p.stats[StatKind.discipline], GameConfig.standard.baseStat + 1);
    expect(p.statDeltaToday[StatKind.discipline], 1);
    final events = await db.select(db.questEvents).get();
    expect(events, hasLength(1));
    expect(events.single.deviceId, await db.deviceId());
    expect((await day()).single.status, QuestStatus.done);
  });

  test('отказ дороже нуля, но дешевле провала', () async {
    await s.createQuest(_quest(penalty: 10, minute: 9 * 60, text: 'A'));
    await s.createQuest(_quest(penalty: 10, minute: 9 * 60, text: 'B'));
    await s.tick(now);
    final items = await day();
    final refused = await s.refuse(items.first.instanceId);
    final refusePenalty = refused.whereType<QuestRefused>().single.penaltyDiamonds;
    expect(refusePenalty, greaterThan(0));
    final balanceAfterRefuse = (await player()).diamonds;
    expect(balanceAfterRefuse, -refusePenalty);

    now = at(0, 12);
    final out = await s.tick(now);
    final failed = out.whereType<QuestFailed>().single;
    expect(failed.penaltyDiamonds, 10);
    expect(refusePenalty, lessThan(failed.penaltyDiamonds));
    expect((await player()).diamonds, balanceAfterRefuse - 10);
  });

  test('штрафной квест нельзя отменить', () async {
    await s.createQuest(_quest(kind: QuestKind.penalty, cancellable: false));
    final item = (await day()).single;
    expect(item.cancellable, isFalse);
    expect(() => s.refuse(item.instanceId), throwsStateError);
  });

  test('tick идемпотентен: провал и штраф один раз', () async {
    await s.createQuest(_quest(minute: 9 * 60, penalty: 7));
    await s.tick(now);
    now = at(0, 11);
    final first = await s.tick(now);
    expect(first.whereType<QuestFailed>(), hasLength(1));
    final second = await s.tick(now);
    expect(second.whereType<QuestFailed>(), isEmpty);
    // Другой экземпляр сервиса (фоновый isolate) — тоже без дублей.
    final other = make();
    expect((await other.tick(now)).whereType<QuestFailed>(), isEmpty);
    await other.dispose();
    expect((await player()).diamonds, -7);
    final failedEvents = await (db.select(db.questEvents)..where((t) => t.type.equals('failed'))).get();
    expect(failedEvents, hasLength(1));
  });

  test('пауза: провал без штрафа, серия не сгорает', () async {
    await s.createQuest(_quest(penalty: 10));
    // День 0 — выполнен.
    await s.tick(now);
    await s.complete((await day()).single.instanceId);
    // День 1 — болезнь, ничего не сделано.
    now = at(1, 0);
    await s.tick(now);
    await s.startPause(PauseReason.illness, until: at(2, 0), at: now);
    expect((await player()).pause?.reason, PauseReason.illness);
    // День 2 — выполнен.
    now = at(2, 9);
    final out = await s.tick(now);
    expect(out.whereType<QuestFailed>(), isEmpty);
    expect((await day(at(1, 0))).single.status, QuestStatus.excused);
    await s.complete((await day()).single.instanceId);
    final p = await player();
    expect(p.diamonds, 20, reason: 'штрафа за день паузы нет');
    expect(p.streakDays, 2);
    expect(p.pause, isNull);
  });

  test('серия ≥ 3 → «Бодрость» на следующий день и +5% опыта', () async {
    await s.createQuest(_quest(xp: 100, diamonds: 1));
    for (var i = 0; i < 3; i++) {
      now = at(i, 9);
      await s.tick(now);
      await s.complete((await day()).single.instanceId);
    }
    expect((await player()).streakDays, 3);
    now = at(3, 9);
    await s.tick(now);
    final p = await player();
    expect(p.effects.map((e) => e.kind), contains(EffectKinds.vigor));
    final out = await s.complete((await day()).single.instanceId);
    expect(out.whereType<QuestCompleted>().single.reward.xp, 105);
  });

  test('провал воды → «Обезвоживание»; эффект истекает', () async {
    await s.createQuest(QuestInput(
      kind: QuestKind.daily,
      title: const QuestTitle(key: 'water', params: {'ml': 2000}),
      stat: StatKind.health,
      reward: const GameReward(diamonds: 5),
      penaltyDiamonds: 5,
    ));
    await s.tick(now);
    now = at(1, 1);
    await s.tick(now);
    expect((await player()).effects.single.kind, EffectKinds.dehydration);
    expect((await player()).effects.single.isBuff, isFalse);
    // Воду дня 1 выпили — иначе её провал даст новое «Обезвоживание».
    await s.complete((await day()).single.instanceId);
    now = at(2, 2);
    await s.tick(now);
    expect((await player()).effects.where((e) => e.kind == EffectKinds.dehydration), isEmpty);
  });

  test('2 провала за день → штрафной квест на завтра', () async {
    await s.createQuest(_quest(minute: 9 * 60, text: 'A'));
    await s.createQuest(_quest(minute: 9 * 60, text: 'B'));
    await s.tick(now);
    now = at(1, 8);
    final out = await s.tick(now);
    expect(out.whereType<QuestFailed>(), hasLength(2));
    final penalty = out.whereType<PenaltyApplied>().single;
    expect(penalty.reasonKey, PenaltyReasons.failedQuests);
    final pq = penalty.penaltyQuest!;
    expect(pq.kind, QuestKind.penalty);
    expect(pq.cancellable, isFalse);
    expect(pq.day, at(1, 0));
    expect(() => s.refuse(pq.instanceId), throwsStateError);
    expect((await s.tick(now)).whereType<PenaltyApplied>(), isEmpty);
  });

  test('покупка: нет при нехватке и при минусе, есть при достатке', () async {
    expect(await s.purchase(rewardId: 'r1', title: 'Шоколадка', price: 10), isFalse);
    await s.createQuest(_quest(diamonds: 15));
    await s.complete((await day()).single.instanceId);
    expect(await s.purchase(rewardId: 'r1', title: 'Шоколадка', price: 20), isFalse);
    expect(await s.purchase(rewardId: 'r1', title: 'Шоколадка', price: 10), isTrue);
    expect((await player()).diamonds, 5);
    final ev = await (db.select(db.questEvents)..where((t) => t.type.equals('purchase'))).getSingle();
    expect(ev.diamonds, -10);
    expect(ev.payload, contains('r1'));

    await s.markDay(DayMark.relapse); // −8 → баланс −3
    expect((await player()).inDebt, isTrue);
    expect(await s.purchase(rewardId: 'r2', title: 'Игры', price: 0), isFalse);
  });

  test('автодисциплина: минус → вкл. (с квестами D), снова ≥ 0 → выкл.', () async {
    discipline = [
      const QuestInput(
        kind: QuestKind.discipline,
        title: QuestTitle(key: 'dscQuestWake', params: {'time': '06:00'}),
        minute: 6 * 60,
        cancellable: false,
        source: QuestSource.system,
      ),
    ];
    await s.createQuest(_quest(minute: 9 * 60, penalty: 10, text: 'A'));
    await s.tick(now);
    now = at(0, 11);
    final on = await s.tick(now);
    expect(on.whereType<DisciplineChanged>().single.active, isTrue);
    expect((await player()).disciplineActive, isTrue);
    expect((await day()).where((q) => q.kind == QuestKind.discipline), hasLength(1));
    expect((await s.tick(now)).whereType<DisciplineChanged>(), isEmpty);

    await s.createQuest(_quest(diamonds: 10, text: 'B'));
    final b = (await day()).firstWhere((q) => q.title.text == 'B');
    await s.complete(b.instanceId);
    final off = await s.tick(now);
    expect(off.whereType<DisciplineChanged>().single.active, isFalse);
    expect((await player()).disciplineActive, isFalse);
  });

  test('ручная дисциплина: при плюсе держится срок, потом выкл.; outcomes транслируются', () async {
    final seen = <GameOutcome>[];
    final sub = s.outcomes.listen(seen.add);
    await s.createQuest(_quest(diamonds: 10));
    await s.complete((await day()).single.instanceId);
    await s.setDiscipline(active: true, reasonKey: 'ai');
    expect((await s.tick(now)).whereType<DisciplineChanged>(), isEmpty);
    expect((await player()).disciplineActive, isTrue);
    now = at(1, 9);
    final out = await s.tick(now);
    expect(out.whereType<DisciplineChanged>().single.active, isFalse);
    await pumpEventQueue();
    expect(seen.whereType<QuestCompleted>(), hasLength(1));
    expect(seen.whereType<DisciplineChanged>().map((e) => e.active), [true, false]);
    await sub.cancel();
  });

  test('импорт плана: категории → характеристики, повторный импорт заменяет', () async {
    final drafts = [
      const QuestDraft(
        key: QuestKey.training,
        category: QuestCategory.training,
        params: {'minutes': 40},
        minute: 18 * 60,
        diamonds: 15,
        xp: 25,
      ),
      const QuestDraft(key: QuestKey.water, category: QuestCategory.daily, params: {'ml': 2000}, diamonds: 5, xp: 10),
      const QuestDraft(key: QuestKey.study, category: QuestCategory.goal, params: {'minutes': 30}, diamonds: 10, xp: 20),
    ];
    await s.importPlanQuests(planId: 'p1', drafts: [for (final d in drafts) d.toJson()]);
    var items = await day();
    expect(items, hasLength(3));
    final training = items.firstWhere((q) => q.title.key == 'training');
    expect(training.stat, StatKind.strength);
    expect(training.reward.stats, {StatKind.strength: 1, StatKind.endurance: 1});
    expect(training.title.params['minute'], 18 * 60);
    expect(training.startsAt, at(0, 18));
    expect(training.penaltyDiamonds, 15);
    expect(training.refusePenaltyDiamonds, inExclusiveRange(0, 15));
    expect(training.source, QuestSource.plan);
    expect(items.firstWhere((q) => q.title.key == 'study').stat, StatKind.intellect);
    expect(items.firstWhere((q) => q.title.key == 'water').target, 2000);

    await s.importPlanQuests(planId: 'p2', drafts: [drafts[1].toJson()]);
    items = await day();
    expect(items.single.title.key, 'water');
    final active = await (db.select(db.quests)..where((t) => t.active)).get();
    expect(active.single.planId, 'p2');
  });

  test('чередование недель: квест «неделя 2» только во вторую', () async {
    await db.into(db.scheduleSettings).insert(ScheduleSettingsCompanion.insert(
          id: 'main',
          updatedAt: DateTime.now().toUtc(),
          deviceId: 'd',
          alternationEnabled: const Value(true),
          week1Anchor: Value(DateTime(2026, 10, 19)),
        ));
    await s.createQuest(_quest(weekParity: 2, text: 'W2'));
    await s.createQuest(_quest(weekParity: 1, text: 'W1'));
    expect((await day()).single.title.text, 'W1');
    expect((await day(at(7, 0))).single.title.text, 'W2');
    expect((await day(at(14, 0))).single.title.text, 'W1');
  });

  test('уровень: LevelUp, очки характеристик и их трата', () async {
    await s.createQuest(_quest(xp: 150, stat: StatKind.strength));
    final out = await s.complete((await day()).single.instanceId);
    final up = out.whereType<LevelUp>().single;
    expect(up.level, 2);
    expect(up.freeStatPoints, GameConfig.standard.statPointsPerLevel);
    expect(up.rank, isNull);
    final before = (await player()).stats[StatKind.looks]!;
    await s.spendStatPoint(StatKind.looks);
    final p = await player();
    expect(p.stats[StatKind.looks], before + 1);
    expect(p.freeStatPoints, GameConfig.standard.statPointsPerLevel - 1);
    expect(p.xpIntoLevel, 50);
    await s.spendStatPoint(StatKind.looks);
    await s.spendStatPoint(StatKind.looks);
    expect(() => s.spendStatPoint(StatKind.looks), throwsStateError);
  });

  test('отметка дня: мягкий штраф один раз, усиленный план на завтра', () async {
    final out = await s.markDay(DayMark.alcohol);
    final pen = out.whereType<PenaltyApplied>().single;
    expect(pen.reasonKey, PenaltyReasons.markAlcohol);
    expect(pen.diamonds, GameConfig.standard.markPenalty[DayMark.alcohol]);
    expect(await s.markDay(DayMark.alcohol), isEmpty);
    expect((await player()).diamonds, -pen.diamonds);
    expect(await day(), isEmpty);
    final tomorrow = await day(at(1, 0));
    expect(tomorrow.length, inInclusiveRange(1, 2));
    expect(tomorrow.map((q) => q.title.key), contains(SystemQuestKey.boostBedOnTime.name));
    expect(tomorrow.every((q) => q.kind != QuestKind.penalty), isTrue);
  });

  test('+10 мин: сдвиг дедлайна, лимит откладываний', () async {
    await s.createQuest(_quest(minute: 8 * 60));
    final q = (await day()).single;
    await s.snooze(q.instanceId, at: now);
    var after = (await day()).single;
    expect(after.deadlineAt, q.deadlineAt.add(const Duration(minutes: 10)));
    expect(after.snoozedUntil, now.add(const Duration(minutes: 10)));
    for (var i = 0; i < 5; i++) {
      await s.snooze(q.instanceId, at: now);
    }
    after = (await day()).single;
    expect(after.deadlineAt, q.deadlineAt.add(Duration(minutes: 10 * GameConfig.standard.maxSnoozes)));
  });

  test('upcoming и watchNext: по началу/дедлайну в окне', () async {
    await s.createQuest(_quest(minute: 9 * 60, text: 'Скоро'));
    await s.createQuest(_quest(minute: 20 * 60, text: 'Вечером'));
    final soon = await s.upcoming(now, const Duration(hours: 2));
    expect(soon.map((q) => q.title.text), ['Скоро']);
    final next = await s.watchNext(now).first;
    expect(next?.title.text, 'Скоро');
  });

  test('подзадачи и прогресс до цели', () async {
    await s.createQuest(QuestInput(
      kind: QuestKind.custom,
      title: const QuestTitle(text: 'Шаги'),
      subtasks: const ['Утро', 'Вечер'],
      target: 100,
      reward: const GameReward(diamonds: 3),
    ));
    final q = (await day()).single;
    await s.toggleSubtask(q.instanceId, 1, true);
    expect((await day()).single.subtasks.map((t) => t.done), [false, true]);
    expect(await s.addProgress(q.instanceId, 60), isEmpty);
    final out = await s.addProgress(q.instanceId, 50);
    expect(out.whereType<QuestCompleted>(), hasLength(1));
    expect((await day()).single.progress, 110);
  });

  test('босс недели: цель из квестов недели, победа и титул; провал в конце недели', () async {
    now = DateTime(2026, 10, 19, 8); // понедельник
    await s.createQuest(_quest(diamonds: 1, xp: 1));
    var week = await s.watchWeek(now).first;
    final boss = week.singleWhere((q) => q.kind == QuestKind.boss);
    expect(boss.day, DateTime(2026, 10, 19));
    expect(boss.target, 5, reason: '7 квестов · 0.7 = 5');
    expect(boss.deadlineAt, DateTime(2026, 10, 26));

    BossResult? win;
    for (var i = 0; i < 5; i++) {
      now = DateTime(2026, 10, 19 + i, 9);
      await s.tick(now);
      final out = await s.complete((await day()).single.instanceId);
      win ??= out.whereType<BossResult>().firstOrNull;
    }
    expect(win, isNotNull);
    expect(win!.won, isTrue);
    expect(win.titleKey, GameTitles.bossSlayer);
    expect(win.reward.diamonds, GameConfig.standard.bossReward.diamonds);
    final p = await player();
    expect(p.titleKey, GameTitles.bossSlayer);
    expect(p.effects.map((e) => e.kind), contains(EffectKinds.bossAura));

    // Следующая неделя: босс не побеждён → итог после конца недели.
    now = DateTime(2026, 10, 26, 8);
    await s.tick(now);
    week = await s.watchWeek(now).first;
    expect(week.where((q) => q.kind == QuestKind.boss).single.status, QuestStatus.pending);
    now = DateTime(2026, 11, 2, 8);
    final out = await s.tick(now);
    final lost = out.whereType<BossResult>().single;
    expect(lost.won, isFalse);
    expect(lost.reward.diamonds, -GameConfig.standard.bossPenalty);
    expect((await s.tick(now)).whereType<BossResult>(), isEmpty);
  });

  test('watchPlayer и watchHistory обновляются по журналу', () async {
    final snaps = <PlayerSnapshot>[];
    final sub = s.watchPlayer().listen(snaps.add);
    await s.createQuest(_quest(diamonds: 4));
    await s.complete((await day()).single.instanceId);
    await pumpEventQueue();
    expect(snaps.last.diamonds, 4);
    final history = await s.watchHistory().first;
    expect(history.single.type, QuestEventType.completed);
    expect(history.single.title?.text, 'Квест');
    expect(history.single.delta.diamonds, 4);
    await sub.cancel();
  });

  test('архив: квест больше не создаётся, незакрытый экземпляр удалён', () async {
    final id = await s.createQuest(_quest());
    expect(await day(), hasLength(1));
    await s.archiveQuest(id);
    expect(await day(), isEmpty);
    expect(await day(at(1, 0)), isEmpty);
  });
}
