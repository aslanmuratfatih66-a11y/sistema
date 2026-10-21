import 'package:flutter/widgets.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/quests/section_hooks.dart';
import 'package:sistema/features/nutrition/data/food_lookup.dart';
import 'package:sistema/features/nutrition/platform/nutrition_platform.dart';

/// Внешняя база продуктов в памяти; [fail] — «нет сети».
class FakeFoodLookup implements FoodLookup {
  FakeFoodLookup(this.products, {this.fail = false});

  final Map<String, FoodProduct> products;
  final bool fail;
  int calls = 0;

  @override
  Future<FoodLookupResult> byBarcode(String barcode) async {
    calls++;
    if (fail) return const FoodLookupResult.failed();
    final p = products[barcode];
    return p == null ? const FoodLookupResult.notFound() : FoodLookupResult.found(p);
  }
}

/// Записывает вызовы хуков квестов; [fail] — движок бросает исключение.
class RecordingHooks extends NoopSectionQuestHooks {
  RecordingHooks({this.fail = false});

  final bool fail;
  final water = <(int, int)>[];
  final meals = <int>[];

  @override
  Future<void> waterAdded({required int ml, required int totalTodayMl, DateTime? at}) async {
    if (fail) throw StateError('движок');
    water.add((ml, totalTodayMl));
  }

  @override
  Future<void> mealLogged({required int mealsToday, DateTime? at}) async {
    if (fail) throw StateError('движок');
    meals.add(mealsToday);
  }
}

class FakeBarcodeScanner implements BarcodeScanner {
  FakeBarcodeScanner(this.code);
  final String? code;

  @override
  Future<String?> scan(BuildContext context) async => code;
}

class FakePhotoPicker implements FoodPhotoPicker {
  FakePhotoPicker(this.path);
  final String? path;

  @override
  Future<String?> pick({required bool camera}) async => path;
}

const testProduct = FoodProduct(
  barcode: '4600000000001',
  name: 'Гречка',
  kcal100: 300,
  protein100: 12,
  fat100: 3,
  carbs100: 60,
  servingG: 50,
  source: FoodSource.openFoodFacts,
);
