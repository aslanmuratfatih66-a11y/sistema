import Foundation

/// Данные виджетов из App Group (пишет приложение через home_widget; ключи — app/lib/core/live/live_codec.dart).
struct WidgetData {
  var nextQuestTitle: String?
  var nextQuestDeadline: Date?
  var nextQuestReward: Int
  var steps: Int
  var stepGoal: Int
  var waterMl: Int
  var waterGoalMl: Int
  var level: Int
  var diamonds: Int
  var labels: [String: String]

  static let sample = WidgetData(
    nextQuestTitle: "Прогулка 30 минут",
    nextQuestDeadline: Date().addingTimeInterval(45 * 60),
    nextQuestReward: 20,
    steps: 5400, stepGoal: 8000,
    waterMl: 1250, waterGoalMl: 2000,
    level: 7, diamonds: 340,
    labels: [:]
  )

  static func load(now: Date = Date()) -> WidgetData {
    guard let d = SistemaAppGroup.defaults else { return WidgetData.empty }
    let pending = max(0, int(d, SistemaAppGroup.pendingWaterKey))
    let today = d.string(forKey: "dataDay") == dayKey(now)
    let title = d.string(forKey: "nextQuestTitle")?.trimmingCharacters(in: .whitespacesAndNewlines)
    let deadlineSec = d.object(forKey: "nextQuestDeadlineSec") as? NSNumber
    var labels: [String: String] = [:]
    for key in labelKeys {
      if let v = d.string(forKey: key), !v.isEmpty { labels[key] = v }
    }
    return WidgetData(
      nextQuestTitle: (title?.isEmpty ?? true) ? nil : title,
      nextQuestDeadline: deadlineSec.map { Date(timeIntervalSince1970: $0.doubleValue) },
      nextQuestReward: int(d, "nextQuestReward"),
      steps: today ? max(0, int(d, "steps")) : 0,
      stepGoal: int(d, "stepGoal", fallback: 8000),
      // waterMl уже включает очередь (её добавляют и Dart, и AddWaterIntent); в новый день — только очередь.
      waterMl: today ? max(0, int(d, "waterMl")) : pending,
      waterGoalMl: int(d, "waterGoalMl"),
      level: max(1, int(d, "level", fallback: 1)),
      diamonds: int(d, "diamonds"),
      labels: labels
    )
  }

  static let empty = WidgetData(
    nextQuestTitle: nil, nextQuestDeadline: nil, nextQuestReward: 0,
    steps: 0, stepGoal: 8000, waterMl: 0, waterGoalMl: 0, level: 1, diamonds: 0, labels: [:]
  )

  func label(_ key: String) -> String {
    labels[key] ?? WidgetData.fallback[key] ?? key
  }

  var stepsProgress: Double { stepGoal > 0 ? min(1, Double(steps) / Double(stepGoal)) : 0 }
  var waterProgress: Double { waterGoalMl > 0 ? min(1, Double(waterMl) / Double(waterGoalMl)) : 0 }

  func isOverdue(at date: Date) -> Bool {
    guard let d = nextQuestDeadline else { return false }
    return d <= date
  }

  // MARK: - helpers

  private static func int(_ d: UserDefaults, _ key: String, fallback: Int = 0) -> Int {
    (d.object(forKey: key) as? NSNumber)?.intValue ?? fallback
  }

  static func dayKey(_ date: Date) -> String {
    let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
    return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
  }

  private static let labelKeys = Array(fallback.keys)

  /// Фолбэк — русский (как в l10n_parts/liv_ru.arb).
  static let fallback: [String: String] = [
    "lblNextQuest": "Следующий квест",
    "lblNoQuest": "Квестов нет",
    "lblOverdue": "Просрочен",
    "lblSteps": "Шаги",
    "lblWater": "Вода",
    "lblAddWater": "+250 мл",
    "lblMl": "мл",
    "lblKm": "км",
    "lblPerKm": "/км",
    "lblReward": "Награда",
    "lblWalk": "Прогулка",
    "lblQuest": "Квест",
    "lblWorkout": "Тренировка",
  ]
}
