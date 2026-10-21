// Тестовые данные главного экрана. Позже homeDataProvider переключится на реальные
// данные (Drift/сервер) — виджеты менять не придётся.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../models/home_view_data.dart';
import 'home_providers.dart';

final homeDataProvider = Provider<HomeViewData>(
  (ref) => buildDemoHomeData(ref.read(homeNowSourceProvider)()),
);

String _num(AppLocalizations l, num v) => NumberFormat.decimalPattern(l.localeName).format(v);

HomeText _t(String Function(AppLocalizations l) f) => HomeText.l10n(f);

/// Демо-состояние «первый день, утро»: всё относительно [now], чтобы таймеры были живыми.
HomeViewData buildDemoHomeData(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  // Конец недели — полночь следующего понедельника.
  final endOfWeek = today.add(Duration(days: 8 - today.weekday));

  return HomeViewData(
    programStart: today,
    unreadNotifications: 3,
    player: PlayerStatus(
      level: 7,
      name: _t((l) => l.homeDemoPlayerName),
      title: _t((l) => l.homeDemoPlayerTitle),
      rank: PlayerRank.e,
      streakDays: 12,
      xp: 1240,
      xpForNextLevel: 2000,
      energyPercent: 78,
      waterMl: 1200,
      waterGoalMl: 2500,
      kcalEaten: 640,
      kcalGoal: 2200,
      stats: const [
        StatValue(kind: StatKind.strength, value: 14, deltaToday: 1),
        StatValue(kind: StatKind.endurance, value: 11),
        StatValue(kind: StatKind.discipline, value: 17, deltaToday: 1),
        StatValue(kind: StatKind.intellect, value: 19),
        StatValue(kind: StatKind.health, value: 13, deltaToday: 1),
        StatValue(kind: StatKind.looks, value: 10),
      ],
      points: 340,
      freeStatPoints: 3,
    ),
    effects: [
      HomeEffect(
        label: _t((l) => l.homeDemoEffectVigor),
        isBuff: true,
        expiresAt: now.add(const Duration(hours: 1, minutes: 24)),
      ),
      HomeEffect(
        label: _t((l) => l.homeDemoEffectDehydration),
        isBuff: false,
        expiresAt: now.add(const Duration(minutes: 38)),
      ),
    ],
    nextQuest: NextQuest(
      title: _t((l) => l.homeDemoNextQuest),
      rewardPoints: 10,
      rewardXp: 15,
      penaltyPoints: 15,
      startedAt: now.subtract(const Duration(minutes: 22)),
      deadline: now.add(const Duration(minutes: 38)),
      contextAction: NextQuestContextAction.noWater,
    ),
    day: const DayPlan(
      leaveHomeMinute: 8 * 60 + 10,
      segments: [
        DaySegment(type: DaySegmentType.sleep, startMinute: 7 * 60, endMinute: 7 * 60 + 20),
        DaySegment(type: DaySegmentType.free, startMinute: 7 * 60 + 20, endMinute: 8 * 60 + 10),
        DaySegment(type: DaySegmentType.commute, startMinute: 8 * 60 + 10, endMinute: 8 * 60 + 50),
        DaySegment(type: DaySegmentType.classes, startMinute: 9 * 60, endMinute: 14 * 60 + 10),
        DaySegment(type: DaySegmentType.commute, startMinute: 14 * 60 + 10, endMinute: 14 * 60 + 50),
        DaySegment(type: DaySegmentType.free, startMinute: 14 * 60 + 50, endMinute: 18 * 60),
        DaySegment(type: DaySegmentType.workout, startMinute: 18 * 60, endMinute: 19 * 60),
        DaySegment(type: DaySegmentType.free, startMinute: 19 * 60, endMinute: 22 * 60 + 30),
        DaySegment(type: DaySegmentType.sleep, startMinute: 22 * 60 + 30, endMinute: 23 * 60),
      ],
    ),
    dailyQuests: [
      DailyQuest(
        id: 'wake',
        title: _t((l) => l.homeDemoQuestWakeUp),
        timeMinute: 7 * 60,
        done: true,
        rewardPoints: 10,
        penaltyPoints: 10,
      ),
      DailyQuest(
        id: 'breakfast',
        title: _t((l) => l.homeDemoQuestBreakfast),
        timeMinute: 7 * 60 + 40,
        overdue: true,
        rewardPoints: 5,
        penaltyPoints: 5,
      ),
      DailyQuest(
        id: 'water',
        title: _t((l) => l.homeDemoQuestWater),
        rewardPoints: 10,
        penaltyPoints: 15,
        progress: 1200 / 2500,
        progressText: _t((l) => l.homeLitersProgress(_num(l, 1.2), _num(l, 2.5))),
      ),
      DailyQuest(
        id: 'workout',
        title: _t((l) => l.homeDemoQuestWorkout),
        timeMinute: 18 * 60,
        rewardPoints: 20,
        penaltyPoints: 20,
        subtasks: [
          DailySubtask(_t((l) => l.homeDemoSubWarmup), done: true),
          DailySubtask(_t((l) => l.homeDemoSubPushups)),
          DailySubtask(_t((l) => l.homeDemoSubPlank)),
        ],
        progress: 1 / 3,
      ),
      DailyQuest(
        id: 'reading',
        title: _t((l) => l.homeDemoQuestReading),
        timeMinute: 21 * 60,
        rewardPoints: 10,
        penaltyPoints: 10,
        progress: 5 / 20,
        progressText: _t((l) => l.homeMinutesProgress(_num(l, 5), _num(l, 20))),
      ),
      DailyQuest(
        id: 'steps',
        title: _t((l) => l.homeDemoQuestSteps),
        rewardPoints: 10,
        penaltyPoints: 10,
        progress: 3420 / 8000,
        progressText: _t((l) => l.homeStepsProgress(_num(l, 3420), _num(l, 8000))),
      ),
      DailyQuest(
        id: 'sleep',
        title: _t((l) => l.homeDemoQuestSleep),
        timeMinute: 23 * 60,
        rewardPoints: 10,
        penaltyPoints: 15,
      ),
    ],
    boss: WeeklyBoss(
      goal: _t((l) => l.homeDemoBossGoal),
      current: 2,
      total: 5,
      endsAt: endOfWeek,
      rewardPoints: 150,
      rewardTitle: _t((l) => l.homeDemoBossRewardTitle),
    ),
    calories: const CaloriesSummary(eaten: 640, burned: 1420, deficit: 450),
    finance: const FoodFinance(spent: 1240, limit: 3500, currencyCode: 'RUB', daysToStipend: 9),
  );
}
