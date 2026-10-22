import Flutter
import Foundation

/// Будильник-квест (SPEC §8.11): AlarmKit (iOS 26+) — канал sistema/alarm. ЗАГОТОВКА каркаса этапа 7,
/// реализует сабагент E (фолбэк — серия громких уведомлений в Dart).
final class AlarmKitChannel {
  private let channel: FlutterMethodChannel

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "sistema/alarm", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "isAvailable":
        result(false)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
