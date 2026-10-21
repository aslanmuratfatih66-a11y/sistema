// Правила режима дисциплины (SPEC §6): квесты дня и условия включения/выключения. Чистые функции.
// Безопасность: сон не сокращается, отбой/подъём не сдвигаются позже обычных, нагрузка — не выше уровня.
import 'package:flutter/foundation.dart';

import '../../core/models/enums.dart';
import '../quests/quest_api.dart';

/// Уровень тренировок из анкеты (раздел training.level). Неизвестный — как новичок (безопаснее).
enum TrainingLevel { beginner, intermediate, advanced }

/// Ключи названий квестов дисциплины (QuestTitle.key). Локализация — `disciplineQuestTitle`.
abstract final class DisciplineQuestKeys {
  static const wake = 'dscQuestWake';
  static const bed = 'dscQuestBed';
  static const workout = 'dscQuestWorkout';
  static const walk = 'dscQuestWalk';

  static const all = {wake, bed, workout, walk};
}

/// Параметры режима (SPEC §6: подъём 6:00, отбой 22:00).
abstract final class DisciplineRules {
  static const wakeMinute = 6 * 60;
  static const bedMinute = 22 * 60;

  /// Отбой раньше полудня считается «после полуночи» (поздний) → сдвигается на 22:00.
  static const _bedAfterMidnightBefore = 12 * 60;

  /// Доп. нагрузка по уровню, минут (верхняя граница; не больше обычных минут в день).
  static const extraMinutesByLevel = {
    TrainingLevel.beginner: 10,
    TrainingLevel.intermediate: 15,
    TrainingLevel.advanced: 20,
  };
  static const minExtraMinutes = 5;

  /// При травмах вместо тренировки — спокойная прогулка.
  static const walkMinutes = 20;

  /// Желаемое время доп. нагрузки (сдвигается внутрь дня бодрствования).
  static const _workoutMinute = 18 * 60;

  // Умеренные награды и штрафы (◆ / опыт).
  static const wakeReward = GameReward(diamonds: 10, xp: 15, stats: {StatKind.discipline: 1});
  static const bedReward = GameReward(diamonds: 10, xp: 15, stats: {StatKind.discipline: 1});
  static const workoutReward = GameReward(diamonds: 15, xp: 20, stats: {StatKind.strength: 1});
  static const walkReward = GameReward(diamonds: 10, xp: 15, stats: {StatKind.endurance: 1});
  static const penaltyDiamonds = 15;

  /// Окно подтверждения подъёма, минут.
  static const wakeWindow = 30;

  /// Отбой: квест начинается за [bedLead] минут до отбоя, дедлайн — через [bedGrace] после.
  static const bedLead = 30;
  static const bedGrace = 15;

  /// Целевой подъём: 6:00, но не позже обычного (если по расписанию раньше 6:00 — оставить).
  static int targetWake(int usualWakeMinute) {
    final w = usualWakeMinute.clamp(0, 24 * 60 - 1);
    return w < wakeMinute ? w : wakeMinute;
  }

  /// Целевой отбой: 22:00, но не позже обычного (если обычно раньше — оставить).
  /// Отбой после полуночи (0:00–11:59) — поздний, становится 22:00.
  static int targetBed(int usualBedMinute) {
    final b = usualBedMinute.clamp(0, 24 * 60 - 1);
    if (b < _bedAfterMidnightBefore) return bedMinute;
    return b < bedMinute ? b : bedMinute;
  }

  /// Длительность сна от отбоя [bed] до подъёма [wake], минут (через полночь).
  static int sleepMinutes(int bed, int wake) {
    final d = (wake - bed) % (24 * 60);
    return d == 0 ? 24 * 60 : d;
  }

  /// Доп. нагрузка, минут: по уровню, но не больше обычных минут в день.
  static int extraMinutes(TrainingLevel? level, int? usualMinutesPerDay) {
    final base = extraMinutesByLevel[level ?? TrainingLevel.beginner]!;
    final usual = usualMinutesPerDay;
    final capped = usual != null && usual > 0 && usual < base ? usual : base;
    return capped < minExtraMinutes ? minExtraMinutes : capped;
  }
}

/// Входные данные режима: анкета тренировок/здоровья и расписание сна.
@immutable
class DisciplineContext {
  const DisciplineContext({
    this.level,
    this.minutesPerDay,
    this.wakeMinute = 7 * 60,
    this.bedMinute = 23 * 60,
    this.hasInjuries = false,
  });

  /// Значения по умолчанию (настроек ещё нет): как ScheduleSettings по умолчанию, уровень — новичок.
  static const fallback = DisciplineContext();

  /// Из JSON разделов анкеты training/health и минут подъёма/отбоя из ScheduleSettings.
  factory DisciplineContext.fromSources({
    required Map<String, Object?> training,
    Map<String, Object?> health = const {},
    int wakeMinute = 7 * 60,
    int bedMinute = 23 * 60,
  }) {
    final minutes = training['minutesPerDay'];
    final injuries = health['injuries'];
    return DisciplineContext(
      level: enumByName(TrainingLevel.values, training['level'] as String?),
      minutesPerDay: minutes is num ? minutes.round() : null,
      wakeMinute: wakeMinute,
      bedMinute: bedMinute,
      hasInjuries: injuries is String && injuries.trim().isNotEmpty,
    );
  }

  final TrainingLevel? level;
  final int? minutesPerDay;

  /// Обычный подъём/отбой — минута суток (ScheduleSettings.wakeMinute/bedMinute).
  final int wakeMinute;
  final int bedMinute;

  /// Указаны травмы — вместо тренировки лёгкая прогулка.
  final bool hasInjuries;

  @override
  bool operator ==(Object other) =>
      other is DisciplineContext &&
      other.level == level &&
      other.minutesPerDay == minutesPerDay &&
      other.wakeMinute == wakeMinute &&
      other.bedMinute == bedMinute &&
      other.hasInjuries == hasInjuries;

  @override
  int get hashCode => Object.hash(level, minutesPerDay, wakeMinute, bedMinute, hasInjuries);
}

/// «06:00».
String disciplineTime(int minute) {
  final m = minute % (24 * 60);
  return '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
}

/// Квесты режима дисциплины на день [day] (хук движка: LocalQuestService.disciplineQuests).
/// Все — kind=discipline, source=system, отменить нельзя. День одинаковый для будней и выходных.
List<QuestInput> disciplineQuests(DateTime day, {required DisciplineContext ctx}) {
  final wake = DisciplineRules.targetWake(ctx.wakeMinute);
  final bed = DisciplineRules.targetBed(ctx.bedMinute);

  QuestInput q({
    required String key,
    required StatKind stat,
    required int minute,
    required int window,
    required GameReward reward,
    Map<String, Object?> params = const {},
  }) =>
      QuestInput(
        kind: QuestKind.discipline,
        title: QuestTitle(key: key, params: params),
        stat: stat,
        minute: minute,
        windowMinutes: window,
        reward: reward,
        penaltyDiamonds: DisciplineRules.penaltyDiamonds,
        cancellable: false,
        source: QuestSource.system,
      );

  // Нагрузка — внутри дня бодрствования: не раньше часа после подъёма и не позже 1,5 ч до отбоя.
  final lo = wake + 60;
  final hi = bed - 90;
  final workoutAt = hi < lo ? lo : DisciplineRules._workoutMinute.clamp(lo, hi);
  final workoutWindow = (bed - DisciplineRules.bedLead - workoutAt).clamp(30, 6 * 60);

  final physical = ctx.hasInjuries
      ? q(
          key: DisciplineQuestKeys.walk,
          stat: StatKind.endurance,
          minute: workoutAt,
          window: workoutWindow,
          reward: DisciplineRules.walkReward,
          params: const {'minutes': DisciplineRules.walkMinutes},
        )
      : q(
          key: DisciplineQuestKeys.workout,
          stat: StatKind.strength,
          minute: workoutAt,
          window: workoutWindow,
          reward: DisciplineRules.workoutReward,
          params: {
            'minutes': DisciplineRules.extraMinutes(ctx.level, ctx.minutesPerDay),
            'level': (ctx.level ?? TrainingLevel.beginner).name,
          },
        );

  return [
    q(
      key: DisciplineQuestKeys.wake,
      stat: StatKind.discipline,
      minute: wake,
      window: DisciplineRules.wakeWindow,
      reward: DisciplineRules.wakeReward,
      params: {'time': disciplineTime(wake), 'minute': wake},
    ),
    physical,
    q(
      key: DisciplineQuestKeys.bed,
      stat: StatKind.discipline,
      minute: bed - DisciplineRules.bedLead,
      window: DisciplineRules.bedLead + DisciplineRules.bedGrace,
      reward: DisciplineRules.bedReward,
      params: {'time': disciplineTime(bed), 'minute': bed},
    ),
  ];
}

// ---------- Включение / выключение ----------

/// Почему режим включён.
enum DisciplineReason {
  debt, // отрицательный баланс (движок, tick)
  manual, // вручную
  ai, // по решению ИИ после срывов (этап 6)
}

/// Ключи причин в payload событий disciplineOn (reasonKey в QuestService.setDiscipline).
abstract final class DisciplineReasonKeys {
  static const debt = 'debt';
  static const manual = 'manual';
  static const ai = 'ai';

  static DisciplineReason? parse(Object? key) => switch (key) {
        debt => DisciplineReason.debt,
        manual => DisciplineReason.manual,
        ai => DisciplineReason.ai,
        _ => null,
      };

  static String of(DisciplineReason r) => switch (r) {
        DisciplineReason.debt => debt,
        DisciplineReason.manual => manual,
        DisciplineReason.ai => ai,
      };
}

/// Когда режим выключится.
enum DisciplineExit {
  balancePositive, // когда баланс станет положительным
  manual, // вручную (когда баланс не отрицательный)
}

/// Включить автоматически: баланс отрицательный, режим ещё выключен.
bool disciplineShouldTurnOn({required int balance, required bool active}) => !active && balance < 0;

/// Выключить автоматически: баланс снова положительный (> 0). Ручной режим баланс не выключает —
/// иначе его нельзя было бы включить при плюсе. ИИ-режим (этап 6) — как долговой.
bool disciplineShouldTurnOff({required int balance, required bool active, DisciplineReason? reason}) =>
    active && balance > 0 && reason != DisciplineReason.manual;

/// Ручное включение — когда выключен.
bool disciplineCanEnableManually({required bool active}) => !active;

/// Ручное выключение — только если баланс не отрицательный.
bool disciplineCanDisableManually({required int balance, required bool active}) => active && balance >= 0;

/// Статус режима для экрана.
@immutable
class DisciplineStatus {
  const DisciplineStatus({required this.active, required this.balance, this.reason, this.since});

  /// Из снимка игрока и последнего события disciplineOn (причина и время) — если есть.
  /// Причина неизвестна: при минусе — долг, иначе ручное включение.
  factory DisciplineStatus.resolve({
    required bool active,
    required int balance,
    String? lastOnReasonKey,
    DateTime? lastOnAt,
  }) {
    if (!active) return DisciplineStatus(active: false, balance: balance);
    final parsed = DisciplineReasonKeys.parse(lastOnReasonKey);
    return DisciplineStatus(
      active: true,
      balance: balance,
      reason: parsed ?? (balance < 0 ? DisciplineReason.debt : DisciplineReason.manual),
      since: lastOnAt,
    );
  }

  final bool active;
  final int balance;
  final DisciplineReason? reason;
  final DateTime? since;

  bool get inDebt => balance < 0;

  DisciplineExit? get exit => !active
      ? null
      : reason == DisciplineReason.manual
          ? DisciplineExit.manual
          : DisciplineExit.balancePositive;

  bool get canEnable => disciplineCanEnableManually(active: active);
  bool get canDisable => disciplineCanDisableManually(balance: balance, active: active);
}
