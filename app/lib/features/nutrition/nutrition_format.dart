// Подписи и форматирование чисел раздела «Питание».
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../schedule/widgets/schedule_common.dart' show ScheduleSubPage;
import 'domain/nutrition_math.dart';
import 'domain/shopping_plan.dart';

export '../schedule/widgets/schedule_common.dart' show ScheduleSubPage;

String mealTypeLabel(AppLocalizations l, MealType t) => switch (t) {
      MealType.breakfast => l.nutMealBreakfast,
      MealType.lunch => l.nutMealLunch,
      MealType.dinner => l.nutMealDinner,
      MealType.snack => l.nutMealSnack,
    };

/// Приём пищи по времени суток (для новой записи).
MealType mealTypeFor(DateTime t) {
  final h = t.hour;
  if (h >= 5 && h < 11) return MealType.breakfast;
  if (h >= 11 && h < 16) return MealType.lunch;
  if (h >= 18 && h < 22) return MealType.dinner;
  return MealType.snack;
}

/// Момент записи для выбранного дня: сегодня — сейчас, другой день — то же время суток.
DateTime entryMomentFor(DateTime day, DateTime now) =>
    sameDay(day, now) ? now : DateTime(day.year, day.month, day.day, now.hour, now.minute);

/// Целое с разделителем разрядов («1 250»).
String fmtInt(AppLocalizations l, num v) => NumberFormat.decimalPattern(l.localeName).format(v.round());

/// До 0.1, без лишнего «,0» («12,5» / «12»).
String fmt1(AppLocalizations l, num v) => NumberFormat('0.#', l.localeName).format(round1(v.toDouble()));

/// «Б 12 · Ж 4,5 · У 30».
String macrosLine(AppLocalizations l, Macros m) =>
    l.nutMacrosLine(fmt1(l, m.protein), fmt1(l, m.fat), fmt1(l, m.carbs));

/// «420 ккал».
String kcalText(AppLocalizations l, num v) => l.homeKcalValue(fmtInt(l, v));

String unitLabel(AppLocalizations l, String? unit) => switch (unit) {
      ShopUnit.g => l.nutUnitG,
      ShopUnit.kg => l.nutUnitKg,
      ShopUnit.pcs => l.nutUnitPcs,
      ShopUnit.l => l.nutUnitL,
      ShopUnit.ml => l.nutUnitMl,
      null => '',
      _ => unit,
    };

String groceryLabel(AppLocalizations l, PlanGrocery g) => switch (g) {
      PlanGrocery.chicken => l.nutGroceryChicken,
      PlanGrocery.eggs => l.nutGroceryEggs,
      PlanGrocery.cottageCheese => l.nutGroceryCottageCheese,
      PlanGrocery.grains => l.nutGroceryGrains,
      PlanGrocery.oats => l.nutGroceryOats,
      PlanGrocery.vegetables => l.nutGroceryVegetables,
      PlanGrocery.fruits => l.nutGroceryFruits,
      PlanGrocery.oil => l.nutGroceryOil,
      PlanGrocery.water => l.nutGroceryWater,
    };

/// Валюта по умолчанию: турецкий интерфейс — лира, иначе рубль.
String defaultCurrency(AppLocalizations l) => l.localeName.startsWith('tr') ? 'TRY' : 'RUB';

/// Сумма из минимальных единиц.
String moneyText(AppLocalizations l, int minor, String currency) =>
    NumberFormat.simpleCurrency(locale: l.localeName, name: currency, decimalDigits: minor % 100 == 0 ? 0 : 2)
        .format(minor / 100);

/// Открыть экран раздела поверх вкладки.
Future<T?> pushNutrition<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute<T>(builder: (_) => page));

/// Страница раздела: фон Системы, «назад», прокрутка.
class NutPage extends StatelessWidget {
  const NutPage({super.key, required this.title, required this.child, this.bottom});

  final String title;
  final Widget child;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) =>
      ScheduleSubPage(title: title, onBack: () => Navigator.of(context).maybePop(), bottom: bottom, child: child);
}

/// Квадратная кнопка-иконка ≥44 pt с подписью для скринридера.
class NutIconButton extends StatelessWidget {
  const NutIconButton({super.key, required this.glyph, required this.tooltip, required this.onPressed, this.color});

  final SysGlyph glyph;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: SysDims.minTap, minHeight: SysDims.minTap),
        icon: SysIcon(glyph, size: 20, color: color ?? SysColors.accentLight),
      );
}

/// Отметка-квадрат (куплено / выбрано).
class NutCheckBox extends StatelessWidget {
  const NutCheckBox({super.key, required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) => Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SysDims.radius),
          border: Border.all(color: checked ? SysColors.success : SysColors.panelBorder, width: 1.5),
          color: checked ? SysColors.success.withValues(alpha: .18) : null,
        ),
        child: checked ? const Center(child: SysIcon(SysGlyph.check, size: 16, color: SysColors.success)) : null,
      );
}
