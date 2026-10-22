// Финансы (SPEC §8.7): обзор — баланс в ₽, счета, лимиты, скоро списание/долги, последние операции, ввод.
// Ввод других модулей — через go_router (чек, банки, выписка, маркет); подэкраны раздела — Navigator.push.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/data/questionnaire_repository.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'domain/fin_math.dart';
import 'fin_texts.dart';
import 'finance_providers.dart';
import 'screens/accounts_screen.dart';
import 'screens/budgets_screen.dart';
import 'screens/fin_settings_screen.dart';
import 'screens/plans_screens.dart';
import 'screens/reports_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/tx_edit_screen.dart';
import 'widgets/fin_common.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _openSection();
  }

  /// Посев категорий, импорт счетов из анкеты (один раз), подписки, итоги лимитов, курсы.
  Future<void> _openSection() async {
    final repo = ref.read(financeRepositoryProvider);
    try {
      await repo.seedCategories();
      await repo.importFromQuestionnaire(await ref.read(questionnaireRepositoryProvider).read(QuestionnaireSection.finance));
    } catch (e) {
      debugPrint('Finance: $e');
    }
    await ref.read(financeLedgerImplProvider).maintenance();
  }

  Future<void> _refreshRates() async {
    final l = AppLocalizations.of(context);
    setState(() => _refreshing = true);
    final src = ref.read(fxRatesImplProvider);
    await src.latest(refresh: true);
    ref.invalidate(finRatesProvider);
    if (!mounted) return;
    setState(() => _refreshing = false);
    final f = src.lastFailure;
    if (f != null) finSnack(context, finAiFailureText(l, f));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ScheduleSubPage(
      title: l.finTitle,
      onBack: () => Navigator.of(context).maybePop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BalancePanel(refreshing: _refreshing, onRefresh: _refreshRates),
          const SizedBox(height: 14),
          const _InputPanel(),
          const SizedBox(height: 14),
          const _AccountsPanel(),
          const SizedBox(height: 14),
          const _BudgetsPanel(),
          const _SoonPanel(),
          const SizedBox(height: 14),
          const _RecentPanel(),
          const SizedBox(height: 14),
          const _MenuPanel(),
        ],
      ),
    );
  }
}

class _BalancePanel extends ConsumerWidget {
  const _BalancePanel({required this.refreshing, required this.onRefresh});

  final bool refreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final ov = ref.watch(finOverviewProvider);
    final rates = ref.watch(finRatesProvider).value;
    final now = DateTime.now();
    final month = periodRange(FinPeriod.month, now);
    final forecast = ref.watch(finForecastProvider).value;
    return SysPanel(
      key: const Key('fin-panel-balance'),
      title: l.finBalance,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            ov == null ? '—' : formatRub(ov.totalRub),
            key: const Key('fin-total'),
            style: SysText.monoLarge.copyWith(fontSize: 28, color: SysColors.accentLighter),
          ),
          if (ov != null && ov.cryptoRub > 0) FinInfoRow(label: l.finCryptoValue, value: formatRub(ov.cryptoRub)),
          if (forecast != null) ...[
            FinInfoRow(
              label: l.finFreeToMonthEnd,
              value: formatRub(forecast.freeNow),
              valueColor: forecast.freeNow >= 0 ? SysColors.success : SysColors.danger,
            ),
            if (forecast.nextIncomeOn case final d?) FinInfoRow(label: l.finNextIncome, value: formatDay(d)),
          ],
          Consumer(builder: (context, ref, _) {
            final txs = ref.watch(finTransactionsProvider).value ?? const <FinTransactionRow>[];
            var spent = 0;
            var income = 0;
            for (final t in txs) {
              if (t.occurredAt.isBefore(month.start) || !t.occurredAt.isBefore(month.end)) continue;
              final v = t.amountRub ?? rates?.toRub(t.amount, t.currency) ?? 0;
              if (t.kind == FinTxKind.expense.name) spent += v;
              if (t.kind == FinTxKind.income.name) income += v;
            }
            return Column(children: [
              FinInfoRow(label: l.finMonthExpenses, value: formatRub(spent), valueColor: SysColors.dangerLight),
              FinInfoRow(label: l.finMonthIncome, value: formatRub(income), valueColor: SysColors.success),
            ]);
          }),
          if (ov?.missingRates ?? false) Text(l.finMissingRates, style: SysText.caption.copyWith(color: SysColors.gold)),
          Row(children: [
            Expanded(
              child: Text(
                rates == null ? l.finRatesNever : l.finRatesUpdated(formatTxTime(rates.updatedAt.toLocal())),
                style: SysText.caption,
              ),
            ),
            TextButton(
              onPressed: refreshing ? null : onRefresh,
              child: Text(refreshing ? l.finRefreshing : l.finRefreshRates),
            ),
          ]),
        ],
      ),
    );
  }
}

class _InputPanel extends StatelessWidget {
  const _InputPanel();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SysPanel(
      title: l.finInput,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
              child: SysButton.primary(
                key: const Key('fin-add-expense'),
                label: l.finExpense,
                icon: SysGlyph.plus,
                expand: true,
                onPressed: () => TxEditScreen.open(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SysButton.secondary(
                key: const Key('fin-add-income'),
                label: l.finIncome,
                icon: SysGlyph.plus,
                expand: true,
                onPressed: () => TxEditScreen.open(context, kind: FinTxKind.income),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          SysButton.secondary(
            key: const Key('fin-add-transfer'),
            label: l.finTransfer,
            icon: SysGlyph.send,
            expand: true,
            onPressed: () => TxEditScreen.open(context, kind: FinTxKind.transfer),
          ),
          FinActions(children: [
            SysButton.secondary(label: l.finReceiptQr, onPressed: () => context.push('${Routes.financeReceipt}?mode=qr')),
            SysButton.secondary(label: l.finReceiptPhoto, onPressed: () => context.push('${Routes.financeReceipt}?mode=photo')),
            SysButton.secondary(label: l.finBanks, onPressed: () => context.push(Routes.financeBanks)),
            SysButton.secondary(label: l.finStatement, onPressed: () => context.push(Routes.financeStatement)),
            SysButton.secondary(label: l.finMarket, icon: SysGlyph.shop, onPressed: () => context.push(Routes.market)),
          ]),
        ],
      ),
    );
  }
}

class _AccountsPanel extends ConsumerWidget {
  const _AccountsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final ov = ref.watch(finOverviewProvider);
    final views = ov?.accounts ?? const [];
    return SysPanel(
      key: const Key('fin-panel-accounts'),
      title: l.finAccounts,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (views.isEmpty) FinEmpty(l.finNoAccounts),
          for (final v in views)
            FinTile(
              title: accountTitle(l, v.account),
              subtitle: accountKindLabel(l, v.account.kind),
              glyph: accountGlyph(v.account.kind),
              trailing: v.isCrypto ? formatRub(v.balance) : formatMoney(v.balance, v.account.currency),
              trailingColor: v.balance < 0 ? SysColors.dangerLight : SysColors.textPrimary,
              onTap: () => TransactionsScreen.open(context, accountId: v.account.id),
            ),
          FinActions(children: [
            SysButton.secondary(
              key: const Key('fin-open-accounts'),
              label: l.finManageAccounts,
              onPressed: () => AccountsScreen.open(context),
            ),
          ]),
        ],
      ),
    );
  }
}

class _BudgetsPanel extends ConsumerWidget {
  const _BudgetsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final budgets = ref.watch(finBudgetsProvider).value ?? const <FinBudgetRow>[];
    final txs = ref.watch(finTransactionsProvider).value ?? const <FinTransactionRow>[];
    final cats = ref.watch(finCategoryMapProvider);
    final rates = ref.watch(finRatesProvider).value;
    final active = budgets.where((b) => b.status == 'active').toList();
    final proposed = budgets.where((b) => b.status == 'proposed').length;
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SysPanel(
        title: l.finBudgets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (active.isEmpty) FinEmpty(l.finBudgetsEmptyShort),
            for (final b in active)
              FinProgress(
                label: '${categoryName(l, cats[b.categoryId])} · ${periodLabel(l, b.period)}',
                value: budgetSpent(b, txs, rates, now),
                max: b.limitRub,
                valueText: '${formatRub(budgetSpent(b, txs, rates, now))} / ${formatRub(b.limitRub)}',
              ),
            if (proposed > 0) Text(l.finBudgetsProposed(proposed), style: SysText.caption.copyWith(color: SysColors.bossLight)),
            FinActions(children: [
              SysButton.secondary(label: l.finManageBudgets, onPressed: () => BudgetsScreen.open(context)),
            ]),
          ],
        ),
      ),
    );
  }
}

/// «Скоро списание» и долги со сроком в ближайшие 3 дня / просроченные.
class _SoonPanel extends ConsumerWidget {
  const _SoonPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = DateTime.now();
    final subs = (ref.watch(finSubscriptionsProvider).value ?? const <FinSubscriptionRow>[])
        .where((s) => subscriptionSoon(s, now))
        .toList();
    final debts = (ref.watch(finDebtsProvider).value ?? const <FinDebtRow>[])
        .where((d) => d.settledAt == null && d.dueOn != null && daysBetween(now, d.dueOn!) <= 3)
        .toList();
    if (subs.isEmpty && debts.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SysPanel(
        title: l.finSoon,
        tone: PanelTone.gold,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final s in subs)
              FinTile(
                title: s.title,
                subtitle: '${l.finChargeSoon} · ${formatDay(s.nextChargeOn)}',
                glyph: SysGlyph.clock,
                glyphColor: SysColors.gold,
                trailing: formatMoney(s.amount, s.currency),
                onTap: () => SubscriptionsScreen.open(context),
              ),
            for (final d in debts)
              FinTile(
                title: d.person.isEmpty ? (d.direction == 'owe' ? l.finDebtOwe : l.finDebtLent) : d.person,
                subtitle: [
                  d.direction == 'owe' ? l.finDebtOwe : l.finDebtLent,
                  l.finUntil(formatDay(d.dueOn!)),
                  if (dayOf(d.dueOn!).isBefore(dayOf(now))) l.finOverdue,
                ].join(' · '),
                glyph: SysGlyph.warning,
                glyphColor: dayOf(d.dueOn!).isBefore(dayOf(now)) ? SysColors.danger : SysColors.gold,
                trailing: formatMoney(d.amount, d.currency),
                onTap: () => DebtsScreen.open(context),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecentPanel extends ConsumerWidget {
  const _RecentPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final txs = ref.watch(finTransactionsProvider).value ?? const <FinTransactionRow>[];
    final accounts = ref.watch(finAccountMapProvider);
    final cats = ref.watch(finCategoryMapProvider);
    return SysPanel(
      key: const Key('fin-panel-recent'),
      title: l.finRecent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (txs.isEmpty) FinEmpty(l.finNoOperations),
          for (final t in txs.take(6)) TxTile(tx: t, accounts: accounts, categories: cats),
          FinActions(children: [
            SysButton.secondary(
              key: const Key('fin-open-operations'),
              label: l.finAllOperations,
              onPressed: () => TransactionsScreen.open(context),
            ),
          ]),
        ],
      ),
    );
  }
}

class _MenuPanel extends StatelessWidget {
  const _MenuPanel();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SysPanel(
      title: l.finMore,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FinTile(title: l.finReports, glyph: SysGlyph.status, onTap: () => ReportsScreen.open(context)),
          FinTile(title: l.finGoals, glyph: SysGlyph.crown, onTap: () => GoalsScreen.open(context)),
          FinTile(title: l.finSubscriptions, glyph: SysGlyph.clock, onTap: () => SubscriptionsScreen.open(context)),
          FinTile(title: l.finDebts, glyph: SysGlyph.arrowUp, onTap: () => DebtsScreen.open(context)),
          FinTile(title: l.finSettings, glyph: SysGlyph.shield, onTap: () => FinSettingsScreen.open(context)),
        ],
      ),
    );
  }
}
