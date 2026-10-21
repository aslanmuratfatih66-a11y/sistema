import Flutter
import Foundation

/// Live Activity (ActivityKit, SistemaActivityAttributes), очередь воды из App Intent. Контракт — app/lib/core/live/live_api.dart.
/// КАРКАС: реализация — сабагент D (этап 4).
final class LiveActivityChannel {
  static let name = "sistema/live"

  private let channel: FlutterMethodChannel

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: LiveActivityChannel.name, binaryMessenger: messenger)
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
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
