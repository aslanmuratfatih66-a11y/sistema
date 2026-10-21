// Общий код приложения и расширения SistemaWidgets (файл входит в оба таргета).
// КОНТРАКТ каркаса этапа 4: App Group, атрибуты Live Activity, App Intent «+250 мл воды».
// Правит главный агент; содержимое виджетов и Live Activity — сабагент D (ios/SistemaWidgets).
import Foundation

#if canImport(ActivityKit)
  import ActivityKit
#endif
#if canImport(AppIntents)
  import AppIntents
#endif
#if canImport(WidgetKit)
  import WidgetKit
#endif

/// App Group: данные виджетов (home_widget) и очередь воды из App Intent.
enum SistemaAppGroup {
  static let id = "group.com.sistema.sistema"

  static var defaults: UserDefaults? { UserDefaults(suiteName: id) }

  /// Выпито через виджет/Intent, ещё не перенесено в БД приложения (мл). Приложение забирает и обнуляет.
  static let pendingWaterKey = "pendingWaterMl"

  static func addPendingWater(_ ml: Int) {
    guard let d = defaults else { return }
    d.set(d.integer(forKey: pendingWaterKey) + ml, forKey: pendingWaterKey)
    // Мгновенный отклик виджета: выпито сегодня (ключ home_widget, пишет и Dart).
    d.set(d.integer(forKey: "waterMl") + ml, forKey: "waterMl")
  }

  /// Забрать очередь воды (вызывает приложение через канал sistema/live).
  static func takePendingWater() -> Int {
    guard let d = defaults else { return 0 }
    let ml = d.integer(forKey: pendingWaterKey)
    d.set(0, forKey: pendingWaterKey)
    return ml
  }
}

#if canImport(ActivityKit)
  /// Live Activity: прогулка, активный квест, тренировка (SPEC §8.12).
  @available(iOS 16.1, *)
  struct SistemaActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
      /// Заголовок: название квеста / «Прогулка» / упражнение.
      var title: String
      /// Подзаголовок: следующее действие («Через 200 м — налево, ускорься»).
      var subtitle: String
      /// Конец таймера (дедлайн квеста, конец отрезка); nil — без таймера.
      var endsAt: Date?
      var distanceM: Double?
      var paceSecPerKm: Double?
      /// 0…1 — прогресс (маршрут, тренировка).
      var progress: Double?
    }

    /// "walk" | "quest" | "workout"
    var kind: String
  }
#endif

#if canImport(AppIntents)
  /// «+250 мл воды» из виджета (интерактивная кнопка, iOS 17+) и из «Команд».
  @available(iOS 17.0, *)
  struct AddWaterIntent: AppIntent {
    static var title: LocalizedStringResource = "+250 мл воды"
    static var description = IntentDescription("Записать стакан воды в «Систему».")

    @Parameter(title: "Миллилитры", default: 250)
    var ml: Int

    init() {}

    init(ml: Int) {
      self.ml = ml
    }

    func perform() async throws -> some IntentResult {
      SistemaAppGroup.addPendingWater(ml)
      #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
      #endif
      return .result()
    }
  }
#endif
