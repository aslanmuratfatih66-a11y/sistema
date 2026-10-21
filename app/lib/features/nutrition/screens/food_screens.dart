// «Мои продукты»: поиск (выбор продукта для записи или рецепта) и ручной ввод продукта
// (в том числе со штрихкодом, которого нет в Open Food Facts).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../data/food_repository.dart';
import '../domain/nutrition_math.dart';
import '../nutrition_format.dart';
import '../nutrition_providers.dart';

/// Поиск по моим продуктам → выбранный продукт ([FoodItemRow]) через pop.
/// [onManual] — кнопка «Без продукта» (ввод КБЖУ вручную); null — кнопки нет.
class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({super.key, this.onManual});

  final VoidCallback? onManual;

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  String _query = '';
  Stream<List<FoodItemRow>>? _stream;
  String? _streamQuery;

  /// Поток пересоздаётся только при смене запроса.
  Stream<List<FoodItemRow>> _results() {
    if (_stream == null || _streamQuery != _query) {
      _streamQuery = _query;
      _stream = ref.read(foodRepositoryProvider).watchSearch(_query);
    }
    return _stream!;
  }

  Future<void> _newProduct() async {
    final nav = Navigator.of(context);
    final id = await pushNutrition<String>(context, const FoodItemEditorScreen());
    if (id == null || !mounted) return;
    final row = await ref.read(foodRepositoryProvider).byId(id);
    if (row != null) nav.pop(row);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final manual = widget.onManual;
    return NutPage(
      title: l.nutMyProducts,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysTextField(
            key: const Key('nut-food-search'),
            value: _query,
            hint: l.nutSearchHint,
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (manual != null) ...[
                Expanded(
                  child: SysButton.secondary(
                    key: const Key('nut-food-manual'),
                    label: l.nutWithoutProduct,
                    icon: SysGlyph.plus,
                    onPressed: () {
                      Navigator.of(context).pop();
                      manual();
                    },
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: SysButton.secondary(
                  key: const Key('nut-food-new'),
                  label: l.nutNewProduct,
                  icon: SysGlyph.plus,
                  onPressed: _newProduct,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          StreamBuilder<List<FoodItemRow>>(
            stream: _results(),
            builder: (context, snap) {
              final items = snap.data ?? const <FoodItemRow>[];
              if (snap.hasData && items.isEmpty) {
                return SysPanel(child: Text(l.nutNoProducts, style: SysText.secondary));
              }
              return SysPanel(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                child: Column(
                  children: [
                    for (final f in items)
                      InkWell(
                        key: Key('nut-food-${f.id}'),
                        onTap: () => Navigator.of(context).pop(f),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: SysDims.minTap),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(f.brand == null ? f.name : '${f.name} · ${f.brand}', style: SysText.body),
                                      Text(
                                        '${l.nutPer100Short}: ${kcalText(l, f.kcal100)} · ${macrosLine(l, f.per100)}',
                                        style: SysText.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                if (f.barcode != null) const SysIcon(SysGlyph.info, size: 14, color: SysColors.textInactive),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Причина ручного ввода после сканирования.
enum FoodEditorReason { manual, notFound, offline }

/// Новый продукт (значения на 100 г). Возвращает id сохранённого продукта.
class FoodItemEditorScreen extends ConsumerStatefulWidget {
  const FoodItemEditorScreen({super.key, this.barcode, this.reason = FoodEditorReason.manual});

  final String? barcode;
  final FoodEditorReason reason;

  @override
  ConsumerState<FoodItemEditorScreen> createState() => _FoodItemEditorScreenState();
}

class _FoodItemEditorScreenState extends ConsumerState<FoodItemEditorScreen> {
  String _name = '';
  String _brand = '';
  late String _barcode = widget.barcode ?? '';
  double? _kcal;
  double? _protein;
  double? _fat;
  double? _carbs;
  double? _serving;
  bool _tried = false;
  bool _busy = false;

  bool get _valid => _name.trim().isNotEmpty && _kcal != null;

  Future<void> _save() async {
    setState(() => _tried = true);
    if (!_valid || _busy) return;
    setState(() => _busy = true);
    final id = await ref.read(foodRepositoryProvider).save(FoodDraft(
          name: _name,
          brand: _brand.trim().isEmpty ? null : _brand.trim(),
          barcode: _barcode.trim().isEmpty ? null : _barcode.trim(),
          per100: Macros(kcal: _kcal ?? 0, protein: _protein ?? 0, fat: _fat ?? 0, carbs: _carbs ?? 0),
          servingG: _serving,
          source: FoodSource.manual,
        ));
    if (mounted) Navigator.of(context).pop(id);
  }

  Widget _num(String key, String label, double? value, ValueChanged<double?> set, String unit) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SysNumberField(
          key: Key(key),
          value: value,
          label: label,
          unit: unit,
          min: 0,
          max: 10000,
          outOfRangeText: AppLocalizations.of(context).commonOutOfRange,
          onChanged: (v) => setState(() => set(v?.toDouble())),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final notice = switch (widget.reason) {
      FoodEditorReason.manual => null,
      FoodEditorReason.notFound => l.nutBarcodeNotFound,
      FoodEditorReason.offline => l.nutBarcodeOffline,
    };
    return NutPage(
      title: l.nutNewProduct,
      bottom: SysButton.primary(
        key: const Key('nut-product-save'),
        label: l.commonSave,
        expand: true,
        onPressed: _busy ? null : _save,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (notice != null) ...[
            SysPanel(
              tone: PanelTone.gold,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SysIcon(SysGlyph.warning, size: 20, color: SysColors.gold),
                  const SizedBox(width: 10),
                  Expanded(child: Text(notice, key: const Key('nut-product-notice'), style: SysText.secondary)),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          SysPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SysFieldLabel(l.nutFieldTitle),
                SysTextField(
                  key: const Key('nut-product-name'),
                  value: _name,
                  hint: l.nutProductNameHint,
                  errorText: _tried && _name.trim().isEmpty ? l.commonRequired : null,
                  onChanged: (v) => setState(() => _name = v),
                ),
                const SysFieldGap(),
                SysFieldLabel(l.nutFieldBrand, optional: true, optionalLabel: l.commonOptional),
                SysTextField(value: _brand, onChanged: (v) => setState(() => _brand = v)),
                const SysFieldGap(),
                SysFieldLabel(l.nutFieldBarcode, optional: true, optionalLabel: l.commonOptional),
                SysTextField(
                  key: const Key('nut-product-barcode'),
                  value: _barcode,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => _barcode = v),
                ),
                const SysFieldGap(),
                Text(l.nutValuesPer100, style: SysText.caption),
                const SizedBox(height: 8),
                _num('nut-product-kcal', l.nutFieldKcal, _kcal, (v) => _kcal = v, l.nutUnitKcal),
                if (_tried && _kcal == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(l.commonRequired, style: SysText.caption.copyWith(color: SysColors.dangerLight)),
                  ),
                _num('nut-product-protein', l.nutFieldProtein, _protein, (v) => _protein = v, l.nutUnitG),
                _num('nut-product-fat', l.nutFieldFat, _fat, (v) => _fat = v, l.nutUnitG),
                _num('nut-product-carbs', l.nutFieldCarbs, _carbs, (v) => _carbs = v, l.nutUnitG),
                _num('nut-product-serving', l.nutFieldServing, _serving, (v) => _serving = v, l.nutUnitG),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
