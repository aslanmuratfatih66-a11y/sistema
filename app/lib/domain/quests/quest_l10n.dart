// Локализация сущностей движка квестов. Сигнатуры — КОНТРАКТ каркаса (используют C, B, D);
// реализация — сабагент A: системные ключи квестов, эффекты, титулы, причины штрафов.
import '../../core/models/enums.dart';
import '../../features/plan/model/plan.dart' show QuestCategory, QuestDraft, QuestKey;
import '../../features/finance/fin_texts.dart' show finReasonLabel;
import '../../features/plan/plan_l10n.dart' show planQuestTitle;
import '../../l10n/app_localizations.dart';
import '../discipline/discipline_l10n.dart' show disciplineQuestTitle;
import 'game_rules.dart';
import 'quest_api.dart';
import 'system_quests.dart';

/// Название квеста: свой текст, ключ плана (QuestKey), системный ключ движка или ключ дисциплины.
String questTitleText(AppLocalizations l, QuestTitle t) {
  final text = t.text;
  if (text != null && text.trim().isNotEmpty) return text;
  final key = enumByName(QuestKey.values, t.key);
  if (key != null) {
    return planQuestTitle(
      l,
      QuestDraft(
        key: key,
        category: QuestCategory.daily,
        params: t.params,
        minute: _int(t.params['minute']),
        diamonds: 0,
        xp: 0,
      ),
    );
  }
  final sys = enumByName(SystemQuestKey.values, t.key);
  if (sys != null) return _systemTitle(l, sys, t.params);
  final raw = t.key;
  if (raw == null) return '';
  return disciplineQuestTitle(l, raw, t.params) ?? raw;
}

String _systemTitle(AppLocalizations l, SystemQuestKey k, Map<String, Object?> p) {
  String s(String key, [Object fallback = '']) => '${p[key] ?? fallback}';
  final minute = _int(p['minute']);
  final time = minute == null ? '' : _hhmm(minute);
  return switch (k) {
    SystemQuestKey.penaltyCleaning => l.qeQuestPenaltyCleaning(s('minutes', 15)),
    SystemQuestKey.penaltyReading => l.qeQuestPenaltyReading(s('minutes', 20)),
    SystemQuestKey.penaltyPlank => l.qeQuestPenaltyPlank(s('seconds', 20)),
    SystemQuestKey.penaltyWalk => l.qeQuestPenaltyWalk(s('minutes', 20)),
    SystemQuestKey.penaltyNoGames => l.qeQuestPenaltyNoGames,
    SystemQuestKey.boostWalk => l.qeQuestBoostWalk(s('minutes', 20)),
    SystemQuestKey.boostWater => l.qeQuestBoostWater(s('ml', 500)),
    SystemQuestKey.boostBedOnTime => l.qeQuestBoostBedOnTime(time),
    SystemQuestKey.boostPlanTomorrow => l.qeQuestBoostPlanTomorrow,
    SystemQuestKey.bossAll => l.qeQuestBossAll(s('count')),
    SystemQuestKey.bossStrength => l.qeQuestBossStrength(s('count')),
    SystemQuestKey.bossEndurance => l.qeQuestBossEndurance(s('count')),
    SystemQuestKey.bossDiscipline => l.qeQuestBossDiscipline(s('count')),
    SystemQuestKey.bossIntellect => l.qeQuestBossIntellect(s('count')),
    SystemQuestKey.bossHealth => l.qeQuestBossHealth(s('count')),
    SystemQuestKey.bossLooks => l.qeQuestBossLooks(s('count')),
  };
}

/// Подпись эффекта («Бодрость +5% опыта»). Неизвестный ключ — как есть.
String effectLabel(AppLocalizations l, ActiveEffect e) {
  final pct = '${e.params['pct'] ?? GameConfig.standard.effects[e.kind]?.params['pct'] ?? 0}';
  return switch (e.kind) {
    EffectKinds.vigor => l.qeEffectVigor(pct),
    EffectKinds.dehydration => l.qeEffectDehydration(pct),
    EffectKinds.bossAura => l.qeEffectBossAura(pct),
    _ => e.kind,
  };
}

/// Титул по ключу; null — без титула.
String? titleLabel(AppLocalizations l, String? titleKey) => switch (titleKey) {
      null => null,
      GameTitles.streak7 => l.qeTitleStreak7,
      GameTitles.streak30 => l.qeTitleStreak30,
      GameTitles.bossSlayer => l.qeTitleBossSlayer,
      GameTitles.bossHunter => l.qeTitleBossHunter,
      GameTitles.level5 => l.qeTitleLevel5,
      GameTitles.level10 => l.qeTitleLevel10,
      GameTitles.level20 => l.qeTitleLevel20,
      GameTitles.level25 => l.qeTitleLevel25,
      GameTitles.level35 => l.qeTitleLevel35,
      GameTitles.level50 => l.qeTitleLevel50,
      GameTitles.level75 => l.qeTitleLevel75,
      GameTitles.level100 => l.qeTitleLevel100,
      _ => titleKey,
    };

/// Форма/скин персонажа за уровень.
String levelSkinLabel(AppLocalizations l, String key) => switch (key) {
      LevelSkins.aura => l.lvlSkinAura,
      LevelSkins.cloak => l.lvlSkinCloak,
      LevelSkins.armor => l.lvlSkinArmor,
      LevelSkins.wings => l.lvlSkinWings,
      LevelSkins.crown => l.lvlSkinCrown,
      LevelSkins.monarch => l.lvlSkinMonarch,
      _ => key,
    };

/// Функция, открываемая уровнем.
String levelFeatureLabel(AppLocalizations l, String key) => switch (key) {
      LevelFeatures.autoplan => l.lvlFeatAutoplan,
      LevelFeatures.hunt => l.lvlFeatHunt,
      LevelFeatures.friends => l.lvlFeatFriends,
      LevelFeatures.rareHunt => l.lvlFeatRareHunt,
      LevelFeatures.globalRating => l.lvlFeatGlobalRating,
      _ => key,
    };

/// Монстр-босс за уровень.
String levelBossLabel(AppLocalizations l, String key) => switch (key) {
      LevelBosses.shadowWolf => l.lvlBossShadowWolf,
      LevelBosses.ironGolem => l.lvlBossIronGolem,
      LevelBosses.stormDrake => l.lvlBossStormDrake,
      LevelBosses.frostWarden => l.lvlBossFrostWarden,
      LevelBosses.abyssLord => l.lvlBossAbyssLord,
      _ => key,
    };

/// Причина отдельного штрафа (PenaltyApplied.reasonKey).
String penaltyReasonLabel(AppLocalizations l, String reasonKey) => switch (reasonKey) {
      PenaltyReasons.failedQuests => l.qeReasonFailedQuests,
      PenaltyReasons.markWalked => l.qeReasonMarkWalked,
      PenaltyReasons.markAlcohol => l.qeReasonMarkAlcohol,
      PenaltyReasons.markRelapse => l.qeReasonMarkRelapse,
      PenaltyReasons.bossFailed => l.qeReasonBossFailed,
      PenaltyReasons.reproach => l.qeReasonReproach,
      PenaltyReasons.blockedAttempt => l.blkReasonBlockedAttempt,
      'almReasonWake' => l.almReasonWake,
      _ => finReasonLabel(l, reasonKey) ?? l.qeReasonOther,
    };

/// Ранг буквой: E, D, C, B, A, S (не переводится).
String rankLabel(PlayerRank r) => r.name.toUpperCase();

int? _int(Object? v) => v is num ? v.toInt() : null;

String _hhmm(int minute) {
  final m = minute % (24 * 60);
  return '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
}
