import Flutter
import Foundation

/// Now Playing Apple Music (MPMusicPlayerController) и голос поверх музыки (AVAudioSession duckOthers). Контракт — app/lib/core/audio/audio_api.dart.
/// КАРКАС: реализация — сабагент B (этап 4).
final class NowPlayingChannel {
  static let name = "sistema/audio"

  private let channel: FlutterMethodChannel

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: NowPlayingChannel.name, binaryMessenger: messenger)
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
