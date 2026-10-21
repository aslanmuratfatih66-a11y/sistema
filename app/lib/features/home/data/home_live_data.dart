// Реальные данные вкладки «Статус»: снимок игрока и ближайший квест из движка (QuestService),
// лента дня — из расписания и тренировок принятого плана, нормы воды/калорий — из плана.
// Съеденное/выпитое и сон — этап 3: пока 0 / «—», без выдуманных чисел.
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/profile_repository.dart';
import '../../../domain/quests/quest_api.dart';
import '../../../domain/quests/quest_l10n.dart';
import '../../../l10n/app_localizations.dart';
import '../../plan/data/plan_repository.dart';
import '../../plan/model/plan.dart';
import '../../quests/data/quest_providers.dart';
import '../../schedule/data/schedule_repository.dart';
import '../../schedule/schedule_logic.dart';
import '../models/home_view_data.dart';
import 'home_providers.dart';

/// Данные вне движка: имя, начало программы, лента дня, нормы. В тестах подменяется значением.
@immutable
class HomeContext {
  const HomeContext({
    required this.programStart,
    required this.day,
    this.playerName,
    this.waterGoalMl,
    this.kcalGoal,
  });

  final DateTime programStart;
  final DayPlan day;
  final String? playerName;
  final int? waterGoalMl;
  final int? kcalGoal;
}

final homeContextProvider = Provider<HomeContext>((ref) {
  final now = ref.watch(homeClockProvider);
  final today = DateTime(now.year, now.month, now.day);
  final profile = ref.watch(profileProvider).value;
  final stored = ref.watch(acceptedPlanProvider).value;
  final config = ref.watch(scheduleConfigProvider).value ?? const ScheduleConfig();
  final entries = ref.watch(scheduleEntriesProvider).value ?? const <ScheduleEntry>[];
  final plan = stored?.plan;
  final day = buildDayPlan(today, config, entries, plan);
  final training = day.segments.any((s) => s.type == DaySegmentType.workout);
  final accepted = stored?.acceptedAt;
  return HomeContext(
    programStart: accepted == null ? today : DateTime(accepted.year, accepted.month, accepted.day),
    day: day,
    playerName: profile?.name,
    waterGoalMl: training ? (plan?.norms.waterTrainingDayMl ?? plan?.norms.waterMl) : plan?.norms.waterMl,
    kcalGoal: plan?.norms.calories,
  );
});

/// Статус для главного экрана; загрузка/ошибка — пока нет первого снимка игрока.
final homeStatusProvider = Provider<AsyncValue<HomeStatusData>>((ref) {
  final player = ref.watch(questPlayerProvider);
  final next = ref.watch(questNextProvider).value;
  final ctx = ref.watch(homeContextProvider);
  return player.whenData((p) => buildHomeStatus(p, next, ctx));
});

DaySegmentType _segmentType(ScheduleSlot s) => switch (s.type) {
      ScheduleSlotType.sleep => DaySegmentType.sleep,
      ScheduleSlotType.commute => DaySegmentType.commute,
      ScheduleSlotType.entry => DaySegmentType.classes,
      ScheduleSlotType.free => DaySegmentType.free,
    };

/// Лента дня: расписание (сон, дорога, пары/работа, свободно) + тренировки плана поверх свободного.
DayPlan buildDayPlan(DateTime date, ScheduleConfig config, List<ScheduleEntry> entries, Plan? plan) {
  final slots = ScheduleLogic.dayTimeline(date, config, entries);
  final workouts = <(int, int)>[];
  if (plan != null && plan.weeks.isNotEmpty) {
    final number = plan.alternation ? ScheduleLogic.weekNumber(date, config) : plan.weeks.first.number;
    final week = plan.weeks.firstWhere((w) => w.number == number, orElse: () => plan.weeks.first);
    for (final item in week.day(date.weekday)?.items ?? const <RoutineItem>[]) {
      if (item.kind == RoutineKind.training && item.durationMinutes > 0) workouts.add((item.startMinute, item.endMinute));
    }
  }

  final segments = <DaySegment>[];
  for (final s in slots) {
    final type = _segmentType(s);
    if (type != DaySegmentType.free || workouts.isEmpty) {
      segments.add(DaySegment(type: type, startMinute: s.startMinute, endMinute: s.endMinute));
      continue;
    }
    // Свободное окно режется тренировками.
    var cursor = s.startMinute;
    for (final (ws, we) in workouts..sort((a, b) => a.$1.compareTo(b.$1))) {
      final a = ws.clamp(s.startMinute, s.endMinute);
      final b = we.clamp(s.startMinute, s.endMinute);
      if (b <= a) continue;
      if (a > cursor) segments.add(DaySegment(type: DaySegmentType.free, startMinute: cursor, endMinute: a));
      segments.add(DaySegment(type: DaySegmentType.workout, startMinute: a, endMinute: b));
      cursor = b;
    }
    if (cursor < s.endMinute) {
      segments.add(DaySegment(type: DaySegmentType.free, startMinute: cursor, endMinute: s.endMinute));
    }
  }

  final wake = config.wakeMinute;
  final bed = config.bedMinute;
  return DayPlan(
    segments: segments,
    leaveHomeMinute: ScheduleLogic.leaveHomeMinute(date, config, entries),
    startMinute: bed > wake ? wake : 7 * 60,
    endMinute: bed > wake ? bed : 23 * 60,
  );
}

/// Ближайший квест → панель «Следующий квест». Без начала окна — час до дедлайна.
NextQuest nextQuestOf(QuestItem q) => NextQuest(
      instanceId: q.instanceId,
      title: HomeText.l10n((l) => questTitleText(l, q.title)),
      rewardPoints: q.reward.diamonds,
      rewardXp: q.reward.xp,
      penaltyPoints: q.penaltyDiamonds,
      startedAt: q.startsAt ?? q.deadlineAt.subtract(const Duration(hours: 1)),
      deadline: q.deadlineAt,
      cancellable: q.cancellable,
      contextAction: q.title.key == QuestKey.water.name ? NextQuestContextAction.noWater : NextQuestContextAction.none,
    );

HomeStatusData buildHomeStatus(PlayerSnapshot p, QuestItem? next, HomeContext ctx) {
  final name = ctx.playerName?.trim();
  final titleKey = p.titleKey;
  return HomeStatusData(
    programStart: ctx.programStart,
    // TODO(B): счётчик уведомлений — когда появится журнал уведомлений.
    unreadNotifications: 0,
    player: PlayerStatus(
      level: p.level,
      name: name == null || name.isEmpty ? HomeText.l10n((l) => l.qstPlayerNoName) : HomeText.raw(name),
      title: titleKey == null ? null : HomeText.l10n((AppLocalizations l) => titleLabel(l, titleKey) ?? ''),
      rank: p.rank,
      streakDays: p.streakDays,
      xp: p.xpIntoLevel,
      xpForNextLevel: p.xpForNextLevel,
      energyPercent: null,
      waterMl: 0,
      waterGoalMl: ctx.waterGoalMl ?? 0,
      kcalEaten: 0,
      kcalGoal: ctx.kcalGoal ?? 0,
      stats: [
        for (final k in StatKind.values)
          StatValue(kind: k, value: p.stats[k] ?? 0, deltaToday: p.statDeltaToday[k] ?? 0),
      ],
      points: p.diamonds,
      freeStatPoints: p.freeStatPoints,
      paused: p.pause != null,
      discipline: p.disciplineActive,
    ),
    effects: [
      for (final e in p.effects)
        HomeEffect(label: HomeText.l10n((l) => effectLabel(l, e)), isBuff: e.isBuff, expiresAt: e.expiresAt),
    ],
    nextQuest: next == null ? null : nextQuestOf(next),
    day: ctx.day,
  );
}
