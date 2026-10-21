// Live Activity и виджеты (SPEC §8.12). КОНТРАКТ каркаса этапа 4.
// Реализация — сабагент D: iOS — ActivityKit (ios/Runner/LiveActivityChannel.swift, канал `sistema/live`,
// атрибуты SistemaActivityAttributes в ios/Shared/SistemaShared.swift) и WidgetKit (ios/SistemaWidgets);
// Android — постоянное уведомление вместо Live Activity и AppWidget (home_widget).
// App Group: group.com.sistema.sistema. Вода из App Intent копится в очереди pendingWaterMl.
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Что показывает Live Activity.
enum LiveKind { walk, quest, workout }

@immutable
class LiveState {
  const LiveState({
    required this.title,
    this.subtitle = '',
    this.endsAt,
    this.distanceM,
    this.paceSecPerKm,
    this.progress,
  });

  final String title;
  final String subtitle;
  final DateTime? endsAt;
  final double? distanceM;
  final double? paceSecPerKm;
  final double? progress;
}

abstract interface class LiveActivityService {
  Future<bool> isSupported();

  /// Запустить; возвращает id или null (не поддерживается/запрещено).
  Future<String?> start(LiveKind kind, LiveState state);
  Future<void> update(String id, LiveState state);
  Future<void> end(String id);
}

/// Данные виджетов и экрана блокировки.
@immutable
class WidgetSnapshot {
  const WidgetSnapshot({
    this.nextQuestTitle,
    this.nextQuestDeadline,
    this.steps = 0,
    this.stepGoal = 8000,
    this.waterMl = 0,
    this.waterGoalMl = 0,
    this.level = 1,
    this.diamonds = 0,
  });

  final String? nextQuestTitle;
  final DateTime? nextQuestDeadline;
  final int steps;
  final int stepGoal;
  final int waterMl;
  final int waterGoalMl;
  final int level;
  final int diamonds;
}

abstract interface class WidgetSync {
  /// Записать данные в App Group / SharedPreferences и перерисовать виджеты.
  Future<void> update(WidgetSnapshot snapshot);

  /// Забрать воду, добавленную кнопкой виджета/App Intent, пока приложение было закрыто (мл).
  Future<int> takePendingWater();
}

/// Переопределяются в main реализацией D. По умолчанию — ничего (тесты, предпросмотр, веб).
final liveActivityServiceProvider = Provider<LiveActivityService>((ref) => const NoLiveActivityService());
final widgetSyncProvider = Provider<WidgetSync>((ref) => const NoWidgetSync());

class NoLiveActivityService implements LiveActivityService {
  const NoLiveActivityService();

  @override
  Future<bool> isSupported() async => false;

  @override
  Future<String?> start(LiveKind kind, LiveState state) async => null;

  @override
  Future<void> update(String id, LiveState state) async {}

  @override
  Future<void> end(String id) async {}
}

class NoWidgetSync implements WidgetSync {
  const NoWidgetSync();

  @override
  Future<void> update(WidgetSnapshot snapshot) async {}

  @override
  Future<int> takePendingWater() async => 0;
}
