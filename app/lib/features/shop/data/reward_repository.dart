// Награды магазина (таблица Rewards) и покупки (события purchase в журнале QuestEvents).
// Поля синхронизации: updatedAt (UTC), deviceId, version+1. Архив — active=false (не удаление).
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../shop_rules.dart';

/// Покупка из журнала.
class PurchaseRecord {
  const PurchaseRecord({
    required this.id,
    required this.rewardId,
    required this.title,
    required this.price,
    required this.at,
  });

  final String id;
  final String? rewardId;

  /// Название на момент покупки (payload.title) или текущее название награды.
  final String title;

  /// Списано ◆ (положительное число).
  final int price;
  final DateTime at;
}

class RewardRepository {
  RewardRepository(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  SimpleSelectStatement<$RewardsTable, RewardRow> _query({required bool active}) =>
      _db.select(_db.rewards)
    ..where((t) => t.deletedAt.isNull() & t.active.equals(active))
    ..orderBy([(t) => OrderingTerm(expression: t.sortOrder), (t) => OrderingTerm(expression: t.title)]);

  Stream<List<Reward>> watchRewards({bool archived = false}) =>
      _query(active: !archived).watch().map((rows) => rows.map(Reward.fromRow).toList());

  Future<List<Reward>> getRewards({bool archived = false}) async =>
      (await _query(active: !archived).get()).map(Reward.fromRow).toList();

  Future<Reward?> getReward(String id) async {
    final row =
        await (_db.select(_db.rewards)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    return row == null ? null : Reward.fromRow(row);
  }

  /// Новая награда — в конец списка.
  Future<String> create(RewardDraft d) async {
    final id = newId();
    final deviceId = await _db.deviceId();
    await _db.transaction(() async {
      final maxOrder = _db.rewards.sortOrder.max();
      final row = await (_db.selectOnly(_db.rewards)..addColumns([maxOrder])).getSingle();
      final next = (row.read(maxOrder) ?? -1) + 1;
      await _db.into(_db.rewards).insert(RewardsCompanion.insert(
            id: id,
            updatedAt: _clock().toUtc(),
            deviceId: deviceId,
            title: d.title.trim(),
            price: d.price,
            limitCount: Value(d.limitPeriod == null ? null : d.limitCount),
            limitPeriod: Value(d.limitPeriod?.name),
            sortOrder: Value(next),
          ));
    });
    return id;
  }

  Future<void> update(String id, RewardDraft d) => _patch(
        id,
        RewardsCompanion(
          title: Value(d.title.trim()),
          price: Value(d.price),
          limitCount: Value(d.limitPeriod == null ? null : d.limitCount),
          limitPeriod: Value(d.limitPeriod?.name),
        ),
      );

  /// В архив / из архива. Возвращённая награда встаёт в конец списка.
  Future<void> setArchived(String id, bool archived) async {
    var sort = const Value<int>.absent();
    if (!archived) {
      final active = await getRewards();
      sort = Value(active.isEmpty ? 0 : active.map((r) => r.sortOrder).reduce((a, b) => a > b ? a : b) + 1);
    }
    await _patch(id, RewardsCompanion(active: Value(!archived), sortOrder: sort));
  }

  /// Порядок активных наград = порядок [ids].
  Future<void> reorder(List<String> ids) => _db.transaction(() async {
        for (var i = 0; i < ids.length; i++) {
          final r = await getReward(ids[i]);
          if (r != null && r.sortOrder != i) await _patch(ids[i], RewardsCompanion(sortOrder: Value(i)));
        }
      });

  /// Сдвинуть награду на [delta] позиций среди активных.
  Future<void> move(String id, int delta) async {
    final ids = (await getRewards()).map((r) => r.id).toList();
    final i = ids.indexOf(id);
    if (i < 0) return;
    final j = (i + delta).clamp(0, ids.length - 1);
    if (i == j) return;
    ids
      ..removeAt(i)
      ..insert(j, id);
    await reorder(ids);
  }

  Future<void> _patch(String id, RewardsCompanion patch) async {
    final deviceId = await _db.deviceId();
    await _db.transaction(() async {
      final existing = await (_db.select(_db.rewards)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (existing == null) return;
      await (_db.update(_db.rewards)..where((t) => t.id.equals(id))).write(patch.copyWith(
            updatedAt: Value(_clock().toUtc()),
            deviceId: Value(deviceId),
            version: Value(existing.version + 1),
          ));
    });
  }

  // ---------- Покупки (журнал) ----------

  /// Покупки, новые сверху. [since] — не раньше этого момента, [limit] — не больше N.
  Stream<List<PurchaseRecord>> watchPurchases({DateTime? since, int? limit}) {
    final q = _db.select(_db.questEvents)
      ..where((t) {
        var w = t.type.equals(QuestEventType.purchase.name) & t.deletedAt.isNull();
        if (since != null) w = w & t.occurredAt.isBiggerOrEqualValue(since);
        return w;
      })
      ..orderBy([(t) => OrderingTerm(expression: t.occurredAt, mode: OrderingMode.desc)]);
    if (limit != null) q.limit(limit);
    return q.watch().asyncMap((rows) async {
      final names = {for (final r in await _db.select(_db.rewards).get()) r.id: r.title};
      return rows.map((e) => _record(e, names)).toList();
    });
  }

  Future<List<PurchaseRecord>> getPurchases({DateTime? since}) => watchPurchases(since: since).first;

  /// Время покупок награды [rewardId] начиная с [since].
  Future<List<DateTime>> purchaseTimes(String rewardId, {required DateTime since}) async =>
      [for (final p in await getPurchases(since: since)) if (p.rewardId == rewardId) p.at];

  static PurchaseRecord _record(QuestEventRow e, Map<String, String> names) {
    Map<String, Object?> payload = const {};
    try {
      final d = jsonDecode(e.payload);
      if (d is Map<String, Object?>) payload = d;
    } on FormatException {
      // битый payload — без названия
    }
    final rewardId = payload['rewardId'] is String ? payload['rewardId']! as String : null;
    final title = payload['title'] is String ? payload['title']! as String : names[rewardId] ?? '';
    return PurchaseRecord(id: e.id, rewardId: rewardId, title: title, price: e.diamonds.abs(), at: e.occurredAt);
  }
}
