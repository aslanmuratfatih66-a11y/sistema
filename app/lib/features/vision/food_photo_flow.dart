// Фото еды (SPEC §9.4): ИИ описывает → «купил или приготовил?».
// Купил → «где?» → КБЖУ веб-поиском сервера с источником (или штрихкод) → «мои продукты» + дневник.
// Приготовил → оценка по фото и граммам → «мои рецепты» + дневник. Везде пометка «оценка».
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../nutrition/data/diary_repository.dart';
import '../nutrition/data/food_repository.dart';
import '../nutrition/data/recipe_repository.dart';
import '../nutrition/domain/nutrition_math.dart';
import '../nutrition/nutrition_format.dart';
import '../nutrition/nutrition_providers.dart';
import '../nutrition/platform/nutrition_platform.dart';
import '../nutrition/screens/food_screens.dart';
import '../nutrition/screens/meal_editor_screen.dart';
import 'vision_api.dart';
import 'vision_common.dart';
import 'vision_repository.dart';

/// Точка входа: выбрать фото → экран разбора. true — что-то записано в дневник.
/// [day] — день дневника (по умолчанию сегодня), [mealType] — приём пищи (по умолчанию по времени).
Future<bool> showFoodPhotoFlow(BuildContext context, {DateTime? day, MealType? mealType}) async {
  final read = ProviderScope.containerOf(context, listen: false).read;
  final path = await pickVisionPhoto(context, read);
  if (path == null || !context.mounted) return false;
  final photo = await storeVisionPhoto(read, path, PhotoKind.food);
  if (!context.mounted) return false;
  final saved = await Navigator.of(context).push<bool>(MaterialPageRoute(
    builder: (_) => FoodPhotoFlowScreen(photoPath: path, photoId: photo.id, day: day, mealType: mealType),
  ));
  if (saved != true) await dropVisionPhoto(read, photo);
  return saved == true;
}

enum _Stage { recognizing, review, bought, cooked }

class _Item {
  _Item(this.name, this.grams);

  String name;
  double grams;
  FoodLookupResult? lookup;
  Map<String, dynamic>? lookupRaw;
}

class FoodPhotoFlowScreen extends ConsumerStatefulWidget {
  const FoodPhotoFlowScreen({super.key, required this.photoPath, this.photoId, this.day, this.mealType});

  /// Временный файл фото (JPEG ≤1600px).
  final String photoPath;
  final String? photoId;
  final DateTime? day;
  final MealType? mealType;

  @override
  ConsumerState<FoodPhotoFlowScreen> createState() => _FoodPhotoFlowScreenState();
}

class _FoodPhotoFlowScreenState extends ConsumerState<FoodPhotoFlowScreen> {
  _Stage _stage = _Stage.recognizing;
  Object? _error;
  bool _busy = false;
  String? _image;
  Map<String, dynamic>? _foodRaw;
  String _description = '';
  final List<_Item> _items = [];
  String _place = '';
  List<EstimatedItem>? _estimate;
  Map<String, dynamic>? _estimateRaw;
  String _title = '';
  int _rev = 0; // ключи полей после пересоздания списка

  VisionApi get _api => ref.read(visionApiProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recognize());
  }

  DateTime get _eatenAt {
    final now = ref.read(nutritionClockProvider)();
    final d = widget.day;
    if (d == null || sameDay(d, now)) return now;
    return DateTime(d.year, d.month, d.day, now.hour, now.minute);
  }

  MealType get _mealType => widget.mealType ?? mealTypeFor(ref.read(nutritionClockProvider)());

  Future<void> _run(Future<void> Function() job) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await job();
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _recognize() => _run(() async {
        _image ??= await encodeVisionImage(widget.photoPath);
        if (!mounted) return;
        final r = await _api.food(_image!, visionLang(context));
        _foodRaw = r.raw;
        _description = r.value.description;
        _items
          ..clear()
          ..addAll([for (final i in r.value.items) _Item(i.name, i.grams > 0 ? i.grams.roundToDouble() : 100)]);
        _title = r.value.items.map((i) => i.name).join(', ');
        _rev++;
        _stage = _Stage.review;
      });

  Future<void> _lookup() => _run(() async {
        final lang = visionLang(context);
        for (final it in _items) {
          if (it.name.trim().isEmpty) continue;
          final r = await _api.lookup(it.name.trim(), lang, place: _place);
          it.lookup = r.value;
          it.lookupRaw = r.raw;
          if (r.value.servingGrams != null && it.grams <= 0) it.grams = r.value.servingGrams!;
        }
        _rev++;
      });

  Future<void> _estimateCooked() => _run(() async {
        final r = await _api.estimate(
          [for (final i in _items) if (i.name.trim().isNotEmpty) FoodGuess(name: i.name.trim(), grams: i.grams)],
          visionLang(context),
          imageB64: _image,
        );
        _estimate = r.value.items;
        _estimateRaw = r.raw;
        _rev++;
      });

  Future<void> _scanBarcode() async {
    final code = await ref.read(barcodeScannerProvider).scan(context);
    if (code == null || code.trim().isEmpty || !mounted) return;
    BarcodeResult? result;
    await _run(() async => result = await ref.read(barcodeFoodServiceProvider).resolve(code));
    if (!mounted || result == null) return;
    var food = result!.food;
    if (food == null) {
      final reason = result!.outcome == BarcodeOutcome.offline ? FoodEditorReason.offline : FoodEditorReason.notFound;
      final id = await pushNutrition<String>(context, FoodItemEditorScreen(barcode: code, reason: reason));
      if (id == null || !mounted) return;
      food = await ref.read(foodRepositoryProvider).byId(id);
      if (food == null || !mounted) return;
    }
    final saved = await pushNutrition<bool>(
      context,
      MealEditorScreen.diary(day: _eatenAt, mealType: _mealType, food: food, photoId: widget.photoId),
    );
    if (saved == true && mounted) {
      await _saveAnalysis({'choice': 'bought', 'barcode': code});
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  Future<void> _saveAnalysis(Map<String, dynamic> extra) => ref.read(photoAnalysisRepositoryProvider).add(
        VisionKind.food,
        {...?_foodRaw, ...extra},
        photoId: widget.photoId,
      );

  Future<void> _saveBought() => _run(() async {
        final foods = ref.read(foodRepositoryProvider);
        final diary = ref.read(diaryRepositoryProvider);
        for (final it in _items) {
          final lk = it.lookup;
          if (lk == null || it.grams <= 0) continue;
          final per100 = Macros(kcal: lk.per100.kcal, protein: lk.per100.protein, fat: lk.per100.fat, carbs: lk.per100.carbs);
          final foodId = await foods.save(FoodDraft(
            name: it.name.trim(),
            per100: per100,
            servingG: lk.servingGrams,
            source: FoodSource.server,
          ));
          await diary.add(MealDraft(
            eatenAt: _eatenAt,
            mealType: _mealType,
            title: it.name.trim(),
            macros: per100.forGrams(it.grams),
            grams: it.grams,
            foodItemId: foodId,
            photoId: widget.photoId,
          ));
        }
        await _saveAnalysis({
          'choice': 'bought',
          'place': _place,
          'lookups': [for (final it in _items) ?it.lookupRaw],
        });
        if (mounted) Navigator.of(context).pop(true);
      });

  Future<void> _saveCooked() => _run(() async {
        final est = _estimate ?? const [];
        if (est.isEmpty) return;
        final items = [
          for (final e in est)
            RecipeItem(
              title: e.name,
              grams: e.grams,
              macros: Macros(kcal: e.macros.kcal, protein: e.macros.protein, fat: e.macros.fat, carbs: e.macros.carbs),
            ),
        ];
        final title = _title.trim().isEmpty ? est.map((e) => e.name).join(', ') : _title.trim();
        final recipeId = await ref.read(recipeRepositoryProvider).save(title: title, items: items, servings: 1);
        await ref.read(diaryRepositoryProvider).add(MealDraft(
              eatenAt: _eatenAt,
              mealType: _mealType,
              title: title,
              macros: Macros.sum(items.map((i) => i.macros)),
              grams: est.fold<double>(0, (a, e) => a + e.grams),
              recipeId: recipeId,
              photoId: widget.photoId,
            ));
        await _saveAnalysis({'choice': 'cooked', 'estimate': ?_estimateRaw, 'recipe_id': recipeId});
        if (mounted) Navigator.of(context).pop(true);
      });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final children = <Widget>[];
    if (_stage == _Stage.recognizing) {
      children.add(_busy || _error == null ? const VisionBusy() : VisionError(error: _error!, onRetry: _recognize));
    } else {
      children
        ..add(_reviewPanel(l))
        ..add(const SizedBox(height: 12));
      if (_stage == _Stage.review) children.add(_questionPanel(l));
      if (_stage == _Stage.bought) children.add(_boughtPanel(l));
      if (_stage == _Stage.cooked) children.add(_cookedPanel(l));
      if (_error != null) {
        children
          ..add(const SizedBox(height: 12))
          ..add(VisionError(
            error: _error!,
            onRetry: switch (_stage) {
              _Stage.bought => _lookup,
              _Stage.cooked => _estimateCooked,
              _ => _recognize,
            },
          ));
      }
      if (_busy) children.add(const VisionBusy());
    }
    return NutPage(
      title: l.visFoodTitle,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }

  Widget _reviewPanel(AppLocalizations l) {
    final editable = _stage == _Stage.review;
    return SysPanel(
      title: l.visFoodSeen,
      trailing: const EstimateBadge(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_description.isNotEmpty) Text(_description, style: SysText.body),
          if (_items.isEmpty) Text(l.visFoodNothing, style: SysText.secondary),
          for (final (i, it) in _items.indexed)
            if (editable)
              Padding(
                key: ValueKey('vis-item-$_rev-$i'),
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: SysTextField(
                        value: it.name,
                        label: l.visFoodItemName,
                        onChanged: (v) => it.name = v,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: SysNumberField(
                        value: it.grams,
                        label: l.visFoodGrams,
                        unit: 'g',
                        min: 0,
                        max: 5000,
                        onChanged: (v) => it.grams = v?.toDouble() ?? 0,
                      ),
                    ),
                    NutIconButton(
                      glyph: SysGlyph.close,
                      tooltip: l.visRemove,
                      onPressed: () => setState(() {
                        _items.removeAt(i);
                        _rev++;
                      }),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(l.visFoodItemLine(it.name, fmtInt(l, it.grams)), style: SysText.secondary),
              ),
          if (editable) ...[
            const SizedBox(height: 10),
            SysButton.secondary(
              label: l.visFoodAddItem,
              icon: SysGlyph.plus,
              onPressed: () => setState(() {
                _items.add(_Item('', 100));
                _rev++;
              }),
            ),
          ],
        ],
      ),
    );
  }

  bool get _hasItems => _items.any((i) => i.name.trim().isNotEmpty);

  Widget _questionPanel(AppLocalizations l) => SysPanel(
        title: l.visFoodQuestion,
        child: Row(
          children: [
            Expanded(
              child: SysButton.secondary(
                label: l.visFoodBought,
                expand: true,
                onPressed: _busy ? null : () => setState(() => _stage = _Stage.bought),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SysButton.primary(
                label: l.visFoodCooked,
                expand: true,
                onPressed: _busy || !_hasItems
                    ? null
                    : () {
                        setState(() => _stage = _Stage.cooked);
                        _estimateCooked();
                      },
              ),
            ),
          ],
        ),
      );

  Widget _boughtPanel(AppLocalizations l) {
    final found = _items.where((i) => i.lookup != null).toList();
    return SysPanel(
      title: l.visFoodWhere,
      trailing: const EstimateBadge(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysTextField(value: _place, hint: l.visFoodWhereHint, onChanged: (v) => _place = v),
          const SizedBox(height: 10),
          SysButton.primary(label: l.visFoodFind, onPressed: _busy || !_hasItems ? null : _lookup),
          const SizedBox(height: 10),
          Text(l.visFoodScanHint, style: SysText.caption),
          const SizedBox(height: 6),
          SysButton.secondary(label: l.visFoodScan, onPressed: _busy ? null : _scanBarcode),
          for (final (i, it) in found.indexed) ...[
            const SizedBox(height: 14),
            _LookupCard(key: ValueKey('vis-lk-$_rev-$i'), item: it, onGrams: (g) => setState(() => it.grams = g)),
          ],
          if (found.isNotEmpty) ...[
            const SizedBox(height: 14),
            SysButton.primary(label: l.visFoodSaveDiary, expand: true, onPressed: _busy ? null : _saveBought),
          ],
          const SizedBox(height: 8),
          SysButton.secondary(label: l.visBack, onPressed: _busy ? null : () => setState(() => _stage = _Stage.review)),
        ],
      ),
    );
  }

  Widget _cookedPanel(AppLocalizations l) {
    final est = _estimate;
    final total = est == null
        ? null
        : Macros.sum(est.map((e) => Macros(kcal: e.macros.kcal, protein: e.macros.protein, fat: e.macros.fat, carbs: e.macros.carbs)));
    return SysPanel(
      title: l.visFoodCooked,
      trailing: const EstimateBadge(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (est != null) ...[
            SysTextField(value: _title, label: l.visFoodRecipeName, onChanged: (v) => _title = v),
            for (final (i, e) in est.indexed)
              Padding(
                key: ValueKey('vis-est-$_rev-$i'),
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.name, style: SysText.body),
                          Text(
                            '${kcalText(l, e.macros.kcal)} · ${macrosLine(l, Macros(protein: e.macros.protein, fat: e.macros.fat, carbs: e.macros.carbs))}',
                            style: SysText.caption,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: SysNumberField(
                        value: e.grams,
                        unit: 'g',
                        min: 0,
                        max: 5000,
                        onChanged: (v) {
                          final g = v?.toDouble();
                          if (g == null || g <= 0) return;
                          setState(() => _estimate = [...est]..[i] = e.withGrams(g));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            VisionRow(label: l.visFoodTotal, value: '${kcalText(l, total!.kcal)} · ${macrosLine(l, total)}'),
            const SizedBox(height: 12),
            SysButton.primary(label: l.visFoodSaveRecipe, expand: true, onPressed: _busy ? null : _saveCooked),
          ],
          const SizedBox(height: 8),
          SysButton.secondary(
            label: l.visBack,
            onPressed: _busy
                ? null
                : () => setState(() {
                      _stage = _Stage.review;
                      _estimate = null;
                      _rev++;
                    }),
          ),
        ],
      ),
    );
  }
}

class _LookupCard extends StatelessWidget {
  const _LookupCard({super.key, required this.item, required this.onGrams});

  final _Item item;
  final ValueChanged<double> onGrams;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lk = item.lookup!;
    final per100 = Macros(kcal: lk.per100.kcal, protein: lk.per100.protein, fat: lk.per100.fat, carbs: lk.per100.carbs);
    final portion = per100.forGrams(item.grams);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(item.name, style: SysText.title),
        Text(l.visFoodPer100(kcalText(l, per100.kcal), macrosLine(l, per100)), style: SysText.caption),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: SysNumberField(
                value: item.grams,
                label: l.visFoodGrams,
                unit: 'g',
                min: 0,
                max: 5000,
                onChanged: (v) => onGrams(v?.toDouble() ?? 0),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text('${kcalText(l, portion.kcal)}\n${macrosLine(l, portion)}', style: SysText.secondary)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          l.visFoodSource(lk.sourceTitle.isEmpty ? '—' : lk.sourceTitle) + (lk.cached ? ' · ${l.visFoodCached}' : ''),
          style: SysText.caption,
        ),
        if (lk.sourceUrl.isNotEmpty) SelectableText(lk.sourceUrl, style: SysText.caption.copyWith(color: SysColors.accentLight)),
      ],
    );
  }
}

