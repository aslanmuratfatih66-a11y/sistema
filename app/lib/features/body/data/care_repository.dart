// Отметки ухода за кожей (CareChecks): строка = выполненный пункт рутины в день.
// Уникальность (day, routine, itemKey) — снятая отметка мягко удаляется, повторная её «воскрешает».
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/questionnaire_repository.dart';
import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../domain/quests/section_hooks.dart';
import '../../onboarding/questionnaire_a/data/goal_repository.dart';
import '../domain/care_template.dart';
import '../domain/sleep_math.dart';
import 'sleep_repository.dart';

/// Отметка: рутина + ключ пункта.
typedef CareMark = ({CareRoutine routine, String itemKey});

class CareRepository {
  CareRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$CareChecksTable, CareCheckRow> _day(DateTime day) =>
      _db.select(_db.careChecks)..where((t) => t.day.equals(dayOf(day)) & t.deletedAt.isNull());

  static Set<CareMark> _marks(List<CareCheckRow> rows) => {
        for (final r in rows)
          if (enumByName(CareRoutine.values, r.routine) case final routine?) (routine: routine, itemKey: r.itemKey),
      };

  Future<Set<CareMark>> marks(DateTime day) async => _marks(await _day(day).get());

  Stream<Set<CareMark>> watchMarks(DateTime day) => _day(day).watch().map(_marks);

  /// Поставить или снять отметку пункта.
  Future<void> setDone(DateTime day, CareRoutine routine, String itemKey, bool done, {DateTime? at}) async {
    final d = dayOf(day);
    final deviceId = await _db.deviceId();
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      final existing = await (_db.select(_db.careChecks)
            ..where((t) => t.day.equals(d) & t.routine.equals(routine.name) & t.itemKey.equals(itemKey)))
          .getSingleOrNull();
      if (existing == null) {
        if (!done) return;
        await _db.into(_db.careChecks).insert(CareChecksCompanion.insert(
              id: newId(),
              updatedAt: now,
              deviceId: deviceId,
              day: d,
              routine: routine.name,
              itemKey: itemKey,
              doneAt: at ?? DateTime.now(),
            ));
        return;
      }
      final active = existing.deletedAt == null;
      if (active == done) return;
      await (_db.update(_db.careChecks)..where((t) => t.id.equals(existing.id))).write(CareChecksCompanion(
            deletedAt: Value(done ? null : now),
            doneAt: done ? Value(at ?? DateTime.now()) : const Value.absent(),
            updatedAt: Value(now),
            deviceId: Value(deviceId),
            version: Value(existing.version + 1),
          ));
    });
  }
}

/// Отметки + сообщение движку квестов, когда рутина закрыта полностью.
class CareService {
  CareService(this.repo, this.hooks);

  final CareRepository repo;
  final SectionQuestHooks hooks;

  /// Отметить пункт. [items] — пункты рутины на этот день (из шаблона).
  /// true — этой отметкой рутина закрыта полностью (вызван hooks.careRoutineDone).
  Future<bool> toggle({
    required DateTime day,
    required CareRoutine routine,
    required String itemKey,
    required bool done,
    required List<String> items,
    DateTime? at,
  }) async {
    bool complete(Set<CareMark> m) => items.isNotEmpty && items.every((k) => m.contains((routine: routine, itemKey: k)));
    final wasComplete = complete(await repo.marks(day));
    await repo.setDone(day, routine, itemKey, done, at: at);
    if (!done || wasComplete) return false;
    if (!complete(await repo.marks(day))) return false;
    await hooks.careRoutineDone(routine, at: at);
    return true;
  }
}

final careRepositoryProvider = Provider<CareRepository>((ref) => CareRepository(ref.watch(databaseProvider)));

final careServiceProvider = Provider<CareService>(
  (ref) => CareService(ref.watch(careRepositoryProvider), ref.watch(sectionQuestHooksProvider)),
);

/// Отметки за день (локальная полночь).
final careMarksProvider = StreamProvider.family<Set<CareMark>, DateTime>(
  (ref, day) => ref.watch(careRepositoryProvider).watchMarks(dayOf(day)),
);

/// Шаблон ухода по анкете (кожа + цели). Пока грузится — пустой профиль (базовый уход).
final careTemplateProvider = Provider<CareTemplate>((ref) {
  final skin = ref.watch(questionnaireSectionProvider(QuestionnaireSection.skin)).value ?? const {};
  final goals = ref.watch(activeGoalsProvider).value ?? const <GoalRow>[];
  final kinds = [for (final g in goals) ?enumByName(GoalKind.values, g.kind)];
  return CareTemplate(CareProfile.from(skin, kinds));
});

/// Сегодня (локальная полночь) по часам раздела.
final bodyTodayProvider = Provider<DateTime>((ref) => dayOf(ref.watch(bodyClockProvider)()));
