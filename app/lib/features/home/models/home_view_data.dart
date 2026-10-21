// Неизменяемые модели главного экрана (вкладка «Статус»).
// Пока заполняются тестовыми данными (data/demo_home_data.dart), позже — из БД/сервера.
import 'package:flutter/foundation.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/models/enums.dart';

export '../../../core/models/enums.dart' show PlayerRank, StatKind;

/// Текст, который отображается в UI: либо пользовательские данные как есть,
/// либо ключ локализации (для тестовых/системных текстов).
@immutable
class HomeText {
  const HomeText.raw(String value)
      : _raw = value,
        _l10n = null;
  const HomeText.l10n(String Function(AppLocalizations l) getter)
      : _raw = null,
        _l10n = getter;

  final String? _raw;
  final String Function(AppLocalizations l)? _l10n;

  String of(AppLocalizations l) => _raw ?? _l10n!(l);
}

extension PlayerRankX on PlayerRank {
  String get letter => name.toUpperCase();
}

@immutable
class StatValue {
  const StatValue({required this.kind, required this.value, this.deltaToday = 0});
  final StatKind kind;
  final int value;

  /// Изменение за сегодня (+1, −1, 0).
  final int deltaToday;
}

@immutable
class PlayerStatus {
  const PlayerStatus({
    required this.level,
    required this.name,
    required this.title,
    required this.rank,
    required this.streakDays,
    required this.xp,
    required this.xpForNextLevel,
    required this.energyPercent,
    required this.waterMl,
    required this.waterGoalMl,
    required this.kcalEaten,
    required this.kcalGoal,
    required this.stats,
    required this.points,
    required this.freeStatPoints,
  });

  final int level;
  final HomeText name;
  final HomeText title;
  final PlayerRank rank;
  final int streakDays;

  /// Опыт внутри текущего уровня и сколько нужно до следующего.
  final int xp;
  final int xpForNextLevel;

  /// Энергия (сон), 0..100.
  final int energyPercent;
  final int waterMl;
  final int waterGoalMl;
  final int kcalEaten;
  final int kcalGoal;
  final List<StatValue> stats;

  /// Баллы ◆ (могут быть отрицательными).
  final int points;
  final int freeStatPoints;
}

@immutable
class HomeEffect {
  const HomeEffect({required this.label, required this.isBuff, required this.expiresAt});
  final HomeText label;
  final bool isBuff;
  final DateTime expiresAt;
}

/// Контекстная кнопка у следующего квеста.
enum NextQuestContextAction { none, noWater }

@immutable
class NextQuest {
  const NextQuest({
    required this.title,
    required this.rewardPoints,
    required this.rewardXp,
    required this.penaltyPoints,
    required this.startedAt,
    required this.deadline,
    this.contextAction = NextQuestContextAction.none,
  });

  final HomeText title;
  final int rewardPoints;
  final int rewardXp;
  final int penaltyPoints;

  /// Начало окна квеста — от него считается заполнение кольца-таймера.
  final DateTime startedAt;
  final DateTime deadline;
  final NextQuestContextAction contextAction;
}

enum DaySegmentType { sleep, classes, workout, free, commute }

@immutable
class DaySegment {
  const DaySegment({required this.type, required this.startMinute, required this.endMinute});
  final DaySegmentType type;

  /// Минуты от полуночи.
  final int startMinute;
  final int endMinute;
}

@immutable
class DayPlan {
  const DayPlan({
    required this.segments,
    this.leaveHomeMinute,
    this.startMinute = 7 * 60,
    this.endMinute = 23 * 60,
  });

  final List<DaySegment> segments;
  final int? leaveHomeMinute;
  final int startMinute;
  final int endMinute;
}

@immutable
class DailySubtask {
  const DailySubtask(this.title, {this.done = false});
  final HomeText title;
  final bool done;
}

@immutable
class DailyQuest {
  const DailyQuest({
    required this.id,
    required this.title,
    this.timeMinute,
    this.done = false,
    this.overdue = false,
    this.rewardPoints = 0,
    this.penaltyPoints = 0,
    this.subtasks = const [],
    this.progress,
    this.progressText,
  });

  final String id;
  final HomeText title;
  final int? timeMinute;
  final bool done;
  final bool overdue;
  final int rewardPoints;
  final int penaltyPoints;
  final List<DailySubtask> subtasks;

  /// 0..1, null — без прогресс-бара.
  final double? progress;
  final HomeText? progressText;
}

@immutable
class WeeklyBoss {
  const WeeklyBoss({
    required this.goal,
    required this.current,
    required this.total,
    required this.endsAt,
    required this.rewardPoints,
    required this.rewardTitle,
  });

  final HomeText goal;
  final int current;
  final int total;
  final DateTime endsAt;
  final int rewardPoints;
  final HomeText rewardTitle;
}

@immutable
class CaloriesSummary {
  const CaloriesSummary({required this.eaten, required this.burned, required this.deficit});
  final int eaten;
  final int burned;
  final int deficit;
}

@immutable
class FoodFinance {
  const FoodFinance({
    required this.spent,
    required this.limit,
    required this.currencyCode,
    required this.daysToStipend,
  });

  final int spent;
  final int limit;

  /// ISO 4217, например RUB.
  final String currencyCode;
  final int daysToStipend;
}

/// Всё, что показывает главный экран.
@immutable
class HomeViewData {
  const HomeViewData({
    required this.programStart,
    required this.unreadNotifications,
    required this.player,
    required this.effects,
    required this.nextQuest,
    required this.day,
    required this.dailyQuests,
    required this.boss,
    required this.calories,
    required this.finance,
  });

  /// Дата начала программы — для «НЕДЕЛЯ n · ДЕНЬ n».
  final DateTime programStart;
  final int unreadNotifications;
  final PlayerStatus player;
  final List<HomeEffect> effects;
  final NextQuest? nextQuest;
  final DayPlan day;
  final List<DailyQuest> dailyQuests;
  final WeeklyBoss? boss;
  final CaloriesSummary calories;
  final FoodFinance finance;
}
