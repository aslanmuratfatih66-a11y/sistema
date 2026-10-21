import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/features/workouts/domain/program_generator.dart';
import 'package:sistema/features/workouts/domain/progression.dart';
import 'package:sistema/features/workouts/domain/training_profile.dart';
import 'package:sistema/features/workouts/model/exercise_catalog.dart';
import 'package:sistema/features/workouts/model/workout_program.dart';

Iterable<Exercise> _exercises(WorkoutProgram p) => [
      for (final d in p.days)
        for (final e in d.exercises) e.exercise!,
    ];

void main() {
  group('TrainingProfile.fromSources', () {
    test('анкета: уровень, минуты, инвентарь, дни, травмы', () {
      final p = TrainingProfile.fromSources(
        training: {
          'level': 'advanced',
          'minutesPerDay': 45,
          'equipment': ['dumbbells', 'mat'],
          'days': [5, 1, 3],
        },
        health: {'injuries': 'колено'},
      );
      expect(p.level, WorkoutLevel.advanced);
      expect(p.levelKnown, isTrue);
      expect(p.minutesPerSession, 45);
      expect(p.equipment, {'dumbbells', 'mat'});
      expect(p.weekdays, [1, 3, 5]);
      expect(p.limitations, isTrue);
    });

    test('пусто — новичок, 20 мин, пн/ср/пт; план важнее анкеты', () {
      final empty = TrainingProfile.fromSources(training: const {});
      expect(empty.level, WorkoutLevel.beginner);
      expect(empty.levelKnown, isFalse);
      expect(empty.minutesPerSession, 20);
      expect(empty.weekdays, [1, 3, 5]);
      expect(empty.limitations, isFalse);

      final plan = TrainingProfile.fromSources(
        training: const {'minutesPerDay': 45, 'days': [1]},
        health: const {'injuries': '  '},
        planMinutes: 30,
        planWeekdays: const [2, 4],
      );
      expect(plan.minutesPerSession, 30);
      expect(plan.weekdays, [2, 4]);
      expect(plan.limitations, isFalse);
    });
  });

  group('generateTemplateProgram', () {
    test('дни A/B/C по выбранным дням недели', () {
      final p = generateTemplateProgram(const TrainingProfile(weekdays: [1, 2, 4, 6]));
      expect(p.days.map((d) => d.key), ['A', 'B', 'C']);
      expect(p.days[0].weekdays, [1, 6]);
      expect(p.days[1].weekdays, [2]);
      expect(p.days[2].weekdays, [4]);
      expect(p.sessionsPerWeek, 4);
      expect(p.dayFor(DateTime(2026, 10, 19))?.key, 'A'); // понедельник
      expect(p.dayFor(DateTime(2026, 10, 21)), isNull); // среда — отдых

      final two = generateTemplateProgram(const TrainingProfile(weekdays: [2, 5]));
      expect(two.days.map((d) => d.key), ['A', 'B']);
    });

    test('разминка первой, заминка последней, упражнения в дне не повторяются', () {
      final p = generateTemplateProgram(const TrainingProfile(level: WorkoutLevel.intermediate, minutesPerSession: 30));
      for (final d in p.days) {
        expect(d.exercises.first.exercise!.category, ExerciseCategory.warmup);
        expect(d.exercises.last.exercise!.category, ExerciseCategory.cooldown);
        final keys = d.exercises.map((e) => e.exerciseKey).toList();
        expect(keys.toSet().length, keys.length);
        expect(d.exercises.length, greaterThanOrEqualTo(4));
      }
    });

    test('упражнения подходят уровню; новичку — без сложных', () {
      for (final level in WorkoutLevel.values) {
        final p = generateTemplateProgram(TrainingProfile(level: level, minutesPerSession: 60));
        for (final e in _exercises(p)) {
          expect(e.fitsLevel(level), isTrue, reason: '${e.key} для $level');
          expect(e.equipment, isNull, reason: 'инвентаря нет: ${e.key}');
        }
      }
      final b = generateTemplateProgram(const TrainingProfile(minutesPerSession: 60));
      expect(_exercises(b).map((e) => e.key), isNot(contains('burpee')));
      expect(_exercises(b).map((e) => e.key), isNot(contains('pushUp')));
    });

    test('нагрузка по уровню: подходы/повторы/отдых и потолок подходов', () {
      for (final level in WorkoutLevel.values) {
        final lp = levelParams[level]!;
        final p = generateTemplateProgram(TrainingProfile(level: level, minutesPerSession: 90));
        for (final d in p.days) {
          for (final e in d.exercises.skip(1).take(d.exercises.length - 2)) {
            expect(e.sets, lessThanOrEqualTo(lp.maxSets));
            expect(e.restSeconds, lp.restSeconds);
            if (e.timed) {
              expect(e.seconds, lp.seconds);
            } else {
              expect(e.reps, lp.reps);
            }
          }
        }
      }
    });

    test('травмы/ограничения — без прыжков и осевой нагрузки, отдых длиннее', () {
      for (final level in WorkoutLevel.values) {
        final p = generateTemplateProgram(TrainingProfile(
          level: level,
          minutesPerSession: 60,
          limitations: true,
          equipment: const {'dumbbells', 'kettlebell', 'pullupBar', 'bands'},
        ));
        expect(p.gentle, isTrue);
        for (final e in _exercises(p)) {
          expect(e.impact, isFalse, reason: e.key);
          expect(e.axialLoad, isFalse, reason: e.key);
        }
        final main = p.days.first.exercises[1];
        expect(main.restSeconds, levelParams[level]!.restSeconds + gentleExtraRest);
      }
    });

    test('инвентарь из анкеты используется', () {
      final p = generateTemplateProgram(const TrainingProfile(
        level: WorkoutLevel.intermediate,
        minutesPerSession: 60,
        equipment: {'dumbbells', 'bands'},
      ));
      expect(_exercises(p).any((e) => e.equipment != null), isTrue);
      expect(_exercises(p).every((e) => e.equipment == null || {'dumbbells', 'bands'}.contains(e.equipment)), isTrue);
    });

    test('объём подгоняется под минуты', () {
      for (final minutes in [10, 20, 30, 45, 60]) {
        final p = generateTemplateProgram(TrainingProfile(minutesPerSession: minutes, level: WorkoutLevel.intermediate));
        for (final d in p.days) {
          expect(estimateSeconds(d.exercises), lessThanOrEqualTo(minutes * 60), reason: '$minutes мин, день ${d.key}');
        }
      }
      final short = generateTemplateProgram(const TrainingProfile(minutesPerSession: 10)).days.first.exercises;
      final long = generateTemplateProgram(const TrainingProfile(minutesPerSession: 45)).days.first.exercises;
      int volume(List<ProgramExercise> l) => l.fold(0, (s, e) => s + e.sets);
      expect(volume(long), greaterThan(volume(short)));
    });

    test('JSON туда-обратно', () {
      final p = generateTemplateProgram(const TrainingProfile(weekdays: [1, 3, 5], limitations: true));
      final back = WorkoutProgram.fromJson(p.toJson())!;
      expect(back.level, p.level);
      expect(back.gentle, isTrue);
      expect(back.minutesPerSession, p.minutesPerSession);
      expect(back.days.length, 3);
      expect(back.days[1].weekdays, p.days[1].weekdays);
      expect(back.days[1].exercises, p.days[1].exercises);
      expect(WorkoutProgram.fromJson(const {'level': 'pro'}), isNull);
    });
  });

  group('Прогрессия', () {
    test('неделя засчитывается при min(тренировок в неделю, 3) завершённых', () {
      final mon = DateTime(2026, 10, 19, 18);
      final dates = [
        mon, mon.add(const Duration(days: 2)), mon.add(const Duration(days: 4)), // неделя 1: 3
        mon.add(const Duration(days: 7)), mon.add(const Duration(days: 9)), // неделя 2: 2
        mon.add(const Duration(days: 14)), mon.add(const Duration(days: 15)), mon.add(const Duration(days: 16)), // 3
      ];
      expect(completedWeeks(dates, sessionsPerWeek: 3), 2);
      expect(completedWeeks(dates, sessionsPerWeek: 2), 3);
      expect(completedWeeks(dates, sessionsPerWeek: 5), 2); // требование не больше 3
      expect(completedWeeks(const [], sessionsPerWeek: 3), 0);
      // воскресенье и следующий понедельник — разные недели
      expect(completedWeeks([DateTime(2026, 10, 25, 20), DateTime(2026, 10, 26, 8)], sessionsPerWeek: 2), 0);
    });

    test('+1 повтор / +5 с за неделю, разминка и заминка без изменений', () {
      final base = generateTemplateProgram(const TrainingProfile(level: WorkoutLevel.intermediate, minutesPerSession: 30));
      final p = applyProgression(base, 2);
      final day = base.days.first;
      final grown = p.days.first;
      expect(grown.exercises.first, day.exercises.first);
      expect(grown.exercises.last, day.exercises.last);
      for (var i = 1; i < day.exercises.length - 1; i++) {
        final a = day.exercises[i];
        final b = grown.exercises[i];
        expect(b.sets, a.sets);
        expect(b.restSeconds, a.restSeconds);
        if (a.timed) {
          expect(b.seconds, a.seconds! + 10);
        } else {
          expect(b.reps, a.reps! + 2);
        }
      }
      expect(identical(applyProgression(base, 0), base), isTrue);
    });

    test('потолок по уровню; в щадящей программе — потолок уровня ниже', () {
      for (final level in WorkoutLevel.values) {
        final caps = levelParams[level]!;
        final p = applyProgression(generateTemplateProgram(TrainingProfile(level: level, minutesPerSession: 30)), 100);
        for (final e in p.days.expand((d) => d.exercises).skip(1)) {
          final c = e.exercise!.category;
          if (c == ExerciseCategory.warmup || c == ExerciseCategory.cooldown) continue;
          if (e.timed) {
            expect(e.seconds, caps.secondsCap);
          } else {
            expect(e.reps, caps.repsCap);
          }
        }
      }
      final gentle = applyProgression(
        generateTemplateProgram(const TrainingProfile(level: WorkoutLevel.advanced, limitations: true)),
        100,
      );
      final caps = levelParams[WorkoutLevel.intermediate]!;
      for (final e in gentle.days.first.exercises.skip(1).take(gentle.days.first.exercises.length - 2)) {
        expect(e.timed ? e.seconds : e.reps, e.timed ? caps.secondsCap : caps.repsCap);
      }
    });
  });
}
