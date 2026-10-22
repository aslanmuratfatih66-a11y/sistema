import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/domain/quests/section_hooks.dart';
import 'package:sistema/features/nutrition/data/food_lookup.dart';
import 'package:sistema/features/nutrition/data/recipe_repository.dart';
import 'package:sistema/features/nutrition/domain/nutrition_math.dart';
import 'package:sistema/features/nutrition/nutrition_providers.dart';
import 'package:sistema/features/nutrition/nutrition_format.dart';
import 'package:sistema/features/nutrition/nutrition_screen.dart';
import 'package:sistema/features/nutrition/screens/shopping_screens.dart';
import 'package:sistema/features/nutrition/platform/nutrition_platform.dart';
import 'package:sistema/features/plan/model/plan.dart';
import 'package:sistema/l10n/app_localizations.dart';
import 'package:sistema/ui/ui.dart';

import '../../helpers/test_db.dart';
import 'nutrition_fakes.dart';

final _now = DateTime(2026, 10, 21, 13, 0); // обед

const _norms = PlanNorms(
  calories: 2200,
  proteinG: 120,
  fatG: 70,
  carbsG: 250,
  waterMl: 2500,
  sleepTargetMinutes: 480,
  wakeMinute: 420,
  bedMinute: 1380,
  recommendedBedMinute: 1380,
);

Widget _app(
  AppDatabase db, {
  RecordingHooks? hooks,
  FoodLookup? lookup,
  String? scanned,
  PlanNorms? norms = _norms,
  Locale locale = const Locale('ru'),
  double textScale = 1,
}) =>
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        nutritionClockProvider.overrideWithValue(() => _now),
        sectionQuestHooksProvider.overrideWithValue(hooks ?? RecordingHooks()),
        nutritionNormsProvider.overrideWithValue(norms),
        foodLookupProvider.overrideWithValue(lookup ?? FakeFoodLookup({})),
        barcodeScannerProvider.overrideWithValue(FakeBarcodeScanner(scanned)),
        foodPhotoPickerProvider.overrideWithValue(FakePhotoPicker(null)),
      ],
      child: MaterialApp(
        theme: buildSystemTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const Scaffold(body: NutritionScreen()),
      ),
    );

Future<void> _pumpApp(WidgetTester tester, Widget app) async {
  tester.view.physicalSize = const Size(393, 852) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(app);
  await _settle(tester);
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 2; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }
}

/// Снять экран и закрыть БД в реальном времени (иначе drift-потоки подвешивают tearDown).
Future<void> _dispose(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(db.close);
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await _settle(tester);
}

String _valueText(WidgetTester tester, String key) => tester.widget<StatBar>(find.byKey(Key(key))).valueText!;

Future<void> _addEntry(AppDatabase db, {required String id, required DateTime at, required String title, double kcal = 400}) =>
    db.into(db.mealEntries).insert(MealEntriesCompanion.insert(
          id: id,
          updatedAt: at.toUtc(),
          deviceId: 'test',
          eatenAt: at,
          mealType: 'breakfast',
          title: title,
          kcal: kcal,
          protein: const Value(20),
        ));

void main() {
  testWidgets('вода: +250, +500, отмена; прогресс к норме и хук квестов', (tester) async {
    final db = memoryDb();
    final hooks = RecordingHooks();
    await _pumpApp(tester, _app(db, hooks: hooks));
    final l = await AppLocalizations.delegate.load(const Locale('ru'));

    expect(find.text(l.navNutrition.toUpperCase()), findsOneWidget);
    expect(find.text(l.nutDiaryEmpty), findsOneWidget);
    expect(_valueText(tester, 'nut-bar-water'), '0 / 2,5 л');

    await _tap(tester, find.byKey(const Key('nut-water-250')));
    await _tap(tester, find.byKey(const Key('nut-water-500')));
    expect(_valueText(tester, 'nut-bar-water'), '0,75 / 2,5 л');
    expect(hooks.water, [(250, 250), (500, 750)]);

    await _tap(tester, find.byKey(const Key('nut-water-undo')));
    expect(_valueText(tester, 'nut-bar-water'), '0,25 / 2,5 л');
    await _dispose(tester, db);
  });

  testWidgets('штрихкод из Open Food Facts → запись дневника с граммами порции', (tester) async {
    final db = memoryDb();
    final hooks = RecordingHooks();
    final lookup = FakeFoodLookup({testProduct.barcode: testProduct});
    await _pumpApp(tester, _app(db, hooks: hooks, lookup: lookup, scanned: testProduct.barcode));

    await _tap(tester, find.byKey(const Key('nut-add-barcode')));
    // Редактор: продукт подставлен, 50 г × 300 ккал/100 г.
    expect(find.byKey(const Key('nut-meal-save')), findsOneWidget);
    expect(find.textContaining('Итого: 150 ккал'), findsOneWidget);
    await _tap(tester, find.byKey(const Key('nut-meal-save')));

    final rows = await tester.runAsync(() => db.select(db.mealEntries).get());
    expect(rows!.single.title, 'Гречка');
    expect(rows.single.kcal, 150);
    expect(rows.single.grams, 50);
    expect(rows.single.mealType, 'lunch');
    expect(rows.single.foodItemId, isNotNull);
    expect(hooks.meals, [1]);
    expect(lookup.calls, 1);

    expect(find.text('Гречка'), findsOneWidget);
    expect(_valueText(tester, 'nut-bar-kcal'), contains('150'));
    expect(_valueText(tester, 'nut-bar-protein'), '6 / 120 г');
    await _dispose(tester, db);
  });

  testWidgets('штрихкода нет в базе → ручной ввод продукта со штрихкодом → запись', (tester) async {
    final db = memoryDb();
    await _pumpApp(tester, _app(db, scanned: '2000000000002'));
    final l = await AppLocalizations.delegate.load(const Locale('ru'));

    await _tap(tester, find.byKey(const Key('nut-add-barcode')));
    expect(find.text(l.nutBarcodeNotFound), findsOneWidget);
    await tester.enterText(find.byKey(const Key('nut-product-name')), 'Сырок');
    await tester.enterText(find.byKey(const Key('nut-product-kcal')), '400');
    await tester.pump();
    await _tap(tester, find.byKey(const Key('nut-product-save')));
    // Порция не указана — 100 г.
    expect(find.textContaining('Итого: 400 ккал'), findsOneWidget);
    await _tap(tester, find.byKey(const Key('nut-meal-save')));

    final foods = await tester.runAsync(() => db.select(db.foodItems).get());
    expect(foods!.single.barcode, '2000000000002');
    expect(foods.single.source, 'manual');
    expect(find.text('Сырок'), findsOneWidget);
    await _dispose(tester, db);
  });

  testWidgets('правка и удаление записи; вчера/сегодня', (tester) async {
    final db = memoryDb();
    await tester.runAsync(() async {
      await _addEntry(db, id: 'today', at: _now.subtract(const Duration(hours: 4)), title: 'Овсянка');
      await _addEntry(db, id: 'yday', at: _now.subtract(const Duration(days: 1)), title: 'Блины', kcal: 600);
    });
    await _pumpApp(tester, _app(db));
    final l = await AppLocalizations.delegate.load(const Locale('ru'));

    expect(find.text('Овсянка'), findsOneWidget);
    expect(find.text('Блины'), findsNothing);

    await _tap(tester, find.text(l.nutYesterday.toUpperCase()));
    expect(find.text('Блины'), findsOneWidget);
    expect(find.text('Овсянка'), findsNothing);
    await _tap(tester, find.text(l.nutToday.toUpperCase()));

    // Правка: ккал 400 → 350 (на порцию).
    await _tap(tester, find.byKey(const Key('nut-entry-today')));
    await tester.enterText(find.byKey(const Key('nut-meal-kcal')), '350');
    await tester.pump();
    await _tap(tester, find.byKey(const Key('nut-meal-save')));
    expect(_valueText(tester, 'nut-bar-kcal'), contains('350'));

    await _tap(tester, find.byKey(const Key('nut-entry-today')));
    await _tap(tester, find.byKey(const Key('nut-meal-delete')));
    expect(find.text('Овсянка'), findsNothing);
    expect(find.text(l.nutDiaryEmpty), findsOneWidget);
    await _dispose(tester, db);
  });

  testWidgets('рецепт в один тап (1.5 порции) и список покупок от плана', (tester) async {
    final db = memoryDb();
    final id = await tester.runAsync(() => RecipeRepository(db).save(title: 'Омлет', servings: 2, items: const [
          RecipeItem(title: 'Яйца', macros: Macros(kcal: 400, protein: 30, fat: 28, carbs: 2)),
        ]));
    await _pumpApp(tester, _app(db));

    await _tap(tester, find.byKey(const Key('nut-add-recipe')));
    await _tap(tester, find.text('1,5'));
    await _tap(tester, find.byKey(Key('nut-recipe-add-$id')));
    final rows = await tester.runAsync(() => db.select(db.mealEntries).get());
    expect(rows!.single.title, 'Омлет');
    expect(rows.single.kcal, 300);
    expect(rows.single.recipeId, id);
    final l = await AppLocalizations.delegate.load(const Locale('ru'));
    await _tap(tester, find.byTooltip(l.schBack));
    expect(find.text('Омлет'), findsOneWidget);

    // Список покупок переехал в «Магазин» → «Покупки»; открываем его экран напрямую.
    pushNutrition<void>(tester.element(find.byType(NutritionScreen)), const ShoppingListScreen());
    await tester.pump(const Duration(milliseconds: 400));
    await _tap(tester, find.byKey(const Key('nut-shop-from-plan')));
    final items = await tester.runAsync(() => db.select(db.shoppingItems).get());
    expect(items, isNotEmpty);
    expect(items!.every((i) => i.source == 'plan' && i.estPriceMinor == null), isTrue);
    final chicken = items.firstWhere((i) => i.title.startsWith('Куриная'));
    await _tap(tester, find.byKey(Key('nut-shop-toggle-${chicken.id}')));
    final after = await tester.runAsync(() => db.select(db.shoppingItems).get());
    expect(after!.firstWhere((i) => i.id == chicken.id).done, isTrue);
    await _dispose(tester, db);
  });

  testWidgets('без плана — значения без нормы и подсказка', (tester) async {
    final db = memoryDb();
    await _pumpApp(tester, _app(db, norms: null));
    final l = await AppLocalizations.delegate.load(const Locale('ru'));
    expect(find.text(l.nutNoNorm), findsOneWidget);
    expect(find.text(l.nutNoWaterNorm), findsOneWidget);
    expect(_valueText(tester, 'nut-bar-water'), '0 л');
    await _dispose(tester, db);
  });

  testWidgets('tr и крупный шрифт ×2: без ошибок вёрстки', (tester) async {
    final db = memoryDb();
    await tester.runAsync(() => _addEntry(db, id: 'e', at: _now, title: 'Yulaf ezmesi'));
    final errors = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = errors.add;
    try {
      await _pumpApp(tester, _app(db, locale: const Locale('tr'), textScale: 2));
      final scroll = find.byKey(const Key('nutrition-scroll'));
      for (var i = 0; i < 10; i++) {
        await tester.drag(scroll, const Offset(0, -600));
        await tester.pump(const Duration(milliseconds: 100));
      }
    } finally {
      FlutterError.onError = previous;
    }
    expect(errors, isEmpty, reason: errors.map((e) => e.toString()).join('\n'));
    await _dispose(tester, db);
  });
}
