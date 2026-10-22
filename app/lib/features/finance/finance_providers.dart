// Провайдеры раздела «Финансы» и реализации контрактов domain/finance (подключаются в main через overrides).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_api.dart';
import '../../core/data/questionnaire_repository.dart';
import '../../core/db/database.dart';
import '../../domain/finance/finance_api.dart';
import '../../domain/quests/quest_api.dart';
import 'data/budget_advisor_impl.dart';
import 'data/finance_ai.dart';
import 'data/finance_ledger_impl.dart';
import 'data/finance_repository.dart';
import 'data/fx_rates_impl.dart';
import 'domain/fin_balance.dart';

final financeRepositoryProvider = Provider<FinanceRepository>((ref) => FinanceRepository(ref.watch(databaseProvider)));

/// Реализация [FxRatesSource] (main: `fxRatesSourceProvider.overrideWith((ref) => ref.watch(fxRatesImplProvider))`).
final fxRatesImplProvider = Provider<CachedFxRatesSource>((ref) {
  final repo = ref.watch(financeRepositoryProvider);
  return CachedFxRatesSource(
    ref.watch(databaseProvider),
    () => ref.read(aiGatewayProvider),
    coins: () async => {for (final h in await repo.crypto()) if (h.coinId.isNotEmpty) h.coinId},
  );
});

QuestService? _quests(Ref ref) {
  try {
    return ref.read(questServiceProvider);
  } catch (_) {
    return null;
  }
}

/// Реализация [FinanceLedger] (main: `financeLedgerProvider.overrideWith((ref) => ref.watch(financeLedgerImplProvider))`).
final financeLedgerImplProvider = Provider<LocalFinanceLedger>((ref) => LocalFinanceLedger(
      ref.watch(financeRepositoryProvider),
      rates: () => ref.read(fxRatesImplProvider),
      quests: () => _quests(ref),
    ));

/// Реализация [BudgetAdvisor] (main: `budgetAdvisorProvider.overrideWith((ref) => ref.watch(budgetAdvisorImplProvider))`).
final budgetAdvisorImplProvider = Provider<LocalBudgetAdvisor>((ref) => LocalBudgetAdvisor(
      ref.watch(financeRepositoryProvider),
      rates: () => ref.read(fxRatesImplProvider),
      questionnaire: () => ref.read(questionnaireRepositoryProvider),
    ));

final financeAiProvider = Provider<FinanceAi>((ref) => FinanceAi(
      ref.watch(financeRepositoryProvider),
      gateway: () => ref.read(aiGatewayProvider),
      rates: () => ref.read(fxRatesImplProvider),
    ));

/// Готовые overrides для main.
final financeOverrides = [
  financeLedgerProvider.overrideWith((ref) => ref.watch(financeLedgerImplProvider)),
  fxRatesSourceProvider.overrideWith((ref) => ref.watch(fxRatesImplProvider)),
  budgetAdvisorProvider.overrideWith((ref) => ref.watch(budgetAdvisorImplProvider)),
];

// ---- Потоки ----

final finAccountsProvider = StreamProvider<List<FinAccountRow>>((ref) => ref.watch(financeRepositoryProvider).watchAccounts());
final finCategoriesProvider =
    StreamProvider<List<FinCategoryRow>>((ref) => ref.watch(financeRepositoryProvider).watchCategories());
final finTransactionsProvider =
    StreamProvider<List<FinTransactionRow>>((ref) => ref.watch(financeRepositoryProvider).watchTransactions());
final finBudgetsProvider = StreamProvider<List<FinBudgetRow>>((ref) => ref.watch(financeRepositoryProvider).watchBudgets());
final finGoalsProvider = StreamProvider<List<FinGoalRow>>((ref) => ref.watch(financeRepositoryProvider).watchGoals());
final finSubscriptionsProvider =
    StreamProvider<List<FinSubscriptionRow>>((ref) => ref.watch(financeRepositoryProvider).watchSubscriptions());
final finDebtsProvider = StreamProvider<List<FinDebtRow>>((ref) => ref.watch(financeRepositoryProvider).watchDebts());
final finCryptoProvider = StreamProvider<List<CryptoHoldingRow>>((ref) => ref.watch(financeRepositoryProvider).watchCrypto());

/// Курсы (кэш; обновление — `ref.invalidate(finRatesProvider)` после `latest(refresh: true)`).
final finRatesProvider = FutureProvider<FxRates?>((ref) async {
  ref.watch(finCryptoProvider); // новая монета → дозапрос курса
  return ref.read(fxRatesImplProvider).latest();
});

final finOverviewProvider = Provider<FinOverview?>((ref) {
  final accounts = ref.watch(finAccountsProvider).value;
  final txs = ref.watch(finTransactionsProvider).value;
  final crypto = ref.watch(finCryptoProvider).value;
  if (accounts == null || txs == null || crypto == null) return null;
  return buildOverview(accounts, txs, crypto, ref.watch(finRatesProvider).value);
});

final finCategoryMapProvider = Provider<Map<String, FinCategoryRow>>(
  (ref) => {for (final c in ref.watch(finCategoriesProvider).value ?? const <FinCategoryRow>[]) c.id: c},
);

final finAccountMapProvider = Provider<Map<String, FinAccountRow>>(
  (ref) => {for (final a in ref.watch(finAccountsProvider).value ?? const <FinAccountRow>[]) a.id: a},
);

final finSettingsProvider = FutureProvider<FinSettings>((ref) => ref.watch(financeRepositoryProvider).settings());

final finForecastProvider = FutureProvider<BudgetForecast?>((ref) {
  ref.watch(finTransactionsProvider);
  ref.watch(finAccountsProvider);
  return ref.read(budgetAdvisorImplProvider).forecast();
});
