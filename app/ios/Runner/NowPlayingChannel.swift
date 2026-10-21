import AVFoundation
import Flutter
import Foundation
import MediaPlayer
import UIKit

/// Now Playing Apple Music (MPMusicPlayerController.systemMusicPlayer) и управление им.
/// Протокол — шапка app/lib/core/audio/channel_music_controller.dart; контракт — audio_api.dart.
/// Голос поверх музыки (duckOthers) настраивается из Dart через audio_session, здесь не нужен.
///
/// - MethodChannel `sistema/audio`: requestAccess, getNowPlaying, playPause, next, previous, isSpotifyInstalled.
/// - EventChannel `sistema/audio/events`: Map? при смене трека/состояния; первое значение — сразу при подписке.
///   Apple Music — по уведомлениям плеера; чужие приложения (без названия) — опрос isOtherAudioPlaying.
final class NowPlayingChannel: NSObject, FlutterStreamHandler {
  static let name = "sistema/audio"
  static let eventsName = "sistema/audio/events"

  private let channel: FlutterMethodChannel
  private let events: FlutterEventChannel
  private var sink: FlutterEventSink?
  private var observers: [NSObjectProtocol] = []
  private var pollTimer: Timer?
  private var lastSent: NSDictionary?
  private var sentOnce = false
  private var generating = false

  private var player: MPMusicPlayerController { MPMusicPlayerController.systemMusicPlayer }

  private var authorized: Bool { MPMediaLibrary.authorizationStatus() == .authorized }

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: NowPlayingChannel.name, binaryMessenger: messenger)
    events = FlutterEventChannel(name: NowPlayingChannel.eventsName, binaryMessenger: messenger)
    super.init()
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.handle(call, result: result)
    }
    events.setStreamHandler(self)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "requestAccess":
      requestAccess(result)
    case "getNowPlaying":
      result(snapshot())
    case "playPause":
      if authorized {
        if player.playbackState == .playing { player.pause() } else { player.play() }
      }
      result(nil)
    case "next":
      if authorized { player.skipToNextItem() }
      result(nil)
    case "previous":
      if authorized { player.skipToPreviousItem() }
      result(nil)
    case "isSpotifyInstalled":
      if let url = URL(string: "spotify:") {
        result(UIApplication.shared.canOpenURL(url))
      } else {
        result(false)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func requestAccess(_ result: @escaping FlutterResult) {
    switch MPMediaLibrary.authorizationStatus() {
    case .authorized:
      startPlayerNotifications()
      result(true)
    case .notDetermined:
      MPMediaLibrary.requestAuthorization { [weak self] status in
        DispatchQueue.main.async {
          let ok = status == .authorized
          if ok {
            self?.startPlayerNotifications()
            self?.send()
          }
          result(ok)
        }
      }
    default:
      result(false)
    }
  }

  /// Текущее состояние в формате протокола; nil — ничего не играет.
  private func snapshot() -> [String: Any]? {
    if authorized {
      let state = player.playbackState
      if let item = player.nowPlayingItem {
        var map: [String: Any] = ["source": "appleMusic", "isPlaying": state == .playing]
        if let title = item.title { map["title"] = title }
        if let artist = item.artist { map["artist"] = artist }
        return map
      }
      if state == .playing { return ["source": "appleMusic", "isPlaying": true] }
    }
    if AVAudioSession.sharedInstance().isOtherAudioPlaying {
      return ["source": "other", "isPlaying": true]
    }
    return nil
  }

  private func send() {
    guard let sink = sink else { return }
    let value = snapshot()
    let dict = value.map { NSDictionary(dictionary: $0) }
    if sentOnce && dict == lastSent { return }
    sentOnce = true
    lastSent = dict
    sink(value ?? NSNull())
  }

  private func startPlayerNotifications() {
    guard !generating, sink != nil, authorized else { return }
    generating = true
    player.beginGeneratingPlaybackNotifications()
    let center = NotificationCenter.default
    for name in [
      Notification.Name.MPMusicPlayerControllerNowPlayingItemDidChange,
      Notification.Name.MPMusicPlayerControllerPlaybackStateDidChange,
    ] {
      observers.append(
        center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in self?.send() })
    }
  }

  private func stopPlayerNotifications() {
    observers.forEach { NotificationCenter.default.removeObserver($0) }
    observers.removeAll()
    if generating {
      player.endGeneratingPlaybackNotifications()
      generating = false
    }
  }

  // MARK: FlutterStreamHandler

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sink = events
    sentOnce = false
    lastSent = nil
    startPlayerNotifications()
    // Чужие плееры уведомлений не шлют — опрашиваем.
    pollTimer?.invalidate()
    pollTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] _ in self?.send() }
    send()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    pollTimer?.invalidate()
    pollTimer = nil
    stopPlayerNotifications()
    sink = nil
    return nil
  }
}
