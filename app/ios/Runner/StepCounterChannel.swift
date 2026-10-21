import CoreMotion
import Flutter

/// Канал шагов (SPEC §8.3, §12): CoreMotion / CMPedometer. Контракт — app/lib/core/activity/activity_api.dart.
///   isAvailable → Bool
///   requestPermission → Bool
///   query {from: ms, to: ms} → {steps: Int, distanceM: Double?, floors: Int?} или nil
/// КАРКАС: реализация — сабагент B (этап 3).
final class StepCounterChannel {
  static let name = "sistema/steps"

  private let channel: FlutterMethodChannel
  private let pedometer = CMPedometer()

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: StepCounterChannel.name, binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isAvailable":
      result(CMPedometer.isStepCountingAvailable())
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
