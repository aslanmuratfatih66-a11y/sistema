// Вкладка «Магазин» (решение владельца 2026-10-22, SPEC §6, §8.8): переключатель
// «За баллы» (награды за ◆) · «Покупки» (маркет ИИ под план + список покупок).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../home/widgets/switch_tab_view.dart';
import '../market/market_screen.dart';
import 'shop_screen.dart';

enum ShopSection { points, purchases }

/// Выбранный раздел магазина (Финансы → «Маркет» открывает «Покупки»).
final shopSectionProvider = NotifierProvider<ShopSectionState, ShopSection>(ShopSectionState.new);

class ShopSectionState extends Notifier<ShopSection> {
  @override
  ShopSection build() => ShopSection.points;

  void set(ShopSection v) => state = v;
}

class ShopTabScreen extends ConsumerWidget {
  const ShopTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return SwitchTabView<ShopSection>(
      key: const Key('shop-tab'),
      title: l.navShop,
      glyph: SysGlyph.shop,
      choices: [
        SysChoice(ShopSection.points, l.shopTabPoints),
        SysChoice(ShopSection.purchases, l.shopTabPurchases),
      ],
      value: ref.watch(shopSectionProvider),
      onChanged: ref.read(shopSectionProvider.notifier).set,
      builder: (s) => switch (s) {
        ShopSection.points => const ShopScreen(),
        ShopSection.purchases => const MarketScreen(),
      },
    );
  }
}
