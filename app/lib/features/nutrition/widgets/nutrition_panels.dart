// Панели вкладки «Питание»: калории и БЖУ против нормы, вода, дневник по приёмам пищи.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/models/daily.dart';
import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../plan/model/plan.dart';
import '../data/diary_repository.dart';
import '../domain/nutrition_math.dart';
import '../nutrition_format.dart';

/// Съедено за день против нормы плана; без нормы — только значения.
class CaloriesPanel extends StatelessWidget {
  const CaloriesPanel({super.key, required this.day, this.norms, this.burnedKcal});

  final NutritionDay day;
  final PlanNorms? norms;

  /// Сожжено за день (шаги + тренировки + базовый обмен); null — неизвестно.
  final double? burnedKcal;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final n = norms;
    final kcalGoal = n?.calories;
    final burned = burnedKcal;

    Widget bar(String key, String label, double value, int? goal, Color color, {SysGlyph? icon, bool kcal = false}) {
      final text = kcal
          ? (goal == null ? kcalText(l, value) : l.homeKcalProgress(fmtInt(l, value), fmtInt(l, goal)))
          : (goal == null ? l.nutGrams(fmt1(l, value)) : l.nutGramsProgress(fmt1(l, value), fmtInt(l, goal)));
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: StatBar(
          key: Key(key),
          label: label,
          value: value,
          max: (goal ?? 0).toDouble(),
          color: color,
          icon: icon,
          valueText: text,
          height: kcal ? 8 : 5,
        ),
      );
    }

    return SysPanel(
      key: const Key('nut-calories'),
      title: l.hqCaloriesTodayTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          bar('nut-bar-kcal', l.homeCalories, day.kcal, kcalGoal, SysColors.calories, icon: SysGlyph.flame, kcal: true),
          bar('nut-bar-protein', l.nutProtein, day.protein, n?.proteinG, SysColors.success),
          bar('nut-bar-fat', l.nutFat, day.fat, n?.fatG, SysColors.gold),
          bar('nut-bar-carbs', l.nutCarbs, day.carbs, n?.carbsG, SysColors.accentLight),
          if (kcalGoal == null) Text(l.nutNoNorm, style: SysText.caption),
          if (burned != null) ...[
            const SizedBox(height: 4),
            _SummaryRow(label: l.homeBurned, value: kcalText(l, burned), color: SysColors.calories),
            _SummaryRow(
              label: l.nutBalance,
              value: kcalText(l, day.kcal - burned),
              color: day.kcal <= burned ? SysColors.success : SysColors.dangerLight,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(child: Text(label, style: SysText.secondary)),
            Text(value, style: SysText.mono.copyWith(color: color ?? SysColors.textPrimary)),
          ],
        ),
      );
}

/// Вода: прогресс к норме, +250 / +500, отмена последней записи.
class WaterPanel extends StatelessWidget {
  const WaterPanel({
    super.key,
    required this.waterMl,
    required this.goalMl,
    required this.trainingDay,
    required this.canUndo,
    required this.onAdd,
    required this.onUndo,
  });

  final int waterMl;
  final int? goalMl;
  final bool trainingDay;
  final bool canUndo;
  final ValueChanged<int> onAdd;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final goal = goalMl;
    String liters(int ml) => NumberFormat('0.##', l.localeName).format(ml / 1000);
    return SysPanel(
      key: const Key('nut-water'),
      title: l.homeWater,
      trailing: trainingDay ? SysPill(label: l.nutTrainingDay, icon: SysGlyph.dumbbell) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatBar(
            key: const Key('nut-bar-water'),
            label: l.homeWater,
            value: waterMl.toDouble(),
            max: (goal ?? 0).toDouble(),
            color: SysColors.water,
            icon: SysGlyph.water,
            valueText: goal == null ? l.nutLiters(liters(waterMl)) : l.homeLitersProgress(liters(waterMl), liters(goal)),
            height: 8,
          ),
          if (goal == null) ...[const SizedBox(height: 4), Text(l.nutNoWaterNorm, style: SysText.caption)],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SysButton.secondary(
                  key: const Key('nut-water-250'),
                  label: l.nutWaterAdd(250),
                  icon: SysGlyph.water,
                  onPressed: () => onAdd(250),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SysButton.secondary(
                  key: const Key('nut-water-500'),
                  label: l.nutWaterAdd(500),
                  icon: SysGlyph.water,
                  onPressed: () => onAdd(500),
                ),
              ),
              const SizedBox(width: 4),
              NutIconButton(
                key: const Key('nut-water-undo'),
                glyph: SysGlyph.close,
                tooltip: l.nutWaterUndo,
                onPressed: canUndo ? onUndo : null,
                color: canUndo ? SysColors.accentLight : SysColors.textInactive,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Дневник дня по приёмам пищи; нажатие на запись — правка.
class DiaryPanel extends StatelessWidget {
  const DiaryPanel({super.key, required this.entries, required this.onOpen});

  final List<MealEntryRow> entries;
  final ValueChanged<MealEntryRow> onOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final byType = <MealType, List<MealEntryRow>>{};
    for (final e in entries) {
      (byType[e.type] ??= []).add(e);
    }
    return SysPanel(
      key: const Key('nut-diary'),
      title: l.hqNutritionDiaryTitle,
      child: entries.isEmpty
          ? Text(l.nutDiaryEmpty, style: SysText.secondary)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final t in MealType.values)
                  if (byType[t] case final list?) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(mealTypeLabel(l, t).toUpperCase(),
                                style: SysText.label.copyWith(color: SysColors.accentLight)),
                          ),
                          Text(
                            kcalText(l, Macros.sum(list.map((e) => e.macros)).kcal),
                            style: SysText.monoSmall.copyWith(color: SysColors.calories),
                          ),
                        ],
                      ),
                    ),
                    for (final e in list) _EntryRow(entry: e, onTap: () => onOpen(e)),
                  ],
              ],
            ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.onTap});

  final MealEntryRow entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final grams = entry.grams;
    return InkWell(
      key: Key('nut-entry-${entry.id}'),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: SysDims.minTap),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.title, style: SysText.body),
                    Text(
                      [
                        if (grams != null) l.nutGrams(fmt1(l, grams)),
                        macrosLine(l, entry.macros),
                        if (entry.photoId != null) l.nutWithPhoto,
                      ].join(' · '),
                      style: SysText.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(fmtInt(l, entry.kcal), style: SysText.mono.copyWith(color: SysColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}
