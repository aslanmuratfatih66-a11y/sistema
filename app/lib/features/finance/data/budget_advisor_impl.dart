// Советник бюджета для маркета: «можно купить / после поступления денег / не по бюджету».
// Свободно = нал и карты − обязательное до конца месяца (подписки, мои долги со сроком, обычные обязательные траты).
import 'dart:math' as math;

import '../../../core/data/questionnaire_repository.dart';
import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../domain/finance/finance_api.dart';
import '../domain/fin_balance.dart';
import '../domain/fin_categories.dart';
import '../domain/fin_math.dart';
import 'finance_repository.dart';

class LocalBudgetAdvisor implements BudgetAdvisor {
  LocalBudgetAdvisor(this.repo, {required this.rates, required this.questionnaire});

  final FinanceRepository repo;
  final FxRatesSource Function() rates;
  final QuestionnaireRepository Function() questionnaire;

  /// [priceRub] — копейки.
  @override
  Future<MarketBudget?> judge(int priceRub, {DateTime? at}) async {
    final f = await forecast(at: at);
    if (f == null) return null;
    if (f.freeNow >= priceRub) return MarketBudget.ok;
    if (f.freeNow + f.expectedIncome >= priceRub) return MarketBudget.afterIncome;
    return MarketBudget.over;
  }

  /// Прогноз до конца месяца; null — нет счетов и операций.
  Future<BudgetForecast?> forecast({DateTime? at}) async {
    final now = at ?? repo.now();
    final accounts = await repo.accounts();
    final txs = await repo.transactions();
    if (accounts.isEmpty && txs.isEmpty) return null;
    FxRates? fx;
    try {
      fx = await rates().latest();
    } catch (_) {}
    final overview = buildOverview(accounts, txs, await repo.crypto(), fx);
    final monthEnd = DateTime(now.year, now.month + 1);

    // Подписки до конца месяца.
    var obligations = 0;
    for (final s in await repo.subscriptions()) {
      if (!s.active) continue;
      var next = s.nextChargeOn;
      var guard = 0;
      while (next.isBefore(monthEnd) && guard++ < 10) {
        if (!next.isBefore(now)) obligations += _rub(fx, s.amount, s.currency);
        next = nextCharge(next, s.period);
      }
    }
    // Мои долги со сроком до конца месяца.
    for (final d in await repo.debts()) {
      if (d.settledAt != null || d.direction != 'owe') continue;
      final due = d.dueOn;
      if (due != null && due.isBefore(monthEnd)) obligations += _rub(fx, d.amount, d.currency);
    }
    // Обязательные траты: средняя за день за 30 дней × оставшиеся дни.
    final cats = await repo.categories();
    final essential = {
      for (final c in cats)
        if (builtinByKey(c.builtinKey)?.essential ?? false) c.id,
    };
    final from = now.subtract(const Duration(days: 30));
    var essentialSpent = 0;
    for (final t in txs) {
      if (t.kind != FinTxKind.expense.name || t.occurredAt.isBefore(from) || t.occurredAt.isAfter(now)) continue;
      if (t.subscriptionId != null) continue;
      if (essential.contains(t.categoryId)) essentialSpent += txRub(t, fx);
    }
    final observed = math.max(1, math.min(30, daysBetween(_firstDay(txs) ?? now, now)));
    final daysLeft = math.max(0, daysBetween(now, monthEnd) - 1);
    obligations += (essentialSpent / observed * daysLeft).round();

    final income = await expectedIncome(now: now, until: monthEnd, rates: fx, txs: txs);
    return BudgetForecast(
      liquid: overview.liquidRub,
      obligations: obligations,
      freeNow: overview.liquidRub - obligations,
      expectedIncome: income.amount,
      nextIncomeOn: income.nextOn,
    );
  }

  /// Самая ранняя операция (список отсортирован по убыванию даты).
  DateTime? _firstDay(List<FinTransactionRow> txs) => txs.isEmpty ? null : txs.last.occurredAt;

  static int _rub(FxRates? fx, int amount, String cur) => cur == 'RUB' ? amount : fx?.toRub(amount, cur) ?? 0;

  /// Ожидаемый доход до [until]: регулярные доходы анкеты (день месяца), иначе — по истории (средний за 90 дней).
  Future<({int amount, DateTime? nextOn})> expectedIncome({
    required DateTime now,
    required DateTime until,
    FxRates? rates,
    List<FinTransactionRow>? txs,
  }) async {
    var sum = 0;
    DateTime? next;
    try {
      final q = await questionnaire().read(QuestionnaireSection.finance);
      final list = q['incomes'];
      if (list is List) {
        for (final e in list) {
          if (e is! Map) continue;
          final amt = e['amount'];
          final day = e['dayOfMonth'];
          if (amt is! num || amt <= 0) continue;
          final cur = (e['currency'] as String?) ?? 'RUB';
          final minor = _rub(rates, toMinor(amt), cur);
          if (day is num) {
            // Ближайшая дата поступления (в этом или следующем месяце).
            var d = DateTime(now.year, now.month, day.toInt().clamp(1, 28));
            if (d.isBefore(dayOf(now))) d = DateTime(now.year, now.month + 1, day.toInt().clamp(1, 28));
            if (next == null || d.isBefore(next)) next = d;
            if (d.isBefore(until.add(const Duration(days: 31)))) sum += minor;
          } else {
            sum += minor;
          }
        }
      }
    } catch (_) {}
    if (sum > 0) return (amount: sum, nextOn: next);
    // По истории: доходы за 90 дней / 3.
    final all = txs ?? await repo.transactions(kind: FinTxKind.income.name);
    final from = now.subtract(const Duration(days: 90));
    var inc = 0;
    DateTime? last;
    for (final t in all) {
      if (t.kind != FinTxKind.income.name) continue;
      final at = t.occurredAt;
      if (at.isBefore(from) || at.isAfter(now)) continue;
      inc += txRub(t, rates);
      if (last == null || at.isAfter(last)) last = at;
    }
    if (inc == 0) return (amount: 0, nextOn: null);
    return (amount: (inc / 3).round(), nextOn: last == null ? null : DateTime(last.year, last.month + 1, last.day));
  }
}

class BudgetForecast {
  const BudgetForecast({
    required this.liquid,
    required this.obligations,
    required this.freeNow,
    required this.expectedIncome,
    this.nextIncomeOn,
  });

  /// Копейки.
  final int liquid;
  final int obligations;
  final int freeNow;
  final int expectedIncome;
  final DateTime? nextIncomeOn;
}
