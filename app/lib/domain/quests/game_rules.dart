// Правила игры (SPEC §6): опыт → уровень, ранги, титулы, характеристики, отказ/провал, серия, эффекты.
// Чистые функции без БД. Все числа баланса — в GameConfig (одно место).
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../core/models/enums.dart';
import 'quest_api.dart';

/// Ключи титулов (`titleLabel` в quest_l10n.dart). Каждый выдаётся один раз (событие bonus с payload.title).
abstract final class GameTitles {
  static const streak7 = 'streak7'; // серия 7 дней
  static const streak30 = 'streak30'; // серия 30 дней
  static const bossSlayer = 'bossSlayer'; // первый побеждённый босс
  static const bossHunter = 'bossHunter'; // 4 побеждённых босса
  static const level10 = 'level10';
  static const level25 = 'level25';
  static const level50 = 'level50';

  static const all = [streak7, streak30, bossSlayer, bossHunter, level10, level25, level50];
}

/// Ключи эффектов (`effectLabel` в quest_l10n.dart).
abstract final class EffectKinds {
  static const vigor = 'vigor'; // «Бодрость»: серия ≥ N дней
  static const dehydration = 'dehydration'; // «Обезвоживание»: провал квеста воды
  static const bossAura = 'bossAura'; // «Аура победителя»: босс недели побеждён
}

/// Причины отдельных штрафов (PenaltyApplied.reasonKey → `penaltyReasonLabel`).
abstract final class PenaltyReasons {
  static const failedQuests = 'failedQuests'; // провалы за день → штрафной квест
  static const markWalked = 'markWalked';
  static const markAlcohol = 'markAlcohol';
  static const markRelapse = 'markRelapse';
  static const bossFailed = 'bossFailed';
  static const reproach = 'reproach'; // упрёк за пропуск (B)

  static String forMark(DayMark m) => switch (m) {
        DayMark.walkedWithFriends => markWalked,
        DayMark.alcohol => markAlcohol,
        DayMark.relapse => markRelapse,
      };
}

/// Описание эффекта: длительность и влияние на начисления (проценты, ±).
@immutable
class EffectDef {
  const EffectDef({
    required this.kind,
    required this.isBuff,
    required this.duration,
    this.xpPct = 0,
    this.diamondsPct = 0,
    this.statPct = const {},
  });

  final String kind;
  final bool isBuff;
  final Duration duration;
  final int xpPct;
  final int diamondsPct;
  final Map<StatKind, int> statPct;

  /// Параметры подписи: pct — главный процент эффекта.
  Map<String, Object?> get params {
    final pct = xpPct != 0 ? xpPct : (diamondsPct != 0 ? diamondsPct : (statPct.values.firstOrNull ?? 0));
    return {'pct': pct.abs(), if (statPct.isNotEmpty) 'stat': statPct.keys.first.name};
  }
}

/// Уровень по опыту.
@immutable
class LevelInfo {
  const LevelInfo(this.level, this.xpIntoLevel, this.xpForNextLevel);
  final int level;
  final int xpIntoLevel;
  final int xpForNextLevel;
}

/// Итог дня для серии.
@immutable
class DayTally {
  const DayTally({this.total = 0, this.done = 0, this.failed = 0, this.excused = 0});
  final int total;
  final int done;
  final int failed;
  final int excused;

  /// Квесты, которые учитываются в доле (освобождённые паузой — нет).
  int get eligible => total - excused;
}

/// Конфиг баланса. Меняется в одном месте; движок и тесты берут [GameConfig.standard].
@immutable
class GameConfig {
  const GameConfig({
    this.xpBase = 100,
    this.xpExponent = 1.4,
    this.maxLevel = 100,
    this.rankLevels = const {
      PlayerRank.e: 1,
      PlayerRank.d: 5,
      PlayerRank.c: 10,
      PlayerRank.b: 20,
      PlayerRank.a: 35,
      PlayerRank.s: 50,
    },
    this.levelTitles = const {10: GameTitles.level10, 25: GameTitles.level25, 50: GameTitles.level50},
    this.statPointsPerLevel = 3,
    this.baseStat = 10,
    this.statPerQuest = 1,
    this.refuseFactor = 0.5,
    this.failFromReward = 1.0,
    this.minFailPenalty = 2,
    this.maxSnoozes = 3,
    this.streakThreshold = 0.8,
    this.streakTitles = const {7: GameTitles.streak7, 30: GameTitles.streak30},
    this.streakBonusEvery = 7,
    this.streakBonusDiamonds = 20,
    this.vigorStreak = 3,
    this.penaltyQuestAfterFails = 2,
    this.penaltyQuestPenalty = 15,
    this.penaltyQuestReward = const GameReward(xp: 10),
    this.markPenalty = const {DayMark.walkedWithFriends: 3, DayMark.alcohol: 6, DayMark.relapse: 8},
    this.boostReward = const GameReward(diamonds: 5, xp: 10),
    this.boostPenalty = 5,
    this.bossReward = const GameReward(diamonds: 80, xp: 150),
    this.bossPenalty = 30,
    this.bossTargetShare = 0.7,
    this.bossMinTarget = 3,
    this.bossHunterWins = 4,
    this.backfillDays = 7,
    this.manualDisciplineMin = const Duration(days: 1),
    this.effects = const {
      EffectKinds.vigor: EffectDef(kind: EffectKinds.vigor, isBuff: true, duration: Duration(days: 1), xpPct: 5),
      EffectKinds.dehydration: EffectDef(
        kind: EffectKinds.dehydration,
        isBuff: false,
        duration: Duration(days: 1),
        statPct: {StatKind.endurance: -10},
      ),
      EffectKinds.bossAura: EffectDef(
        kind: EffectKinds.bossAura,
        isBuff: true,
        duration: Duration(days: 3),
        diamondsPct: 10,
      ),
    },
  });

  static const standard = GameConfig();

  /// Опыт до следующего уровня: xpBase · n^xpExponent (L1 → 100, L5 → ~950, L10 → ~2500).
  final int xpBase;
  final double xpExponent;
  final int maxLevel;

  /// Минимальный уровень ранга.
  final Map<PlayerRank, int> rankLevels;

  /// Титулы за уровень: {уровень: ключ}.
  final Map<int, String> levelTitles;
  final int statPointsPerLevel;

  /// Стартовое значение характеристики (снимок = baseStat + сумма журнала).
  final int baseStat;

  /// Прирост характеристики квеста, если в награде не указаны свои.
  final int statPerQuest;

  /// Отказ = провал · refuseFactor (если в шаблоне не задан), строго меньше провала.
  final double refuseFactor;

  /// Провал по умолчанию (импорт плана) = награда ◆ · failFromReward, не меньше minFailPenalty.
  final double failFromReward;
  final int minFailPenalty;

  /// Сколько раз можно нажать «+10 мин» на экземпляре.
  final int maxSnoozes;

  /// День засчитан в серию, если выполнено ≥ этой доли квестов.
  final double streakThreshold;
  final Map<int, String> streakTitles;
  final int streakBonusEvery;
  final int streakBonusDiamonds;

  /// С какой длины серии действует «Бодрость».
  final int vigorStreak;

  /// Сколько провалов за день → штрафной квест на следующий день.
  final int penaltyQuestAfterFails;
  final int penaltyQuestPenalty;
  final GameReward penaltyQuestReward;

  /// Честная отметка — мягче скрытого срыва (провалов на день).
  final Map<DayMark, int> markPenalty;

  /// Квесты усиленного плана на завтра.
  final GameReward boostReward;
  final int boostPenalty;

  final GameReward bossReward;
  final int bossPenalty;

  /// Цель босса = ожидаемое число квестов недели · доля (не меньше минимума).
  final double bossTargetShare;
  final int bossMinTarget;
  final int bossHunterWins;

  /// Сколько прошедших дней tick догоняет, если приложение долго не открывали.
  final int backfillDays;

  /// Ручную дисциплину баланс > 0 выключает не раньше, чем через этот срок.
  final Duration manualDisciplineMin;
  final Map<String, EffectDef> effects;
}

/// Правила по конфигу.
@immutable
class GameRules {
  const GameRules([this.config = GameConfig.standard]);
  final GameConfig config;

  // ---- Опыт и уровни ----

  /// Опыт, нужный с уровня [level] до следующего.
  int xpToNext(int level) => (config.xpBase * math.pow(math.max(1, level), config.xpExponent)).round();

  /// Суммарный опыт, нужный для достижения уровня [level] с первого.
  int xpTotalFor(int level) {
    var total = 0;
    for (var n = 1; n < level; n++) {
      total += xpToNext(n);
    }
    return total;
  }

  LevelInfo levelFor(int xp) {
    var level = 1;
    var rest = math.max(0, xp);
    while (level < config.maxLevel && rest >= xpToNext(level)) {
      rest -= xpToNext(level);
      level++;
    }
    return LevelInfo(level, rest, xpToNext(level));
  }

  PlayerRank rankFor(int level) {
    var rank = PlayerRank.e;
    for (final r in PlayerRank.values) {
      if (level >= (config.rankLevels[r] ?? 1 << 30)) rank = r;
    }
    return rank;
  }

  /// Титулы за уровни в (from, to].
  List<String> levelTitlesBetween(int from, int to) => [
        for (final e in config.levelTitles.entries)
          if (e.key > from && e.key <= to) e.value,
      ];

  // ---- Характеристики ----

  int freeStatPoints(int level, int spent) => math.max(0, (level - 1) * config.statPointsPerLevel - spent);

  /// Прирост характеристик квеста: свои из награды или statPerQuest к [stat].
  Map<StatKind, int> questStats(StatKind? stat, Map<StatKind, int> own) {
    if (own.isNotEmpty) return own;
    return stat == null ? const {} : {stat: config.statPerQuest};
  }

  // ---- Штрафы ----

  /// Штраф за провал по умолчанию — от награды ◆.
  int failPenaltyFor(int rewardDiamonds) =>
      math.max(config.minFailPenalty, (rewardDiamonds * config.failFromReward).round());

  /// Штраф за отказ: заданный в шаблоне или по формуле. По формуле: > 0 и < провала (при провале ≥ 2).
  int refusePenalty(int failPenalty, [int? explicit]) {
    if (explicit != null) return math.max(0, explicit);
    if (failPenalty <= 0) return 0;
    final upper = failPenalty > 1 ? failPenalty - 1 : 1;
    return (failPenalty * config.refuseFactor).round().clamp(1, upper);
  }

  int markPenalty(DayMark m) => config.markPenalty[m] ?? 0;

  // ---- Эффекты ----

  /// Награда с учётом активных эффектов (проценты складываются). Штрафы эффектами не меняются.
  GameReward applyEffects(GameReward base, Iterable<EffectDef> active) {
    var xpPct = 0;
    var dPct = 0;
    final sPct = <StatKind, int>{};
    for (final e in active) {
      xpPct += e.xpPct;
      dPct += e.diamondsPct;
      e.statPct.forEach((k, v) => sPct[k] = (sPct[k] ?? 0) + v);
    }
    int scale(int v, int pct) => pct == 0 || v <= 0 ? v : math.max(0, (v * (100 + pct) / 100).round());
    return GameReward(
      diamonds: scale(base.diamonds, dPct),
      xp: scale(base.xp, xpPct),
      stats: {for (final e in base.stats.entries) e.key: scale(e.value, sPct[e.key] ?? 0)},
    );
  }

  // ---- Серия ----

  /// null — день нейтральный (нет учитываемых квестов), true — засчитан, false — сорван.
  bool? dayCounted(DayTally t) {
    if (t.eligible <= 0) return null;
    return t.done / t.eligible >= config.streakThreshold - 1e-9;
  }

  /// Серия на день [today]: сегодня считается, только если уже засчитан; пауза и нейтральные дни
  /// пропускаются (серия не сгорает); день без квестов или сорванный — обрыв.
  int streakDays({
    required DateTime today,
    required Map<DateTime, DayTally> tallies,
    required bool Function(DateTime day) isPaused,
    int maxDays = 400,
  }) {
    final d0 = DateTime(today.year, today.month, today.day);
    var streak = 0;
    final t0 = tallies[d0];
    if (t0 != null && dayCounted(t0) == true) streak++;
    for (var i = 1; i <= maxDays; i++) {
      final d = DateTime(d0.year, d0.month, d0.day - i);
      if (isPaused(d)) continue;
      final t = tallies[d];
      if (t == null) break;
      final c = dayCounted(t);
      if (c == null) continue;
      if (!c) break;
      streak++;
    }
    return streak;
  }

  // ---- Расписание шаблона ----

  /// Попадает ли шаблон на день. [weekNumber] — номер недели дня (1/2, ScheduleLogic.weekNumber).
  static bool occursOn({
    required DateTime day,
    required int weekNumber,
    List<int> weekdays = const [],
    int weekParity = 0,
    DateTime? activeFrom,
    DateTime? activeUntil,
  }) {
    final d = DateTime(day.year, day.month, day.day);
    if (activeFrom != null && d.isBefore(DateTime(activeFrom.year, activeFrom.month, activeFrom.day))) return false;
    if (activeUntil != null && d.isAfter(DateTime(activeUntil.year, activeUntil.month, activeUntil.day))) {
      return false;
    }
    if (weekdays.isNotEmpty && !weekdays.contains(d.weekday)) return false;
    if (weekParity != 0 && weekParity != weekNumber) return false;
    return true;
  }

  /// Начало и дедлайн экземпляра: со временем — [minute] + окно; без времени — до конца дня.
  static (DateTime?, DateTime) instanceTimes(DateTime day, int? minute, int windowMinutes) {
    if (minute == null) return (null, DateTime(day.year, day.month, day.day + 1));
    final start = DateTime(day.year, day.month, day.day, 0, minute);
    return (start, start.add(Duration(minutes: math.max(1, windowMinutes))));
  }
}
