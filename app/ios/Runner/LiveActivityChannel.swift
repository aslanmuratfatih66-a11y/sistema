import Flutter
import Foundation

#if canImport(ActivityKit)
  import ActivityKit
#endif

/// Live Activity (ActivityKit, SistemaActivityAttributes), очередь воды из App Intent.
/// Контракт — app/lib/core/live/live_api.dart, протокол канала — app/lib/core/live/live_codec.dart:
///   isSupported → Bool
///   start {kind, title, subtitle, endsAt(ms)?, distanceM?, paceSecPerKm?, progress?} → String? (id)
///   update {id, …состояние} → nil
///   end {id} → nil
///   takePendingWater → Int (мл; очередь обнуляется)
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
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "isSupported":
      result(LiveActivityChannel.isSupported())
    case "start":
      #if canImport(ActivityKit)
        if #available(iOS 16.2, *) {
          result(LiveActivities.start(args))
          return
        }
      #endif
      result(nil)
    case "update":
      #if canImport(ActivityKit)
        if #available(iOS 16.2, *) {
          LiveActivities.update(args) { LiveActivityChannel.reply(result, nil) }
          return
        }
      #endif
      result(nil)
    case "end":
      #if canImport(ActivityKit)
        if #available(iOS 16.2, *) {
          LiveActivities.end(args) { LiveActivityChannel.reply(result, nil) }
          return
        }
      #endif
      result(nil)
    case "takePendingWater":
      result(SistemaAppGroup.takePendingWater())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private static func isSupported() -> Bool {
    #if canImport(ActivityKit)
      if #available(iOS 16.2, *) {
        return ActivityAuthorizationInfo().areActivitiesEnabled
      }
    #endif
    return false
  }

  fileprivate static func reply(_ result: @escaping FlutterResult, _ value: Any?) {
    DispatchQueue.main.async { result(value) }
  }
}

#if canImport(ActivityKit)
  @available(iOS 16.2, *)
  private enum LiveActivities {
    static func state(_ a: [String: Any]) -> SistemaActivityAttributes.ContentState {
      let endsAt = (a["endsAt"] as? NSNumber).map { Date(timeIntervalSince1970: $0.doubleValue / 1000.0) }
      return SistemaActivityAttributes.ContentState(
        title: a["title"] as? String ?? "",
        subtitle: a["subtitle"] as? String ?? "",
        endsAt: endsAt,
        distanceM: (a["distanceM"] as? NSNumber)?.doubleValue,
        paceSecPerKm: (a["paceSecPerKm"] as? NSNumber)?.doubleValue,
        progress: (a["progress"] as? NSNumber)?.doubleValue
      )
    }

    static func find(_ id: String?) -> Activity<SistemaActivityAttributes>? {
      guard let id = id else { return nil }
      return Activity<SistemaActivityAttributes>.activities.first { $0.id == id }
    }

    static func start(_ a: [String: Any]) -> String? {
      guard ActivityAuthorizationInfo().areActivitiesEnabled else { return nil }
      let kind = a["kind"] as? String ?? "quest"
      // Осиротевшие активности того же вида (приложение было выгружено) — закрываем.
      for old in Activity<SistemaActivityAttributes>.activities where old.attributes.kind == kind {
        let s = old.content.state
        Task { await old.end(ActivityContent(state: s, staleDate: nil), dismissalPolicy: .immediate) }
      }
      do {
        let activity = try Activity.request(
          attributes: SistemaActivityAttributes(kind: kind),
          content: ActivityContent(state: state(a), staleDate: nil),
          pushType: nil
        )
        return activity.id
      } catch {
        NSLog("LiveActivityChannel: start failed: \(error)")
        return nil
      }
    }

    static func update(_ a: [String: Any], done: @escaping () -> Void) {
      guard let activity = find(a["id"] as? String) else {
        done()
        return
      }
      let s = state(a)
      Task {
        await activity.update(ActivityContent(state: s, staleDate: nil))
        done()
      }
    }

    static func end(_ a: [String: Any], done: @escaping () -> Void) {
      guard let activity = find(a["id"] as? String) else {
        done()
        return
      }
      let s = activity.content.state
      Task {
        await activity.end(ActivityContent(state: s, staleDate: nil), dismissalPolicy: .immediate)
        done()
      }
    }
  }
#endif
