import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../models/home_view_data.dart';
import '../utils/home_format.dart';
import 'level_hexagon.dart';

/// Блок 2: сжатый статус игрока — уровень/имя/ранг/серия, опыт и «Очки характ.»,
/// три шкалы в ряд, 6 характеристик в 2 ряда, баллы ◆ в шапке панели.
class StatusPanel extends StatelessWidget {
  const StatusPanel({super.key, required this.player, this.onStatPoints});

  final PlayerStatus player;
  final VoidCallback? onStatPoints;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final nf = NumberFormat.decimalPattern(l.localeName);
    final oneDec = NumberFormat('0.0', l.localeName);
    final p = player;
    final pointsText = l.homePointsValue(nf.format(p.points));
    final title = p.title?.of(l);
    final energy = p.energyPercent;

    final points = Semantics(
      label: l.homePointsLabel,
      value: pointsText,
      excludeSemantics: true,
      child: Text(
        pointsText,
        style: SysText.mono.copyWith(
          fontSize: 13,
          color: p.points < 0 ? SysColors.danger : SysColors.gold,
          fontWeight: FontWeight.w700,
          shadows: const [Shadow(color: Color(0x99FFC857), blurRadius: 10)],
        ),
      ),
    );

    return SysPanel(
      title: l.homeStatusTitle,
      trailing: points,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LevelHexagon(level: p.level, size: 50),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: upperFor(p.name.of(l), locale),
                          style: SysText.heading.copyWith(fontSize: 17, letterSpacing: 2),
                        ),
                        if (title != null && title.isNotEmpty) ...[
                          const TextSpan(text: '   '),
                          TextSpan(
                            text: title,
                            style: SysText.caption.copyWith(color: SysColors.accentLight),
                          ),
                        ],
                      ]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        SysPill(label: l.homeRank(p.rank.letter), icon: SysGlyph.shield),
                        SysPill(label: l.homeStreakDays(p.streakDays), tone: PanelTone.gold, icon: SysGlyph.flame),
                        if (p.paused) SysPill(label: l.qstPausedPill, tone: PanelTone.success, icon: SysGlyph.moon),
                        if (p.discipline)
                          SysPill(label: l.qstDisciplinePill, tone: PanelTone.danger, icon: SysGlyph.shield),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: StatBar(
                  label: l.homeXpLabel(p.level + 1),
                  value: p.xp.toDouble(),
                  max: p.xpForNextLevel.toDouble(),
                  color: SysColors.accent,
                  icon: SysGlyph.star,
                  valueText: l.homeXpValue(nf.format(p.xp), nf.format(p.xpForNextLevel)),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: _StatPointsButton(
                  label: l.homeStatPointsButton(p.freeStatPoints),
                  onTap: p.freeStatPoints > 0 ? (onStatPoints ?? () {}) : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MiniBar(
                  label: l.homeEnergy,
                  icon: SysGlyph.bolt,
                  color: SysColors.energy,
                  fraction: energy == null ? 0 : energy / 100,
                  value: energy == null ? l.qstNoValue : l.homePercentValue(nf.format(energy)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniBar(
                  label: l.homeWater,
                  icon: SysGlyph.water,
                  color: SysColors.water,
                  fraction: p.waterGoalMl <= 0 ? 0 : p.waterMl / p.waterGoalMl,
                  value: l.homeLitersProgress(
                    oneDec.format(p.waterMl / 1000),
                    p.waterGoalMl <= 0 ? l.qstNoValue : oneDec.format(p.waterGoalMl / 1000),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniBar(
                  label: l.homeCalories,
                  icon: SysGlyph.flame,
                  color: SysColors.calories,
                  fraction: p.kcalGoal <= 0 ? 0 : p.kcalEaten / p.kcalGoal,
                  value: l.homeKcalProgress(
                    nf.format(p.kcalEaten),
                    p.kcalGoal <= 0 ? l.qstNoValue : nf.format(p.kcalGoal),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _StatsGrid(stats: p.stats),
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

/// Короткое обозначение характеристики (СИЛ, ВЫН…) для компактной сетки.
String statShortLabel(AppLocalizations l, StatKind k) => switch (k) {
      StatKind.strength => l.hqStatStrengthShort,
      StatKind.endurance => l.hqStatEnduranceShort,
      StatKind.discipline => l.hqStatDisciplineShort,
      StatKind.intellect => l.hqStatIntellectShort,
      StatKind.health => l.hqStatHealthShort,
      StatKind.looks => l.hqStatLooksShort,
    };

/// «Очки характ.: N» — визуально низкая кнопка, зона нажатия ≥44.
class _StatPointsButton extends StatelessWidget {
  const _StatPointsButton({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = enabled ? SysColors.accentLighter : SysColors.textInactive;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 28,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: SysDims.minTap, minWidth: SysDims.minTap),
          child: Center(
            widthFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: SysColors.accent.withValues(alpha: enabled ? .14 : .05),
                border: Border.all(color: color.withValues(alpha: .6)),
                borderRadius: BorderRadius.circular(2),
                boxShadow: enabled ? const [BoxShadow(color: Color(0x553FB4FF), blurRadius: 8)] : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SysIcon(SysGlyph.plus, size: 13, color: color),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: SysText.caption.copyWith(color: color, fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Узкая шкала для ряда «Энергия · Вода · Калории».
class _MiniBar extends StatelessWidget {
  const _MiniBar({
    required this.label,
    required this.icon,
    required this.color,
    required this.fraction,
    required this.value,
  });

  final String label;
  final SysGlyph icon;
  final Color color;
  final double fraction;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      value: value,
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SysIcon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SysText.caption.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: SysText.mono.copyWith(fontSize: 11.5, color: SysColors.textPrimary),
            ),
          ),
          const SizedBox(height: 4),
          SysBar(value: fraction.clamp(0.0, 1.0), color: color, height: 5),
        ],
      ),
    );
  }
}

/// 6 характеристик: 2 ряда по 3 (на узкой ширине / крупном шрифте — 3 ряда по 2).
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final List<StatValue> stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final cols = (c.maxWidth / scale) >= 240 ? 3 : 2;
      final rows = <Widget>[];
      for (var i = 0; i < stats.length; i += cols) {
        final cells = <Widget>[];
        for (var j = 0; j < cols; j++) {
          if (j > 0) cells.add(const SizedBox(width: 6));
          final idx = i + j;
          cells.add(Expanded(child: idx < stats.length ? _StatCell(stat: stats[idx]) : const SizedBox()));
        }
        if (rows.isNotEmpty) rows.add(const SizedBox(height: 6));
        rows.add(Row(crossAxisAlignment: CrossAxisAlignment.start, children: cells));
      }
      return Column(mainAxisSize: MainAxisSize.min, children: rows);
    });
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.stat});

  final StatValue stat;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final delta = stat.deltaToday;
    final deltaColor = delta > 0 ? SysColors.success : (delta < 0 ? SysColors.danger : SysColors.textInactive);
    return Semantics(
      label: l.homeStatDeltaSemantics(statLabel(l, stat.kind), '${stat.value}', formatSigned(delta)),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(63, 180, 255, .06),
          border: Border.all(color: const Color.fromRGBO(63, 180, 255, .22)),
          borderRadius: BorderRadius.circular(SysDims.radius),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                statShortLabel(l, stat.kind),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SysText.caption.copyWith(fontFamily: SysFonts.heading, letterSpacing: 1.1, fontSize: 11),
              ),
            ),
            Text('${stat.value}', style: SysText.mono.copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
            if (delta != 0) ...[
              const SizedBox(width: 4),
              Text(formatSigned(delta), style: SysText.mono.copyWith(fontSize: 11, color: deltaColor)),
            ],
          ],
        ),
      ),
    );
  }
}
