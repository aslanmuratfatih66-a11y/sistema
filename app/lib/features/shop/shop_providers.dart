// Провайдеры магазина наград.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../domain/quests/quest_api.dart';
import 'data/reward_repository.dart';
import 'shop_rules.dart';

/// Часы магазина (в тестах — фиксированные).
final shopClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final rewardRepositoryProvider = Provider<RewardRepository>(
  (ref) => RewardRepository(ref.watch(databaseProvider), clock: ref.watch(shopClockProvider)),
);

final rewardsProvider = StreamProvider<List<Reward>>((ref) => ref.watch(rewardRepositoryProvider).watchRewards());

final archivedRewardsProvider =
    StreamProvider<List<Reward>>((ref) => ref.watch(rewardRepositoryProvider).watchRewards(archived: true));

/// Покупки за окно лимитов (с начала текущей недели или месяца — что раньше).
final limitPurchasesProvider = StreamProvider<List<PurchaseRecord>>((ref) {
  final now = ref.watch(shopClockProvider)();
  return ref.watch(rewardRepositoryProvider).watchPurchases(since: purchasesWindowStart(now));
});

/// История покупок (последние).
final purchaseHistoryProvider =
    StreamProvider<List<PurchaseRecord>>((ref) => ref.watch(rewardRepositoryProvider).watchPurchases(limit: 50));

/// Снимок игрока (баланс ◆).
final shopPlayerProvider = StreamProvider<PlayerSnapshot>((ref) => ref.watch(questServiceProvider).watchPlayer());

/// Итог попытки покупки.
enum PurchaseResult { bought, shopClosed, notEnough, limitReached, rejected }

/// Покупка: свежая проверка баланса и лимита по журналу, затем QuestService.purchase.
class ShopController {
  ShopController(this._ref);

  final Ref _ref;

  Future<PurchaseResult> purchase(Reward reward) async {
    final now = _ref.read(shopClockProvider)();
    final repo = _ref.read(rewardRepositoryProvider);
    final service = _ref.read(questServiceProvider);
    final player = await service.watchPlayer().first;
    final times = await repo.purchaseTimes(reward.id, since: purchasesWindowStart(now));
    final check = checkPurchase(reward: reward, balance: player.diamonds, purchases: times, now: now);
    switch (check.block) {
      case PurchaseBlock.shopClosed:
        return PurchaseResult.shopClosed;
      case PurchaseBlock.notEnough:
        return PurchaseResult.notEnough;
      case PurchaseBlock.limitReached:
        return PurchaseResult.limitReached;
      case null:
        break;
    }
    final ok = await service.purchase(rewardId: reward.id, title: reward.title, price: reward.price, at: now);
    return ok ? PurchaseResult.bought : PurchaseResult.rejected;
  }
}

final shopControllerProvider = Provider<ShopController>(ShopController.new);
