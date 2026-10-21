import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/quests/game_rules.dart';
import 'package:sistema/domain/quests/quest_api.dart';
import 'package:sistema/domain/quests/system_quests.dart';
import 'package:sistema/features/plan/model/plan.dart';

const _rules = GameRules();

void main() {
  group('опыт и уровни', () {
    test('опыт до уровня растёт плавно', () {
      expect(_rules.xpToNext(1), 100);
      for (var n = 1; n < 60; n++) {
        final a = _rules.xpToNext(n);
        final b = _rules.xpToNext(n + 1);
        expect(b, greaterThan(a), reason: 'уровень $n');
        expect(b / a, lessThan(2.7), reason: 'без скачков, уровень $n');
      }
    });

    test('уровень по опыту, остаток и порог', () {
      expect(_rules.levelFor(0).level, 1);
      expect(_rules.levelFor(-50).level, 1);
      expect(_rules.levelFor(99).level, 1);
      final l2 = _rules.levelFor(100);
      expect(l2.level, 2);
      expect(l2.xpIntoLevel, 0);
      expect(l2.xpForNextLevel, _rules.xpToNext(2));
      final total10 = _rules.xpTotalFor(10);
      expect(_rules.levelFor(total10).level, 10);
      expect(_rules.levelFor(total10 - 1).level, 9);
      expect(_rules.levelFor(total10 + 5).xpIntoLevel, 5);
    });

    test('ранги E→S по уровню', () {
      expect(_rules.rankFor(1), PlayerRank.e);
      expect(_rules.rankFor(4), PlayerRank.e);
      expect(_rules.rankFor(5), PlayerRank.d);
      expect(_rules.rankFor(10), PlayerRank.c);
      expect(_rules.rankFor(20), PlayerRank.b);
      expect(_rules.rankFor(35), PlayerRank.a);
      expect(_rules.rankFor(50), PlayerRank.s);
      expect(_rules.rankFor(99), PlayerRank.s);
    });

    test('титулы за уровни в интервале', () {
      expect(_rules.levelTitlesBetween(1, 9), isEmpty);
      expect(_rules.levelTitlesBetween(9, 10), [GameTitles.level10]);
      expect(_rules.levelTitlesBetween(9, 30), containsAll([GameTitles.level10, GameTitles.level25]));
    });

    test('очки характеристик: за уровень, минус потраченные, не меньше 0', () {
      expect(_rules.freeStatPoints(1, 0), 0);
      expect(_rules.freeStatPoints(3, 0), 6);
      expect(_rules.freeStatPoints(3, 4), 2);
      expect(_rules.freeStatPoints(2, 10), 0);
    });

    test('характеристика квеста: своя награда или +1 к категории', () {
      expect(_rules.questStats(StatKind.health, const {}), {StatKind.health: 1});
      expect(_rules.questStats(StatKind.health, const {StatKind.strength: 2}), {StatKind.strength: 2});
      expect(_rules.questStats(null, const {}), isEmpty);
    });
  });

  group('штрафы', () {
    test('отказ: дороже 0 и дешевле провала', () {
      for (final fail in [2, 3, 5, 10, 15, 30, 100]) {
        final r = _rules.refusePenalty(fail);
        expect(r, greaterThan(0), reason: 'провал $fail');
        expect(r, lessThan(fail), reason: 'провал $fail');
      }
      expect(_rules.refusePenalty(0), 0);
      expect(_rules.refusePenalty(10, 7), 7, reason: 'заданный в шаблоне');
    });

    test('провал по умолчанию — от награды, не меньше минимума', () {
      expect(_rules.failPenaltyFor(10), 10);
      expect(_rules.failPenaltyFor(0), GameConfig.standard.minFailPenalty);
    });

    test('честная отметка мягче скрытого срыва (провалов на штрафной квест)', () {
      final hidden = GameConfig.standard.penaltyQuestAfterFails * _rules.failPenaltyFor(5);
      for (final m in DayMark.values) {
        expect(_rules.markPenalty(m), greaterThan(0));
        expect(_rules.markPenalty(m), lessThan(hidden), reason: m.name);
      }
    });

    test('штрафной квест — лёгкий, не отменяется, без урезания еды и сна', () {
      for (var i = 0; i < 10; i++) {
        final q = SystemQuests.penaltyFor(DateTime(2026, 10, 21 + i), level: 1);
        expect(q.kind, QuestKind.penalty);
        expect(q.cancellable, isFalse);
        expect(q.stat, isNot(StatKind.health));
        final key = enumByName(SystemQuestKey.values, q.title.key)!;
        expect(key.name, startsWith('penalty'));
        if (key == SystemQuestKey.penaltyPlank) expect(q.title.params['seconds'], 20);
      }
      final strong = SystemQuests.penaltyFor(DateTime(2026, 10, 23), level: 50);
      if (strong.title.key == SystemQuestKey.penaltyPlank.name) {
        expect(strong.title.params['seconds'], lessThanOrEqualTo(60));
      }
    });

    test('усиленный план: 1–2 квеста, отбой не позже обычного', () {
      for (final m in DayMark.values) {
        final list = SystemQuests.boostFor(m, DateTime(2026, 10, 22), bedMinute: 23 * 60);
        expect(list.length, inInclusiveRange(1, 2));
        for (final q in list) {
          expect(q.kind, isNot(QuestKind.penalty));
          if (q.title.key == SystemQuestKey.boostBedOnTime.name) {
            expect(q.title.params['minute'], 23 * 60);
            expect(q.minute! + q.windowMinutes, lessThanOrEqualTo(23 * 60 + 15));
          }
        }
      }
    });
  });

  group('эффекты', () {
    test('бафф опыта и дебафф характеристики меняют начисление', () {
      final c = GameConfig.standard;
      const base = GameReward(diamonds: 20, xp: 100, stats: {StatKind.endurance: 20, StatKind.strength: 1});
      final r = _rules.applyEffects(base, [c.effects[EffectKinds.vigor]!, c.effects[EffectKinds.dehydration]!]);
      expect(r.xp, 105);
      expect(r.diamonds, 20);
      expect(r.stats[StatKind.endurance], 18);
      expect(r.stats[StatKind.strength], 1);
      final aura = _rules.applyEffects(base, [c.effects[EffectKinds.bossAura]!]);
      expect(aura.diamonds, 22);
      expect(_rules.applyEffects(base, const []).xp, 100);
    });
  });

  group('серия', () {
    final today = DateTime(2026, 10, 21);
    DateTime d(int back) => DateTime(today.year, today.month, today.day - back);
    const good = DayTally(total: 5, done: 4);
    const bad = DayTally(total: 5, done: 3, failed: 2);

    test('порог доли выполненных', () {
      expect(_rules.dayCounted(good), isTrue);
      expect(_rules.dayCounted(bad), isFalse);
      expect(_rules.dayCounted(const DayTally(total: 2, excused: 2)), isNull);
    });

    test('сегодня — только если уже засчитан; обрыв на сорванном дне', () {
      final tallies = {d(0): bad, d(1): good, d(2): good, d(3): bad, d(4): good};
      expect(_rules.streakDays(today: today, tallies: tallies, isPaused: (_) => false), 2);
      tallies[d(0)] = good;
      expect(_rules.streakDays(today: today, tallies: tallies, isPaused: (_) => false), 3);
    });

    test('в паузу серия не сгорает', () {
      final tallies = {d(0): good, d(1): bad, d(2): good};
      final paused = d(1);
      expect(_rules.streakDays(today: today, tallies: tallies, isPaused: (x) => x == paused), 2);
      // День без квестов (нет записей) — обрыв, если не пауза.
      final gap = {d(0): good, d(2): good};
      expect(_rules.streakDays(today: today, tallies: gap, isPaused: (_) => false), 1);
      expect(_rules.streakDays(today: today, tallies: gap, isPaused: (x) => x == paused), 2);
    });
  });

  group('расписание шаблона', () {
    final wed = DateTime(2026, 10, 21);
    test('дни недели, чётность недели, срок действия', () {
      expect(GameRules.occursOn(day: wed, weekNumber: 1), isTrue);
      expect(GameRules.occursOn(day: wed, weekNumber: 1, weekdays: const [1, 3]), isTrue);
      expect(GameRules.occursOn(day: wed, weekNumber: 1, weekdays: const [1, 2]), isFalse);
      expect(GameRules.occursOn(day: wed, weekNumber: 1, weekParity: 2), isFalse);
      expect(GameRules.occursOn(day: wed, weekNumber: 2, weekParity: 2), isTrue);
      expect(GameRules.occursOn(day: wed, weekNumber: 1, activeFrom: DateTime(2026, 10, 22)), isFalse);
      expect(GameRules.occursOn(day: wed, weekNumber: 1, activeUntil: DateTime(2026, 10, 21, 5)), isTrue);
      expect(GameRules.occursOn(day: wed, weekNumber: 1, activeUntil: DateTime(2026, 10, 20)), isFalse);
    });

    test('время экземпляра: со временем — окно, без — до конца дня', () {
      final (s, dl) = GameRules.instanceTimes(wed, 9 * 60, 30);
      expect(s, DateTime(2026, 10, 21, 9));
      expect(dl, DateTime(2026, 10, 21, 9, 30));
      final (s2, dl2) = GameRules.instanceTimes(wed, null, 30);
      expect(s2, isNull);
      expect(dl2, DateTime(2026, 10, 22));
    });
  });

  group('квесты плана', () {
    test('категория → характеристика и вид', () {
      QuestInput conv(QuestKey k, QuestCategory c, {int? minute}) =>
          SystemQuests.fromDraft(QuestDraft(key: k, category: c, minute: minute, diamonds: 10, xp: 20));
      final training = conv(QuestKey.training, QuestCategory.training);
      expect(training.stat, StatKind.strength);
      expect(training.reward.stats, {StatKind.strength: 1, StatKind.endurance: 1});
      expect(conv(QuestKey.study, QuestCategory.goal).stat, StatKind.intellect);
      expect(conv(QuestKey.study, QuestCategory.goal).kind, QuestKind.goal);
      expect(conv(QuestKey.skincareMorning, QuestCategory.health).stat, StatKind.looks);
      expect(conv(QuestKey.water, QuestCategory.daily).stat, StatKind.health);
      expect(conv(QuestKey.wakeOnTime, QuestCategory.goal).stat, StatKind.discipline);
      final lesson = conv(QuestKey.attendLesson, QuestCategory.schedule, minute: 540);
      expect(lesson.kind, QuestKind.schedule);
      expect(lesson.title.params['minute'], 540);
      expect(lesson.penaltyDiamonds, 10);
      expect(lesson.refusePenaltyDiamonds, isNull);
      expect(lesson.source, QuestSource.plan);
    });
  });
}
