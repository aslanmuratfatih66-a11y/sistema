// Программа тренировок: JSON в WorkoutPrograms.payload, формат `v: 1`.
// Тот же формат будет у программы от ИИ (этап 5, source = 'ai'). Строки UI здесь не хранятся — только ключи.
import 'exercise_catalog.dart';

/// Упражнение в дне программы (базовая нагрузка, до прогрессии).
class ProgramExercise {
  const ProgramExercise({
    required this.exerciseKey,
    required this.sets,
    this.reps,
    this.seconds,
    required this.restSeconds,
  });

  final String exerciseKey;
  final int sets;

  /// Повторов в подходе (для [ExerciseMode.reps]).
  final int? reps;

  /// Секунд работы в подходе (для [ExerciseMode.time]).
  final int? seconds;

  /// Отдых после каждого подхода.
  final int restSeconds;

  Exercise? get exercise => exerciseByKey(exerciseKey);

  bool get timed => seconds != null && reps == null;

  ProgramExercise copyWith({int? sets, int? reps, int? seconds, int? restSeconds}) => ProgramExercise(
        exerciseKey: exerciseKey,
        sets: sets ?? this.sets,
        reps: reps ?? this.reps,
        seconds: seconds ?? this.seconds,
        restSeconds: restSeconds ?? this.restSeconds,
      );

  Map<String, Object?> toJson() => {
        'ex': exerciseKey,
        'sets': sets,
        if (reps != null) 'reps': reps,
        if (seconds != null) 'sec': seconds,
        'rest': restSeconds,
      };

  static ProgramExercise? fromJson(Map<String, Object?> j) {
    final key = j['ex'];
    if (key is! String) return null;
    final reps = _int(j['reps']);
    final sec = _int(j['sec']);
    if (reps == null && sec == null) return null;
    return ProgramExercise(
      exerciseKey: key,
      sets: (_int(j['sets']) ?? 1).clamp(1, 10),
      reps: reps,
      seconds: reps == null ? sec : null,
      restSeconds: (_int(j['rest']) ?? 45).clamp(0, 600),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ProgramExercise &&
      other.exerciseKey == exerciseKey &&
      other.sets == sets &&
      other.reps == reps &&
      other.seconds == seconds &&
      other.restSeconds == restSeconds;

  @override
  int get hashCode => Object.hash(exerciseKey, sets, reps, seconds, restSeconds);

  @override
  String toString() => 'ProgramExercise($exerciseKey ×$sets ${reps ?? '${seconds}s'} rest $restSeconds)';
}

/// День программы (вариант A/B/C) и дни недели, на которые он приходится.
class ProgramDay {
  const ProgramDay({required this.key, required this.weekdays, required this.exercises});

  /// 'A', 'B', 'C'.
  final String key;

  /// DateTime.monday..sunday.
  final List<int> weekdays;
  final List<ProgramExercise> exercises;

  Map<String, Object?> toJson() => {
        'key': key,
        'weekdays': weekdays,
        'exercises': [for (final e in exercises) e.toJson()],
      };

  static ProgramDay? fromJson(Map<String, Object?> j) {
    final key = j['key'];
    if (key is! String) return null;
    return ProgramDay(
      key: key,
      weekdays: [for (final d in _list(j['weekdays'])) ?_int(d)],
      exercises: [
        for (final e in _list(j['exercises']))
          if (e is Map<String, Object?>) ?ProgramExercise.fromJson(e),
      ],
    );
  }
}

class WorkoutProgram {
  const WorkoutProgram({
    required this.level,
    required this.minutesPerSession,
    required this.gentle,
    required this.days,
  });

  final WorkoutLevel level;
  final int minutesPerSession;

  /// Щадящий вариант (указаны травмы/ограничения): без прыжков и осевой нагрузки.
  final bool gentle;
  final List<ProgramDay> days;

  /// Сколько тренировок в неделю по программе.
  int get sessionsPerWeek => {for (final d in days) ...d.weekdays}.length;

  /// День программы на дату (null — день отдыха).
  ProgramDay? dayFor(DateTime date) {
    for (final d in days) {
      if (d.weekdays.contains(date.weekday)) return d;
    }
    return null;
  }

  ProgramDay? dayByKey(String? key) {
    for (final d in days) {
      if (d.key == key) return d;
    }
    return null;
  }

  Map<String, Object?> toJson() => {
        'v': 1,
        'level': level.name,
        'minutes': minutesPerSession,
        'gentle': gentle,
        'days': [for (final d in days) d.toJson()],
      };

  static WorkoutProgram? fromJson(Map<String, Object?> j) {
    final level = WorkoutLevel.values.where((l) => l.name == j['level']).firstOrNull;
    if (level == null) return null;
    final days = [
      for (final d in _list(j['days']))
        if (d is Map<String, Object?>) ?ProgramDay.fromJson(d),
    ];
    if (days.isEmpty) return null;
    return WorkoutProgram(
      level: level,
      minutesPerSession: _int(j['minutes']) ?? 20,
      gentle: j['gentle'] == true,
      days: days,
    );
  }
}

int? _int(Object? v) => v is num ? v.round() : null;
List<Object?> _list(Object? v) => v is List ? v.cast<Object?>() : const [];
