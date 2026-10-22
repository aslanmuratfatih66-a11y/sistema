// Демо-данные веб-предпросмотра: при пустой БД браузера засеваются через репозитории и движок квестов,
// чтобы все экраны были с содержимым. Флаг в AppSettings — второй раз не засевается. Alt+R — сброс.
// Только для lib/main_preview.dart (в релиз не попадает).
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../core/activity/step_repository.dart';
import '../core/ai/ai_api.dart';
import '../core/alarm/alarm_repository.dart';
import '../core/alarm/alarm_schedule.dart';
import '../core/data/profile_repository.dart';
import '../core/data/questionnaire_repository.dart';
import '../core/db/database.dart';
import '../core/location/walk_repository.dart';
import '../core/models/daily.dart';
import '../core/models/enums.dart';
import '../domain/discipline/app_blocker_catalog.dart';
import '../domain/discipline/app_blocker_repository.dart';
import '../domain/finance/finance_api.dart';
import '../domain/quests/local_quest_service.dart';
import '../domain/quests/quest_api.dart';
import '../domain/quests/quest_section_hooks.dart';
import '../features/body/data/measurement_repository.dart';
import '../features/body/data/sleep_repository.dart';
import '../features/chat/chat_repository.dart';
import '../features/finance/data/finance_ledger_impl.dart';
import '../features/finance/data/finance_repository.dart';
import '../features/finance/domain/fin_categories.dart';
import '../features/learning/learning_repository.dart';
import '../features/market/market_data.dart';
import '../features/nutrition/data/diary_repository.dart';
import '../features/nutrition/data/shopping_repository.dart';
import '../features/nutrition/data/water_repository.dart';
import '../features/nutrition/domain/nutrition_math.dart';
import '../features/onboarding/onboarding_progress.dart';
import '../features/onboarding/questionnaire_a/data/goal_repository.dart';
import '../features/plan/data/plan_inputs_loader.dart';
import '../features/plan/data/plan_repository.dart';
import '../features/plan/draft_plan_builder.dart';
import '../features/schedule/data/schedule_repository.dart';
import '../features/schedule/schedule_logic.dart';
import '../features/shop/data/reward_repository.dart';
import '../features/shop/shop_rules.dart';
import '../features/workouts/data/workout_repository.dart';
import '../features/workouts/domain/program_generator.dart';
import '../features/workouts/domain/training_profile.dart';
import '../features/workouts/model/exercise_catalog.dart';
import 'preview_fakes.dart';

/// Ключ AppSettings: демо-данные уже засеяны.
const demoSeededKey = 'preview.demoSeeded';

class DemoData {
  DemoData(this.db);

  final AppDatabase db;

  /// Засеять, если ещё не засеяно (первый запуск в этом браузере).
  Future<void> seedIfNeeded() async {
    if (await db.getSetting(demoSeededKey) != null) return;
    // Анкету уже прошли руками — не трогаем.
    if (await db.getSetting(OnboardingProgress.completedKey) == '1') return;
    await seed();
  }

  /// Очистить все таблицы (вместе с флагом). Засеивание — при следующем старте: на живом приложении
  /// движок квестов экранов и засеивающий мешают друг другу, поэтому после очистки страница перезагружается.
  Future<void> clear() => db.transaction(() async {
        for (final t in db.allTables) {
          await db.delete(t).go();
        }
      });

  Future<void> seed() async {
    final sw = Stopwatch()..start();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime day(int offset, [int hour = 0, int minute = 0]) => DateTime(today.year, today.month, today.day + offset, hour, minute);

    // Движок квестов с подменяемыми часами: история за прошлую неделю «проживается» по дням.
    var clock = day(-7, 6);
    final quests = LocalQuestService(db, clock: () => clock);

    Future<void> step(String name, Future<void> Function() body) async {
      try {
        await body();
      } catch (e, s) {
        debugPrint('Демо-данные: $name — $e\n$s');
      }
    }

    // ---------- Анкета ----------
    await step('профиль', () async {
      await ProfileRepository(db).update(ProfilesCompanion(
        name: const Value('Мурат'),
        sex: Value(Sex.male.name),
        birthDate: Value(DateTime(2005, 5, 14)),
        city: const Value('Москва'),
        timezone: const Value('Europe/Moscow'),
        heightCm: const Value(180),
        activityLevel: Value(ActivityLevel.light.name),
        workload: Value(Workload.sitting.name),
      ));
      final m = BodyMeasurementRepository(db);
      for (final (offset, kg, waist) in [(-28, 78.4, 86.0), (-21, 77.9, 85.5), (-14, 77.1, 85.0), (-7, 76.6, 84.0), (0, 76.2, 83.5)]) {
        await m.add(MeasurementInput(
          {MeasureField.weight: kg, MeasureField.waist: waist, if (offset == 0) MeasureField.chest: 98, if (offset == 0) MeasureField.arm: 33},
          measuredAt: day(offset, 8),
        ));
      }
      final goals = GoalRepository(db);
      await goals.select(GoalKind.weightLoss);
      await goals.select(GoalKind.discipline);
      await goals.select(GoalKind.study);
    });

    await step('разделы анкеты', () async {
      final q = QuestionnaireRepository(db);
      await q.write(QuestionnaireSection.character, {
        'archetype': CharacterArchetype.animeGirl.name,
        'motivation': 'normal',
        'profanityAllowed': false,
      });
      await q.write(QuestionnaireSection.training, {
        'level': WorkoutLevel.beginner.name,
        'minutesPerDay': 30,
        'equipment': <String>[],
        'days': [DateTime.monday, DateTime.wednesday, DateTime.friday],
      });
      await q.write(QuestionnaireSection.nutrition, {'mealsPerDay': 3});
      await q.write(QuestionnaireSection.finance, {
        'accounts': [
          {'id': '1', 'kind': 'card', 'currency': 'RUB', 'balance': 48500, 'bank': 'Т-Банк'},
          {'id': '2', 'kind': 'card', 'currency': 'RUB', 'balance': 12300, 'bank': 'Сбер'},
          {'id': '3', 'kind': 'cash', 'currency': 'RUB', 'balance': 3500},
        ],
        'crypto': [
          {'id': '1', 'symbol': 'BTC', 'amount': 0.0021},
        ],
        'debts': [
          {'id': '1', 'person': 'Артём', 'direction': 'iOwe', 'amount': 2000, 'currency': 'RUB', 'dueDate': day(9).toIso8601String()},
          {'id': '2', 'person': 'Лена', 'direction': 'oweMe', 'amount': 1500, 'currency': 'RUB', 'dueDate': day(4).toIso8601String()},
        ],
      });
    });

    await step('расписание', () async {
      final s = ScheduleRepository(db, clock: () => clock);
      await s.updateSettings(ScheduleSettingsCompanion(
        institutionType: Value(InstitutionType.university.name),
        institutionName: const Value('МИРЭА'),
        wakeMinute: const Value(7 * 60),
        bedMinute: const Value(23 * 60),
        commuteMinutes: const Value(40),
      ));
      await s.setAlternation(true);
      for (final e in const [
        (DateTime.monday, 9 * 60, 'Матанализ', 0),
        (DateTime.monday, 10 * 60 + 40, 'Физика', 0),
        (DateTime.tuesday, 10 * 60 + 40, 'Программирование', 0),
        (DateTime.wednesday, 9 * 60, 'Английский', 1),
        (DateTime.wednesday, 12 * 60 + 40, 'Линейная алгебра', 2),
        (DateTime.thursday, 9 * 60, 'Программирование', 0),
        (DateTime.friday, 10 * 60 + 40, 'История', 0),
      ]) {
        await s.saveEntry(ScheduleEntry(
            id: '', kind: ScheduleItemKind.lesson, title: e.$3, weekday: e.$1, startMinute: e.$2, durationMinutes: 90, weekParity: e.$4));
      }
    });

    // ---------- План и квесты ----------
    await step('план', () async {
      final repo = PlanRepository(db);
      final stored = await PlanDraftService(PlanInputsLoader(db, QuestionnaireRepository(db)), const DraftPlanBuilder(), repo)
          .recalculate(now: clock);
      await repo.accept(stored.id);
      await quests.importPlanQuests(planId: stored.id, drafts: [for (final q in stored.plan.quests) q.toJson()]);
    });

    await step('история квестов', () async {
      await quests.createQuest(const QuestInput(
        kind: QuestKind.daily,
        title: QuestTitle(text: 'Прочитать 10 страниц'),
        stat: StatKind.intellect,
        minute: 21 * 60,
        reward: GameReward(diamonds: 5, xp: 10),
        penaltyDiamonds: 3,
      ));
      for (var offset = -7; offset <= -1; offset++) {
        clock = day(offset, 5);
        await quests.tick(clock);
        final items = await quests.watchDay(day(offset)).first;
        var i = 0;
        for (final q in items) {
          if (!q.isPending || q.kind == QuestKind.boss) continue;
          i++;
          if ((i + offset) % 6 == 0) continue; // часть — провалена: штрафы и журнал правдоподобнее
          final at = _doneAt(q);
          clock = at;
          try {
            await quests.complete(q.instanceId, at: at);
          } catch (_) {}
        }
      }
      // Сегодня: закрыть уже начавшиеся квесты до проверки просрочек.
      clock = day(0, 5);
      await quests.tick(clock);
      for (final q in await quests.watchDay(today).first) {
        final at = _doneAt(q);
        if (!q.isPending || q.kind == QuestKind.boss || q.startsAt == null || at.isAfter(now)) continue;
        clock = at;
        try {
          await quests.complete(q.instanceId, at: at);
        } catch (_) {}
      }
      clock = now;
      await quests.tick(now);
    });

    await step('магазин', () async {
      final rewards = RewardRepository(db);
      final game = await rewards.create(const RewardDraft(title: 'Час игр', price: 40));
      await rewards.create(const RewardDraft(title: 'Серия сериала', price: 25));
      await rewards.create(const RewardDraft(title: 'Пицца в выходные', price: 120, limitCount: 1, limitPeriod: RewardLimitPeriod.week));
      await quests.purchase(rewardId: game, title: 'Час игр', price: 40, at: day(-1, 20));
    });

    // ---------- Питание, вода, сон, шаги ----------
    await step('питание', () async {
      final diary = DiaryRepository(db, clock: () => now, hooks: QuestSectionHooks(quests));
      await diary.add(MealDraft(
          eatenAt: day(0, 8, 10), mealType: MealType.breakfast, title: 'Овсянка с бананом', grams: 300,
          macros: const Macros(kcal: 390, protein: 12, fat: 8, carbs: 66)));
      if (now.hour >= 13) {
        await diary.add(MealDraft(
            eatenAt: day(0, 13, 20), mealType: MealType.lunch, title: 'Курица с рисом', grams: 350,
            macros: const Macros(kcal: 560, protein: 42, fat: 12, carbs: 68)));
      }
      await diary.add(MealDraft(
          eatenAt: day(-1, 19, 30), mealType: MealType.dinner, title: 'Гречка с котлетой', grams: 320,
          macros: const Macros(kcal: 610, protein: 35, fat: 22, carbs: 64)));
      final water = WaterRepository(db, clock: () => now, hooks: QuestSectionHooks(quests));
      for (final h in [8, 10, 12, 15]) {
        if (h <= now.hour) await water.add(250, at: day(0, h, 5));
      }
      final shop = ShoppingRepository(db, clock: () => now);
      await shop.add(const ShoppingDraft(title: 'Куриное филе', quantity: 1, unit: 'кг', estPriceMinor: 42000, currency: 'RUB'));
      await shop.add(const ShoppingDraft(title: 'Гречка', quantity: 2, unit: 'уп', estPriceMinor: 15000, currency: 'RUB'));
      await shop.add(const ShoppingDraft(title: 'Бананы', quantity: 1, unit: 'кг', estPriceMinor: 13000, currency: 'RUB'));
    });

    await step('сон и шаги', () async {
      final sleep = SleepRepository(db);
      final steps = StepRepository(db);
      for (var offset = -6; offset <= 0; offset++) {
        final late = offset % 3 == 0 ? 50 : 10;
        await sleep.save(bedAt: day(offset - 1, 23, late), wakeAt: day(offset, 7), quality: offset % 3 == 0 ? 3 : 4);
        final count = offset == 0 ? 4300 : 7200 + (offset * 731).abs() % 4000;
        await steps.upsert(StepDay(day: day(offset), steps: count, distanceM: count * 0.75), StepSourceKind.manual);
      }
    });

    // ---------- Тренировки и прогулки ----------
    await step('тренировки', () async {
      final repo = WorkoutRepository(db);
      final program = await repo.saveProgram(
        generateTemplateProgram(const TrainingProfile(minutesPerSession: 30)),
        now: day(-7, 6),
      );
      for (final (offset, dayKey) in [(-6, 'A'), (-4, 'B'), (-2, 'C')]) {
        final start = day(offset, 18);
        final id = await repo.startSession(programId: program.id, dayKey: dayKey, startedAt: start);
        await repo.saveSession(id,
            activeSeconds: 27 * 60,
            kcal: 185,
            finishedAt: start.add(const Duration(minutes: 31)),
            payload: {'v': 1, 'day': dayKey, 'sets': const [], 'restSec': 240, 'weightKg': 76.6});
      }
    });

    await step('прогулки', () async {
      final repo = WalkRepository(db);
      for (final (offset, km) in [(-5, 3.2), (-1, 4.1)]) {
        final start = day(offset, 19);
        final id = await repo.start(startedAt: start, payload: const {'preview': true});
        final track = [
          for (var i = 0; i <= 20; i++)
            [previewHome.lat + i * 0.0006, previewHome.lon + (i.isEven ? 0.0004 : 0), start.add(Duration(minutes: i * 2)).millisecondsSinceEpoch ~/ 1000],
        ];
        final secs = (km * 1000 / 1.4).round();
        await repo.save(id,
            distanceM: km * 1000,
            activeSeconds: secs,
            track: track,
            payload: const {'preview': true},
            kcal: km * 50,
            finishedAt: start.add(Duration(seconds: secs)));
      }
    });

    // ---------- Персонаж и знания ----------
    await step('чат', () async {
      final chat = ChatRepository(db, const _NoGateway());
      await chat.add(ChatRole.user, 'Привет! С чего начать неделю?');
      await chat.add(ChatRole.assistant, 'Игрок, начни с малого: вода, сон до 23:00 и одна тренировка. Квесты на сегодня уже ждут.');
      await chat.add(ChatRole.user, 'Сегодня пропустил тренировку, что делать?');
      await chat.add(ChatRole.assistant, 'Не страшно. Прогулка 30 минут вечером закроет часть нагрузки. Завтра — по плану.');
    });

    await step('курс', () async {
      final learning = LearningRepository(db, const PreviewLearningApi(), clock: () => now);
      final courseId = await learning.createCourse(topic: 'Финансовая грамотность', lang: 'ru', dailyLessons: 1, lessons: 5);
      final lessons = (await learning.watchLessons().first).where((l) => l.courseId == courseId).toList()
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      if (lessons.isNotEmpty) {
        final first = await learning.ensureLoaded(lessons.first);
        await learning.finish(first, percent: 100);
      }
    });

    // ---------- Финансы и маркет ----------
    await step('финансы', () async {
      final repo = FinanceRepository(db, clock: () => now);
      await repo.seedCategories();
      await repo.importFromQuestionnaire(await QuestionnaireRepository(db).read(QuestionnaireSection.finance));
      final ledger = LocalFinanceLedger(repo, rates: () => const _NoRates(), quests: () => quests);
      Future<void> tx(int offset, FinTxKind kind, int rub, String cat, String merchant, [int hour = 13]) => ledger.add(TxDraft(
            kind: kind,
            amount: rub * 100,
            currency: 'RUB',
            occurredAt: day(offset, hour),
            source: FinTxSource.manual,
            categoryKey: cat,
            merchant: merchant,
            externalRef: 'demo:$offset:$cat:$merchant',
          ));
      await tx(-27, FinTxKind.income, 3100, FinCat.stipend, 'Стипендия', 10);
      await tx(-14, FinTxKind.income, 15000, FinCat.salary, 'Подработка', 10);
      for (var offset = -27; offset <= 0; offset++) {
        if (offset.isEven) await tx(offset, FinTxKind.expense, 650 + (offset.abs() * 37) % 900, FinCat.groceries, 'Пятёрочка', 19);
        if (offset % 3 == 0) await tx(offset, FinTxKind.expense, 120, FinCat.transport, 'Метро', 8);
        if (offset % 7 == -3) await tx(offset, FinTxKind.expense, 540, FinCat.cafe, 'Кофейня', 15);
      }
      await tx(-20, FinTxKind.expense, 489, FinCat.fastfood, 'Вкусно — и точка', 21);
      await tx(-9, FinTxKind.expense, 2990, FinCat.clothes, 'Wildberries', 12);
      await tx(-6, FinTxKind.expense, 650, FinCat.phone, 'Связь', 9);
      await tx(-2, FinTxKind.expense, 399, FinCat.subscriptions, 'Яндекс Плюс', 9);

      final groceries = await repo.categoryByKey(FinCat.groceries);
      final cafe = await repo.categoryByKey(FinCat.cafe);
      if (groceries != null) await repo.saveBudget(repo.newBudget(categoryId: groceries.id, limitRub: 12000 * 100));
      if (cafe != null) await repo.saveBudget(repo.newBudget(categoryId: cafe.id, limitRub: 2500 * 100));
      final subsCat = await repo.categoryByKey(FinCat.subscriptions);
      await repo.saveSubscription(repo.newSubscription().copyWith(
            title: 'Яндекс Плюс',
            amount: 39900,
            nextChargeOn: day(26, 9),
            categoryId: Value(subsCat?.id),
          ));
      await repo.saveSubscription(repo.newSubscription().copyWith(title: 'Spotify', amount: 29900, nextChargeOn: day(5, 9)));
      await repo.saveGoal(repo.newGoal(title: 'Ноутбук', target: 80000 * 100).copyWith(deadline: Value(day(120))));
    });

    await step('маркет', () async {
      final at = now.toUtc();
      await MarketRepository(db, clock: () => now).addSuggestions([
        MarketSuggestion(
          title: 'Шейкер для протеина',
          category: 'equipment',
          reason: 'Удобно брать на тренировки',
          price: 49000,
          currency: 'RUB',
          priceSource: 'ozon.ru',
          priceAt: at,
          links: const [MarketLink(store: 'Ozon', url: 'https://www.ozon.ru/search/?text=шейкер', search: true)],
        ),
        MarketSuggestion(
          title: 'Солнцезащитный крем SPF 50',
          category: 'skin',
          reason: 'Защита кожи по уходу из анкеты',
          price: 89000,
          currency: 'RUB',
          priceSource: 'goldapple.ru',
          priceAt: at,
          links: const [MarketLink(store: 'Золотое яблоко', url: 'https://goldapple.ru/search?q=spf50', search: true)],
        ),
      ]);
    });

    // ---------- Будильник и блокировка ----------
    await step('будильник', () async {
      final weekdays = [for (var d = DateTime.monday; d <= DateTime.friday; d++) alarmWeekdayBit(d)].fold<int>(0, (a, b) => a | b);
      await AlarmRepository(db).save(minute: 7 * 60, weekdays: weekdays, label: 'Подъём на пары', task: AlarmTask.squats, squats: 15);
      await AlarmRepository(db).save(minute: 9 * 60 + 30, weekdays: alarmWeekdayBit(DateTime.saturday) | alarmWeekdayBit(DateTime.sunday),
          label: 'Выходные', task: AlarmTask.squats, squats: 10, enabled: false);
    });

    await step('блокировка', () async {
      final repo = AppBlockerRepository(db);
      for (final (id, name) in const [
        ('com.zhiliaoapp.musically', 'TikTok'),
        ('com.google.android.youtube', 'YouTube'),
        ('com.instagram.android', 'Instagram'),
        ('org.telegram.messenger', 'Telegram'),
      ]) {
        await repo.setEnabled(platform: BlockerPlatformKey.android, appId: id, name: name, enabled: id != 'org.telegram.messenger');
      }
      for (final (id, name) in const [('tiktok', 'TikTok'), ('youtube', 'YouTube'), ('instagram', 'Instagram')]) {
        await repo.setEnabled(platform: BlockerPlatformKey.ios, appId: id, name: name, enabled: true);
      }
    });

    // ---------- Анкета пройдена ----------
    await db.setSetting(OnboardingProgress.introSeenKey, '1');
    await db.setSetting(OnboardingProgress.completedKey, '1');
    await db.setSetting(demoSeededKey, now.toIso8601String());
    await quests.dispose();
    debugPrint('Демо-данные засеяны за ${sw.elapsedMilliseconds} мс');
  }

  /// Момент «выполнения» квеста: вскоре после начала, но до дедлайна.
  static DateTime _doneAt(QuestItem q) {
    final start = q.startsAt ?? q.deadlineAt.subtract(const Duration(hours: 1));
    final at = start.add(const Duration(minutes: 5));
    return at.isBefore(q.deadlineAt) ? at : q.deadlineAt.subtract(const Duration(minutes: 1));
  }
}

class _NoRates implements FxRatesSource {
  const _NoRates();

  @override
  Future<FxRates?> latest({bool refresh = false}) async => null;
}

class _NoGateway implements AiGateway {
  const _NoGateway();

  @override
  Future<Map<String, dynamic>> json(String method, String path, {Object? body, Map<String, String>? query}) =>
      Future.error(const AiException(AiFailure.notSignedIn));

  @override
  Future<List<int>> bytes(String method, String path, {Object? body}) => Future.error(const AiException(AiFailure.notSignedIn));
}
