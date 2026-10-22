// Остатки счетов и итоги периодов (чистые функции).
import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../domain/finance/finance_api.dart';
import '../data/fx_rates_impl.dart';

/// Остаток счёта в его валюте (мин. единицы). Крипто-счёт — 0 (его стоимость — в монетах).
int accountBalance(FinAccountRow a, Iterable<FinTransactionRow> txs, FxRates? rates) {
  var bal = a.openingBalance;
  for (final t in txs) {
    if (t.accountId == a.id) {
      final amt = convertMinor(rates, t.amount, t.currency, a.currency) ?? t.amount;
      bal += t.kind == FinTxKind.income.name ? amt : -amt;
    } else if (t.toAccountId == a.id && t.kind == FinTxKind.transfer.name) {
      bal += t.toAmount ?? convertMinor(rates, t.amount, t.currency, a.currency) ?? t.amount;
    }
  }
  return bal;
}

class AccountView {
  const AccountView(this.account, this.balance, this.balanceRub);
  final FinAccountRow account;

  /// В валюте счёта (для крипто-счёта — стоимость монет в копейках).
  final int balance;

  /// null — нет курса.
  final int? balanceRub;

  bool get isCrypto => account.kind == FinAccountKind.crypto.name;
}

class FinOverview {
  const FinOverview({
    required this.accounts,
    required this.cryptoRub,
    required this.totalRub,
    required this.liquidRub,
    required this.missingRates,
  });

  final List<AccountView> accounts;

  /// Стоимость всей крипты в копейках (без монет без курса).
  final int cryptoRub;
  final int totalRub;

  /// Нал и карты (без вкладов и крипты) — для советника бюджета.
  final int liquidRub;

  /// Есть суммы, которые не удалось перевести в ₽.
  final bool missingRates;
}

FinOverview buildOverview(
  List<FinAccountRow> accounts,
  List<FinTransactionRow> txs,
  List<CryptoHoldingRow> holdings,
  FxRates? rates,
) {
  var missing = false;
  var crypto = 0;
  final byAccount = <String, int>{};
  for (final h in holdings) {
    final v = cryptoRub(rates, h.coinId, h.amount);
    if (v == null) {
      missing = true;
      continue;
    }
    crypto += v;
    final acc = h.accountId;
    if (acc != null) byAccount[acc] = (byAccount[acc] ?? 0) + v;
  }
  final views = <AccountView>[];
  var total = crypto;
  var liquid = 0;
  for (final a in accounts) {
    if (a.archived) continue;
    if (a.kind == FinAccountKind.crypto.name) {
      final v = byAccount[a.id] ?? 0;
      views.add(AccountView(a, v, v));
      continue;
    }
    final bal = accountBalance(a, txs, rates);
    final rub = a.currency == 'RUB' ? bal : rates?.toRub(bal, a.currency);
    if (rub == null) {
      missing = true;
    } else {
      total += rub;
      if (a.kind != FinAccountKind.deposit.name) liquid += rub;
    }
    views.add(AccountView(a, bal, rub));
  }
  return FinOverview(accounts: views, cryptoRub: crypto, totalRub: total, liquidRub: liquid, missingRates: missing);
}

/// Сумма операции в копейках (сохранённая или по текущему курсу).
int txRub(FinTransactionRow t, FxRates? rates) => t.amountRub ?? rates?.toRub(t.amount, t.currency) ?? 0;

class PeriodTotals {
  PeriodTotals();
  int income = 0;
  int expense = 0;
  final Map<String?, int> byCategory = {};
  int get net => income - expense;
}

PeriodTotals totalsFor(Iterable<FinTransactionRow> txs, DateTime start, DateTime end, FxRates? rates) {
  final r = PeriodTotals();
  for (final t in txs) {
    if (t.occurredAt.isBefore(start) || !t.occurredAt.isBefore(end)) continue;
    final v = txRub(t, rates);
    if (t.kind == FinTxKind.income.name) {
      r.income += v;
    } else if (t.kind == FinTxKind.expense.name) {
      r.expense += v;
      r.byCategory[t.categoryId] = (r.byCategory[t.categoryId] ?? 0) + v;
    }
  }
  return r;
}
