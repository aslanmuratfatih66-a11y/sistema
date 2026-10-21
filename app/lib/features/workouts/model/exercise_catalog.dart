// Локальный каталог упражнений для дома (SPEC §8.4). Названия и подсказки техники — в ARB
// (wrk_l10n.dart: ключ → строка), здесь только ключи и свойства для подбора и расчёта ккал.
// MET — ориентировочные значения из сводных таблиц физической активности (оценка расхода, не измерение).

/// Тип выполнения: повторы (подход закрывает пользователь) или работа на время (таймер).
enum ExerciseMode { reps, time }

/// Роль в тренировке — для подбора по слотам и иконки.
enum ExerciseCategory { warmup, legs, push, pull, core, cardio, cooldown }

/// Уровень подготовки из анкеты (training.level).
enum WorkoutLevel { beginner, intermediate, advanced }

class Exercise {
  const Exercise({
    required this.key,
    required this.category,
    required this.mode,
    required this.met,
    this.minLevel = WorkoutLevel.beginner,
    this.maxLevel = WorkoutLevel.advanced,
    this.impact = false,
    this.axialLoad = false,
    this.equipment,
  });

  /// Стабильный ключ (хранится в payload программы и сессии).
  final String key;
  final ExerciseCategory category;
  final ExerciseMode mode;

  /// Метаболический эквивалент для расчёта ккал.
  final double met;

  /// Для каких уровней подходит (включительно).
  final WorkoutLevel minLevel;
  final WorkoutLevel maxLevel;

  /// Прыжки/ударная нагрузка — исключается в щадящей программе.
  final bool impact;

  /// Осевая нагрузка на позвоночник (вес на плечах/в руках над корпусом) — исключается в щадящей программе.
  final bool axialLoad;

  /// Нужный инвентарь (ключ из анкеты: dumbbells, pullupBar, bands, mat, kettlebell); null — без инвентаря.
  final String? equipment;

  bool fitsLevel(WorkoutLevel l) => l.index >= minLevel.index && l.index <= maxLevel.index;

  /// Безопасно при травмах/ограничениях: без прыжков и осевой нагрузки.
  bool get gentleSafe => !impact && !axialLoad;
}

const _b = WorkoutLevel.beginner;
const _i = WorkoutLevel.intermediate;
const _a = WorkoutLevel.advanced;

/// Весь каталог. Порядок внутри категории — от простого к сложному (важно для подбора).
const exerciseCatalog = <Exercise>[
  // Разминка
  Exercise(key: 'marchInPlace', category: ExerciseCategory.warmup, mode: ExerciseMode.time, met: 3.5),
  Exercise(key: 'armCircles', category: ExerciseCategory.warmup, mode: ExerciseMode.time, met: 2.8),
  Exercise(key: 'jumpingJacks', category: ExerciseCategory.warmup, mode: ExerciseMode.time, met: 8.0, minLevel: _i, impact: true),
  // Ноги
  Exercise(key: 'chairSquat', category: ExerciseCategory.legs, mode: ExerciseMode.reps, met: 3.5, maxLevel: _b),
  Exercise(key: 'gluteBridge', category: ExerciseCategory.legs, mode: ExerciseMode.reps, met: 3.5),
  Exercise(key: 'squat', category: ExerciseCategory.legs, mode: ExerciseMode.reps, met: 5.0),
  Exercise(key: 'wallSit', category: ExerciseCategory.legs, mode: ExerciseMode.time, met: 4.0),
  Exercise(key: 'reverseLunge', category: ExerciseCategory.legs, mode: ExerciseMode.reps, met: 4.5, minLevel: _i),
  Exercise(key: 'gobletSquat', category: ExerciseCategory.legs, mode: ExerciseMode.reps, met: 5.5, minLevel: _i, axialLoad: true, equipment: 'dumbbells'),
  Exercise(key: 'kettlebellSwing', category: ExerciseCategory.legs, mode: ExerciseMode.reps, met: 7.0, minLevel: _i, axialLoad: true, equipment: 'kettlebell'),
  Exercise(key: 'jumpSquat', category: ExerciseCategory.legs, mode: ExerciseMode.reps, met: 8.0, minLevel: _a, impact: true),
  // Толкающие
  Exercise(key: 'wallPushUp', category: ExerciseCategory.push, mode: ExerciseMode.reps, met: 3.0, maxLevel: _b),
  Exercise(key: 'kneePushUp', category: ExerciseCategory.push, mode: ExerciseMode.reps, met: 3.8, maxLevel: _i),
  Exercise(key: 'pushUp', category: ExerciseCategory.push, mode: ExerciseMode.reps, met: 4.0, minLevel: _i),
  Exercise(key: 'dumbbellPress', category: ExerciseCategory.push, mode: ExerciseMode.reps, met: 4.0, equipment: 'dumbbells'),
  Exercise(key: 'diamondPushUp', category: ExerciseCategory.push, mode: ExerciseMode.reps, met: 4.5, minLevel: _a),
  // Тянущие / спина
  Exercise(key: 'superman', category: ExerciseCategory.pull, mode: ExerciseMode.reps, met: 3.0),
  Exercise(key: 'reverseSnowAngel', category: ExerciseCategory.pull, mode: ExerciseMode.reps, met: 3.0),
  Exercise(key: 'bandRow', category: ExerciseCategory.pull, mode: ExerciseMode.reps, met: 3.5, equipment: 'bands'),
  Exercise(key: 'dumbbellRow', category: ExerciseCategory.pull, mode: ExerciseMode.reps, met: 4.0, equipment: 'dumbbells'),
  Exercise(key: 'pullUp', category: ExerciseCategory.pull, mode: ExerciseMode.reps, met: 5.0, minLevel: _a, equipment: 'pullupBar'),
  // Кор
  Exercise(key: 'deadBug', category: ExerciseCategory.core, mode: ExerciseMode.reps, met: 3.0),
  Exercise(key: 'birdDog', category: ExerciseCategory.core, mode: ExerciseMode.reps, met: 3.0),
  Exercise(key: 'plank', category: ExerciseCategory.core, mode: ExerciseMode.time, met: 4.0),
  Exercise(key: 'crunch', category: ExerciseCategory.core, mode: ExerciseMode.reps, met: 3.8),
  Exercise(key: 'sidePlank', category: ExerciseCategory.core, mode: ExerciseMode.time, met: 4.0, minLevel: _i),
  Exercise(key: 'legRaise', category: ExerciseCategory.core, mode: ExerciseMode.reps, met: 4.0, minLevel: _i),
  // Кардио
  Exercise(key: 'stepTouch', category: ExerciseCategory.cardio, mode: ExerciseMode.time, met: 4.0),
  Exercise(key: 'shadowBoxing', category: ExerciseCategory.cardio, mode: ExerciseMode.time, met: 5.5),
  Exercise(key: 'highKnees', category: ExerciseCategory.cardio, mode: ExerciseMode.time, met: 8.0, minLevel: _i, impact: true),
  Exercise(key: 'mountainClimber', category: ExerciseCategory.cardio, mode: ExerciseMode.time, met: 8.0, minLevel: _i, impact: true),
  Exercise(key: 'burpee', category: ExerciseCategory.cardio, mode: ExerciseMode.reps, met: 8.0, minLevel: _a, impact: true),
  // Заминка
  Exercise(key: 'fullBodyStretch', category: ExerciseCategory.cooldown, mode: ExerciseMode.time, met: 2.3),
];

final Map<String, Exercise> _byKey = {for (final e in exerciseCatalog) e.key: e};

/// Упражнение по ключу; неизвестный ключ (например, из программы ИИ) — null.
Exercise? exerciseByKey(String key) => _byKey[key];

/// MET для отдыха между подходами (стоя/сидя, восстановление).
const restMet = 1.5;

/// MET по умолчанию для неизвестного упражнения.
const defaultMet = 4.0;
