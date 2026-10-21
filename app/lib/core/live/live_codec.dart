// Сериализация Live Activity и данных виджетов (общие ключи Dart ↔ Swift ↔ Kotlin).
// Ключи App Group / SharedPreferences читают: ios/SistemaWidgets/WidgetData.swift,
// android/.../SistemaWidgetProvider.kt. Меняешь ключ — меняй во всех трёх местах.
import 'package:flutter/foundation.dart';

import '../../l10n/app_localizations.dart';
import 'live_api.dart';

/// Канал ActivityKit и очереди воды (ios/Runner/LiveActivityChannel.swift).
const liveChannelName = 'sistema/live';

/// App Group (SistemaAppGroup.id в ios/Shared/SistemaShared.swift).
const sistemaAppGroupId = 'group.com.sistema.sistema';

/// Имена виджетов: iOS — kind в WidgetKit, Android — класс AppWidgetProvider (относительно пакета).
abstract final class WidgetKinds {
  static const iosNextQuest = 'SistemaNextQuest';
  static const iosStepsWater = 'SistemaStepsWater';
  static const iosLockScreen = 'SistemaLockScreen';
  static const ios = [iosNextQuest, iosStepsWater, iosLockScreen];
  static const androidProvider = 'SistemaWidgetProvider';
}

/// Ключи данных виджетов (home_widget: UserDefaults(suiteName:) на iOS, HomeWidgetPreferences на Android).
abstract final class WidgetKeys {
  static const nextQuestTitle = 'nextQuestTitle';

  /// Дедлайн следующего квеста, секунды Unix (int).
  static const nextQuestDeadline = 'nextQuestDeadlineSec';
  static const nextQuestReward = 'nextQuestReward';
  static const steps = 'steps';
  static const stepGoal = 'stepGoal';

  /// Выпито сегодня (мл), включая ещё не забранную очередь. Его же увеличивают App Intent и кнопка Android.
  static const waterMl = 'waterMl';
  static const waterGoalMl = 'waterGoalMl';
  static const level = 'level';
  static const diamonds = 'diamonds';

  /// День данных «yyyy-MM-dd» (локальный): если не сегодня — шаги/вода показываются как 0 + очередь.
  static const day = 'dataDay';

  /// Очередь воды из виджета/App Intent (SistemaAppGroup.pendingWaterKey).
  static const pendingWater = 'pendingWaterMl';

  /// Подписи на языке приложения (виджеты и Live Activity берут их отсюда; фолбэк — русский).
  static const lblNextQuest = 'lblNextQuest';
  static const lblNoQuest = 'lblNoQuest';
  static const lblOverdue = 'lblOverdue';
  static const lblSteps = 'lblSteps';
  static const lblWater = 'lblWater';
  static const lblAddWater = 'lblAddWater';
  static const lblMl = 'lblMl';
  static const lblKm = 'lblKm';
  static const lblPerKm = 'lblPerKm';
  static const lblReward = 'lblReward';
  static const lblWalk = 'lblWalk';
  static const lblQuest = 'lblQuest';
  static const lblWorkout = 'lblWorkout';
}

/// Снимок с наградой следующего квеста (контракт WidgetSnapshot её не содержит).
@immutable
class WidgetSnapshotPlus extends WidgetSnapshot {
  const WidgetSnapshotPlus({
    super.nextQuestTitle,
    super.nextQuestDeadline,
    super.steps,
    super.stepGoal,
    super.waterMl,
    super.waterGoalMl,
    super.level,
    super.diamonds,
    this.nextQuestRewardDiamonds = 0,
  });

  final int nextQuestRewardDiamonds;
}

/// Только конечные числа (ActivityKit кодирует состояние в JSON — NaN/∞ ломают кодирование).
double? _finite(double? v) => v == null || !v.isFinite ? null : v;

/// Аргументы канала для состояния Live Activity. endsAt — миллисекунды Unix.
Map<String, Object?> liveStateToArgs(LiveState s) => {
      'title': s.title,
      'subtitle': s.subtitle,
      'endsAt': s.endsAt?.millisecondsSinceEpoch,
      'distanceM': _finite(s.distanceM),
      'paceSecPerKm': _finite(s.paceSecPerKm),
      'progress': _finite(s.progress)?.clamp(0.0, 1.0),
    };

String dayKey(DateTime t) =>
    '${t.year.toString().padLeft(4, '0')}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

/// Подписи виджетов на языке приложения.
Map<String, String> widgetLabels(AppLocalizations l) => {
      WidgetKeys.lblNextQuest: l.livNextQuest,
      WidgetKeys.lblNoQuest: l.livNoQuest,
      WidgetKeys.lblOverdue: l.livOverdue,
      WidgetKeys.lblSteps: l.livSteps,
      WidgetKeys.lblWater: l.livWater,
      WidgetKeys.lblAddWater: l.livAddWater,
      WidgetKeys.lblMl: l.livMl,
      WidgetKeys.lblKm: l.livKm,
      WidgetKeys.lblPerKm: l.livPerKm,
      WidgetKeys.lblReward: l.livReward,
      WidgetKeys.lblWalk: l.livWalk,
      WidgetKeys.lblQuest: l.livQuest,
      WidgetKeys.lblWorkout: l.livWorkout,
    };

/// Все ключи для записи (null — удалить ключ). [pendingWaterMl] — ещё не забранная очередь воды,
/// чтобы виджет не «откатывал» стакан, добавленный кнопкой до переноса в БД.
Map<String, Object?> widgetData(
  WidgetSnapshot s, {
  required DateTime now,
  int pendingWaterMl = 0,
  Map<String, String> labels = const {},
}) {
  final title = s.nextQuestTitle?.trim();
  final hasQuest = title != null && title.isNotEmpty;
  final reward = s is WidgetSnapshotPlus ? s.nextQuestRewardDiamonds : 0;
  return {
    WidgetKeys.nextQuestTitle: hasQuest ? title : null,
    WidgetKeys.nextQuestDeadline: hasQuest ? s.nextQuestDeadline?.millisecondsSinceEpoch.let((ms) => ms ~/ 1000) : null,
    WidgetKeys.nextQuestReward: hasQuest && reward > 0 ? reward : null,
    WidgetKeys.steps: s.steps < 0 ? 0 : s.steps,
    WidgetKeys.stepGoal: s.stepGoal,
    WidgetKeys.waterMl: (s.waterMl < 0 ? 0 : s.waterMl) + (pendingWaterMl < 0 ? 0 : pendingWaterMl),
    WidgetKeys.waterGoalMl: s.waterGoalMl,
    WidgetKeys.level: s.level,
    WidgetKeys.diamonds: s.diamonds,
    WidgetKeys.day: dayKey(now),
    ...labels,
  };
}

/// Подпись снимка для отсечения повторной записи одинаковых данных.
String widgetSnapshotSignature(WidgetSnapshot s) => [
      s.nextQuestTitle,
      s.nextQuestDeadline?.millisecondsSinceEpoch,
      if (s is WidgetSnapshotPlus) s.nextQuestRewardDiamonds,
      s.steps,
      s.stepGoal,
      s.waterMl,
      s.waterGoalMl,
      s.level,
      s.diamonds,
    ].join('|');

extension _Let<T extends Object> on T {
  R let<R>(R Function(T) f) => f(this);
}
