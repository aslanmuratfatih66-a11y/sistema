import AVFoundation
import AudioToolbox
import Flutter
import Foundation

#if canImport(AlarmKit)
  import AlarmKit
  import AppIntents
  import SwiftUI
#endif

// Будильник-квест (SPEC §8.11): AlarmKit (iOS 26+), канал "sistema/alarm".
// Контракт — app/lib/core/alarm/alarm_api.dart, Dart-сторона — channel_alarm_scheduler.dart:
//   isAvailable → Bool (AlarmKit авторизован)
//   permissionState → {available, alarmKit: authorized|denied|notDetermined|unsupported}
//   requestPermission → Bool
//   schedule {entries: [{key, id, atMs, title, body}], labels: {doTask, stop}} → Bool (запланировано в AlarmKit)
//   cancelAll
//   pendingRing → {id, firedAtMs} | nil
//   ringStart {id} — звук в приложении, пока открыт экран задания; stop {id}
// Из натива в Dart: onRing {id, firedAtMs} (звонок AlarmKit, пока приложение запущено).
// Если AlarmKit недоступен — Dart ставит серию громких уведомлений (alarm_fallback_notifications.dart).
// Обе кнопки звонка («Выполнить задание» и «Стоп») открывают приложение (App Intent с openAppWhenRun):
// выключить будильник без задания нельзя — в Dart по времени определяется «звонящий» будильник.

#if canImport(AlarmKit)
  @available(iOS 26.0, *)
  struct SistemaAlarmMetadata: AlarmMetadata {}

  /// Кнопка звонка AlarmKit → открыть приложение на экране задания.
  @available(iOS 26.0, *)
  struct SistemaAlarmOpenIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Alarm task"
    static var openAppWhenRun: Bool = true
    static var isDiscoverable: Bool = false

    @Parameter(title: "Alarm")
    var alarmID: String

    init() {
      self.alarmID = ""
    }

    init(alarmID: String) {
      self.alarmID = alarmID
    }

    func perform() async throws -> some IntentResult {
      AlarmKitChannel.markOpened(uuid: alarmID)
      return .result()
    }
  }
#endif

final class AlarmKitChannel {
  private let channel: FlutterMethodChannel
  private var player: AVAudioPlayer?
  private var vibrateTimer: Timer?
  private var sessionActivated = false
  private var observeTask: Task<Void, Never>?
  private var notified = Set<String>()

  /// [uuid AlarmKit: id будильника Dart] и [uuid: время срабатывания, мс].
  private static let mapKey = "sistema.alarm.map"
  private static let atKey = "sistema.alarm.at"
  private static let openedKey = "sistema.alarm.opened"
  private static let openedAtKey = "sistema.alarm.openedAt"

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "sistema/alarm", binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(FlutterMethodNotImplemented)
        return
      }
      self.handle(call, result: result)
    }
    startObserving()
  }

  deinit {
    observeTask?.cancel()
  }

  // MARK: - Хранилище соответствий

  private static var defaults: UserDefaults { UserDefaults.standard }

  private static func loadMap() -> [String: String] {
    defaults.dictionary(forKey: mapKey) as? [String: String] ?? [:]
  }

  private static func loadAt() -> [String: Double] {
    defaults.dictionary(forKey: atKey) as? [String: Double] ?? [:]
  }

  private static func save(map: [String: String], at: [String: Double]) {
    defaults.set(map, forKey: mapKey)
    defaults.set(at, forKey: atKey)
  }

  /// Вызывается App Intent кнопки звонка (в процессе приложения).
  static func markOpened(uuid: String) {
    defaults.set(uuid, forKey: openedKey)
    defaults.set(Date().timeIntervalSince1970 * 1000, forKey: openedAtKey)
  }

  private static func clearOpened() {
    defaults.removeObject(forKey: openedKey)
    defaults.removeObject(forKey: openedAtKey)
  }

  // MARK: - Канал

  private func reply(_ result: @escaping FlutterResult, _ value: Any?) {
    DispatchQueue.main.async { result(value) }
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "isAvailable":
      result(authorizationString() == "authorized")
    case "permissionState":
      let s = authorizationString()
      result(["available": s == "authorized", "alarmKit": s])
    case "requestPermission":
      requestAuthorization { granted in self.reply(result, granted) }
    case "schedule":
      let entries = args["entries"] as? [[String: Any]] ?? []
      let labels = args["labels"] as? [String: Any] ?? [:]
      schedule(entries: entries, labels: labels) { ok in self.reply(result, ok) }
    case "cancelAll":
      cancelAll()
      result(nil)
    case "pendingRing":
      result(pendingRing())
    case "ringStart":
      startSound()
      result(nil)
    case "stop":
      stopSound()
      stop(alarmId: args["id"] as? String)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - AlarmKit

  private func authorizationString() -> String {
    #if canImport(AlarmKit)
      if #available(iOS 26.0, *) {
        switch AlarmManager.shared.authorizationState {
        case .authorized: return "authorized"
        case .denied: return "denied"
        case .notDetermined: return "notDetermined"
        @unknown default: return "denied"
        }
      }
    #endif
    return "unsupported"
  }

  private func requestAuthorization(_ done: @escaping (Bool) -> Void) {
    #if canImport(AlarmKit)
      if #available(iOS 26.0, *) {
        Task {
          do {
            let state = try await AlarmManager.shared.requestAuthorization()
            done(state == .authorized)
          } catch {
            done(false)
          }
        }
        return
      }
    #endif
    done(false)
  }

  private func schedule(entries: [[String: Any]], labels: [String: Any], _ done: @escaping (Bool) -> Void) {
    #if canImport(AlarmKit)
      if #available(iOS 26.0, *) {
        guard AlarmManager.shared.authorizationState == .authorized else {
          cancelAll()
          done(false)
          return
        }
        let doTask = labels["doTask"] as? String ?? "Open"
        let stopText = labels["stop"] as? String ?? "Stop"
        Task {
          let ok = await self.scheduleAlarmKit(entries: entries, doTask: doTask, stopText: stopText)
          done(ok)
        }
        return
      }
    #endif
    done(false)
  }

  #if canImport(AlarmKit)
    @available(iOS 26.0, *)
    private func scheduleAlarmKit(entries: [[String: Any]], doTask: String, stopText: String) async -> Bool {
      let manager = AlarmManager.shared
      cancelAll()
      var map: [String: String] = [:]
      var at: [String: Double] = [:]
      var ok = true
      let now = Date()
      for e in entries {
        guard let id = e["id"] as? String, let ms = (e["atMs"] as? NSNumber)?.doubleValue else { continue }
        let date = Date(timeIntervalSince1970: ms / 1000)
        if date <= now { continue }
        let title = (e["title"] as? String) ?? ""
        let uuid = UUID()
        let stopButton = AlarmButton(
          text: LocalizedStringResource(stringLiteral: stopText),
          textColor: .white,
          systemImageName: "stop.circle")
        let taskButton = AlarmButton(
          text: LocalizedStringResource(stringLiteral: doTask),
          textColor: .white,
          systemImageName: "figure.strengthtraining.functional")
        let alert = AlarmPresentation.Alert(
          title: LocalizedStringResource(stringLiteral: title),
          stopButton: stopButton,
          secondaryButton: taskButton,
          secondaryButtonBehavior: .custom)
        let attributes = AlarmAttributes<SistemaAlarmMetadata>(
          presentation: AlarmPresentation(alert: alert),
          metadata: SistemaAlarmMetadata(),
          tintColor: Color.blue)
        let config = AlarmManager.AlarmConfiguration<SistemaAlarmMetadata>(
          countdownDuration: nil,
          schedule: .fixed(date),
          attributes: attributes,
          stopIntent: SistemaAlarmOpenIntent(alarmID: uuid.uuidString),
          secondaryIntent: SistemaAlarmOpenIntent(alarmID: uuid.uuidString))
        do {
          _ = try await manager.schedule(id: uuid, configuration: config)
          map[uuid.uuidString] = id
          at[uuid.uuidString] = ms
        } catch {
          NSLog("AlarmKitChannel: schedule failed: \(error)")
          ok = false
        }
      }
      AlarmKitChannel.save(map: map, at: at)
      return ok
    }
  #endif

  private func cancelAll() {
    #if canImport(AlarmKit)
      if #available(iOS 26.0, *) {
        let manager = AlarmManager.shared
        var ids = Set(AlarmKitChannel.loadMap().keys.compactMap { UUID(uuidString: $0) })
        if let list = try? manager.alarms {
          for a in list { ids.insert(a.id) }
        }
        for id in ids {
          try? manager.cancel(id: id)
        }
      }
    #endif
    AlarmKitChannel.save(map: [:], at: [:])
  }

  private func stop(alarmId: String?) {
    let map = AlarmKitChannel.loadMap()
    if let opened = AlarmKitChannel.defaults.string(forKey: AlarmKitChannel.openedKey),
      alarmId == nil || map[opened] == alarmId || map[opened] == nil
    {
      AlarmKitChannel.clearOpened()
    }
    #if canImport(AlarmKit)
      if #available(iOS 26.0, *) {
        let manager = AlarmManager.shared
        for (uuid, id) in map where alarmId == nil || id == alarmId {
          guard let u = UUID(uuidString: uuid) else { continue }
          if let list = try? manager.alarms, let a = list.first(where: { $0.id == u }), a.state == .alerting {
            try? manager.stop(id: u)
          }
        }
      }
    #endif
    notified.removeAll()
  }

  private func pendingRing() -> [String: Any]? {
    let map = AlarmKitChannel.loadMap()
    let at = AlarmKitChannel.loadAt()
    #if canImport(AlarmKit)
      if #available(iOS 26.0, *) {
        if let list = try? AlarmManager.shared.alarms {
          for a in list where a.state == .alerting {
            if let id = map[a.id.uuidString] {
              return ["id": id, "firedAtMs": Int64(at[a.id.uuidString] ?? Date().timeIntervalSince1970 * 1000)]
            }
          }
        }
      }
    #endif
    // Звонок выключили кнопкой (App Intent открыл приложение).
    if let opened = AlarmKitChannel.defaults.string(forKey: AlarmKitChannel.openedKey), let id = map[opened] {
      let openedAt = AlarmKitChannel.defaults.double(forKey: AlarmKitChannel.openedAtKey)
      if Date().timeIntervalSince1970 * 1000 - openedAt < 3 * 3600 * 1000 {
        return ["id": id, "firedAtMs": Int64(at[opened] ?? openedAt)]
      }
    }
    return nil
  }

  private func startObserving() {
    #if canImport(AlarmKit)
      if #available(iOS 26.0, *) {
        observeTask = Task { [weak self] in
          for await alarms in AlarmManager.shared.alarmUpdates {
            for a in alarms where a.state == .alerting {
              let uuid = a.id.uuidString
              await MainActor.run { self?.notifyRing(uuid: uuid) }
            }
          }
        }
      }
    #endif
  }

  private func notifyRing(uuid: String) {
    guard !notified.contains(uuid), let id = AlarmKitChannel.loadMap()[uuid] else { return }
    notified.insert(uuid)
    let ms = AlarmKitChannel.loadAt()[uuid] ?? Date().timeIntervalSince1970 * 1000
    channel.invokeMethod("onRing", arguments: ["id": id, "firedAtMs": Int64(ms)])
  }

  // MARK: - Звук в приложении (экран задания)

  private func startSound() {
    if player?.isPlaying == true { return }
    let session = AVAudioSession.sharedInstance()
    do {
      // .playback — звучит и в беззвучном режиме.
      try session.setCategory(.playback, mode: .default, options: [])
      try session.setActive(true)
      sessionActivated = true
    } catch {
      NSLog("AlarmKitChannel: audio session: \(error)")
    }
    do {
      let p = try AVAudioPlayer(data: AlarmKitChannel.beepWav())
      p.numberOfLoops = -1
      p.volume = 1.0
      p.prepareToPlay()
      p.play()
      player = p
    } catch {
      NSLog("AlarmKitChannel: player: \(error)")
    }
    vibrateTimer?.invalidate()
    vibrateTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
      AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
  }

  private func stopSound() {
    player?.stop()
    player = nil
    vibrateTimer?.invalidate()
    vibrateTimer = nil
    if sessionActivated {
      try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
      sessionActivated = false
    }
  }

  /// Сигнал будильника без файлов-ресурсов: 4 коротких писка + пауза, WAV 16 бит моно.
  private static func beepWav() -> Data {
    let rate = 44100
    var samples: [Int16] = []
    func tone(_ freq: Double, _ seconds: Double) {
      let n = Int(seconds * Double(rate))
      for i in 0..<n {
        let t = Double(i) / Double(rate)
        let edge = min(1.0, Double(min(i, n - i)) / 300.0)
        samples.append(Int16(sin(2 * Double.pi * freq * t) * 0.9 * edge * 32767))
      }
    }
    func silence(_ seconds: Double) {
      samples.append(contentsOf: [Int16](repeating: 0, count: Int(seconds * Double(rate))))
    }
    for _ in 0..<4 {
      tone(1760, 0.12)
      silence(0.06)
    }
    silence(0.45)

    var data = Data()
    func u32(_ v: UInt32) {
      var x = v.littleEndian
      withUnsafeBytes(of: &x) { data.append(contentsOf: $0) }
    }
    func u16(_ v: UInt16) {
      var x = v.littleEndian
      withUnsafeBytes(of: &x) { data.append(contentsOf: $0) }
    }
    let byteCount = UInt32(samples.count * 2)
    data.append(contentsOf: Array("RIFF".utf8))
    u32(36 + byteCount)
    data.append(contentsOf: Array("WAVE".utf8))
    data.append(contentsOf: Array("fmt ".utf8))
    u32(16)
    u16(1)  // PCM
    u16(1)  // моно
    u32(UInt32(rate))
    u32(UInt32(rate * 2))
    u16(2)
    u16(16)
    data.append(contentsOf: Array("data".utf8))
    u32(byteCount)
    for s in samples {
      u16(UInt16(bitPattern: s))
    }
    return data
  }
}
