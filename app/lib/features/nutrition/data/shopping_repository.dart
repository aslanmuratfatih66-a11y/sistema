// Список покупок (таблица ShoppingItems): ручные пункты и базовый список от плана (source 'plan').
// Цена — примерная, в минимальных единицах (копейки/куруши).
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../core/db/database.dart';
import '../domain/shopping_plan.dart';

@immutable
class ShoppingDraft {
  const ShoppingDraft({required this.title, this.quantity, this.unit, this.estPriceMinor, this.currency});

  final String title;
  final double? quantity;
  final String? unit;
  final int? estPriceMinor;
  final String? currency;
}

/// Сумма по валютам (минимальные единицы): всего и ещё не куплено.
@immutable
class ShoppingTotals {
  const ShoppingTotals({required this.total, required this.remaining});
  final Map<String, int> total;
  final Map<String, int> remaining;

  static ShoppingTotals of(Iterable<ShoppingItemRow> items, {required String fallbackCurrency}) {
    final total = <String, int>{};
    final remaining = <String, int>{};
    for (final i in items) {
      final p = i.estPriceMinor;
      if (p == null) continue;
      final c = i.currency ?? fallbackCurrency;
      total[c] = (total[c] ?? 0) + p;
      if (!i.done) remaining[c] = (remaining[c] ?? 0) + p;
    }
    return ShoppingTotals(total: total, remaining: remaining);
  }
}

class ShoppingRepository {
  ShoppingRepository(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  static const sourceManual = 'manual';
  static const sourcePlan = 'plan';

  /// Не купленные сверху, затем по порядку.
  Stream<List<ShoppingItemRow>> watchAll() => (_db.select(_db.shoppingItems)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([
          (t) => OrderingTerm.asc(t.done),
          (t) => OrderingTerm.asc(t.sortOrder),
          (t) => OrderingTerm.asc(t.title),
        ]))
      .watch();

  Future<List<ShoppingItemRow>> getAll() => watchAll().first;

  Future<String> add(ShoppingDraft d, {String source = sourceManual}) async {
    final id = newId();
    final deviceId = await _db.deviceId();
    await _db.transaction(() async {
      final maxOrder = _db.shoppingItems.sortOrder.max();
      final row = await (_db.selectOnly(_db.shoppingItems)..addColumns([maxOrder])).getSingle();
      await _db.into(_db.shoppingItems).insert(ShoppingItemsCompanion.insert(
            id: id,
            updatedAt: _clock().toUtc(),
            deviceId: deviceId,
            title: d.title.trim(),
            quantity: Value(d.quantity),
            unit: Value(d.unit),
            estPriceMinor: Value(d.estPriceMinor),
            currency: Value(d.estPriceMinor == null ? null : d.currency),
            source: Value(source),
            sortOrder: Value((row.read(maxOrder) ?? -1) + 1),
          ));
    });
    return id;
  }

  Future<void> update(String id, ShoppingDraft d) => _patch(
        id,
        ShoppingItemsCompanion(
          title: Value(d.title.trim()),
          quantity: Value(d.quantity),
          unit: Value(d.unit),
          estPriceMinor: Value(d.estPriceMinor),
          currency: Value(d.estPriceMinor == null ? null : d.currency),
        ),
      );

  Future<void> setDone(String id, bool done) => _patch(id, ShoppingItemsCompanion(done: Value(done)));

  Future<void> softDelete(String id) => _patch(id, ShoppingItemsCompanion(deletedAt: Value(_clock().toUtc())));

  /// Убрать купленные.
  Future<void> clearDone() async {
    for (final i in await getAll()) {
      if (i.done) await softDelete(i.id);
    }
  }

  /// Базовый список от плана: прежние некупленные пункты плана заменяются новыми.
  /// [titleOf] — локализованное название продукта.
  Future<int> replacePlanItems(List<PlanShoppingLine> lines, String Function(PlanGrocery) titleOf) async {
    await _db.transaction(() async {
      for (final i in await getAll()) {
        if (i.source == sourcePlan && !i.done) await softDelete(i.id);
      }
      for (final line in lines) {
        await add(ShoppingDraft(title: titleOf(line.item), quantity: line.quantity, unit: line.unit), source: sourcePlan);
      }
    });
    return lines.length;
  }

  Future<void> _patch(String id, ShoppingItemsCompanion patch) async {
    final deviceId = await _db.deviceId();
    await _db.transaction(() async {
      final row = await (_db.select(_db.shoppingItems)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null) return;
      await (_db.update(_db.shoppingItems)..where((t) => t.id.equals(id))).write(patch.copyWith(
            updatedAt: Value(_clock().toUtc()),
            deviceId: Value(deviceId),
            version: Value(row.version + 1),
          ));
    });
  }
}
