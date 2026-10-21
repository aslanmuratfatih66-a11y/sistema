import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/quests/section_hooks.dart';
import 'package:sistema/features/nutrition/data/diary_repository.dart';
import 'package:sistema/features/nutrition/data/food_lookup.dart';
import 'package:sistema/features/nutrition/data/food_repository.dart';
import 'package:sistema/features/nutrition/data/recipe_repository.dart';
import 'package:sistema/features/nutrition/data/shopping_repository.dart';
import 'package:sistema/features/nutrition/data/water_repository.dart';
import 'package:sistema/features/nutrition/domain/nutrition_math.dart';
import 'package:sistema/features/nutrition/domain/shopping_plan.dart';
import 'package:sistema/features/nutrition/nutrition_providers.dart';

import '../../helpers/test_db.dart';
import 'nutrition_fakes.dart';

final _now = DateTime(2026, 10, 21, 12, 30);
DateTime _clock() => _now;

void main() {
  late AppDatabase db;
  setUp(() => db = memoryDb());
  tearDown(() => db.close());

  group('штрихкод', () {
    test('OFF → сохранение в FoodItems, второй раз — из кэша без запроса', () async {
      final lookup = FakeFoodLookup({
        '4600000000001': const FoodProduct(
          barcode: '4600000000001',
          name: 'Гречка',
          kcal100: 313,
          protein100: 12.6,
          fat100: 3.3,
          carbs100: 62.1,
          source: FoodSource.openFoodFacts,
        ),
      });
      final service = BarcodeFoodService(FoodRepository(db, clock: _clock), lookup);

      final first = await service.resolve('4600000000001');
      expect(first.outcome, BarcodeOutcome.fetched);
      expect(first.food!.name, 'Гречка');
      expect(first.food!.source, FoodSource.openFoodFacts.name);
      expect(first.food!.kcal100, 313);
      expect(lookup.calls, 1);

      final second = await service.resolve('4600000000001');
      expect(second.outcome, BarcodeOutcome.cached);
      expect(second.food!.id, first.food!.id);
      expect(lookup.calls, 1);
    });

    test('нет в базе / нет сети — ничего не сохраняется; ручной ввод сохраняет со штрихкодом', () async {
      final repo = FoodRepository(db, clock: _clock);
      final notFound = await BarcodeFoodService(repo, FakeFoodLookup({})).resolve('111');
      expect(notFound.outcome, BarcodeOutcome.notFound);
      final offline = await BarcodeFoodService(repo, FakeFoodLookup({}, fail: true)).resolve('111');
      expect(offline.outcome, BarcodeOutcome.offline);
      expect(await repo.search(''), isEmpty);

      await repo.save(const FoodDraft(name: 'Сырок', barcode: '111', per100: Macros(kcal: 400, protein: 8)));
      final cached = await BarcodeFoodService(repo, FakeFoodLookup({})).resolve('111');
      expect(cached.outcome, BarcodeOutcome.cached);
      expect(cached.food!.source, FoodSource.manual.name);
    });

    test('повторное сохранение того же штрихкода обновляет продукт', () async {
      final repo = FoodRepository(db, clock: _clock);
      final a = await repo.save(const FoodDraft(name: 'A', barcode: '222', per100: Macros(kcal: 100)));
      final b = await repo.save(const FoodDraft(name: 'B', barcode: '222', per100: Macros(kcal: 200)));
      expect(b, a);
      final row = await repo.byId(a);
      expect(row!.name, 'B');
      expect(row.version, 2);
    });

    test('поиск по названию и бренду без учёта регистра', () async {
      final repo = FoodRepository(db, clock: _clock);
      await repo.save(const FoodDraft(name: 'Овсянка', per100: Macros(kcal: 350)));
      await repo.save(const FoodDraft(name: 'Йогурт', brand: 'Ферма', per100: Macros(kcal: 60)));
      expect((await repo.search('овс')).map((f) => f.name), ['Овсянка']);
      expect((await repo.search('ферм')).map((f) => f.name), ['Йогурт']);
      expect(await repo.search(''), hasLength(2));
    });
  });

  group('дневник', () {
    test('запись дня, правка, мягкое удаление; хук квестов — число приёмов пищи', () async {
      final hooks = RecordingHooks();
      final repo = DiaryRepository(db, clock: _clock, hooks: hooks);
      final id = await repo.add(MealDraft(
        eatenAt: _now,
        mealType: MealType.lunch,
        title: 'Гречка',
        macros: const Macros(kcal: 313, protein: 12.6, fat: 3.3, carbs: 62.1).forGrams(150),
        grams: 150,
      ));
      await repo.add(MealDraft(
        eatenAt: _now,
        mealType: MealType.lunch,
        title: 'Курица',
        macros: const Macros(kcal: 165, protein: 31),
      ));
      // Вчера — хук не вызывается.
      await repo.add(MealDraft(
        eatenAt: _now.subtract(const Duration(days: 1)),
        mealType: MealType.dinner,
        title: 'Ужин',
        macros: const Macros(kcal: 500),
      ));
      expect(hooks.meals, [1, 1]);

      final today = await repo.getDay(_now);
      expect(today, hasLength(2));
      final first = today.firstWhere((e) => e.id == id);
      expect(first.kcal, 469.5);
      expect(first.grams, 150);

      await repo.update(
        id,
        MealDraft(eatenAt: _now, mealType: MealType.breakfast, title: 'Гречка', macros: const Macros(kcal: 300)),
      );
      final edited = await repo.byId(id);
      expect(edited!.mealType, 'breakfast');
      expect(edited.kcal, 300);
      expect(edited.version, 2);

      await repo.softDelete(id);
      expect(await repo.getDay(_now), hasLength(1));
    });
  });

  group('вода', () {
    test('add/total/undo; хук получает итог за сегодня; объём проверяется', () async {
      final hooks = RecordingHooks();
      final repo = WaterRepository(db, clock: _clock, hooks: hooks);
      await repo.add(250);
      await repo.add(500, at: _now.add(const Duration(minutes: 5)));
      await repo.add(250, at: _now.subtract(const Duration(days: 1)));
      expect(await repo.totalFor(_now), 750);
      expect(hooks.water, [(250, 250), (500, 750)]);

      expect(await repo.undoLast(_now), 500);
      expect(await repo.totalFor(_now), 250);
      expect(await repo.totalFor(_now.subtract(const Duration(days: 1))), 250);
      expect(await repo.undoLast(DateTime(2026, 1, 1)), isNull);
      expect(() => repo.add(0), throwsArgumentError);
    });

    test('ошибка движка квестов не мешает записи', () async {
      final repo = WaterRepository(db, clock: _clock, hooks: RecordingHooks(fail: true));
      await repo.add(250);
      expect(await repo.totalFor(_now), 250);
    });
  });

  test('nutritionDayProvider: сумма дневника и воды за день', () async {
    final container = ProviderContainer(overrides: [
      databaseProvider.overrideWithValue(db),
      nutritionClockProvider.overrideWithValue(_clock),
      sectionQuestHooksProvider.overrideWithValue(const NoopSectionQuestHooks()),
    ]);
    addTearDown(container.dispose);
    final day = dayStart(_now);
    final sub = container.listen(nutritionDayProvider(day), (_, _) {});
    addTearDown(sub.close);

    await container.read(diaryRepositoryProvider).add(MealDraft(
          eatenAt: _now,
          mealType: MealType.breakfast,
          title: 'Овсянка',
          macros: const Macros(kcal: 350, protein: 12, fat: 6, carbs: 60),
        ));
    await container.read(waterRepositoryProvider).add(500);
    await pumpEventQueue();
    final d = await container.read(nutritionDayProvider(day).future);
    expect(d.kcal, 350);
    expect(d.protein, 12);
    expect(d.waterMl, 500);
    expect(d.meals, 1);
  });

  group('рецепты', () {
    test('итоги из состава, порции', () async {
      final repo = RecipeRepository(db, clock: _clock);
      final id = await repo.save(title: 'Омлет', servings: 2, items: const [
        RecipeItem(title: 'Яйца', grams: 120, macros: Macros(kcal: 186, protein: 15, fat: 13, carbs: 1)),
        RecipeItem(title: 'Молоко', macros: Macros(kcal: 64, protein: 3, fat: 3, carbs: 5)),
      ]);
      final r = (await repo.byId(id))!;
      expect(r.total.kcal, 250);
      expect(r.items, hasLength(2));
      expect(r.items.first.grams, 120);
      expect(r.perServing.kcal, 125);
      expect(r.portions(1.5).protein, 13.5);

      await repo.save(id: id, title: 'Омлет', servings: 1, items: [r.items.first]);
      final updated = (await repo.byId(id))!;
      expect(updated.total.kcal, 186);
      expect(updated.servings, 1);

      await repo.softDelete(id);
      expect(await repo.byId(id), isNull);
    });

    test('битый JSON состава — пустой список', () {
      expect(RecipeItem.decodeList('{oops'), isEmpty);
      expect(RecipeItem.decodeList('{"a":1}'), isEmpty);
    });
  });

  group('покупки', () {
    test('сумма: всего и не куплено, по валютам', () async {
      final repo = ShoppingRepository(db, clock: _clock);
      final a = await repo.add(const ShoppingDraft(title: 'Гречка', quantity: 1, unit: ShopUnit.kg, estPriceMinor: 12000, currency: 'RUB'));
      await repo.add(const ShoppingDraft(title: 'Яйца', quantity: 10, unit: ShopUnit.pcs, estPriceMinor: 15050, currency: 'RUB'));
      await repo.add(const ShoppingDraft(title: 'Ayran', estPriceMinor: 3000, currency: 'TRY'));
      await repo.add(const ShoppingDraft(title: 'Соль'));
      await repo.setDone(a, true);

      final items = await repo.getAll();
      expect(items.last.done, isTrue); // купленные — в конце
      final t = ShoppingTotals.of(items, fallbackCurrency: 'RUB');
      expect(t.total, {'RUB': 27050, 'TRY': 3000});
      expect(t.remaining, {'RUB': 15050, 'TRY': 3000});

      await repo.clearDone();
      expect(await repo.getAll(), hasLength(3));
    });

    test('от плана: некупленные пункты плана заменяются, ручные и купленные остаются', () async {
      final repo = ShoppingRepository(db, clock: _clock);
      await repo.add(const ShoppingDraft(title: 'Кофе'));
      final lines = planShoppingList(proteinG: 100, carbsG: 200);
      await repo.replacePlanItems(lines, (g) => g.name);
      var items = await repo.getAll();
      expect(items.where((i) => i.source == 'plan'), hasLength(lines.length));
      expect(items.where((i) => i.source == 'plan').every((i) => i.estPriceMinor == null), isTrue);

      final bought = items.firstWhere((i) => i.source == 'plan');
      await repo.setDone(bought.id, true);
      await repo.replacePlanItems(lines, (g) => g.name);
      items = await repo.getAll();
      expect(items.where((i) => i.source == 'plan'), hasLength(lines.length + 1));
      expect(items.where((i) => i.title == 'Кофе'), hasLength(1));
    });
  });
}
