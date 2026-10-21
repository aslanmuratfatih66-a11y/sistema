// Правила магазина наград (SPEC §6): лимиты частоты по календарным периодам, доступность покупки.
import 'package:flutter/foundation.dart';

import '../../core/db/database.dart';
import '../../core/models/enums.dart';

/// Награда магазина (строка Rewards).
@immutable
class Reward {
  const Reward({
    required this.id,
    required this.title,
    required this.price,
    this.limitCount,
    this.limitPeriod,
    this.active = true,
    this.sortOrder = 0,
  });

  factory Reward.fromRow(RewardRow r) => Reward(
        id: r.id,
        title: r.title,
        price: r.price,
        limitCount: r.limitCount,
        limitPeriod: enumByName(RewardLimitPeriod.values, r.limitPeriod),
        active: r.active,
        sortOrder: r.sortOrder,
      );

  final String id;
  final String title;
  final int price;

  /// Сколько раз за [limitPeriod]; лимит действует, только если заданы оба.
  final int? limitCount;
  final RewardLimitPeriod? limitPeriod;
  final bool active;
  final int sortOrder;

  bool get hasLimit => limitCount != null && limitCount! > 0 && limitPeriod != null;
}

/// Ввод редактора награды.
@immutable
class RewardDraft {
  const RewardDraft({required this.title, required this.price, this.limitCount, this.limitPeriod});

  static const minPrice = 1;
  static const maxPrice = 100000;
  static const minCount = 1;
  static const maxCount = 99;

  final String title;
  final int price;
  final int? limitCount;
  final RewardLimitPeriod? limitPeriod;

  bool get titleValid => title.trim().isNotEmpty;
  bool get priceValid => price >= minPrice && price <= maxPrice;
  bool get limitValid =>
      limitPeriod == null || (limitCount != null && limitCount! >= minCount && limitCount! <= maxCount);
  bool get isValid => titleValid && priceValid && limitValid;
}

/// Начало календарного периода, содержащего [now] (локальное время). Неделя — с понедельника.
DateTime periodStart(DateTime now, RewardLimitPeriod p) => switch (p) {
      RewardLimitPeriod.day => DateTime(now.year, now.month, now.day),
      RewardLimitPeriod.week => DateTime(now.year, now.month, now.day - (now.weekday - DateTime.monday)),
      RewardLimitPeriod.month => DateTime(now.year, now.month),
    };

/// Начало следующего периода (лимит обнуляется).
DateTime periodEnd(DateTime now, RewardLimitPeriod p) {
  final s = periodStart(now, p);
  return switch (p) {
    RewardLimitPeriod.day => DateTime(s.year, s.month, s.day + 1),
    RewardLimitPeriod.week => DateTime(s.year, s.month, s.day + 7),
    RewardLimitPeriod.month => DateTime(s.year, s.month + 1),
  };
}

/// Самое раннее начало периода среди всех видов лимита — с него нужно читать покупки.
DateTime purchasesWindowStart(DateTime now) {
  final w = periodStart(now, RewardLimitPeriod.week);
  final m = periodStart(now, RewardLimitPeriod.month);
  return w.isBefore(m) ? w : m;
}

/// Сколько покупок из [purchases] попадает в текущий период [p] (на момент [now]).
int usedInPeriod(Iterable<DateTime> purchases, DateTime now, RewardLimitPeriod p) {
  final s = periodStart(now, p);
  final e = periodEnd(now, p);
  return purchases.where((t) {
    final lt = t.toLocal();
    return !lt.isBefore(s) && lt.isBefore(e);
  }).length;
}

/// Почему нельзя купить.
enum PurchaseBlock {
  shopClosed, // баланс отрицательный
  notEnough, // не хватает ◆
  limitReached, // лимит частоты исчерпан
}

/// Результат проверки покупки.
@immutable
class PurchaseCheck {
  const PurchaseCheck({this.block, this.remaining, this.resetsAt, this.missing = 0});

  final PurchaseBlock? block;

  /// Осталось покупок в периоде (null — без лимита).
  final int? remaining;

  /// Когда лимит обнулится (null — без лимита).
  final DateTime? resetsAt;

  /// Сколько ◆ не хватает.
  final int missing;

  bool get allowed => block == null;
}

/// Можно ли купить [reward] при балансе [balance]. [purchases] — время покупок этой награды.
/// Порядок причин: магазин закрыт → лимит → нехватка ◆.
PurchaseCheck checkPurchase({
  required Reward reward,
  required int balance,
  required Iterable<DateTime> purchases,
  required DateTime now,
}) {
  int? remaining;
  DateTime? resetsAt;
  final period = reward.limitPeriod;
  if (reward.hasLimit && period != null) {
    final left = reward.limitCount! - usedInPeriod(purchases, now, period);
    remaining = left < 0 ? 0 : left;
    resetsAt = periodEnd(now, period);
  }
  final missing = balance >= reward.price ? 0 : reward.price - (balance < 0 ? 0 : balance);
  final block = balance < 0
      ? PurchaseBlock.shopClosed
      : remaining == 0
          ? PurchaseBlock.limitReached
          : missing > 0
              ? PurchaseBlock.notEnough
              : null;
  return PurchaseCheck(block: block, remaining: remaining, resetsAt: resetsAt, missing: missing);
}
