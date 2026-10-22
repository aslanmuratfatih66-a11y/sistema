// Вкладка «Питание» (SPEC §8.2): калории и БЖУ против нормы плана, вода, ввод (штрихкод, вручную,
// фото, рецепты), дневник по приёмам пищи за сегодня/вчера, список покупок.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/sync/sync_api.dart';
import '../../core/models/daily.dart';
import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../home/widgets/tab_section_view.dart';
import '../onboarding/questionnaire_a/data/photo_repository.dart';
import 'data/food_repository.dart';
import 'data/shopping_repository.dart';
import 'nutrition_format.dart';
import 'nutrition_providers.dart';
import 'platform/nutrition_platform.dart';
import 'screens/food_screens.dart';
import 'screens/meal_editor_screen.dart';
import 'screens/recipe_screens.dart';
import 'screens/shopping_screens.dart';
import 'widgets/nutrition_panels.dart';
import '../vision/vision.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  /// 0 — сегодня, −1 — вчера.
  int _offset = 0;
  bool _busy = false;

  DateTime _day(DateTime now) => DateTime(now.year, now.month, now.day + _offset);

  DateTime get _now => ref.read(nutritionClockProvider)();

  MealType get _defaultMeal => mealTypeFor(_now);

  Future<void> _openEditor(Widget editor) => pushNutrition<bool>(context, editor);

  Future<void> _manual() async {
    final day = _day(_now);
    final food = await pushNutrition<FoodItemRow>(
      context,
      FoodSearchScreen(onManual: () => _openEditor(MealEditorScreen.diary(day: day, mealType: _defaultMeal))),
    );
    if (food == null || !mounted) return;
    await _openEditor(MealEditorScreen.diary(day: day, mealType: _defaultMeal, food: food));
  }

  Future<void> _barcode() async {
    if (_busy) return;
    final day = _day(_now);
    final code = await ref.read(barcodeScannerProvider).scan(context);
    if (code == null || code.trim().isEmpty || !mounted) return;
    setState(() => _busy = true);
    BarcodeResult result;
    try {
      result = await ref.read(barcodeFoodServiceProvider).resolve(code);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    var food = result.food;
    if (food == null) {
      final reason = result.outcome == BarcodeOutcome.offline ? FoodEditorReason.offline : FoodEditorReason.notFound;
      final id = await pushNutrition<String>(context, FoodItemEditorScreen(barcode: code, reason: reason));
      if (id == null || !mounted) return;
      food = await ref.read(foodRepositoryProvider).byId(id);
      if (food == null || !mounted) return;
    }
    await _openEditor(MealEditorScreen.diary(day: day, mealType: _defaultMeal, food: food));
  }

  Future<void> _photo() async {
    if (_busy) return;
    // Вошли в аккаунт — распознавание ИИ (SPEC §9.4); иначе — фото + ручной ввод.
    if (ref.read(accountProvider).value != null) {
      await showFoodPhotoFlow(context, day: _day(_now), mealType: _defaultMeal);
      return;
    }
    final l = AppLocalizations.of(context);
    final day = _day(_now);
    final camera = await showSystemWindow<bool>(
      context,
      window: SystemWindow(
        key: const Key('nut-photo-source'),
        kind: SystemWindowKind.notice,
        label: l.nutNoticeLabel,
        title: l.nutPhotoTitle,
        message: l.nutPhotoMessage,
        actions: [
          Builder(
            builder: (c) => SysButton.secondary(
              key: const Key('nut-photo-gallery'),
              label: l.nutPhotoGallery,
              onPressed: () => Navigator.of(c).pop(false),
            ),
          ),
          Builder(
            builder: (c) => SysButton.primary(
              key: const Key('nut-photo-camera'),
              label: l.nutPhotoCamera,
              onPressed: () => Navigator.of(c).pop(true),
            ),
          ),
        ],
      ),
    );
    if (camera == null || !mounted) return;
    final path = await ref.read(foodPhotoPickerProvider).pick(camera: camera);
    if (path == null || !mounted) return;
    setState(() => _busy = true);
    final storage = ref.read(photoStorageProvider);
    final photos = ref.read(photoRepositoryProvider);
    String rel;
    String photoId;
    try {
      rel = await storage.import(path, PhotoKind.food);
      photoId = await photos.add(kind: PhotoKind.food, pose: PhotoPose.other, localPath: rel, takenAt: _now);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;
    final saved = await pushNutrition<bool>(
      context,
      MealEditorScreen.diary(day: day, mealType: _defaultMeal, photoId: photoId),
    );
    if (saved != true) {
      // Запись не сохранена — фото не нужно.
      await photos.softDelete(photoId);
      await storage.delete(rel);
    }
  }

  void _recipes() => pushNutrition<void>(context, RecipesScreen(day: _day(_now), mealType: _defaultMeal));

  Future<void> _addWater(int ml) async {
    final now = _now;
    await ref.read(waterRepositoryProvider).add(ml, at: entryMomentFor(_day(now), now));
  }

  Future<void> _undoWater() => ref.read(waterRepositoryProvider).undoLast(_day(_now));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(nutritionClockProvider)();
    final day = _day(now);
    final summary = ref.watch(nutritionDayProvider(day)).value ?? NutritionDay.empty;
    final entries = ref.watch(mealEntriesProvider(day)).value ?? const <MealEntryRow>[];
    final waterLogs = ref.watch(waterLogsProvider(day)).value ?? const <WaterLogRow>[];
    final shopping = ref.watch(shoppingItemsProvider).value ?? const <ShoppingItemRow>[];
    final remaining = shopping.where((i) => !i.done).toList();
    final remainingSum = ShoppingTotals.of(remaining, fallbackCurrency: defaultCurrency(l)).remaining;

    return TabSectionView(
      scrollKey: const Key('nutrition-scroll'),
      title: l.navNutrition,
      glyph: SysGlyph.nutrition,
      children: [
        SysSegmented<int>(
          key: const Key('nut-day'),
          choices: [SysChoice(-1, l.nutYesterday), SysChoice(0, l.nutToday)],
          value: _offset,
          onChanged: (v) => setState(() => _offset = v),
        ),
        CaloriesPanel(
          day: summary,
          norms: ref.watch(nutritionNormsProvider),
          burnedKcal: ref.watch(nutritionBurnedKcalProvider(day)),
        ),
        WaterPanel(
          waterMl: summary.waterMl,
          goalMl: ref.watch(waterGoalProvider(day)),
          trainingDay: ref.watch(trainingDayProvider(day)),
          canUndo: waterLogs.isNotEmpty,
          onAdd: _addWater,
          onUndo: _undoWater,
        ),
        SysPanel(
          title: l.nutAddTitle,
          trailing: _busy ? SysPill(label: l.nutSearching, icon: SysGlyph.clock) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SysButton.secondary(
                      key: const Key('nut-add-barcode'),
                      label: l.nutAddBarcode,
                      onPressed: _busy ? null : _barcode,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SysButton.secondary(
                      key: const Key('nut-add-manual'),
                      label: l.nutAddManual,
                      onPressed: _busy ? null : _manual,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SysButton.secondary(
                      key: const Key('nut-add-photo'),
                      label: l.nutAddPhoto,
                      onPressed: _busy ? null : _photo,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SysButton.secondary(
                      key: const Key('nut-add-recipe'),
                      label: l.nutRecipes,
                      onPressed: _busy ? null : _recipes,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        DiaryPanel(
          entries: entries,
          onOpen: (e) => _openEditor(MealEditorScreen.diary(day: day, entry: e)),
        ),
        SysPanel(
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
        ),
      ],
    );
  }
}

