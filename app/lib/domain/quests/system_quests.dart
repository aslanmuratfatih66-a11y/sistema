// Системные квесты движка: штрафные, усиленный план, босс недели, перевод квестов плана в шаблоны.
// Только безопасное (SPEC §6): штраф не трогает еду и сон, нагрузка — в пределах уровня.
import 'dart:math' as math;

import '../../core/models/enums.dart';
import '../../features/plan/model/plan.dart';
import 'game_rules.dart';
import 'quest_api.dart';

/// Ключи названий системных квестов (QuestTitle.key = name). Локализация — `questTitleText`.
/// Квесты режима дисциплины — ключи D (DisciplineQuestKeys в domain/discipline).
enum SystemQuestKey {
  // Штрафные (kind=penalty, отменить нельзя).
  penaltyCleaning, // {minutes}
  penaltyReading, // {minutes}
  penaltyPlank, // {seconds}
  penaltyWalk, // {minutes}
  penaltyNoGames, // вечер без игр и соцсетей
  // Усиленный план после честной отметки.
  boostWalk, // {minutes}
  boostWater, // {ml} — сверх нормы
  boostBedOnTime, // {minute} — отбой не позже обычного
  boostPlanTomorrow, // расписать завтрашний день
  // Босс недели.
  bossAll, // {count}
  bossStrength,
  bossEndurance,
  bossDiscipline,
  bossIntellect,
  bossHealth,
  bossLooks,
}

abstract final class SystemQuests {
  static const _penaltyRotation = [
    SystemQuestKey.penaltyCleaning,
    SystemQuestKey.penaltyReading,
    SystemQuestKey.penaltyPlank,
    SystemQuestKey.penaltyWalk,
    SystemQuestKey.penaltyNoGames,
  ];

  /// Штрафной квест на день [day]: лёгкое доп. задание, весь день, отменить нельзя.
  /// Планка — по уровню: 20 с + 5 с за уровень, не больше 60 с.
  static QuestInput penaltyFor(DateTime day, {required int level, GameConfig config = GameConfig.standard}) {
    final idx = DateTime.utc(day.year, day.month, day.day).difference(DateTime.utc(2000)).inDays;
    final key = _penaltyRotation[idx % _penaltyRotation.length];
    final params = switch (key) {
      SystemQuestKey.penaltyCleaning => {'minutes': 15},
      SystemQuestKey.penaltyReading => {'minutes': 20},
      SystemQuestKey.penaltyPlank => {'seconds': math.min(60, 20 + 5 * (math.max(1, level) - 1))},
      SystemQuestKey.penaltyWalk => {'minutes': 20},
      _ => const <String, Object?>{},
    };
    final stat = switch (key) {
      SystemQuestKey.penaltyReading => StatKind.intellect,
      SystemQuestKey.penaltyPlank => StatKind.strength,
      SystemQuestKey.penaltyWalk => StatKind.endurance,
      _ => StatKind.discipline,
    };
    return QuestInput(
      kind: QuestKind.penalty,
      title: QuestTitle(key: key.name, params: params),
      stat: stat,
      activeFrom: day,
      activeUntil: day,
      reward: config.penaltyQuestReward,
      penaltyDiamonds: config.penaltyQuestPenalty,
      refusePenaltyDiamonds: 0,
      cancellable: false,
      nag: false,
      source: QuestSource.system,
    );
  }

  /// Усиленный план на день [day] после отметки: 1–2 безопасных доп. квеста.
  /// [bedMinute] — обычный отбой (из расписания): ранний отбой не позже обычного, сон не урезается.
  static List<QuestInput> boostFor(
    DayMark mark,
    DateTime day, {
    required int bedMinute,
    GameConfig config = GameConfig.standard,
  }) {
    QuestInput q(
      SystemQuestKey key,
      StatKind stat, {
      Map<String, Object?> params = const {},
      int? minute,
      int window = 60,
    }) =>
        QuestInput(
          kind: QuestKind.daily,
          title: QuestTitle(key: key.name, params: params),
          stat: stat,
          minute: minute,
          windowMinutes: window,
          activeFrom: day,
          activeUntil: day,
          reward: config.boostReward,
          penaltyDiamonds: config.boostPenalty,
          source: QuestSource.system,
        );
    final bed = bedMinute.clamp(0, 24 * 60 - 1);
    // Квест начинается за 30 мин до обычного отбоя, дедлайн — через 15 мин после.
    final bedQuest = q(
      SystemQuestKey.boostBedOnTime,
      StatKind.discipline,
      params: {'minute': bed},
      minute: math.max(0, bed - 30),
      window: 45,
    );
    return switch (mark) {
      DayMark.walkedWithFriends => [bedQuest, q(SystemQuestKey.boostPlanTomorrow, StatKind.discipline)],
      DayMark.alcohol => [q(SystemQuestKey.boostWater, StatKind.health, params: {'ml': 500}), bedQuest],
      DayMark.relapse => [
          q(SystemQuestKey.boostWalk, StatKind.endurance, params: {'minutes': 20}),
          q(SystemQuestKey.boostPlanTomorrow, StatKind.discipline),
        ],
    };
  }

  /// Характеристика босса по цели (null — «закрой N любых квестов»).
  static StatKind? bossStatForGoal(GoalKind? goal) => switch (goal) {
        GoalKind.weightLoss => StatKind.endurance,
        GoalKind.muscle => StatKind.strength,
        GoalKind.acne || GoalKind.blackheads || GoalKind.swelling => StatKind.looks,
        GoalKind.discipline || GoalKind.money => StatKind.discipline,
        GoalKind.study => StatKind.intellect,
        GoalKind.custom || null => null,
      };

  static SystemQuestKey bossKey(StatKind? stat) => switch (stat) {
        StatKind.strength => SystemQuestKey.bossStrength,
        StatKind.endurance => SystemQuestKey.bossEndurance,
        StatKind.discipline => SystemQuestKey.bossDiscipline,
        StatKind.intellect => SystemQuestKey.bossIntellect,
        StatKind.health => SystemQuestKey.bossHealth,
        StatKind.looks => SystemQuestKey.bossLooks,
        null => SystemQuestKey.bossAll,
      };

  /// Цель босса по ожидаемому числу подходящих квестов недели.
  static int bossTarget(int expected, {GameConfig config = GameConfig.standard}) =>
      math.max(config.bossMinTarget, (expected * config.bossTargetShare).ceil());

  /// Босс недели с понедельника [monday]: прогресс +1 за каждый выполненный квест [stat] (null — любой).
  static QuestInput boss(
    DateTime monday, {
    required StatKind? stat,
    required int target,
    GameConfig config = GameConfig.standard,
  }) =>
      QuestInput(
        kind: QuestKind.boss,
        title: QuestTitle(key: bossKey(stat).name, params: {'count': target}),
        stat: stat,
        activeFrom: monday,
        activeUntil: DateTime(monday.year, monday.month, monday.day + 6),
        reward: config.bossReward,
        penaltyDiamonds: config.bossPenalty,
        refusePenaltyDiamonds: config.bossPenalty,
        target: target,
        confirm: ConfirmMethod.steps,
        nag: false,
        source: QuestSource.system,
      );

  // ---- Квесты плана ----

  /// Категория плана → характеристика (по ключу точнее, чем по категории).
  static StatKind statForPlanKey(QuestKey key) => switch (key) {
        QuestKey.training => StatKind.strength,
        QuestKey.study || QuestKey.attendLesson => StatKind.intellect,
        QuestKey.skincareMorning || QuestKey.skincareEvening => StatKind.looks,
        QuestKey.water || QuestKey.meals => StatKind.health,
        QuestKey.wakeOnTime ||
        QuestKey.sleepOnTime ||
        QuestKey.leaveHome ||
        QuestKey.attendWork ||
        QuestKey.trackExpenses =>
          StatKind.discipline,
      };

  /// Окно выполнения квеста плана, минут (для квестов со временем).
  static int windowForPlanKey(QuestKey key) => switch (key) {
        QuestKey.leaveHome => 15,
        QuestKey.wakeOnTime || QuestKey.sleepOnTime || QuestKey.attendLesson || QuestKey.attendWork => 30,
        _ => 60,
      };

  /// Квест плана → ввод шаблона. Название — ключ плана + параметры (+ minute для времени).
  static QuestInput fromDraft(QuestDraft d, {GameRules rules = const GameRules()}) {
    final stat = statForPlanKey(d.key);
    final stats = d.key == QuestKey.training
        ? {StatKind.strength: 1, StatKind.endurance: 1}
        : {stat: rules.config.statPerQuest};
    final kind = switch (d.category) {
      QuestCategory.schedule => QuestKind.schedule,
      QuestCategory.goal => QuestKind.goal,
      _ => QuestKind.daily,
    };
    final ml = d.params['ml'];
    return QuestInput(
      kind: kind,
      title: QuestTitle(key: d.key.name, params: {...d.params, if (d.minute != null) 'minute': d.minute}),
      stat: stat,
      minute: d.minute,
      windowMinutes: windowForPlanKey(d.key),
      weekdays: d.weekdays,
      weekParity: d.week,
      reward: GameReward(diamonds: d.diamonds, xp: d.xp, stats: stats),
      penaltyDiamonds: rules.failPenaltyFor(d.diamonds),
      target: d.key == QuestKey.water && ml is num ? ml.round() : null,
      source: QuestSource.plan,
    );
  }
}
