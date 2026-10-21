// «Мои рецепты»: список с добавлением в дневник в один тап (выбранное число порций) и редактор
// (состав из моих продуктов с граммами или ручных строк, число порций).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../data/diary_repository.dart';
import '../data/recipe_repository.dart';
import '../domain/nutrition_math.dart';
import '../nutrition_format.dart';
import '../nutrition_providers.dart';
import 'food_screens.dart';
import 'meal_editor_screen.dart';

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key, required this.day, required this.mealType});

  /// День и приём пищи, куда добавлять.
  final DateTime day;
  final MealType mealType;

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  static const _portionChoices = [0.5, 1.0, 1.5, 2.0];
  double _portions = 1;
  late MealType _mealType = widget.mealType;
  String? _added;

  Future<void> _add(Recipe r) async {
    final now = ref.read(nutritionClockProvider)();
    await ref.read(diaryRepositoryProvider).add(MealDraft(
          eatenAt: entryMomentFor(widget.day, now),
          mealType: _mealType,
          title: r.title,
          macros: r.portions(_portions),
          recipeId: r.id,
        ));
    if (mounted) setState(() => _added = r.id);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final recipes = ref.watch(recipesProvider).value ?? const <Recipe>[];
    return NutPage(
      title: l.nutRecipes,
      bottom: SysButton.secondary(
        key: const Key('nut-recipe-new'),
        label: l.nutNewRecipe,
        icon: SysGlyph.plus,
        expand: true,
        onPressed: () => pushNutrition<void>(context, const RecipeEditorScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SysFieldLabel(l.nutFieldMeal),
                SysSegmented<MealType>(
                  choices: [for (final t in MealType.values) SysChoice(t, mealTypeLabel(l, t))],
                  value: _mealType,
                  onChanged: (v) => setState(() => _mealType = v),
                ),
                const SizedBox(height: 12),
                SysFieldLabel(l.nutPortions),
                SysSegmented<double>(
                  key: const Key('nut-recipe-portions'),
                  choices: [for (final p in _portionChoices) SysChoice(p, fmt1(l, p))],
                  value: _portions,
                  onChanged: (v) => setState(() => _portions = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (recipes.isEmpty)
            SysPanel(child: Text(l.nutRecipesEmpty, style: SysText.secondary))
          else
            SysPanel(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              child: Column(
                children: [
                  for (final r in recipes)
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            key: Key('nut-recipe-open-${r.id}'),
                            onTap: () => pushNutrition<void>(context, RecipeEditorScreen(recipe: r)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.title, style: SysText.body),
                                  Text(
                                    l.nutPerServing(kcalText(l, r.perServing.kcal), macrosLine(l, r.perServing)),
                                    style: SysText.caption,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        NutIconButton(
                          key: Key('nut-recipe-add-${r.id}'),
                          glyph: _added == r.id ? SysGlyph.check : SysGlyph.plus,
                          color: _added == r.id ? SysColors.success : null,
                          tooltip: l.nutAddToDiary,
                          onPressed: () => _add(r),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class RecipeEditorScreen extends ConsumerStatefulWidget {
  const RecipeEditorScreen({super.key, this.recipe});

  final Recipe? recipe;

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  late String _title = widget.recipe?.title ?? '';
  late int? _servings = widget.recipe?.servings ?? 1;
  late final List<RecipeItem> _items = [...?widget.recipe?.items];
  bool _tried = false;
  bool _busy = false;

  bool get _valid => _title.trim().isNotEmpty && _items.isNotEmpty && (_servings ?? 0) >= 1;

  Future<void> _addFromProduct() async {
    final food = await pushNutrition<FoodItemRow>(context, const FoodSearchScreen());
    if (food == null || !mounted) return;
    final item = await pushNutrition<RecipeItem>(context, MealEditorScreen.recipeLine(food: food));
    if (item != null) setState(() => _items.add(item));
  }

  Future<void> _addManual() async {
    final item = await pushNutrition<RecipeItem>(context, const MealEditorScreen.recipeLine());
    if (item != null) setState(() => _items.add(item));
  }

  Future<void> _editItem(int i) async {
    final item = await pushNutrition<RecipeItem>(context, MealEditorScreen.recipeLine(recipeItem: _items[i]));
    if (item != null) setState(() => _items[i] = item);
  }

  Future<void> _save() async {
    setState(() => _tried = true);
    if (!_valid || _busy) return;
    setState(() => _busy = true);
    await ref
        .read(recipeRepositoryProvider)
        .save(id: widget.recipe?.id, title: _title, items: _items, servings: _servings ?? 1);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final r = widget.recipe;
    if (r == null || _busy) return;
    setState(() => _busy = true);
    await ref.read(recipeRepositoryProvider).softDelete(r.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final total = Macros.sum(_items.map((i) => i.macros));
    final perServing = recipePortion(total, _servings ?? 1, 1);
    return NutPage(
      title: widget.recipe == null ? l.nutNewRecipe : l.nutEditRecipe,
      bottom: SysButton.primary(
        key: const Key('nut-recipe-save'),
        label: l.commonSave,
        expand: true,
        onPressed: _busy ? null : _save,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SysFieldLabel(l.nutFieldTitle),
                SysTextField(
                  key: const Key('nut-recipe-title'),
                  value: _title,
                  hint: l.nutRecipeTitleHint,
                  errorText: _tried && _title.trim().isEmpty ? l.commonRequired : null,
                  onChanged: (v) => setState(() => _title = v),
                ),
                const SysFieldGap(),
                SysNumberField(
                  key: const Key('nut-recipe-servings'),
                  value: _servings,
                  label: l.nutServings,
                  decimal: false,
                  min: 1,
                  max: 50,
                  outOfRangeText: l.commonOutOfRange,
                  onChanged: (v) => setState(() => _servings = v?.round()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SysPanel(
            title: l.nutIngredients,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_items.isEmpty)
                  Text(
                    l.nutIngredientsEmpty,
                    style: SysText.secondary.copyWith(color: _tried ? SysColors.dangerLight : null),
                  ),
                for (var i = 0; i < _items.length; i++)
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _editItem(i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _items[i].grams == null
                                      ? _items[i].title
                                      : '${_items[i].title} · ${fmt1(l, _items[i].grams!)} ${l.nutUnitG}',
                                  style: SysText.body,
                                ),
                                Text('${kcalText(l, _items[i].macros.kcal)} · ${macrosLine(l, _items[i].macros)}',
                                    style: SysText.caption),
                              ],
                            ),
                          ),
                        ),
                      ),
                      NutIconButton(
                        glyph: SysGlyph.close,
                        tooltip: l.commonDelete,
                        color: SysColors.dangerLight,
                        onPressed: () => setState(() => _items.removeAt(i)),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SysButton.secondary(
                        key: const Key('nut-recipe-add-product'),
                        label: l.nutFromProducts,
                        onPressed: _addFromProduct,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SysButton.secondary(
                        key: const Key('nut-recipe-add-manual'),
                        label: l.nutManualLine,
                        onPressed: _addManual,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(l.nutTotalLine(fmtInt(l, total.kcal), macrosLine(l, total)), style: SysText.mono),
                Text(
                  l.nutPerServing(kcalText(l, perServing.kcal), macrosLine(l, perServing)),
                  key: const Key('nut-recipe-per-serving'),
                  style: SysText.mono.copyWith(color: SysColors.calories),
                ),
              ],
            ),
          ),
          if (widget.recipe != null) ...[
            const SizedBox(height: 20),
            SysButton.danger(
              key: const Key('nut-recipe-delete'),
              label: l.commonDelete,
              expand: true,
              onPressed: _busy ? null : _delete,
            ),
          ],
        ],
      ),
    );
  }
}
