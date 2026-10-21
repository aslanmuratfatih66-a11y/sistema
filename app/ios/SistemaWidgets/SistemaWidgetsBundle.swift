import SwiftUI
import WidgetKit

/// Расширение виджетов и Live Activity (SPEC §8.12). КАРКАС: содержимое — сабагент D.
/// Данные — App Group (SistemaAppGroup), их пишет приложение через home_widget.
@main
struct SistemaWidgetsBundle: WidgetBundle {
  var body: some Widget {
    PlaceholderWidget()
  }
}

struct PlaceholderEntry: TimelineEntry {
  let date: Date
}

struct PlaceholderProvider: TimelineProvider {
  func placeholder(in context: Context) -> PlaceholderEntry { PlaceholderEntry(date: Date()) }

  func getSnapshot(in context: Context, completion: @escaping (PlaceholderEntry) -> Void) {
    completion(PlaceholderEntry(date: Date()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<PlaceholderEntry>) -> Void) {
    completion(Timeline(entries: [PlaceholderEntry(date: Date())], policy: .never))
  }
}

struct PlaceholderWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: "SistemaPlaceholder", provider: PlaceholderProvider()) { _ in
      Text("Система")
        .containerBackground(.black, for: .widget)
    }
    .configurationDisplayName("Система")
    .supportedFamilies([.systemSmall])
  }
}
