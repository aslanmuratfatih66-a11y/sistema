// Исходные данные для программы: анкета (training, health) и принятый план (квест training).
import '../model/exercise_catalog.dart';

class TrainingProfile {
  const TrainingProfile({
    this.level = WorkoutLevel.beginner,
    this.minutesPerSession = 20,
    this.equipment = const {},
    this.weekdays = const [DateTime.monday, DateTime.wednesday, DateTime.friday],
    this.limitations = false,
    this.levelKnown = true,
  });

  /// Анкета (training.level/minutesPerDay/equipment/days, health.injuries) + квесты плана.
  /// План важнее анкеты: пользователь мог поправить минуты/дни при принятии.
  factory TrainingProfile.fromSources({
    required Map<String, Object?> training,
    Map<String, Object?> health = const {},
    int? planMinutes,
    List<int> planWeekdays = const [],
  }) {
    final level = WorkoutLevel.values.where((l) => l.name == training['level']).firstOrNull;
    final minutesRaw = planMinutes ?? (training['minutesPerDay'] is num ? (training['minutesPerDay']! as num).round() : null);
    final eq = training['equipment'];
    final days = planWeekdays.isNotEmpty
        ? planWeekdays
        : [
            for (final d in (training['days'] is List ? training['days']! as List : const []))
              if (d is num && d >= 1 && d <= 7) d.round(),
          ];
    final injuries = health['injuries'];
    return TrainingProfile(
      level: level ?? WorkoutLevel.beginner,
      levelKnown: level != null,
      minutesPerSession: (minutesRaw ?? 20).clamp(10, 90),
      equipment: {
        if (eq is List)
          for (final e in eq)
            if (e is String && e != 'none') e,
      },
      weekdays: days.isEmpty ? const [DateTime.monday, DateTime.wednesday, DateTime.friday] : ({...days}.toList()..sort()),
      limitations: injuries is String && injuries.trim().isNotEmpty,
    );
  }

  final WorkoutLevel level;

  /// Уровень не указан в анкете — взят «новичок» (показывается пометка).
  final bool levelKnown;
  final int minutesPerSession;
  final Set<String> equipment;
  final List<int> weekdays;

  /// Указаны травмы/ограничения — щадящая программа.
  final bool limitations;
}
