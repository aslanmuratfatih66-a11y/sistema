// Запись дневника: ввод вручную (на порцию или на 100 г × граммы), из «моего продукта», по фото
// (фото уже сохранено, КБЖУ — вручную; распознавание ИИ — этап 5). Тот же экран — строка рецепта.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../data/diary_repository.dart';
import '../data/food_repository.dart';
import '../data/recipe_repository.dart';
import '../domain/nutrition_math.dart';
import '../nutrition_format.dart';
import '../nutrition_providers.dart';

enum MacroMode { per100, portion }

class MealEditorScreen extends ConsumerStatefulWidget {
  /// Запись дневника за [day]: новая или правка [entry].
  const MealEditorScreen.diary({
    super.key,
    required DateTime this.day,
    this.mealType,
    this.entry,
    this.food,
    this.photoId,
  })  : recipeItem = null,
        forRecipe = false;

  /// Строка рецепта: экран возвращает [RecipeItem] через pop.
  const MealEditorScreen.recipeLine({super.key, this.food, this.recipeItem})
      : day = null,
        mealType = null,
        entry = null,
        photoId = null,
        forRecipe = true;

  final DateTime? day;
  final MealType? mealType;
  final MealEntryRow? entry;
  final FoodItemRow? food;
  final String? photoId;
  final RecipeItem? recipeItem;
  final bool forRecipe;

  @override
  ConsumerState<MealEditorScreen> createState() => _MealEditorScreenState();
}

class _MealEditorScreenState extends ConsumerState<MealEditorScreen> {
  late String _title;
  late MealType _mealType;
  late MacroMode _mode;
  double? _grams;
  double? _kcal;
  double? _protein;
  double? _fat;
  double? _carbs;
  bool _saveProduct = false;
  bool _tried = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final now = ref.read(nutritionClockProvider)();
    final e = widget.entry;
    final f = widget.food;
    final r = widget.recipeItem;
    _mealType = e?.type ?? widget.mealType ?? mealTypeFor(now);
    if (e != null) {
      _title = e.title;
      _initFrom(e.macros, e.grams);
    } else if (r != null) {
      _title = r.title;
      _initFrom(r.macros, r.grams);
    } else if (f != null) {
      _title = f.brand == null ? f.name : '${f.name} (${f.brand})';
      _mode = MacroMode.per100;
      _grams = f.servingG ?? 100;
      _setValues(f.per100);
    } else {
      _title = '';
      _mode = MacroMode.portion;
    }
  }

  void _initFrom(Macros total, double? grams) {
    if (grams != null && grams > 0) {
      _mode = MacroMode.per100;
      _grams = grams;
      _setValues(total.per100From(grams).rounded());
    } else {
      _mode = MacroMode.portion;
      _setValues(total);
    }
  }

  void _setValues(Macros m) {
    _kcal = m.kcal;
    _protein = m.protein;
    _fat = m.fat;
    _carbs = m.carbs;
  }

  Macros get _values => Macros(kcal: _kcal ?? 0, protein: _protein ?? 0, fat: _fat ?? 0, carbs: _carbs ?? 0);

  bool get _gramsOk => _mode == MacroMode.portion || ((_grams ?? 0) > 0);

  /// Итог записи.
  Macros get _total => _mode == MacroMode.per100 ? _values.forGrams(_grams ?? 0) : _values;

  bool get _valid => _title.trim().isNotEmpty && _kcal != null && _gramsOk;

  Future<void> _save() async {
    setState(() => _tried = true);
    if (!_valid || _busy) return;
    final grams = _mode == MacroMode.per100 ? _grams : null;
    if (widget.forRecipe) {
      Navigator.of(context).pop(RecipeItem(
        foodItemId: widget.food?.id ?? widget.recipeItem?.foodItemId,
        title: _title.trim(),
        grams: grams,
        macros: _total.rounded(),
      ));
      return;
    }
    setState(() => _busy = true);
    try {
      var foodId = widget.food?.id ?? widget.entry?.foodItemId;
      if (_saveProduct && foodId == null && _mode == MacroMode.per100) {
        foodId = await ref.read(foodRepositoryProvider).save(FoodDraft(name: _title, per100: _values));
      }
      final e = widget.entry;
      final now = ref.read(nutritionClockProvider)();
      final draft = MealDraft(
        eatenAt: e?.eatenAt ?? entryMomentFor(widget.day!, now),
        mealType: _mealType,
        title: _title,
        macros: _total,
        grams: grams,
        foodItemId: foodId,
        recipeId: e?.recipeId,
        photoId: widget.photoId ?? e?.photoId,
      );
      final repo = ref.read(diaryRepositoryProvider);
      if (e == null) {
        await repo.add(draft);
      } else {
        await repo.update(e.id, draft);
      }
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final e = widget.entry;
    if (e == null || _busy) return;
    setState(() => _busy = true);
    await ref.read(diaryRepositoryProvider).softDelete(e.id);
    if (mounted) Navigator.of(context).pop(true);
  }

  Widget _num(String key, String label, double? value, ValueChanged<double?> onChanged, {String? unit}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SysNumberField(
          key: Key(key),
          value: value,
          label: label,
          unit: unit,
          min: 0,
          max: 100000,
          outOfRangeText: AppLocalizations.of(context).commonOutOfRange,
          onChanged: (v) => setState(() => onChanged(v?.toDouble())),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final editing = widget.entry != null || widget.recipeItem != null;
    final per100 = _mode == MacroMode.per100;
    final total = _total;
    final title = widget.forRecipe
        ? l.nutRecipeLineTitle
        : editing
            ? l.nutEditEntry
            : l.nutNewEntry;
    return NutPage(
      title: title,
      bottom: SysButton.primary(
        key: const Key('nut-meal-save'),
        label: widget.forRecipe ? l.commonDone : l.commonSave,
        expand: true,
        onPressed: _busy ? null : _save,
      ),
      child: SysPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.photoId != null || widget.entry?.photoId != null) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: SysPill(label: l.nutPhotoSaved, icon: SysGlyph.check, tone: PanelTone.success),
              ),
              const SizedBox(height: 6),
              Text(l.nutPhotoAiLater, style: SysText.caption),
              const SysFieldGap(),
            ],
            SysFieldLabel(l.nutFieldTitle),
            SysTextField(
              key: const Key('nut-meal-title'),
              value: _title,
              hint: l.nutFieldTitleHint,
              errorText: _tried && _title.trim().isEmpty ? l.commonRequired : null,
              onChanged: (v) => setState(() => _title = v),
            ),
            if (!widget.forRecipe) ...[
              const SysFieldGap(),
              SysFieldLabel(l.nutFieldMeal),
              SysSegmented<MealType>(
                choices: [for (final t in MealType.values) SysChoice(t, mealTypeLabel(l, t))],
                value: _mealType,
                onChanged: (v) => setState(() => _mealType = v),
              ),
            ],
            const SysFieldGap(),
            SysFieldLabel(l.nutFieldMode),
            SysSegmented<MacroMode>(
              key: const Key('nut-meal-mode'),
              choices: [
                SysChoice(MacroMode.portion, l.nutModePortion),
                SysChoice(MacroMode.per100, l.nutModePer100),
              ],
              value: _mode,
              onChanged: (v) => setState(() => _mode = v),
            ),
            const SysFieldGap(),
            if (per100) ...[
              _num('nut-meal-grams', l.nutFieldGrams, _grams, (v) => _grams = v, unit: l.nutUnitG),
              if (_tried && !_gramsOk)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(l.nutErrorGrams, style: SysText.caption.copyWith(color: SysColors.dangerLight)),
                ),
            ],
            Text(per100 ? l.nutValuesPer100 : l.nutValuesPortion, style: SysText.caption),
            const SizedBox(height: 8),
            _num('nut-meal-kcal', l.nutFieldKcal, _kcal, (v) => _kcal = v, unit: l.nutUnitKcal),
            if (_tried && _kcal == null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(l.commonRequired, style: SysText.caption.copyWith(color: SysColors.dangerLight)),
              ),
            _num('nut-meal-protein', l.nutFieldProtein, _protein, (v) => _protein = v, unit: l.nutUnitG),
            _num('nut-meal-fat', l.nutFieldFat, _fat, (v) => _fat = v, unit: l.nutUnitG),
            _num('nut-meal-carbs', l.nutFieldCarbs, _carbs, (v) => _carbs = v, unit: l.nutUnitG),
            const SizedBox(height: 4),
            Text(
              l.nutTotalLine(fmtInt(l, total.kcal), macrosLine(l, total)),
              key: const Key('nut-meal-total'),
              style: SysText.mono.copyWith(color: SysColors.calories),
            ),
            if (!widget.forRecipe && per100 && widget.food == null && widget.entry?.foodItemId == null) ...[
              const SysFieldGap(),
              SysSwitchRow(
                label: l.nutSaveToProducts,
                hint: l.nutSaveToProductsHint,
                value: _saveProduct,
                onChanged: (v) => setState(() => _saveProduct = v),
              ),
            ],
            if (widget.entry != null) ...[
              const SizedBox(height: 24),
              SysButton.danger(
                key: const Key('nut-meal-delete'),
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
