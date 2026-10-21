import AppIntents
import SwiftUI
import WidgetKit

// Виджеты рабочего стола и экрана блокировки (SPEC §8.12). Kind'ы — WidgetKinds в live_codec.dart.

enum SistemaStyle {
  static let accent = Color(red: 0.30, green: 0.75, blue: 1.0)
  static let gold = Color(red: 1.0, green: 0.80, blue: 0.30)
  static let danger = Color(red: 1.0, green: 0.35, blue: 0.35)
  static let water = Color(red: 0.35, green: 0.65, blue: 1.0)
  static let background = LinearGradient(
    colors: [Color(red: 0.03, green: 0.05, blue: 0.12), Color(red: 0.06, green: 0.10, blue: 0.22)],
    startPoint: .topLeading, endPoint: .bottomTrailing
  )
}

// MARK: - Timeline

struct SistemaEntry: TimelineEntry {
  let date: Date
  let data: WidgetData
}

struct SistemaProvider: TimelineProvider {
  func placeholder(in context: Context) -> SistemaEntry {
    SistemaEntry(date: Date(), data: .sample)
  }

  func getSnapshot(in context: Context, completion: @escaping (SistemaEntry) -> Void) {
    completion(SistemaEntry(date: Date(), data: context.isPreview ? .sample : WidgetData.load()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<SistemaEntry>) -> Void) {
    let now = Date()
    let data = WidgetData.load(now: now)
    var entries = [SistemaEntry(date: now, data: data)]
    // Перерисовка в момент дедлайна («Просрочен») и после полуночи (новый день — шаги/вода с нуля).
    if let deadline = data.nextQuestDeadline, deadline > now, deadline < now.addingTimeInterval(24 * 3600) {
      entries.append(SistemaEntry(date: deadline, data: data))
    }
    let midnight = Calendar.current.startOfDay(for: now).addingTimeInterval(24 * 3600 + 60)
    let refresh = min(now.addingTimeInterval(30 * 60), midnight)
    completion(Timeline(entries: entries, policy: .after(refresh)))
  }
}

// MARK: - Общие элементы

struct CountdownText: View {
  let endsAt: Date
  let now: Date

  var body: some View {
    if endsAt > now {
      Text(timerInterval: now...endsAt, countsDown: true)
        .monospacedDigit()
    } else {
      Text("0:00").monospacedDigit()
    }
  }
}

struct QuestBlock: View {
  let entry: SistemaEntry
  var compact = false

  var body: some View {
    let d = entry.data
    VStack(alignment: .leading, spacing: 4) {
      Text(d.label("lblNextQuest").uppercased())
        .font(.system(size: 10, weight: .semibold))
        .foregroundStyle(SistemaStyle.accent)
      if let title = d.nextQuestTitle {
        Text(title)
          .font(.system(size: compact ? 13 : 15, weight: .bold))
          .foregroundStyle(.white)
          .lineLimit(compact ? 2 : 3)
        if let deadline = d.nextQuestDeadline {
          if d.isOverdue(at: entry.date) {
            Text(d.label("lblOverdue"))
              .font(.system(size: 13, weight: .semibold))
              .foregroundStyle(SistemaStyle.danger)
          } else {
            CountdownText(endsAt: deadline, now: entry.date)
              .font(.system(size: compact ? 18 : 22, weight: .heavy))
              .foregroundStyle(.white)
          }
        }
        if d.nextQuestReward > 0 {
          Text("◆ \(d.nextQuestReward)")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(SistemaStyle.gold)
        }
      } else {
        Text(d.label("lblNoQuest"))
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(.white.opacity(0.7))
      }
    }
  }
}

struct MetricRow: View {
  let icon: String
  let label: String
  let value: String
  let progress: Double
  let tint: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 3) {
      HStack(spacing: 4) {
        Image(systemName: icon).font(.system(size: 10))
        Text(label).font(.system(size: 10, weight: .semibold))
        Spacer(minLength: 2)
        Text(value).font(.system(size: 11, weight: .bold)).monospacedDigit()
      }
      .foregroundStyle(.white)
      ProgressView(value: progress)
        .tint(tint)
    }
  }
}

struct AddWaterButton: View {
  let title: String

  var body: some View {
    Button(intent: AddWaterIntent(ml: 250)) {
      Label(title, systemImage: "drop.fill")
        .font(.system(size: 12, weight: .bold))
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.borderedProminent)
    .tint(SistemaStyle.water)
  }
}

struct StepsWaterBlock: View {
  let data: WidgetData

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      MetricRow(
        icon: "figure.walk", label: data.label("lblSteps"),
        value: "\(data.steps)/\(data.stepGoal)", progress: data.stepsProgress, tint: SistemaStyle.accent
      )
      MetricRow(
        icon: "drop.fill", label: data.label("lblWater"),
        value: data.waterGoalMl > 0
          ? "\(data.waterMl)/\(data.waterGoalMl)" : "\(data.waterMl) \(data.label("lblMl"))",
        progress: data.waterProgress, tint: SistemaStyle.water
      )
      AddWaterButton(title: data.label("lblAddWater"))
    }
  }
}

// MARK: - «Следующий квест» (малый: квест + таймер; средний: + шаги, вода, кнопка)

struct NextQuestView: View {
  @Environment(\.widgetFamily) var family
  let entry: SistemaEntry

  var body: some View {
    Group {
      if family == .systemMedium {
        HStack(alignment: .top, spacing: 12) {
          QuestBlock(entry: entry).frame(maxWidth: .infinity, alignment: .leading)
          StepsWaterBlock(data: entry.data).frame(maxWidth: .infinity)
        }
      } else {
        QuestBlock(entry: entry)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      }
    }
    .containerBackground(for: .widget) { SistemaStyle.background }
  }
}

struct SistemaNextQuestWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "SistemaNextQuest", provider: SistemaProvider()) { entry in
      NextQuestView(entry: entry)
    }
    .configurationDisplayName("Система")
    .description("Следующий квест, шаги и вода")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

// MARK: - «Шаги и вода»

struct SistemaStepsWaterWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "SistemaStepsWater", provider: SistemaProvider()) { entry in
      StepsWaterBlock(data: entry.data)
        .containerBackground(for: .widget) { SistemaStyle.background }
    }
    .configurationDisplayName("Шаги и вода")
    .description("Шаги, вода и кнопка +250 мл")
    .supportedFamilies([.systemSmall])
  }
}

// MARK: - Экран блокировки: уровень, баллы, следующий квест

struct LockScreenView: View {
  @Environment(\.widgetFamily) var family
  let entry: SistemaEntry

  var body: some View {
    let d = entry.data
    switch family {
    case .accessoryCircular:
      ZStack {
        AccessoryWidgetBackground()
        VStack(spacing: 0) {
          Text("LV").font(.system(size: 9, weight: .semibold))
          Text("\(d.level)").font(.system(size: 18, weight: .heavy)).minimumScaleFactor(0.6)
        }
      }
      .containerBackground(for: .widget) { Color.clear }
    case .accessoryInline:
      Text("LV \(d.level) · ◆ \(d.diamonds)")
        .containerBackground(for: .widget) { Color.clear }
    default:
      VStack(alignment: .leading, spacing: 1) {
        Text("LV \(d.level) · ◆ \(d.diamonds)")
          .font(.system(size: 13, weight: .bold))
        if let title = d.nextQuestTitle {
          Text(title).font(.system(size: 13)).lineLimit(1)
          if let deadline = d.nextQuestDeadline {
            if d.isOverdue(at: entry.date) {
              Text(d.label("lblOverdue")).font(.system(size: 12, weight: .semibold))
            } else {
              CountdownText(endsAt: deadline, now: entry.date).font(.system(size: 12, weight: .semibold))
            }
          }
        } else {
          Text(d.label("lblNoQuest")).font(.system(size: 13)).lineLimit(1)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .containerBackground(for: .widget) { Color.clear }
    }
  }
}

struct SistemaLockScreenWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "SistemaLockScreen", provider: SistemaProvider()) { entry in
      LockScreenView(entry: entry)
    }
    .configurationDisplayName("Система")
    .description("Уровень, баллы и следующий квест")
    .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline])
  }
}
