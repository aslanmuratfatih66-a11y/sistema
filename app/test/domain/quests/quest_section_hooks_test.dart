import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/quests/local_quest_service.dart';
import 'package:sistema/domain/quests/quest_api.dart';
import 'package:sistema/domain/quests/quest_section_hooks.dart';
import 'package:sistema/domain/quests/system_quests.dart';
import 'package:sistema/features/plan/model/plan.dart';

import '../../helpers/test_db.dart';

/// Ср, 21.10.2026.
final _day = DateTime(2026, 10, 21);

QuestInput _plan(QuestKey key, {Map<String, Object?> params = const {}, int? minute}) => SystemQuests.fromDraft(
      QuestDraft(key: key, category: QuestCategory.daily, params: params, minute: minute, diamonds: 10, xp: 10),
    );

void main() {
  late AppDatabase db;
  late DateTime now;
  late LocalQuestService s;
  late QuestSectionHooks hooks;

  setUp(() {
    db = memoryDb();
    now = _day.add(const Duration(hours: 9));
    s = LocalQuestService(db, clock: () => now);
    hooks = QuestSectionHooks(s, clock: () => now);
  });
  tearDown(() async {
    await s.dispose();
    await db.close();
  });

  Future<List<QuestItem>> day([DateTime? d]) => s.watchDay(d ?? now).first;
  Future<QuestItem> byKey(QuestKey k) async => (await day()).firstWhere((q) => q.title.key == k.name);

  test('вода: прогресс по порядку, остаток — в следующий квест', () async {
    await s.createQuest(_plan(QuestKey.water, params: {'ml': 500}, minute: 8 * 60));
    await s.createQuest(_plan(QuestKey.water, params: {'ml': 500}, minute: 12 * 60));
    await hooks.waterAdded(ml: 750, totalTodayMl: 750);
    final water = (await day()).where((q) => q.title.key == QuestKey.water.name).toList()
      ..sort((a, b) => a.startsAt!.compareTo(b.startsAt!));
    expect(water[0].status, QuestStatus.done);
    expect(water[1].status, QuestStatus.pending);
    expect(water[1].progress, 250);
  });

  test('еда: закрывается, когда приёмов не меньше нормы', () async {
    await s.createQuest(_plan(QuestKey.meals, params: {'count': 3}));
    await hooks.mealLogged(mealsToday: 2);
    expect((await byKey(QuestKey.meals)).status, QuestStatus.pending);
    await hooks.mealLogged(mealsToday: 3);
    expect((await byKey(QuestKey.meals)).status, QuestStatus.done);
  });

  test('тренировка: засчитывается от 80% минут', () async {
    await s.createQuest(_plan(QuestKey.training, params: {'minutes': 30}));
    await hooks.workoutFinished(activeMinutes: 20);
    expect((await byKey(QuestKey.training)).status, QuestStatus.pending);
    await hooks.workoutFinished(activeMinutes: 24);
    expect((await byKey(QuestKey.training)).status, QuestStatus.done);
  });

  test('уход: утренняя рутина закрывает только утренний квест', () async {
    await s.createQuest(_plan(QuestKey.skincareMorning));
    await s.createQuest(_plan(QuestKey.skincareEvening));
    await hooks.careRoutineDone(CareRoutine.morning);
    expect((await byKey(QuestKey.skincareMorning)).status, QuestStatus.done);
    expect((await byKey(QuestKey.skincareEvening)).status, QuestStatus.pending);
  });

  test('шаги: квест с подтверждением шагами получает абсолютное значение', () async {
    await s.createQuest(const QuestInput(
      kind: QuestKind.daily,
      title: QuestTitle(text: 'Шаги'),
      reward: GameReward(diamonds: 5),
      confirm: ConfirmMethod.steps,
      target: 8000,
    ));
    await hooks.stepsUpdated(stepsToday: 3000);
    await hooks.stepsUpdated(stepsToday: 5000);
    final q = (await day()).single;
    expect(q.progress, 5000);
    await hooks.stepsUpdated(stepsToday: 8100);
    expect((await day()).single.status, QuestStatus.done);
  });

  test('сон: лёг вовремя и выспался — квест вечера закрыт', () async {
    now = _day.add(const Duration(hours: 21));
    await s.createQuest(_plan(QuestKey.sleepOnTime, params: {'hours': 8}, minute: 22 * 60 + 30));
    await hooks.sleepLogged(
      bedAt: _day.add(const Duration(hours: 22, minutes: 40)),
      wakeAt: _day.add(const Duration(days: 1, hours: 6, minutes: 30)),
    );
    expect((await byKey(QuestKey.sleepOnTime)).status, QuestStatus.done);
  });

  test('ошибки движка не пробрасываются', () async {
    await s.dispose();
    await hooks.waterAdded(ml: 250, totalTodayMl: 250);
  });
}
