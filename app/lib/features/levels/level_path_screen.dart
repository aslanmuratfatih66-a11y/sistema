// «Путь уровней» (решение владельца 2026-10-22, SPEC §6): вертикальная дорога уровней 1…max.
// Пройденные — зелёные, текущий подсвечен с прогрессом опыта, будущие — приглушены. У каждого уровня —
// награда из таблицы GameConfig.levelRewards (◆, форма/скин, функция, монстр-босс), титул и новый ранг.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/quests/game_rules.dart';
import '../../domain/quests/quest_api.dart';
import '../../domain/quests/quest_l10n.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../home/widgets/level_hexagon.dart';
import '../quests/data/quest_providers.dart';
import '../schedule/widgets/schedule_common.dart';

class LevelPathScreen extends ConsumerStatefulWidget {
  const LevelPathScreen({super.key, this.rules = const GameRules()});

  final GameRules rules;

  @override
  ConsumerState<LevelPathScreen> createState() => _LevelPathScreenState();
}

class _LevelPathScreenState extends ConsumerState<LevelPathScreen> {
  final _currentKey = GlobalKey();
  bool _scrolled = false;

  /// Один раз после загрузки — прокрутить к текущему уровню.
  void _scrollToCurrent() {
    if (_scrolled) return;
    _scrolled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = _currentKey.currentContext;
      if (c != null && c.mounted) Scrollable.ensureVisible(c, alignment: 0.35);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final player = ref.watch(questPlayerProvider).value;
    final rules = widget.rules;
    final max = rules.config.maxLevel;
    final current = player?.level ?? 1;
    if (player != null) _scrollToCurrent();

    return ScheduleSubPage(
      key: const Key('level-path'),
      title: l.lvlPathTitle,
      onBack: () => Navigator.of(context).maybePop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (player != null) ...[
            _Summary(player: player, rules: rules),
            const SizedBox(height: 12),
          ],
          for (var n = 1; n <= max; n++)
            _LevelRow(
              key: n == current ? _currentKey : ValueKey('lvl-$n'),
              level: n,
              current: current,
              last: n == max,
              rules: rules,
              xpInto: n == current ? player?.xpIntoLevel ?? 0 : 0,
              xpNeed: n == current ? player?.xpForNextLevel ?? rules.xpToNext(n) : rules.xpToNext(n),
            ),
        ],
      ),
    );
  }
}

/// Сводка сверху: уровень, ранг, опыт до следующего и ближайшая награда из таблицы.
class _Summary extends StatelessWidget {
  const _Summary({required this.player, required this.rules});

  final PlayerSnapshot player;
  final GameRules rules;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final next = rules.levelRewardsBetween(player.level, rules.config.maxLevel).firstOrNull;
    return SysPanel(
      tone: PanelTone.gold,
      child: Row(
        children: [
          LevelHexagon(level: player.level, size: 56),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.lvlPathRank(rankLabel(player.rank)), style: SysText.body),
                const SizedBox(height: 4),
                Text(
                  l.lvlPathXpLeft(player.xpForNextLevel - player.xpIntoLevel),
                  style: SysText.monoSmall.copyWith(color: SysColors.textSecondary),
                ),
                if (next != null) ...[
                  const SizedBox(height: 4),
                  Text(l.lvlPathNextReward(next.$1), style: SysText.caption.copyWith(color: SysColors.gold)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({
    super.key,
    required this.level,
    required this.current,
    required this.last,
    required this.rules,
    required this.xpInto,
    required this.xpNeed,
  });

  final int level;
  final int current;
  final bool last;
  final GameRules rules;
  final int xpInto;
  final int xpNeed;

  static const double _rail = 56;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final passed = level < current;
    final isCurrent = level == current;
    final dim = SysColors.textInactive.withValues(alpha: .35);
    final reward = rules.config.levelRewards[level];
    final title = rules.config.levelTitles[level];
    final rank = rules.rankAt(level);
    final skin = reward?.skin;
    final feature = reward?.feature;
    final boss = reward?.boss;

    final pills = <Widget>[
      if (reward != null && reward.diamonds > 0)
        SysPill(label: l.lvlRewardDiamonds(reward.diamonds), icon: SysGlyph.diamond, tone: PanelTone.gold),
      if (title != null) SysPill(label: titleLabel(l, title) ?? title, icon: SysGlyph.crown, tone: PanelTone.gold),
      if (rank != null) SysPill(label: l.lvlPathRank(rankLabel(rank)), icon: SysGlyph.arrowUp),
      if (skin != null) SysPill(label: l.lvlRewardSkin(levelSkinLabel(l, skin)), icon: SysGlyph.sparkle),
      if (feature != null)
        SysPill(label: l.lvlRewardFeature(levelFeatureLabel(l, feature)), icon: SysGlyph.lock, tone: PanelTone.success),
      if (boss != null) SysPill(label: l.lvlRewardBoss(levelBossLabel(l, boss)), icon: SysGlyph.sword, tone: PanelTone.boss),
    ];

    final textColor = passed
        ? SysColors.textSecondary
        : isCurrent
            ? SysColors.textPrimary
            : SysColors.textCaption;

    return Semantics(
      container: true,
      label: passed
          ? l.lvlPathPassedSemantics(level)
          : isCurrent
              ? l.lvlPathCurrentSemantics(level)
              : l.lvlPathLockedSemantics(level),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Дорога: отрезок сверху, узел уровня, отрезок снизу.
            SizedBox(
              width: _rail,
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Container(width: 2, color: level == 1 ? Colors.transparent : (level <= current ? SysColors.success : dim)),
                    ),
                  ),
                  _Node(level: level, passed: passed, current: isCurrent),
                  Expanded(
                    child: Center(child: Container(width: 2, color: last ? Colors.transparent : (passed ? SysColors.success : dim))),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: isCurrent ? SysColors.accent.withValues(alpha: .12) : SysColors.panelBottom.withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(SysDims.radius),
                    border: Border.all(
                      color: isCurrent
                          ? SysColors.accentLight
                          : passed
                              ? SysColors.success.withValues(alpha: .35)
                              : SysColors.panelBorder.withValues(alpha: .25),
                      width: isCurrent ? 1.5 : 1,
                    ),
                    boxShadow: isCurrent ? const [BoxShadow(color: SysColors.panelOuterGlow, blurRadius: 18)] : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l.lvlPathLevel(level),
                              style: SysText.heading.copyWith(fontSize: 15, letterSpacing: 1.6, color: textColor),
                            ),
                          ),
                          if (passed) const SysIcon(SysGlyph.check, size: 16, color: SysColors.success),
                          if (isCurrent) SysPill(label: l.lvlPathCurrent),
                          if (!passed && !isCurrent) const SysIcon(SysGlyph.lock, size: 16, color: SysColors.textInactive),
                        ],
                      ),
                      if (isCurrent) ...[
                        const SizedBox(height: 8),
                        SysBar(value: xpNeed > 0 ? xpInto / xpNeed : 0),
                        const SizedBox(height: 4),
                        Text(
                          l.lvlPathXp(xpInto, xpNeed),
                          key: const Key('lvl-current-xp'),
                          style: SysText.monoSmall.copyWith(color: SysColors.textSecondary),
                        ),
                      ] else if (!passed) ...[
                        const SizedBox(height: 2),
                        Text(
                          l.lvlPathXpTotal(rules.xpTotalFor(level)),
                          style: SysText.monoSmall.copyWith(color: SysColors.textInactive),
                        ),
                      ],
                      if (pills.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Opacity(opacity: passed ? .7 : 1, child: Wrap(spacing: 6, runSpacing: 6, children: pills)),
                      ] else if (level > 1) ...[
                        const SizedBox(height: 4),
                        Text(l.lvlRewardStatPoints(rules.config.statPointsPerLevel), style: SysText.caption),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({required this.level, required this.passed, required this.current});

  final int level;
  final bool passed;
  final bool current;

  @override
  Widget build(BuildContext context) {
    if (current) return ExcludeSemantics(child: LevelHexagon(level: level, size: 44));
    final color = passed ? SysColors.success : SysColors.textInactive;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: passed ? SysColors.success.withValues(alpha: .15) : SysColors.background,
        border: Border.all(color: color.withValues(alpha: passed ? .9 : .5), width: 1.5),
      ),
      child: Text('$level', style: SysText.monoSmall.copyWith(fontSize: 11, color: color)),
    );
  }
}
