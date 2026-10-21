import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/discipline/discipline_hook.dart';
import 'package:sistema/domain/discipline/discipline_rules.dart';
import 'package:sistema/domain/quests/quest_api.dart';

final _day = DateTime(2026, 10, 21);
const _earlyBed = 19 * 60;

QuestInput _byKey(List<QuestInput> qs, String key) => qs.singleWhere((q) => q.title.key == key);

int _h(int h, [int m = 0]) => h * 60 + m;

void main() {
  group('подъём и отбой', () {
    test('по умолчанию 7:00/23:00 → 6:00/22:00', () {
      expect(DisciplineRules.targetWake(_h(7)), _h(6));
      expect(DisciplineRules.targetBed(_h(23)), _h(22));
    });

    test('подъём раньше 6:00 не сдвигается позже', () {
      expect(DisciplineRules.targetWake(_h(5, 30)), _h(5, 30));
      expect(DisciplineRules.targetWake(_h(6)), _h(6));
      expect(DisciplineRules.targetWake(_h(6, 1)), _h(6));
    });

    test('отбой раньше 22:00 не сдвигается позже', () {
      expect(DisciplineRules.targetBed(_h(21, 30)), _h(21, 30));
      expect(DisciplineRules.targetBed(_h(22)), _h(22));
      expect(DisciplineRules.targetBed(_h(22, 1)), _h(22));
    });

    test('отбой после полуночи — поздний, становится 22:00', () {
      expect(DisciplineRules.targetBed(_h(0, 30)), _h(22));
      expect(DisciplineRules.targetBed(_h(2)), _h(22));
      expect(DisciplineRules.targetBed(_h(11, 59)), _h(22));
      expect(DisciplineRules.targetBed(_h(12)), _h(12));
    });

    test('подъём/отбой не позже обычных, ночной сон не короче min(обычного, 8 ч)', () {
      for (var wake = 0; wake < 24 * 60; wake += 30) {
        for (var bed = 0; bed < 24 * 60; bed += 30) {
          if (wake == bed) continue;
          final tw = DisciplineRules.targetWake(wake);
          final tb = DisciplineRules.targetBed(bed);
          expect(tw <= wake, isTrue, reason: 'wake $wake');
          if (bed >= _h(12)) expect(tb <= bed, isTrue, reason: 'bed $bed');
          // Ночной сон: отбой вечером/ночью, подъём утром.
          if (wake >= _h(2) && wake <= _h(12) && (bed >= _h(18) || bed < wake)) {
            final usual = DisciplineRules.sleepMinutes(bed, wake);
            final next = DisciplineRules.sleepMinutes(tb, tw);
            expect(next >= (usual < 480 ? usual : 480), isTrue, reason: 'bed $bed wake $wake: $usual → $next');
          }
        }
      }
    });
  });

  group('доп. нагрузка', () {
    test('по уровню', () {
      expect(DisciplineRules.extraMinutes(TrainingLevel.beginner, null), 10);
      expect(DisciplineRules.extraMinutes(TrainingLevel.intermediate, null), 15);
      expect(DisciplineRules.extraMinutes(TrainingLevel.advanced, null), 20);
    });

    test('неизвестный уровень — как новичок', () {
      expect(DisciplineRules.extraMinutes(null, null), 10);
    });

    test('не больше обычных минут в день, но не меньше минимума', () {
      expect(DisciplineRules.extraMinutes(TrainingLevel.advanced, 12), 12);
      expect(DisciplineRules.extraMinutes(TrainingLevel.advanced, 60), 20);
      expect(DisciplineRules.extraMinutes(TrainingLevel.beginner, 2), DisciplineRules.minExtraMinutes);
      expect(DisciplineRules.extraMinutes(TrainingLevel.beginner, 0), 10);
    });
  });

  group('disciplineQuests', () {
    test('три квеста: подъём, нагрузка, отбой — системные, без отмены', () {
      final qs = disciplineQuests(_day, ctx: DisciplineContext.fallback);
      expect(
        qs.map((q) => q.title.key),
        [DisciplineQuestKeys.wake, DisciplineQuestKeys.workout, DisciplineQuestKeys.bed],
      );
      for (final q in qs) {
        expect(q.kind, QuestKind.discipline);
        expect(q.source, QuestSource.system);
        expect(q.cancellable, isFalse);
        expect(q.reward.diamonds, inInclusiveRange(1, 20));
        expect(q.penaltyDiamonds, inInclusiveRange(1, 20));
        expect(q.minute, isNotNull);
        expect(q.minute! + q.windowMinutes <= 24 * 60, isTrue);
      }
    });

    test('время и параметры по контексту', () {
      final qs = disciplineQuests(
        _day,
        ctx: const DisciplineContext(
          level: TrainingLevel.intermediate,
          minutesPerDay: 30,
          wakeMinute: 330,
          bedMinute: 1260,
        ),
      );
      final wake = _byKey(qs, DisciplineQuestKeys.wake);
      expect(wake.minute, 330);
      expect(wake.title.params['time'], '05:30');
      final bed = _byKey(qs, DisciplineQuestKeys.bed);
      expect(bed.title.params['minute'], 1260);
      expect(bed.title.params['time'], '21:00');
      expect(bed.minute! + bed.windowMinutes, 1260 + DisciplineRules.bedGrace);
      final w = _byKey(qs, DisciplineQuestKeys.workout);
      expect(w.title.params['minutes'], 15);
      expect(w.title.params['level'], 'intermediate');
      expect(w.minute, _h(18));
    });

    test('нагрузка внутри дня при раннем отбое', () {
      final qs = disciplineQuests(_day, ctx: const DisciplineContext(wakeMinute: 300, bedMinute: _earlyBed));
      final w = _byKey(qs, DisciplineQuestKeys.workout);
      expect(w.minute, _earlyBed - 90);
      expect(w.windowMinutes >= 30, isTrue);
    });

    test('при травмах — прогулка вместо тренировки', () {
      final qs = disciplineQuests(_day, ctx: const DisciplineContext(level: TrainingLevel.advanced, hasInjuries: true));
      expect(qs.any((q) => q.title.key == DisciplineQuestKeys.workout), isFalse);
      expect(_byKey(qs, DisciplineQuestKeys.walk).title.params['minutes'], DisciplineRules.walkMinutes);
    });

    test('хук с фиксированным контекстом', () {
      final hook = disciplineQuestsHook(const DisciplineContext(level: TrainingLevel.advanced));
      expect(_byKey(hook(_day), DisciplineQuestKeys.workout).title.params['minutes'], 20);
    });
  });

  group('контекст из анкеты', () {
    test('уровень, минуты, травмы', () {
      final c = DisciplineContext.fromSources(
        training: {'level': 'advanced', 'minutesPerDay': 45},
        health: {'injuries': 'колено'},
        wakeMinute: 400,
        bedMinute: 1300,
      );
      expect(
        c,
        const DisciplineContext(
          level: TrainingLevel.advanced,
          minutesPerDay: 45,
          wakeMinute: 400,
          bedMinute: 1300,
          hasInjuries: true,
        ),
      );
    });

    test('мусор → безопасные значения', () {
      final c = DisciplineContext.fromSources(
        training: {'level': 'pro', 'minutesPerDay': 'x'},
        health: {'injuries': '  '},
      );
      expect(c.level, isNull);
      expect(c.minutesPerDay, isNull);
      expect(c.hasInjuries, isFalse);
    });
  });

  group('включение и выключение', () {
    test('автовключение при минусе', () {
      expect(disciplineShouldTurnOn(balance: -1, active: false), isTrue);
      expect(disciplineShouldTurnOn(balance: 0, active: false), isFalse);
      expect(disciplineShouldTurnOn(balance: -5, active: true), isFalse);
    });

    test('автовыключение, когда баланс положительный (> 0)', () {
      expect(disciplineShouldTurnOff(balance: 1, active: true, reason: DisciplineReason.debt), isTrue);
      expect(disciplineShouldTurnOff(balance: 0, active: true, reason: DisciplineReason.debt), isFalse);
      expect(disciplineShouldTurnOff(balance: 10, active: true), isTrue);
      expect(disciplineShouldTurnOff(balance: 10, active: true, reason: DisciplineReason.manual), isFalse);
      expect(disciplineShouldTurnOff(balance: 10, active: false), isFalse);
    });

    test('ручное выключение — только если баланс не отрицательный', () {
      expect(disciplineCanDisableManually(balance: -1, active: true), isFalse);
      expect(disciplineCanDisableManually(balance: 0, active: true), isTrue);
      expect(disciplineCanDisableManually(balance: 5, active: false), isFalse);
      expect(disciplineCanEnableManually(active: false), isTrue);
      expect(disciplineCanEnableManually(active: true), isFalse);
    });

    test('статус: причина из журнала или по балансу', () {
      final debt = DisciplineStatus.resolve(active: true, balance: -10);
      expect(debt.reason, DisciplineReason.debt);
      expect(debt.exit, DisciplineExit.balancePositive);
      expect(debt.canDisable, isFalse);

      final manual = DisciplineStatus.resolve(active: true, balance: 50, lastOnReasonKey: 'manual');
      expect(manual.reason, DisciplineReason.manual);
      expect(manual.exit, DisciplineExit.manual);
      expect(manual.canDisable, isTrue);

      expect(DisciplineStatus.resolve(active: true, balance: 50).reason, DisciplineReason.manual);
      expect(
        DisciplineStatus.resolve(active: true, balance: 5, lastOnReasonKey: 'ai').exit,
        DisciplineExit.balancePositive,
      );

      final off = DisciplineStatus.resolve(active: false, balance: 3, lastOnReasonKey: 'debt');
      expect(off.reason, isNull);
      expect(off.exit, isNull);
      expect(off.canEnable, isTrue);
    });

    test('ключи причин', () {
      for (final r in DisciplineReason.values) {
        expect(DisciplineReasonKeys.parse(DisciplineReasonKeys.of(r)), r);
      }
      expect(DisciplineReasonKeys.parse('x'), isNull);
    });
  });
}
