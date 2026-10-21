import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/shop/data/reward_repository.dart';
import 'package:sistema/features/shop/shop_rules.dart';

import '../../helpers/test_db.dart';

Future<void> _purchase(AppDatabase db, String rewardId, DateTime at, {int price = 10, String? title}) async =>
    db.into(db.questEvents).insert(QuestEventsCompanion.insert(
          id: newId(),
          updatedAt: at.toUtc(),
          deviceId: await db.deviceId(),
          type: QuestEventType.purchase.name,
          occurredAt: at,
          diamonds: Value(-price),
          payload: Value(jsonEncode({'rewardId': rewardId, 'title': ?title})),
        ));

void main() {
  late AppDatabase db;
  late RewardRepository repo;
  final now = DateTime(2026, 10, 21, 12);

  setUp(() {
    db = memoryDb();
    repo = RewardRepository(db, clock: () => now);
  });
  tearDown(() => db.close());

  test('создание, правка, порядок, архив', () async {
    final a = await repo.create(const RewardDraft(title: ' Шоколадка ', price: 50));
    final b = await repo.create(
      const RewardDraft(title: 'Час игр', price: 100, limitCount: 2, limitPeriod: RewardLimitPeriod.week),
    );
    final c = await repo.create(const RewardDraft(title: 'Фастфуд', price: 150, limitCount: 5));
    var list = await repo.getRewards();
    expect(list.map((r) => r.id), [a, b, c]);
    expect(list[0].title, 'Шоколадка');
    expect(list[1].hasLimit, isTrue);
    // Количество без периода не сохраняется.
    expect(list[2].limitCount, isNull);

    await repo.update(a, const RewardDraft(title: 'Шоколад', price: 60, limitCount: 1, limitPeriod: RewardLimitPeriod.day));
    final row = await (db.select(db.rewards)..where((t) => t.id.equals(a))).getSingle();
    expect(row.version, 2);
    expect(row.limitPeriod, 'day');

    await repo.move(c, -2);
    expect((await repo.getRewards()).map((r) => r.id), [c, a, b]);

    await repo.setArchived(a, true);
    expect((await repo.getRewards()).map((r) => r.id), [c, b]);
    expect((await repo.getRewards(archived: true)).single.id, a);

    await repo.setArchived(a, false);
    expect((await repo.getRewards()).map((r) => r.id), [c, b, a]);
  });

  test('покупки из журнала: фильтр по времени, названия, сортировка', () async {
    final id = await repo.create(const RewardDraft(title: 'Час игр', price: 100));
    await _purchase(db, id, DateTime(2026, 10, 20, 18), price: 100);
    await _purchase(db, id, DateTime(2026, 10, 21, 9), price: 100, title: 'Старое название');
    await _purchase(db, 'other', DateTime(2026, 9, 1), price: 5);
    // Не покупка — не учитывается.
    await db.into(db.questEvents).insert(QuestEventsCompanion.insert(
          id: newId(),
          updatedAt: now,
          deviceId: await db.deviceId(),
          type: QuestEventType.completed.name,
          occurredAt: now,
          diamonds: const Value(10),
        ));

    final all = await repo.getPurchases();
    expect(all.length, 3);
    expect(all.first.title, 'Старое название');
    expect(all[1].title, 'Час игр');
    expect(all[1].price, 100);

    final times = await repo.purchaseTimes(id, since: purchasesWindowStart(now));
    expect(times.length, 2);
    expect(await repo.purchaseTimes(id, since: DateTime(2026, 10, 21)), [DateTime(2026, 10, 21, 9)]);
  });
}
