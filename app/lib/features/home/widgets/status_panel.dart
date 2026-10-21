import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../models/home_view_data.dart';
import '../utils/home_format.dart';
import 'level_hexagon.dart';

/// Блок 2: статус игрока.
class StatusPanel extends StatelessWidget {
  const StatusPanel({super.key, required this.player, this.onStatPoints});

  final PlayerStatus player;
  final VoidCallback? onStatPoints;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final nf = NumberFormat.decimalPattern(l.localeName);
    final p = player;

    return SysPanel(
      title: l.homeStatusTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LevelHexagon(level: p.level),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upperFor(p.name.of(l), Localizations.localeOf(context)),
                      style: SysText.heading.copyWith(fontSize: 20, letterSpacing: 2.4),
                    ),
                    const SizedBox(height: 2),
                    Text(p.title.of(l), style: SysText.secondary.copyWith(color: SysColors.accentLight)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        SysPill(label: l.homeRank(p.rank.letter), icon: SysGlyph.shield),
                        SysPill(label: l.homeStreakDays(p.streakDays), tone: PanelTone.gold, icon: SysGlyph.flame),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StatBar(
            label: l.homeXpLabel(p.level + 1),
            value: p.xp.toDouble(),
            max: p.xpForNextLevel.toDouble(),
            color: SysColors.accent,
            icon: SysGlyph.star,
            valueText: l.homeXpValue(nf.format(p.xp), nf.format(p.xpForNextLevel)),
          ),
          const SizedBox(height: 12),
          StatBar(
            label: l.homeEnergy,
            value: p.energyPercent.toDouble(),
            max: 100,
            color: SysColors.energy,
            icon: SysGlyph.bolt,
            valueText: l.homePercentValue(nf.format(p.energyPercent)),
          ),
          const SizedBox(height: 8),
          StatBar(
            label: l.homeWater,
            value: p.waterMl.toDouble(),
            max: p.waterGoalMl.toDouble(),
            color: SysColors.water,
            icon: SysGlyph.water,
            valueText: l.homeLitersProgress(
              NumberFormat('0.0', l.localeName).format(p.waterMl / 1000),
              NumberFormat('0.0', l.localeName).format(p.waterGoalMl / 1000),
            ),
          ),
          const SizedBox(height: 8),
          StatBar(
            label: l.homeCalories,
            value: p.kcalEaten.toDouble(),
            max: p.kcalGoal.toDouble(),
            color: SysColors.calories,
            icon: SysGlyph.flame,
            valueText: l.homeKcalProgress(nf.format(p.kcalEaten), nf.format(p.kcalGoal)),
          ),
          const SizedBox(height: 14),
          _StatsGrid(stats: p.stats),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Semantics(
                label: l.homePointsLabel,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      upperFor(l.homePointsLabel, Localizations.localeOf(context)),
                      style: SysText.caption.copyWith(fontFamily: SysFonts.heading, letterSpacing: 1.4),
                    ),
                    Text(
                      l.homePointsValue(nf.format(p.points)),
                      style: SysText.monoLarge.copyWith(
                        color: p.points < 0 ? SysColors.danger : SysColors.gold,
                        fontWeight: FontWeight.w700,
                        shadows: const [Shadow(color: Color(0x99FFC857), blurRadius: 10)],
                      ),
                    ),
                  ],
                ),
              ),
              SysButton.secondary(
                label: l.homeStatPointsButton(p.freeStatPoints),
                icon: SysGlyph.plus,
                onPressed: p.freeStatPoints > 0 ? (onStatPoints ?? () {}) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String statLabel(AppLocalizations l, StatKind k) => switch (k) {
      StatKind.strength => l.homeStatStrength,
      StatKind.endurance => l.homeStatEndurance,
      StatKind.discipline => l.homeStatDiscipline,
      StatKind.intellect => l.homeStatIntellect,
      StatKind.health => l.homeStatHealth,
      StatKind.looks => l.homeStatLooks,
    };

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<StatValue> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      // 3 колонки на обычной ширине, 2 — на узкой или при крупном шрифте.
      final cols = (c.maxWidth / scale) >= 280 ? 3 : 2;
      final rows = <Widget>[];
      for (var i = 0; i < stats.length; i += cols) {
        final cells = <Widget>[];
        for (var j = 0; j < cols; j++) {
          if (j > 0) cells.add(const SizedBox(width: 6));
          final idx = i + j;
          cells.add(Expanded(child: idx < stats.length ? _StatCell(stat: stats[idx]) : const SizedBox()));
        }
        if (rows.isNotEmpty) rows.add(const SizedBox(height: 6));
        rows.add(IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells)));
      }
      return Column(children: rows);
    });
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.stat});

  final StatValue stat;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final label = statLabel(l, stat.kind);
    final delta = stat.deltaToday;
    final deltaColor = delta > 0 ? SysColors.success : (delta < 0 ? SysColors.danger : SysColors.textInactive);
    return Semantics(
      label: l.homeStatDeltaSemantics(label, '${stat.value}', formatSigned(delta)),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(63, 180, 255, .06),
          border: Border.all(color: const Color.fromRGBO(63, 180, 255, .22)),
          borderRadius: BorderRadius.circular(SysDims.radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              upperFor(label, Localizations.localeOf(context)),
              style: SysText.caption.copyWith(fontFamily: SysFonts.heading, letterSpacing: 1.1, fontSize: 10.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 6,
              children: [
                Text('${stat.value}', style: SysText.mono.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
                if (delta != 0)
                  Text(formatSigned(delta), style: SysText.mono.copyWith(fontSize: 12, color: deltaColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
