// Оценка расхода тренировки: ккал = MET × вес_кг × часы (по каждому упражнению, отдых — [restMet]).
import '../model/exercise_catalog.dart';

/// Вес, если замеров нет (с пометкой «оценка по весу 70 кг»).
const fallbackWeightKg = 70.0;

double workoutKcal({
  required Map<String, int> workSecondsByExercise,
  int restSeconds = 0,
  required double weightKg,
}) {
  var kcal = 0.0;
  for (final e in workSecondsByExercise.entries) {
    final met = exerciseByKey(e.key)?.met ?? defaultMet;
    kcal += met * weightKg * e.value / 3600;
  }
  kcal += restMet * weightKg * restSeconds / 3600;
  return kcal;
}
