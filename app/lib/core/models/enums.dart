// Перечисления домена этапа 1. В БД хранятся как `name` (строка) — переименовывать нельзя,
// только добавлять. Правит главный агент.

enum Sex { male, female }

/// Коэффициенты активности для Миффлина–Сан Жеора — в features/plan.
enum ActivityLevel { sedentary, light, moderate, active, veryActive }

/// Характер нагрузки на учёбе/работе.
enum Workload { sitting, mixed, standing, physical }

enum MeasurementSource { manual, scale, aiEstimate }

enum PhotoKind { body, skin, food, receipt }

enum PhotoPose {
  bodyFront,
  bodySide,
  bodyBack,
  faceFront,
  faceLeft,
  faceRight,
  closeup,
  other,
}

enum GoalKind { acne, blackheads, swelling, weightLoss, muscle, discipline, study, money, custom }

enum InstitutionType { school, college, university, none }

enum ScheduleItemKind { lesson, work, other }

/// Разделы анкеты, хранимые как JSON в QuestionnaireSections (id = name).
enum QuestionnaireSection { skin, health, nutrition, training, finance, character, permissions }

/// Безопасный разбор `name` из БД/JSON: неизвестное значение → null.
T? enumByName<T extends Enum>(List<T> values, String? name) {
  if (name == null) return null;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}
