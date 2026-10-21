// Шаблонная программа под уровень/время/инвентарь/ограничения (SPEC §8.4). Программа от ИИ — этап 5
// (TODO: тот же формат WorkoutProgram, source = 'ai').
//
// Правила:
// - Дни: 1 тренировка в неделю — вариант A; 2 — A/B; 3 и больше — A/B/C по кругу на выбранные дни недели.
// - Каждый день: разминка → основная часть по слотам (ноги/толкающие/кор/спина/кардио…) → заминка.
// - Упражнение слота — из каталога: подходит уровню, есть инвентарь; при ограничениях — только без прыжков
//   и осевой нагрузки (щадящий вариант, отдых длиннее). Это подбор нагрузки, не медицинская рекомендация.
// - Подходы/повторы/время/отдых — по уровню ([levelParams]); затем объём подгоняется под минуты:
//   сначала убираются последние слоты (минимум 2 основных упражнения), потом уменьшаются подходы (минимум 1);
//   если время остаётся — подходы добавляются, но не выше потолка уровня.
import '../model/exercise_catalog.dart';
import '../model/workout_program.dart';
import 'training_profile.dart';

/// Нагрузка уровня.
class LevelParams {
  const LevelParams({
    required this.sets,
    required this.maxSets,
    required this.reps,
    required this.seconds,
    required this.restSeconds,
    required this.repsCap,
    required this.secondsCap,
  });

  final int sets;
  final int maxSets;
  final int reps;
  final int seconds;
  final int restSeconds;

  /// Потолок прогрессии (повторы/секунды в подходе) — выше уровня пользователя нагрузка не растёт.
  final int repsCap;
  final int secondsCap;
}

const levelParams = <WorkoutLevel, LevelParams>{
  WorkoutLevel.beginner:
      LevelParams(sets: 2, maxSets: 3, reps: 8, seconds: 20, restSeconds: 60, repsCap: 15, secondsCap: 45),
  WorkoutLevel.intermediate:
      LevelParams(sets: 3, maxSets: 4, reps: 12, seconds: 30, restSeconds: 45, repsCap: 20, secondsCap: 60),
  WorkoutLevel.advanced:
      LevelParams(sets: 4, maxSets: 5, reps: 15, seconds: 40, restSeconds: 30, repsCap: 25, secondsCap: 90),
};

/// Щадящий вариант: отдых длиннее.
const gentleExtraRest = 15;

const warmupSeconds = 60;
const cooldownSeconds = 60;
const warmupRest = 15;

/// Оценка: секунда на повтор и переход между упражнениями.
const secondsPerRep = 3;
const transitionSeconds = 10;

const _slots = <String, List<ExerciseCategory>>{
  'A': [
    ExerciseCategory.legs,
    ExerciseCategory.push,
    ExerciseCategory.core,
    ExerciseCategory.pull,
    ExerciseCategory.cardio,
    ExerciseCategory.legs,
    ExerciseCategory.core,
  ],
  'B': [
    ExerciseCategory.push,
    ExerciseCategory.legs,
    ExerciseCategory.pull,
    ExerciseCategory.core,
    ExerciseCategory.cardio,
    ExerciseCategory.push,
    ExerciseCategory.core,
  ],
  'C': [
    ExerciseCategory.legs,
    ExerciseCategory.pull,
    ExerciseCategory.core,
    ExerciseCategory.push,
    ExerciseCategory.cardio,
    ExerciseCategory.legs,
    ExerciseCategory.core,
  ],
};

/// Подходящие упражнения категории (в порядке каталога — от простого к сложному).
List<Exercise> candidatesFor(ExerciseCategory c, TrainingProfile p) => [
      for (final e in exerciseCatalog)
        if (e.category == c &&
            e.fitsLevel(p.level) &&
            (!p.limitations || e.gentleSafe) &&
            (e.equipment == null || p.equipment.contains(e.equipment)))
          e,
    ];

/// Оценка длительности дня, секунд.
int estimateSeconds(List<ProgramExercise> list) {
  var s = 0;
  for (final e in list) {
    final work = e.reps != null ? e.reps! * secondsPerRep : (e.seconds ?? 0);
    s += e.sets * (work + e.restSeconds) + transitionSeconds;
  }
  return s;
}

WorkoutProgram generateTemplateProgram(TrainingProfile p) {
  final weekdays = p.weekdays.isEmpty ? const [1, 3, 5] : p.weekdays;
  final variants = ['A', 'B', 'C'].take(weekdays.length.clamp(1, 3)).toList();
  final days = <ProgramDay>[];
  for (var i = 0; i < variants.length; i++) {
    days.add(ProgramDay(
      key: variants[i],
      weekdays: [
        for (var w = 0; w < weekdays.length; w++)
          if (w % variants.length == i) weekdays[w],
      ],
      exercises: _dayExercises(p, variants[i], i),
    ));
  }
  return WorkoutProgram(level: p.level, minutesPerSession: p.minutesPerSession, gentle: p.limitations, days: days);
}

List<ProgramExercise> _dayExercises(TrainingProfile p, String variant, int dayIndex) {
  final lp = levelParams[p.level]!;
  final rest = lp.restSeconds + (p.limitations ? gentleExtraRest : 0);

  ProgramExercise base(Exercise e) => ProgramExercise(
        exerciseKey: e.key,
        sets: lp.sets,
        reps: e.mode == ExerciseMode.reps ? lp.reps : null,
        seconds: e.mode == ExerciseMode.time ? lp.seconds : null,
        restSeconds: rest,
      );

  // Разминка и заминка — одна «станция» на время.
  final warmups = candidatesFor(ExerciseCategory.warmup, p);
  final warmup = warmups[dayIndex % warmups.length];
  final cooldown = candidatesFor(ExerciseCategory.cooldown, p).first;

  final used = <String>{};
  final occurrence = <ExerciseCategory, int>{};
  final main = <ProgramExercise>[];
  for (final c in _slots[variant]!) {
    final list = candidatesFor(c, p);
    if (list.isEmpty) continue;
    final n = occurrence[c] = (occurrence[c] ?? -1) + 1;
    // Начинаем с более сложных подходящих (конец списка), сдвиг по дню и повтору слота.
    Exercise? pick;
    for (var k = 0; k < list.length; k++) {
      final e = list[(list.length - 1 - ((dayIndex + n * 2 + k) % list.length))];
      if (!used.contains(e.key)) {
        pick = e;
        break;
      }
    }
    if (pick == null) continue;
    used.add(pick.key);
    main.add(base(pick));
  }

  final head = ProgramExercise(exerciseKey: warmup.key, sets: 1, seconds: warmupSeconds, restSeconds: warmupRest);
  final tail = ProgramExercise(exerciseKey: cooldown.key, sets: 1, seconds: cooldownSeconds, restSeconds: 0);
  final budget = p.minutesPerSession * 60;
  int est() => estimateSeconds([head, ...main, tail]);

  while (est() > budget && main.length > 2) {
    main.removeLast();
  }
  while (est() > budget) {
    var idx = -1;
    for (var k = main.length - 1; k >= 0; k--) {
      if (main[k].sets > 1 && (idx < 0 || main[k].sets > main[idx].sets)) idx = k;
    }
    if (idx < 0) break;
    main[idx] = main[idx].copyWith(sets: main[idx].sets - 1);
  }
  // Свободное время — больше подходов, но не выше потолка уровня.
  var grown = true;
  while (grown) {
    grown = false;
    for (var k = 0; k < main.length; k++) {
      if (main[k].sets >= lp.maxSets) continue;
      final prev = main[k];
      main[k] = prev.copyWith(sets: prev.sets + 1);
      if (est() > budget) {
        main[k] = prev;
      } else {
        grown = true;
      }
    }
  }
  return [head, ...main, tail];
}
