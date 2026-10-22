// Список покупок: ручные пункты (количество, единица, примерная цена), «куплено», суммы,
// базовый список на неделю от норм плана (без цен; меню от ИИ — этап 5).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../data/shopping_repository.dart';
import '../domain/shopping_plan.dart';
import '../nutrition_format.dart';
import '../nutrition_providers.dart';

/// «2 кг», «10 шт.».
String shoppingQuantity(AppLocalizations l, ShoppingItemRow i) {
  final q = i.quantity;
  if (q == null) return '';
  final u = unitLabel(l, i.unit);
  return u.isEmpty ? fmt1(l, q) : '${fmt1(l, q)} $u';
}

/// Суммы по валютам: «1 250 ₽ · 300 ₺».
String totalsText(AppLocalizations l, Map<String, int> m) =>
    m.isEmpty ? '—' : m.entries.map((e) => moneyText(l, e.value, e.key)).join(' · ');

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  Future<void> _fromPlan(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final n = ref.read(nutritionNormsProvider);
    if (n == null) return;
    final lines = planShoppingList(proteinG: n.proteinG, fatG: n.fatG, carbsG: n.carbsG, waterMl: n.waterMl);
    await ref.read(shoppingRepositoryProvider).replacePlanItems(lines, (g) => groceryLabel(l, g));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final items = ref.watch(shoppingItemsProvider).value ?? const <ShoppingItemRow>[];
    final norms = ref.watch(nutritionNormsProvider);
    final totals = ShoppingTotals.of(items, fallbackCurrency: defaultCurrency(l));
    final repo = ref.read(shoppingRepositoryProvider);
    final hasDone = items.any((i) => i.done);
    return NutPage(
      title: l.nutShopping,
      bottom: SysButton.primary(
        key: const Key('nut-shop-add'),
        label: l.nutShopAdd,
        icon: SysGlyph.plus,
        expand: true,
        onPressed: () => pushNutrition<void>(context, const ShoppingItemEditorScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanel(
            tone: PanelTone.gold,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _line(l.nutShopTotal, totalsText(l, totals.total), const Key('nut-shop-total')),
                _line(l.nutShopRemaining, totalsText(l, totals.remaining), const Key('nut-shop-remaining')),
                const SizedBox(height: 4),
                Text(l.nutShopPriceNote, style: SysText.caption),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SysPanel(
            title: l.nutShopFromPlan,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(norms == null ? l.nutShopNoPlan : l.nutShopFromPlanHint, style: SysText.secondary),
                const SizedBox(height: 10),
                SysButton.secondary(
                  key: const Key('nut-shop-from-plan'),
                  label: l.nutShopGenerate,
                  expand: true,
                  onPressed: norms == null ? null : () => _fromPlan(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            SysPanel(child: SysEmptyState.inline(l.nutShopEmpty, glyph: SysGlyph.shop))
          else
            SysPanel(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Column(
                children: [
                  for (final i in items)
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            key: Key('nut-shop-toggle-${i.id}'),
                            onTap: () => repo.setDone(i.id, !i.done),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: SysDims.minTap),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                child: Row(
                                  children: [
                                    Semantics(checked: i.done, child: NutCheckBox(checked: i.done)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            i.title,
                                            style: SysText.body.copyWith(
                                              color: i.done ? SysColors.textInactive : null,
                                              decoration: i.done ? TextDecoration.lineThrough : null,
                                            ),
                                          ),
                                          if (i.quantity != null || i.estPriceMinor != null)
                                            Text(
                                              [
                                                if (i.quantity != null) shoppingQuantity(l, i),
                                                if (i.estPriceMinor != null)
                                                  '≈ ${moneyText(l, i.estPriceMinor!, i.currency ?? defaultCurrency(l))}',
                                              ].join(' · '),
                                              style: SysText.caption,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        NutIconButton(
                          key: Key('nut-shop-edit-${i.id}'),
                          glyph: SysGlyph.settings,
                          tooltip: l.commonEdit,
                          onPressed: () => pushNutrition<void>(context, ShoppingItemEditorScreen(item: i)),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          if (hasDone) ...[
            const SizedBox(height: 14),
            SysButton.secondary(
              key: const Key('nut-shop-clear-done'),
              label: l.nutShopClearDone,
              expand: true,
              onPressed: repo.clearDone,
            ),
          ],
        ],
      ),
    );
  }

  Widget _line(String label, String value, Key key) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(child: Text(label, style: SysText.secondary)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(value, key: key, textAlign: TextAlign.end, style: SysText.mono.copyWith(color: SysColors.gold)),
            ),
          ],
        ),
      );
}

class ShoppingItemEditorScreen extends ConsumerStatefulWidget {
  const ShoppingItemEditorScreen({super.key, this.item});

  final ShoppingItemRow? item;

  @override
  ConsumerState<ShoppingItemEditorScreen> createState() => _ShoppingItemEditorScreenState();
}

class _ShoppingItemEditorScreenState extends ConsumerState<ShoppingItemEditorScreen> {
  static const _currencies = ['RUB', 'TRY'];

  late String _title = widget.item?.title ?? '';
  late double? _quantity = widget.item?.quantity;
  late String? _unit = widget.item?.unit ?? ShopUnit.pcs;
  late double? _price = widget.item?.estPriceMinor == null ? null : widget.item!.estPriceMinor! / 100;
  String? _currency;
  bool _tried = false;
  bool _busy = false;

  ShoppingDraft _draft(String fallbackCurrency) => ShoppingDraft(
        title: _title,
        quantity: _quantity,
        unit: _quantity == null ? null : _unit,
        estPriceMinor: _price == null ? null : (_price! * 100).round(),
        currency: _currency ?? widget.item?.currency ?? fallbackCurrency,
      );

  Future<void> _save() async {
    setState(() => _tried = true);
    if (_title.trim().isEmpty || _busy) return;
    setState(() => _busy = true);
    final d = _draft(defaultCurrency(AppLocalizations.of(context)));
    final repo = ref.read(shoppingRepositoryProvider);
    final i = widget.item;
    if (i == null) {
      await repo.add(d);
    } else {
      await repo.update(i.id, d);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final i = widget.item;
    if (i == null || _busy) return;
    setState(() => _busy = true);
    await ref.read(shoppingRepositoryProvider).softDelete(i.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final currency = _currency ?? widget.item?.currency ?? defaultCurrency(l);
    return NutPage(
      title: widget.item == null ? l.nutShopAdd : l.nutShopEdit,
      bottom: SysButton.primary(
        key: const Key('nut-shop-save'),
        label: l.commonSave,
        expand: true,
        onPressed: _busy ? null : _save,
      ),
      child: SysPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SysFieldLabel(l.nutFieldTitle),
            SysTextField(
              key: const Key('nut-shop-title'),
              value: _title,
              hint: l.nutShopTitleHint,
              errorText: _tried && _title.trim().isEmpty ? l.commonRequired : null,
              onChanged: (v) => setState(() => _title = v),
            ),
            const SysFieldGap(),
            SysNumberField(
              key: const Key('nut-shop-quantity'),
              value: _quantity,
              label: l.nutShopQuantity,
              min: 0,
              max: 100000,
              outOfRangeText: l.commonOutOfRange,
              onChanged: (v) => setState(() => _quantity = v?.toDouble()),
            ),
            const SizedBox(height: 10),
            SysChoiceChips<String>(
              choices: [for (final u in ShopUnit.all) SysChoice(u, unitLabel(l, u))],
              selected: {?_unit},
              onChanged: (s) => setState(() => _unit = s.isEmpty ? null : s.first),
            ),
            const SysFieldGap(),
            SysNumberField(
              key: const Key('nut-shop-price'),
              value: _price,
              label: l.nutShopPrice,
              min: 0,
              max: 10000000,
              outOfRangeText: l.commonOutOfRange,
              onChanged: (v) => setState(() => _price = v?.toDouble()),
            ),
            const SizedBox(height: 10),
            SysSegmented<String>(
              choices: [for (final c in _currencies) SysChoice(c, c)],
              value: currency,
              onChanged: (v) => setState(() => _currency = v),
            ),
            if (widget.item != null) ...[
              const SizedBox(height: 24),
              SysButton.danger(
                key: const Key('nut-shop-delete'),
                label: l.commonDelete,
                expand: true,
                onPressed: _busy ? null : _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
