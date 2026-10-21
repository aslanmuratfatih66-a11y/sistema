// Создание сервисов вне дерева виджетов: main и фоновые isolate'ы (кнопки уведомлений, BGAppRefresh).
import '../core/db/database.dart';
import '../core/models/enums.dart';
import '../domain/discipline/discipline_hook.dart';
import '../domain/quests/local_quest_service.dart';
import '../domain/quests/quest_api.dart';
import '../features/plan/data/plan_repository.dart';

/// Движок квестов поверх [db]. В фоне вызывается с собственным экземпляром БД.
/// [watch] — следить за анкетой/расписанием (main); в фоне достаточно однократной загрузки.
Future<QuestService> createQuestService(AppDatabase db, {bool watch = false}) async {
  final discipline = DisciplineQuestSource(db);
  watch ? await discipline.start() : await discipline.load();
  return LocalQuestService(db, disciplineQuests: discipline.call);
}

/// План, принятый до появления движка (этап 1), — квесты из него ещё не созданы.
/// Если квестов из плана нет совсем (даже архивных), импортирует их из последнего принятого плана.
Future<void> importAcceptedPlanIfMissing(AppDatabase db, QuestService quests) async {
  final any = await (db.select(db.quests)
        ..where((t) => t.source.equals(QuestSource.plan.name))
        ..limit(1))
      .getSingleOrNull();
  if (any != null) return;
  final plan = await PlanRepository(db).latestAccepted();
  if (plan == null) return;
  await quests.importPlanQuests(planId: plan.id, drafts: [for (final q in plan.plan.quests) q.toJson()]);
}
