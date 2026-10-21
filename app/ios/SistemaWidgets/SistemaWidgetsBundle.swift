import SwiftUI
import WidgetKit

/// Расширение виджетов и Live Activity (SPEC §8.12).
/// Данные — App Group (SistemaAppGroup), их пишет приложение через home_widget (WidgetData.swift).
@main
struct SistemaWidgetsBundle: WidgetBundle {
  var body: some Widget {
    SistemaNextQuestWidget()
    SistemaStepsWaterWidget()
    SistemaLockScreenWidget()
    SistemaLiveActivityWidget()
  }
}
