// Панель «Список покупок» (Магазин → «Покупки»): сколько осталось купить и примерная сумма; нажатие — список.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../data/shopping_repository.dart';
import '../nutrition_format.dart';
import '../nutrition_providers.dart';
import '../screens/shopping_screens.dart';

class ShoppingListPanel extends ConsumerWidget {
  const ShoppingListPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final shopping = ref.watch(shoppingItemsProvider).value ?? const <ShoppingItemRow>[];
    final remaining = shopping.where((i) => !i.done).toList();
    final remainingSum = ShoppingTotals.of(remaining, fallbackCurrency: defaultCurrency(l)).remaining;
    return SysPanel(
      title: l.nutShopping,
      tone: PanelTone.gold,
      child: InkWell(
        key: const Key('nut-open-shopping'),
        onTap: () => pushNutrition<void>(context, const ShoppingListScreen()),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: SysDims.minTap),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  remaining.isEmpty
                      ? l.nutShopNothing
                      : l.nutShopRemainingCount(remaining.length, totalsText(l, remainingSum)),
                  style: SysText.secondary,
                ),
              ),
              const SysIcon(SysGlyph.chevronRight, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
