import Flutter
import Foundation

/// Маршруты и поиск мест (SPEC §8.5, §12): MKDirections (пешком), MKLocalSearch. Контракт — app/lib/features/walks/walks_api.dart.
/// КАРКАС: реализация — сабагент A (этап 4).
final class MapKitChannel {
  static let name = "sistema/maps"

  private let channel: FlutterMethodChannel

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: MapKitChannel.name, binaryMessenger: messenger)
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
