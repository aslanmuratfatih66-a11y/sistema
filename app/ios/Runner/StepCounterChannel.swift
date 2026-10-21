import CoreMotion
import Flutter

/// Канал шагов (SPEC §8.3, §12): CoreMotion / CMPedometer. Контракт — app/lib/core/activity/activity_api.dart.
///   isAvailable → Bool
///   kind → String ("coreMotion") — тип источника (StepSourceKind.name)
///   requestPermission → Bool
///   query {from: ms, to: ms} → {steps: Int, distanceM: Double?, floors: Int?} или nil (нет доступа)
/// HealthKit не используем (SPEC §3). Ответы — всегда на главном потоке.
final class StepCounterChannel {
  static let name = "sistema/steps"

  private let channel: FlutterMethodChannel
  private let pedometer = CMPedometer()

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: StepCounterChannel.name, binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isAvailable":
      result(CMPedometer.isStepCountingAvailable())
    case "kind":
      result("coreMotion")
    case "requestPermission":
      requestPermission(result: result)
    case "query":
      guard
        let args = call.arguments as? [String: Any],
        let fromMs = (args["from"] as? NSNumber)?.doubleValue,
        let toMs = (args["to"] as? NSNumber)?.doubleValue
      else {
        result(FlutterError(code: "bad_args", message: "query: нужны from и to (мс)", details: nil))
        return
      }
      query(
        from: Date(timeIntervalSince1970: fromMs / 1000),
        to: Date(timeIntervalSince1970: toMs / 1000),
        result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Статус доступа Motion & Fitness: true — есть, false — запрещён, nil — ещё не спрашивали.
  private static func authorized() -> Bool? {
    switch CMPedometer.authorizationStatus() {
    case .authorized:
      return true
    case .denied, .restricted:
      return false
    case .notDetermined:
      return nil
    @unknown default:
      return false
    }
  }

  /// Системный запрос показывается при первом обращении к CMPedometer — делаем пробный запрос
  /// за последние 10 минут и после ответа смотрим статус.
  private func requestPermission(result: @escaping FlutterResult) {
    guard CMPedometer.isStepCountingAvailable() else {
      result(false)
      return
    }
    if let known = StepCounterChannel.authorized() {
      result(known)
      return
    }
    let now = Date()
    pedometer.queryPedometerData(from: now.addingTimeInterval(-600), to: now) { _, _ in
      // Обработчик — на фоновой очереди, когда пользователь ответил; в главный поток передаём только Bool.
      let granted = StepCounterChannel.authorized() ?? false
      DispatchQueue.main.async {
        result(granted)
      }
    }
  }

  private func query(from: Date, to: Date, result: @escaping FlutterResult) {
    guard CMPedometer.isStepCountingAvailable(), from < to else {
      result(nil)
      return
    }
    // Без явного разрешения не показываем системный запрос из фонового опроса.
    guard StepCounterChannel.authorized() == true else {
      result(nil)
      return
    }
    pedometer.queryPedometerData(from: from, to: to) { data, error in
      // Значения извлекаем здесь (простые типы), объект CMPedometerData в главный поток не передаём.
      let failed = error != nil || data == nil
      let steps = data?.numberOfSteps.intValue ?? 0
      let distance = data?.distance?.doubleValue
      let floors = data?.floorsAscended?.intValue
      DispatchQueue.main.async {
        if failed {
          result(nil)
          return
        }
        var map: [String: Any] = ["steps": steps]
        if let distance = distance { map["distanceM"] = distance }
        if let floors = floors { map["floors"] = floors }
        result(map)
      }
    }
  }
}
