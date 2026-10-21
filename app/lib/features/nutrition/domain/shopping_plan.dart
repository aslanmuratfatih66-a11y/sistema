// Базовый список покупок на неделю из норм плана (SPEC §8.2). У плана пока нет меню —
// примерные количества по белку/углеводам/жирам/воде, без выдуманных цен (цена — null).
// TODO(этап 5): список из меню, составленного ИИ, с ценами магазинов пользователя.
import 'package:flutter/foundation.dart';

/// Базовые продукты (названия локализуются при сохранении).
enum PlanGrocery { chicken, eggs, cottageCheese, grains, oats, vegetables, fruits, oil, water }

/// Единицы списка покупок (хранятся в ShoppingItems.unit).
abstract final class ShopUnit {
  static const g = 'g';
  static const kg = 'kg';
  static const pcs = 'pcs';
  static const l = 'l';
  static const ml = 'ml';
  static const all = [pcs, kg, g, l, ml];
}

@immutable
class PlanShoppingLine {
  const PlanShoppingLine(this.item, this.quantity, this.unit);
  final PlanGrocery item;
  final double quantity;
  final String unit;

  @override
  String toString() => '$item $quantity $unit';
}

/// Нормы на день → строки на [days] дней. Нет нормы БЖУ — строки по ней не создаются.
List<PlanShoppingLine> planShoppingList({int? proteinG, int? fatG, int? carbsG, int? waterMl, int days = 7}) {
  final out = <PlanShoppingLine>[];
  double kg(double grams) => (grams / 100).ceilToDouble() / 10; // до 0.1 кг вверх

  if (proteinG != null && proteinG > 0) {
    final weekProtein = proteinG * days.toDouble();
    // Половина белка — курица/индейка (~23 г белка на 100 г), четверть — яйца (~6 г на шт.),
    // четверть — творог (~17 г на 100 г). Остальной белок даёт обычная еда — запас не нужен.
    out
      ..add(PlanShoppingLine(PlanGrocery.chicken, kg(weekProtein * 0.5 / 0.23), ShopUnit.kg))
      ..add(PlanShoppingLine(PlanGrocery.eggs, (weekProtein * 0.25 / 6).ceilToDouble(), ShopUnit.pcs))
      ..add(PlanShoppingLine(PlanGrocery.cottageCheese, kg(weekProtein * 0.25 / 0.17), ShopUnit.kg));
  }
  if (carbsG != null && carbsG > 0) {
    final weekCarbs = carbsG * days.toDouble();
    // Крупы (гречка/рис, ~70 г углеводов на 100 г сухих) — 40%, овсянка (~60 г) — 15%.
    out
      ..add(PlanShoppingLine(PlanGrocery.grains, kg(weekCarbs * 0.4 / 0.7), ShopUnit.kg))
      ..add(PlanShoppingLine(PlanGrocery.oats, kg(weekCarbs * 0.15 / 0.6), ShopUnit.kg));
  }
  // Овощи ~400 г и 2 фрукта в день — общая рекомендация, от норм не зависит.
  out
    ..add(PlanShoppingLine(PlanGrocery.vegetables, kg(400.0 * days), ShopUnit.kg))
    ..add(PlanShoppingLine(PlanGrocery.fruits, 2.0 * days, ShopUnit.pcs));
  if (fatG != null && fatG > 0) {
    // Масло — около 20% жиров (1 мл ≈ 0.9 г жира), округление до 50 мл.
    final ml = fatG * days * 0.2 / 0.9;
    out.add(PlanShoppingLine(PlanGrocery.oil, ((ml / 50).ceil() * 50).toDouble(), ShopUnit.ml));
  }
  if (waterMl != null && waterMl > 0) {
    out.add(PlanShoppingLine(PlanGrocery.water, (waterMl * days / 1000).ceilToDouble(), ShopUnit.l));
  }
  return out;
}
