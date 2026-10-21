// Провайдеры раздела «Питание». Публичные для «Статуса» и интеграции:
//   nutritionClockProvider  — часы (в тестах фиксированные);
//   nutritionDayProvider    — StreamProvider.family<NutritionDay, DateTime> (ключ — локальная полночь);
//   waterRepositoryProvider — WaterRepository.add(ml, at:) для виджета / App Intent;
//   waterGoalProvider       — норма воды на день (с учётом дня тренировки);
//   nutritionBurnedKcalProvider — сожжено за день (подключает интеграция к dailyEnergyProvider, B).
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../core/activity/activity_providers.dart';
import '../../core/data/app_locale.dart';
import '../../core/db/database.dart';
import '../../core/models/daily.dart';
import '../../domain/quests/section_hooks.dart';
import '../plan/data/plan_repository.dart';
import '../plan/model/plan.dart';
import '../schedule/data/schedule_repository.dart';
import '../schedule/schedule_logic.dart';
import 'data/diary_repository.dart';
import 'data/food_lookup.dart';
import 'data/food_repository.dart';
import 'data/recipe_repository.dart';
import 'data/shopping_repository.dart';
import 'data/water_repository.dart';
import 'domain/nutrition_math.dart';

/// Часы раздела (в тестах — фиксированные).
final nutritionClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// HTTP-клиент для Open Food Facts (в тестах — фейковый).
final nutritionHttpClientProvider = Provider<http.Client>((ref) {
  final c = http.Client();
  ref.onDispose(c.close);
  return c;
});

/// Язык названий продуктов OFF ('ru'/'tr'); null — как в базе.
final foodLookupLangProvider = Provider<String?>((ref) => ref.watch(appLocaleProvider)?.languageCode);

/// Внешние источники по штрихкоду: Open Food Facts, затем сервер (этап 5, пока заглушка).
final foodLookupProvider = Provider<FoodLookup>((ref) => ChainedFoodLookup([
      OpenFoodFactsLookup(ref.watch(nutritionHttpClientProvider), preferLang: ref.watch(foodLookupLangProvider)),
      const ServerFoodLookup(),
    ]));

final foodRepositoryProvider =
    Provider<FoodRepository>((ref) => FoodRepository(ref.watch(databaseProvider), clock: ref.watch(nutritionClockProvider)));

final barcodeFoodServiceProvider =
    Provider<BarcodeFoodService>((ref) => BarcodeFoodService(ref.watch(foodRepositoryProvider), ref.watch(foodLookupProvider)));

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) => DiaryRepository(
      ref.watch(databaseProvider),
      clock: ref.watch(nutritionClockProvider),
      hooks: ref.watch(sectionQuestHooksProvider),
    ));

final waterRepositoryProvider = Provider<WaterRepository>((ref) => WaterRepository(
      ref.watch(databaseProvider),
      clock: ref.watch(nutritionClockProvider),
      hooks: ref.watch(sectionQuestHooksProvider),
    ));

final recipeRepositoryProvider =
    Provider<RecipeRepository>((ref) => RecipeRepository(ref.watch(databaseProvider), clock: ref.watch(nutritionClockProvider)));

final shoppingRepositoryProvider = Provider<ShoppingRepository>(
    (ref) => ShoppingRepository(ref.watch(databaseProvider), clock: ref.watch(nutritionClockProvider)));

/// Записи дневника дня (ключ — локальная полночь).
final mealEntriesProvider = StreamProvider.family<List<MealEntryRow>, DateTime>(
    (ref, day) => ref.watch(diaryRepositoryProvider).watchDay(day));

/// Записи воды дня.
final waterLogsProvider =
    StreamProvider.family<List<WaterLogRow>, DateTime>((ref, day) => ref.watch(waterRepositoryProvider).watchDay(day));

/// Сводка дня для «Статуса» и квестов: КБЖУ записей дневника + вода.
final nutritionDayProvider = StreamProvider.family<NutritionDay, DateTime>((ref, day) {
  final key = dayStart(day);
  return combineLatest2(
    ref.watch(diaryRepositoryProvider).watchDay(key),
    ref.watch(waterRepositoryProvider).watchDay(key),
    (meals, water) => buildNutritionDay(
      entries: meals.map((m) => m.macros),
      mealTypes: meals.map((m) => m.mealType),
      waterMl: water.map((w) => w.ml),
    ),
  );
});

/// Нормы принятого плана (null — плана нет).
final nutritionNormsProvider = Provider<PlanNorms?>((ref) => ref.watch(acceptedPlanProvider).value?.plan.norms);

/// День тренировки по плану (пункт «тренировка» в распорядке дня с учётом чередования недель).
final trainingDayProvider = Provider.family<bool, DateTime>((ref, day) {
  final plan = ref.watch(acceptedPlanProvider).value?.plan;
  if (plan == null || plan.weeks.isEmpty) return false;
  final config = ref.watch(scheduleConfigProvider).value ?? const ScheduleConfig();
  final number = plan.alternation ? ScheduleLogic.weekNumber(day, config) : plan.weeks.first.number;
  final week = plan.weeks.firstWhere((w) => w.number == number, orElse: () => plan.weeks.first);
  return (week.day(day.weekday)?.items ?? const <RoutineItem>[]).any((i) => i.kind == RoutineKind.training);
});

/// Норма воды на день, мл (null — нормы нет).
final waterGoalProvider = Provider.family<int?, DateTime>((ref, day) {
  final n = ref.watch(nutritionNormsProvider);
  return waterGoalMl(
    baseMl: n?.waterMl,
    trainingDayMl: n?.waterTrainingDayMl,
    trainingDay: ref.watch(trainingDayProvider(dayStart(day))),
  );
});

/// Сожжено за день, ккал (null — неизвестно). TODO(интеграция): dailyEnergyProvider(day).totalKcal (сабагент B).
final nutritionBurnedKcalProvider =
    Provider.family<double?, DateTime>((ref, day) => ref.watch(dailyEnergyProvider(day)).value?.totalKcal);

final recipesProvider = StreamProvider<List<Recipe>>((ref) => ref.watch(recipeRepositoryProvider).watchAll());

final shoppingItemsProvider = StreamProvider<List<ShoppingItemRow>>((ref) => ref.watch(shoppingRepositoryProvider).watchAll());

/// Последние значения двух потоков (событие — когда оба дали хотя бы по одному значению).
Stream<R> combineLatest2<A, B, R>(Stream<A> a, Stream<B> b, R Function(A, B) combine) {
  late StreamController<R> controller;
  StreamSubscription<A>? sa;
  StreamSubscription<B>? sb;
  A? va;
  B? vb;
  var hasA = false;
  var hasB = false;
  var done = 0;
  void emit() {
    if (hasA && hasB) controller.add(combine(va as A, vb as B));
  }

  void onDone() {
    if (++done == 2) controller.close();
  }

  controller = StreamController<R>(
    onListen: () {
      sa = a.listen((v) {
        va = v;
        hasA = true;
        emit();
      }, onError: controller.addError, onDone: onDone);
      sb = b.listen((v) {
        vb = v;
        hasB = true;
        emit();
      }, onError: controller.addError, onDone: onDone);
    },
    onPause: () {
      sa?.pause();
      sb?.pause();
    },
    onResume: () {
      sa?.resume();
      sb?.resume();
    },
    onCancel: () async {
      await Future.wait([if (sa != null) sa!.cancel(), if (sb != null) sb!.cancel()]);
    },
  );
  return controller.stream;
}
