// Вкладка «Магазин» (SPEC §6): баланс ◆, награды пользователя с лимитами, покупка, архив, история.
// При отрицательном балансе магазин закрыт.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'data/reward_repository.dart';
import 'reward_editor_screen.dart';
import 'shop_providers.dart';
import 'shop_rules.dart';

/// «21.10».
String _dayMonth(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';

/// «21.10 18:05».
String _dateTime(DateTime d) =>
    '${_dayMonth(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// Подпись лимита: «2 раза в неделю» / «Без лимита».
String rewardLimitLabel(AppLocalizations l, Reward r) {
  final count = r.limitCount;
  if (!r.hasLimit || count == null) return l.shpLimitNone;
  return switch (r.limitPeriod!) {
    RewardLimitPeriod.day => l.shpLimitDay(count),
    RewardLimitPeriod.week => l.shpLimitWeek(count),
    RewardLimitPeriod.month => l.shpLimitMonth(count),
  };
}

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  bool _reorder = false;
  bool _buying = false;

  Future<void> _buy(Reward r, int balance) async {
    if (_buying) return;
    final l = AppLocalizations.of(context);
    final confirmed = await showSystemWindow<bool>(
      context,
      window: SystemWindow(
        key: const Key('shp-confirm'),
        kind: SystemWindowKind.notice,
        label: l.shpNoticeLabel,
        title: l.shpConfirmTitle,
        message: l.shpConfirmMessage(r.title, r.price, balance - r.price),
        actions: [
          Builder(
            builder: (c) => SysButton.secondary(label: l.commonCancel, onPressed: () => Navigator.of(c).pop(false)),
          ),
          Builder(
            builder: (c) => SysButton.primary(
              key: const Key('shp-confirm-buy'),
              label: l.shpBuy,
              onPressed: () => Navigator.of(c).pop(true),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _buying = true);
    PurchaseResult result;
    try {
      result = await ref.read(shopControllerProvider).purchase(r);
    } finally {
      if (mounted) setState(() => _buying = false);
    }
    if (!mounted) return;
    final ok = result == PurchaseResult.bought;
    final message = switch (result) {
      PurchaseResult.bought => l.shpBoughtMessage(r.title),
      PurchaseResult.shopClosed => l.shpClosedMessage,
      PurchaseResult.limitReached => l.shpLimitReachedMessage,
      PurchaseResult.notEnough || PurchaseResult.rejected => l.shpFailedMessage,
    };
    await showSystemWindow<void>(
      context,
      window: SystemWindow(
        key: Key(ok ? 'shp-bought' : 'shp-failed'),
        kind: ok ? SystemWindowKind.notice : SystemWindowKind.warning,
        warningTone: PanelTone.danger,
        label: ok ? l.shpNoticeLabel : l.shpWarningLabel,
        message: message,
        actions: [
          Builder(
            builder: (c) => SysButton.primary(label: l.commonDone, onPressed: () => Navigator.of(c).pop()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final player = ref.watch(shopPlayerProvider);
    final rewards = ref.watch(rewardsProvider);
    final archived = ref.watch(archivedRewardsProvider).value ?? const <Reward>[];
    final purchases = ref.watch(limitPurchasesProvider).value ?? const <PurchaseRecord>[];
    final history = ref.watch(purchaseHistoryProvider).value ?? const <PurchaseRecord>[];
    final now = ref.watch(shopClockProvider)();
    final balance = player.value?.diamonds;
    final closed = balance != null && balance < 0;
    final list = rewards.value ?? const <Reward>[];

    return SafeArea(
      bottom: false,
      child: ListView(
        key: const Key('shop-list'),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _BalancePanel(balance: balance),
          if (closed) ...[
            const SizedBox(height: 16),
            SystemWindow(
              key: const Key('shp-closed'),
              kind: SystemWindowKind.warning,
              warningTone: PanelTone.danger,
              animateIn: false,
              label: l.shpWarningLabel,
              message: l.shpClosedMessage,
            ),
            const SizedBox(height: 8),
            Text(l.shpClosedHint, style: SysText.caption, textAlign: TextAlign.center),
          ],
          const SizedBox(height: 16),
          SysPanel(
            title: l.shpRewards,
            tone: PanelTone.gold,
            appearDelay: const Duration(milliseconds: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (rewards.hasValue && list.isEmpty)
                  _EmptyRewards(
                    onExample: (title, price) => openRewardEditor(context, initialTitle: title, initialPrice: price),
                  )
                else
                  for (var i = 0; i < list.length; i++) ...[
                    if (i > 0) const _Divider(),
                    _RewardRow(
                      reward: list[i],
                      check: checkPurchase(
                        reward: list[i],
                        balance: balance ?? 0,
                        purchases: [for (final p in purchases) if (p.rewardId == list[i].id) p.at],
                        now: now,
                      ),
                      loading: balance == null || _buying,
                      reorder: _reorder,
                      isFirst: i == 0,
                      isLast: i == list.length - 1,
                      onBuy: () => _buy(list[i], balance ?? 0),
                      onEdit: () => openRewardEditor(context, reward: list[i]),
                      onMove: (delta) => ref.read(rewardRepositoryProvider).move(list[i].id, delta),
                    ),
                  ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: SysButton.secondary(
                        key: const Key('shp-add'),
                        label: l.shpAdd,
                        icon: SysGlyph.plus,
                        expand: true,
                        onPressed: () => openRewardEditor(context),
                      ),
                    ),
                    if (list.length > 1) ...[
                      const SizedBox(width: 10),
                      SysButton.secondary(
                        key: const Key('shp-reorder'),
                        label: _reorder ? l.commonDone : l.shpReorder,
                        onPressed: () => setState(() => _reorder = !_reorder),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (archived.isNotEmpty) ...[
            const SizedBox(height: 16),
            _ArchivePanel(rewards: archived),
          ],
          const SizedBox(height: 16),
          _HistoryPanel(history: history),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: SysColors.gold.withValues(alpha: .14),
      );
}

/// Баланс ◆ (золотая тема; при минусе — красная).
class _BalancePanel extends StatelessWidget {
  const _BalancePanel({required this.balance});

  final int? balance;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final b = balance;
    final negative = b != null && b < 0;
    final color = negative ? SysColors.dangerLight : SysColors.gold;
    return SysPanel(
      tone: negative ? PanelTone.danger : PanelTone.gold,
      child: Row(
        children: [
          SysIcon(SysGlyph.diamond, size: 26, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(l.shpBalance.toUpperCase(), style: SysText.title.copyWith(color: color))),
          Text(
            b == null ? '—' : '$b ◆',
            key: const Key('shp-balance'),
            style: SysText.monoLarge.copyWith(
              color: color,
              shadows: [Shadow(color: color.withValues(alpha: .6), blurRadius: 10)],
            ),
          ),
        ],
      ),
    );
  }
}

/// Пустое состояние: пояснение и примеры (нажатие заполняет форму, без автосоздания).
class _EmptyRewards extends StatelessWidget {
  const _EmptyRewards({required this.onExample});

  final void Function(String title, int price) onExample;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final examples = [
      (l.shpExampleChocolate, 50),
      (l.shpExampleFastFood, 150),
      (l.shpExampleGames, 100),
      (l.shpExampleFreeEvening, 300),
    ];
    return Column(
      key: const Key('shp-empty'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.shpEmptyTitle.toUpperCase(), style: SysText.title.copyWith(color: SysColors.gold)),
        const SizedBox(height: 6),
        Text(l.shpEmptyText, style: SysText.secondary),
        const SizedBox(height: 12),
        SysChoiceChips<int>(
          choices: [for (var i = 0; i < examples.length; i++) SysChoice(i, examples[i].$1, glyph: SysGlyph.sparkle)],
          selected: const {},
          onChanged: (s) {
            if (s.isEmpty) return;
            final e = examples[s.first];
            onExample(e.$1, e.$2);
          },
        ),
      ],
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({
    required this.reward,
    required this.check,
    required this.loading,
    required this.reorder,
    required this.isFirst,
    required this.isLast,
    required this.onBuy,
    required this.onEdit,
    required this.onMove,
  });

  final Reward reward;
  final PurchaseCheck check;
  final bool loading;
  final bool reorder;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onBuy;
  final VoidCallback onEdit;
  final ValueChanged<int> onMove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final r = reward;
    final parts = <String>[rewardLimitLabel(l, r)];
    final remaining = check.remaining;
    final resets = check.resetsAt;
    if (remaining != null) {
      parts.add(
        remaining == 0 && resets != null ? l.shpLimitReachedUntil(_dayMonth(resets)) : l.shpLimitLeft(remaining),
      );
    }
    final short = check.block == PurchaseBlock.notEnough;
    final canBuy = check.allowed && !loading;

    return InkWell(
      key: Key('shp-reward-${r.id}'),
      onTap: reorder ? null : onEdit,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: SysDims.minTap),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.title, style: SysText.body),
                    const SizedBox(height: 2),
                    Text(parts.join(' · '), style: SysText.caption),
                    if (short)
                      Text(
                        l.shpNotEnough(check.missing),
                        key: Key('shp-short-${r.id}'),
                        style: SysText.caption.copyWith(color: SysColors.dangerLight),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text('${r.price} ◆', style: SysText.mono.copyWith(color: SysColors.gold, fontSize: 15)),
              const SizedBox(width: 10),
              if (reorder) ...[
                _MoveButton(up: true, enabled: !isFirst, onTap: () => onMove(-1)),
                _MoveButton(up: false, enabled: !isLast, onTap: () => onMove(1)),
              ] else
                SysButton.primary(key: Key('shp-buy-${r.id}'), label: l.shpBuy, onPressed: canBuy ? onBuy : null),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoveButton extends StatelessWidget {
  const _MoveButton({required this.up, required this.enabled, required this.onTap});

  final bool up;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return IconButton(
      onPressed: enabled ? onTap : null,
      tooltip: up ? l.shpMoveUp : l.shpMoveDown,
      constraints: const BoxConstraints(minWidth: SysDims.minTap, minHeight: SysDims.minTap),
      icon: SysIcon(
        up ? SysGlyph.arrowUp : SysGlyph.arrowDown,
        size: 20,
        color: enabled ? SysColors.gold : SysColors.textInactive,
      ),
    );
  }
}

class _ArchivePanel extends ConsumerWidget {
  const _ArchivePanel({required this.rewards});

  final List<Reward> rewards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return SysPanel(
      key: const Key('shp-archive'),
      title: l.shpArchive,
      trailing: Text('${rewards.length}'),
      appearDelay: const Duration(milliseconds: 80),
      child: Column(
        children: [
          for (final r in rewards)
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: SysDims.minTap),
              child: Row(
                children: [
                  Expanded(child: Text(r.title, style: SysText.secondary)),
                  Text('${r.price} ◆', style: SysText.monoSmall),
                  const SizedBox(width: 10),
                  SysButton.secondary(
                    key: Key('shp-restore-${r.id}'),
                    label: l.shpRestore,
                    onPressed: () => ref.read(rewardRepositoryProvider).setArchived(r.id, false),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({required this.history});

  final List<PurchaseRecord> history;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SysPanel(
      key: const Key('shp-history'),
      title: l.shpHistory,
      appearDelay: const Duration(milliseconds: 120),
      child: history.isEmpty
          ? SysEmptyState.inline(l.shpHistoryEmpty, glyph: SysGlyph.clock)
          : Column(
              children: [
                for (final p in history)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Text(_dateTime(p.at.toLocal()), style: SysText.monoSmall),
                        const SizedBox(width: 12),
                        Expanded(child: Text(p.title, style: SysText.secondary, overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        Text('−${p.price} ◆', style: SysText.mono.copyWith(color: SysColors.gold)),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
