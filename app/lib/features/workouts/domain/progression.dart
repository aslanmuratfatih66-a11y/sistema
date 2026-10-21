// Прогрессия нагрузки (SPEC §8.4) — простое правило:
// - «Выполненная неделя» — календарная неделя (пн–вс), в которой завершено не меньше тренировок этой программы,
//   чем min(тренировок в неделю по программе, 3). Прерванные тренировки не считаются.
// - За каждую выполненную неделю: +1 повтор в подходе (упражнения на повторы) и +5 с работы (на время).
//   Разминка и заминка не меняются, подходы и отдых не меняются.
// - Потолок — по уровню (LevelParams.repsCap/secondsCap); в щадящей программе — потолок уровня ниже
//   (для новичка — свой). Нагрузка никогда не выше уровня пользователя (SPEC §6), в т.ч. в режиме дисциплины.
import '../model/exercise_catalog.dart';
import '../model/workout_program.dart';
import 'program_generator.dart';

const repsPerWeek = 1;
const secondsPerWeek = 5;

/// Понедельник недели даты (локальная полночь).
DateTime weekStart(DateTime d) {
  final day = DateTime(d.year, d.month, d.day);
  return day.subtract(Duration(days: day.weekday - DateTime.monday));
}

/// Сколько недель выполнено по датам завершённых тренировок программы.
int completedWeeks(Iterable<DateTime> finishedAt, {required int sessionsPerWeek}) {
  final need = sessionsPerWeek.clamp(1, 3);
  final perWeek = <DateTime, int>{};
  for (final f in finishedAt) {
    final w = weekStart(f.toLocal());
    perWeek[w] = (perWeek[w] ?? 0) + 1;
  }
  return perWeek.values.where((n) => n >= need).length;
}

/// Потолок прогрессии для программы.
LevelParams progressionCaps(WorkoutProgram program) {
  final level = program.gentle && program.level.index > 0
      ? WorkoutLevel.values[program.level.index - 1]
      : program.level;
  return levelParams[level]!;
}

/// Программа с прогрессией на [weeks] выполненных недель.
WorkoutProgram applyProgression(WorkoutProgram program, int weeks) {
  if (weeks <= 0) return program;
  final caps = progressionCaps(program);
  ProgramExercise grow(ProgramExercise e) {
    final cat = e.exercise?.category;
    if (cat == ExerciseCategory.warmup || cat == ExerciseCategory.cooldown) return e;
    final r = e.reps;
    final s = e.seconds;
    if (r != null) {
      final next = r + weeks * repsPerWeek;
      return e.copyWith(reps: r >= caps.repsCap ? r : (next > caps.repsCap ? caps.repsCap : next));
    }
    if (s != null) {
      final next = s + weeks * secondsPerWeek;
      return e.copyWith(seconds: s >= caps.secondsCap ? s : (next > caps.secondsCap ? caps.secondsCap : next));
    }
    return e;
  }

  return WorkoutProgram(
    level: program.level,
    minutesPerSession: program.minutesPerSession,
    gentle: program.gentle,
    days: [
      for (final d in program.days)
        ProgramDay(key: d.key, weekdays: d.weekdays, exercises: [for (final e in d.exercises) grow(e)]),
    ],
  );
}
