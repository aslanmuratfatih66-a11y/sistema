import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/shop/shop_rules.dart';

const _games = Reward(id: 'g', title: 'Час игр', price: 100, limitCount: 2, limitPeriod: RewardLimitPeriod.week);

void main() {
  group('границы периодов', () {
    final now = DateTime(2026, 10, 21, 15, 30); // среда

    test('день', () {
      expect(periodStart(now, RewardLimitPeriod.day), DateTime(2026, 10, 21));
      expect(periodEnd(now, RewardLimitPeriod.day), DateTime(2026, 10, 22));
    });

    test('неделя — с понедельника', () {
      expect(periodStart(now, RewardLimitPeriod.week), DateTime(2026, 10, 19));
      expect(periodEnd(now, RewardLimitPeriod.week), DateTime(2026, 10, 26));
      final monday = DateTime(2026, 10, 19, 0, 0);
      expect(periodStart(monday, RewardLimitPeriod.week), monday);
      final sunday = DateTime(2026, 10, 25, 23, 59);
      expect(periodStart(sunday, RewardLimitPeriod.week), monday);
    });

    test('месяц и переход года', () {
      expect(periodStart(now, RewardLimitPeriod.month), DateTime(2026, 10));
      expect(periodEnd(now, RewardLimitPeriod.month), DateTime(2026, 11));
      expect(periodEnd(DateTime(2026, 12, 31, 23), RewardLimitPeriod.month), DateTime(2027));
    });

    test('неделя через границу месяца', () {
      final d = DateTime(2026, 11, 1, 10); // воскресенье
      expect(periodStart(d, RewardLimitPeriod.week), DateTime(2026, 10, 26));
      expect(purchasesWindowStart(d), DateTime(2026, 10, 26));
      expect(purchasesWindowStart(DateTime(2026, 10, 21)), DateTime(2026, 10, 1));
    });
  });

  group('лимиты', () {
    test('учёт покупок в периоде, границы включительно/исключительно', () {
      final now = DateTime(2026, 10, 21, 12);
      final times = [
        DateTime(2026, 10, 21, 0, 0), // начало дня — в периоде
        DateTime(2026, 10, 20, 23, 59), // вчера
        DateTime(2026, 10, 19, 0, 0), // понедельник — в неделе
        DateTime(2026, 10, 18, 23, 59), // прошлая неделя
        DateTime(2026, 10, 1), // начало месяца
        DateTime(2026, 9, 30, 23, 59),
      ];
      expect(usedInPeriod(times, now, RewardLimitPeriod.day), 1);
      expect(usedInPeriod(times, now, RewardLimitPeriod.week), 3);
      expect(usedInPeriod(times, now, RewardLimitPeriod.month), 5);
    });

    test('лимит исчерпан → дата сброса', () {
      final now = DateTime(2026, 10, 21, 12);
      final c = checkPurchase(
        reward: _games,
        balance: 500,
        purchases: [DateTime(2026, 10, 19, 9), DateTime(2026, 10, 20, 9)],
        now: now,
      );
      expect(c.block, PurchaseBlock.limitReached);
      expect(c.remaining, 0);
      expect(c.resetsAt, DateTime(2026, 10, 26));
    });

    test('новая неделя — лимит обнулён', () {
      final c = checkPurchase(
        reward: _games,
        balance: 500,
        purchases: [DateTime(2026, 10, 19, 9), DateTime(2026, 10, 20, 9)],
        now: DateTime(2026, 10, 26, 0, 1),
      );
      expect(c.allowed, isTrue);
      expect(c.remaining, 2);
    });

    test('без лимита', () {
      const r = Reward(id: 'c', title: 'Шоколадка', price: 50);
      final c = checkPurchase(reward: r, balance: 50, purchases: List.filled(10, DateTime(2026, 10, 21)), now: DateTime(2026, 10, 21, 12));
      expect(c.allowed, isTrue);
      expect(c.remaining, isNull);
      expect(c.resetsAt, isNull);
    });
  });

  group('баланс', () {
    final now = DateTime(2026, 10, 21, 12);

    test('отрицательный — магазин закрыт (важнее лимита и цены)', () {
      final c = checkPurchase(
        reward: _games,
        balance: -1,
        purchases: [DateTime(2026, 10, 19, 9), DateTime(2026, 10, 20, 9)],
        now: now,
      );
      expect(c.block, PurchaseBlock.shopClosed);
      expect(c.missing, 100);
    });

    test('не хватает ◆', () {
      final c = checkPurchase(reward: _games, balance: 70, purchases: const [], now: now);
      expect(c.block, PurchaseBlock.notEnough);
      expect(c.missing, 30);
    });

    test('ровно хватает; ноль — не хватает', () {
      expect(checkPurchase(reward: _games, balance: 100, purchases: const [], now: now).allowed, isTrue);
      expect(checkPurchase(reward: _games, balance: 0, purchases: const [], now: now).block, PurchaseBlock.notEnough);
    });
  });

  test('валидация черновика', () {
    expect(const RewardDraft(title: 'A', price: 10).isValid, isTrue);
    expect(const RewardDraft(title: '  ', price: 10).isValid, isFalse);
    expect(const RewardDraft(title: 'A', price: 0).isValid, isFalse);
    expect(const RewardDraft(title: 'A', price: 100001).isValid, isFalse);
    expect(const RewardDraft(title: 'A', price: 1, limitPeriod: RewardLimitPeriod.day).isValid, isFalse);
    expect(const RewardDraft(title: 'A', price: 1, limitPeriod: RewardLimitPeriod.day, limitCount: 3).isValid, isTrue);
    expect(const RewardDraft(title: 'A', price: 1, limitPeriod: RewardLimitPeriod.day, limitCount: 100).isValid, isFalse);
  });
}
