import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/onboarding/questionnaire_a/data/goal_repository.dart';

import '../../../helpers/test_db.dart';

void main() {
  test('выбор цели: одна строка на вид, повторный выбор не дублирует', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final repo = GoalRepository(db);

    final id = await repo.select(GoalKind.acne);
    expect(await repo.select(GoalKind.acne), id);
    await repo.select(GoalKind.money);

    final rows = await repo.active();
    expect(rows.map((r) => r.kind), [GoalKind.acne.name, GoalKind.money.name]);
    expect(rows.first.priority, goalPriorityMedium);
    expect(rows.first.version, 1);
    expect(rows.first.deviceId, isNotEmpty);
  });

  test('снятие выбора — мягкое удаление', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final repo = GoalRepository(db);

    final id = await repo.select(GoalKind.muscle);
    await repo.unselect(GoalKind.muscle);

    expect(await repo.active(), isEmpty);
    final raw = await (db.select(db.goals)..where((t) => t.id.equals(id))).getSingle();
    expect(raw.deletedAt, isNotNull);
    expect(raw.version, 2);

    // Повторный выбор после снятия — новая активная строка.
    final again = await repo.select(GoalKind.muscle);
    expect(again, isNot(id));
    expect((await repo.active()).single.id, again);
  });

  test('приоритет, срок и свои цели', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final repo = GoalRepository(db);

    final id = await repo.select(GoalKind.study);
    await repo.setPriority(id, goalPriorityHigh);
    await repo.setDeadline(id, DateTime(2027, 6, 1));
    final c1 = await repo.addCustom('  Выучить турецкий ');
    await repo.addCustom('Права');

    var rows = await repo.active();
    expect(rows, hasLength(3));
    final study = rows.firstWhere((r) => r.id == id);
    expect(study.priority, goalPriorityHigh);
    expect(study.deadline, DateTime(2027, 6, 1));
    expect(study.version, 3);
    final custom = rows.firstWhere((r) => r.id == c1);
    expect(custom.kind, GoalKind.custom.name);
    expect(custom.title, 'Выучить турецкий');

    await repo.setDeadline(id, null);
    await repo.remove(c1);
    rows = await repo.active();
    expect(rows, hasLength(2));
    expect(rows.map((r) => r.title), isNot(contains('Выучить турецкий')));
    expect(rows.firstWhere((r) => r.id == id).deadline, isNull);
  });
}
