import ActivityKit
import SwiftUI
import WidgetKit

// Live Activity (SPEC §8.12): прогулка — дистанция/темп/следующее действие; квест и тренировка — таймер.
// Состояние приходит из приложения (ios/Runner/LiveActivityChannel.swift), подписи — из App Group.

enum LiveFormat {
  static func distance(_ m: Double?, km: String) -> String? {
    guard let m = m, m.isFinite, m >= 0 else { return nil }
    return String(format: "%.2f %@", m / 1000.0, km)
  }

  static func pace(_ secPerKm: Double?, perKm: String) -> String? {
    guard let p = secPerKm, p.isFinite, p > 0, p < 60 * 60 else { return nil }
    let s = Int(p.rounded())
    return String(format: "%d:%02d %@", s / 60, s % 60, perKm)
  }

  static func icon(_ kind: String) -> String {
    switch kind {
    case "walk": return "figure.walk"
    case "workout": return "dumbbell.fill"
    default: return "bolt.fill"
    }
  }

  static func kindLabel(_ kind: String, _ data: WidgetData) -> String {
    switch kind {
    case "walk": return data.label("lblWalk")
    case "workout": return data.label("lblWorkout")
    default: return data.label("lblQuest")
    }
  }
}

struct LiveTimer: View {
  let endsAt: Date?

  var body: some View {
    if let endsAt = endsAt {
      CountdownText(endsAt: endsAt, now: Date())
    }
  }
}

struct LiveWalkStats: View {
  let state: SistemaActivityAttributes.ContentState
  let labels: WidgetData

  var body: some View {
    HStack(spacing: 10) {
      if let d = LiveFormat.distance(state.distanceM, km: labels.label("lblKm")) {
        Text(d).font(.system(size: 15, weight: .bold)).monospacedDigit()
      }
      if let p = LiveFormat.pace(state.paceSecPerKm, perKm: labels.label("lblPerKm")) {
        Text(p).font(.system(size: 13, weight: .semibold)).monospacedDigit()
          .foregroundStyle(.white.opacity(0.8))
      }
    }
  }
}

/// Экран блокировки / баннер.
struct LiveLockScreenView: View {
  let context: ActivityViewContext<SistemaActivityAttributes>

  var body: some View {
    let s = context.state
    let kind = context.attributes.kind
    let labels = WidgetData.load()
    VStack(alignment: .leading, spacing: 6) {
      HStack(spacing: 6) {
        Image(systemName: LiveFormat.icon(kind)).foregroundStyle(SistemaStyle.accent)
        Text(LiveFormat.kindLabel(kind, labels).uppercased())
          .font(.system(size: 11, weight: .semibold))
          .foregroundStyle(SistemaStyle.accent)
        Spacer()
        LiveTimer(endsAt: s.endsAt)
          .font(.system(size: 20, weight: .heavy))
          .foregroundStyle(.white)
          .frame(maxWidth: 110, alignment: .trailing)
      }
      Text(s.title)
        .font(.system(size: 16, weight: .bold))
        .foregroundStyle(.white)
        .lineLimit(1)
      if kind == "walk" {
        LiveWalkStats(state: s, labels: labels)
          .foregroundStyle(.white)
      }
      if !s.subtitle.isEmpty {
        Text(s.subtitle)
          .font(.system(size: 13))
          .foregroundStyle(.white.opacity(0.85))
          .lineLimit(2)
      }
      if let p = s.progress {
        ProgressView(value: min(max(p, 0), 1)).tint(SistemaStyle.accent)
      }
    }
    .padding(14)
  }
}

struct SistemaLiveActivityWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: SistemaActivityAttributes.self) { context in
      LiveLockScreenView(context: context)
        .activityBackgroundTint(Color(red: 0.03, green: 0.05, blue: 0.12))
        .activitySystemActionForegroundColor(SistemaStyle.accent)
    } dynamicIsland: { context in
      let s = context.state
      let kind = context.attributes.kind
      let labels = WidgetData.load()
      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Label(LiveFormat.kindLabel(kind, labels), systemImage: LiveFormat.icon(kind))
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(SistemaStyle.accent)
        }
        DynamicIslandExpandedRegion(.trailing) {
          LiveTimer(endsAt: s.endsAt)
            .font(.system(size: 16, weight: .bold))
            .frame(maxWidth: 80, alignment: .trailing)
        }
        DynamicIslandExpandedRegion(.center) {
          Text(s.title).font(.system(size: 14, weight: .bold)).lineLimit(1)
        }
        DynamicIslandExpandedRegion(.bottom) {
          VStack(alignment: .leading, spacing: 4) {
            if kind == "walk" {
              LiveWalkStats(state: s, labels: labels)
            }
            if !s.subtitle.isEmpty {
              Text(s.subtitle).font(.system(size: 12)).lineLimit(2)
            }
            if let p = s.progress {
              ProgressView(value: min(max(p, 0), 1)).tint(SistemaStyle.accent)
            }
          }
          .frame(maxWidth: .infinity, alignment: .leading)
        }
      } compactLeading: {
        Image(systemName: LiveFormat.icon(kind)).foregroundStyle(SistemaStyle.accent)
      } compactTrailing: {
        if s.endsAt != nil {
          LiveTimer(endsAt: s.endsAt).frame(maxWidth: 52)
        } else if let d = LiveFormat.distance(s.distanceM, km: labels.label("lblKm")) {
          Text(d).font(.system(size: 12, weight: .semibold)).monospacedDigit()
        } else {
          Text(s.title).lineLimit(1).frame(maxWidth: 52)
        }
      } minimal: {
        Image(systemName: LiveFormat.icon(kind)).foregroundStyle(SistemaStyle.accent)
      }
    }
  }
}
