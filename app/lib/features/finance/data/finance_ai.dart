// ИИ раздела через сервер: предложение лимитов и комментарий к отчёту. Ошибки — AiException (UI объясняет).
import '../../../core/ai/ai_api.dart';
import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../domain/finance/finance_api.dart';
import '../domain/fin_balance.dart';
import '../domain/fin_math.dart';
import 'finance_repository.dart';

class FinanceAi {
  FinanceAi(this.repo, {required this.gateway, required this.rates});

  final FinanceRepository repo;
  final AiGateway Function() gateway;
  final FxRatesSource Function() rates;

  /// Минимум наблюдений для предложения лимитов (SPEC: 2–4 недели).
  static const minObservationDays = 14;

  /// Сколько дней ведётся учёт (от первой операции).
  Future<int> observationDays() async {
    final first = await repo.firstTransaction();
    return first == null ? 0 : daysBetween(first.occurredAt, repo.now());
  }

  Future<FxRates?> _fx() async {
    try {
      return await rates().latest();
    } catch (_) {
      return null;
    }
  }

  /// Запросить лимиты → бюджеты status=proposed (прежние непринятые предложения удаляются). Возвращает их число.
  Future<int> suggestBudgets({required String lang, required String Function(FinCategoryRow) categoryName}) async {
    final days = await observationDays();
    final now = repo.now();
    final fx = await _fx();
    final window = days.clamp(7, 28);
    final from = dayOf(now).subtract(Duration(days: window));
    final txs = await repo.transactions(from: from, to: now.add(const Duration(minutes: 1)));
    final weeks = (window / 7).ceil();
    final cats = {for (final c in await repo.categories()) c.id: c};
    final spent = <String, List<int>>{};
    var income = 0;
    for (final t in txs) {
      final v = txRub(t, fx);
      if (t.kind == FinTxKind.income.name) {
        income += v;
        continue;
      }
      if (t.kind != FinTxKind.expense.name || t.categoryId == null) continue;
      final w = (daysBetween(from, t.occurredAt) ~/ 7).clamp(0, weeks - 1);
      (spent[t.categoryId!] ??= List.filled(weeks, 0))[w] += v;
    }
    final body = {
      'lang': lang,
      'days': days,
      'categories': [
        for (final e in spent.entries)
          if (cats[e.key] case final c?) {'id': c.id, 'name': categoryName(c), 'spent_rub': e.value},
      ],
      // Доход за месяц (оценка по окну наблюдений).
      'income_rub': (income * 30 / window).round(),
    };
    final r = await gateway().json('POST', '/api/v1/finance/budget/suggest', body: body);
    final list = r['budgets'];
    if (list is! List) return 0;
    for (final b in await repo.budgets()) {
      if (b.status == 'proposed') await repo.deleteBudget(b);
    }
    var n = 0;
    for (final e in list) {
      if (e is! Map) continue;
      final catId = e['category_id'];
      final limit = e['limit_rub'];
      if (catId is! String || !cats.containsKey(catId) || limit is! num || limit <= 0) continue;
      final period = e['period'] == 'week' ? 'week' : 'month';
      await repo.saveBudget(repo.newBudget(
        categoryId: catId,
        limitRub: limit.round(),
        period: period,
        status: 'proposed',
        source: 'ai',
        reason: e['reason'] is String ? e['reason'] as String : null,
      ));
      n++;
    }
    return n;
  }

  /// Комментарий ИИ к отчёту.
  Future<String> reportComment({
    required String lang,
    required FinPeriod period,
    required PeriodTotals totals,
    required List<({String name, int spent})> byCategory,
    required List<({String name, int limit, int spent})> budgets,
  }) async {
    final r = await gateway().json('POST', '/api/v1/finance/report/comment', body: {
      'lang': lang,
      'period': period.name,
      'totals': {'income_rub': totals.income, 'expense_rub': totals.expense, 'net_rub': totals.net},
      'by_category': [for (final c in byCategory) {'name': c.name, 'spent_rub': c.spent}],
      'budgets': [for (final b in budgets) {'name': b.name, 'limit_rub': b.limit, 'spent_rub': b.spent}],
    });
    final c = r['comment'];
    if (c is! String || c.trim().isEmpty) throw const AiException(AiFailure.server);
    return c.trim();
  }
}
