// Журнал операций (FinanceLedger): дедуп, подбор счёта и категории, курс в ₽, «налог на фастфуд», лимиты, подписки.
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../domain/finance/finance_api.dart';
import '../../../domain/quests/quest_api.dart';
import '../domain/fin_categories.dart';
import '../domain/fin_math.dart';
import 'finance_repository.dart';

/// Причины начислений/штрафов ◆ (QuestService.award reasonKey). Подписи — `finReasonLabel`.
abstract final class FinReasons {
  static const junkTax = 'finJunkTax';
  static const budgetOver = 'finBudgetOver';
  static const budgetKept = 'finBudgetKept';
}

class LocalFinanceLedger implements FinanceLedger {
  LocalFinanceLedger(this.repo, {required this.rates, required this.quests});

  final FinanceRepository repo;
  final FxRatesSource Function() rates;

  /// null — движок недоступен (тесты/предпросмотр).
  final QuestService? Function() quests;

  /// «Налог на фастфуд» — только за свежие покупки (импорт старой выписки не штрафует).
  static const junkTaxWindow = Duration(days: 3);

  Future<FxRates?> _rates() async {
    try {
      return await rates().latest();
    } catch (e) {
      debugPrint('FinanceLedger: курсы: $e');
      return null;
    }
  }

  @override
  Future<String?> add(TxDraft d) async {
    if (d.amount <= 0) throw ArgumentError.value(d.amount, 'amount', 'должна быть > 0');
    await repo.seedCategories();
    final ref = d.externalRef;
    final id = ref == null ? newId() : finSid('tx:$ref');
    if (ref != null && (await repo.hasExternalRef(ref) || await repo.txExists(id))) return null;

    final account = await _resolveAccount(d);
    final categoryId = d.kind == FinTxKind.transfer ? null : await _resolveCategory(d);
    final fx = await _rates();
    final row = repo.newTransaction(
      id: id,
      kind: d.kind,
      accountId: account.id,
      amount: d.amount,
      currency: d.currency,
      occurredAt: d.occurredAt,
      amountRub: d.currency == 'RUB' ? d.amount : fx?.toRub(d.amount, d.currency),
      categoryId: categoryId,
      merchant: _clean(d.merchant),
      note: _clean(d.note),
      source: d.source,
      externalRef: ref,
      items: d.items.isEmpty ? null : jsonEncode([for (final i in d.items) i.toJson()]),
      photoId: d.photoId,
    );
    await repo.saveTransaction(row);
    await afterWrite(row);
    return id;
  }

  /// После записи расхода: «налог на фастфуд» и лимиты. Ошибки движка не пробрасываются.
  Future<void> afterWrite(FinTransactionRow tx) async {
    if (tx.kind != FinTxKind.expense.name) return;
    try {
      await _junkTax(tx);
      await checkBudgets(at: tx.occurredAt);
    } catch (e) {
      debugPrint('FinanceLedger: квесты: $e');
    }
  }

  Future<void> _junkTax(FinTransactionRow tx) async {
    final catId = tx.categoryId;
    if (catId == null) return;
    final cat = await repo.category(catId);
    if (cat == null || !cat.junkFood) return;
    final now = repo.now();
    if (now.difference(tx.occurredAt).abs() > junkTaxWindow) return;
    final s = await repo.settings();
    if (!s.junkTaxEnabled || s.junkTax <= 0) return;
    await quests()?.award(diamonds: -s.junkTax, reasonKey: FinReasons.junkTax, ref: 'fin:junk:${tx.id}', at: now);
  }

  /// Перевод между счетами (ручной ввод).
  Future<String> addTransfer({
    required String fromAccountId,
    required String toAccountId,
    required int amount,
    required String currency,
    int? toAmount,
    required DateTime occurredAt,
    String? note,
  }) async {
    final fx = await _rates();
    final row = repo.newTransaction(
      kind: FinTxKind.transfer,
      accountId: fromAccountId,
      toAccountId: toAccountId,
      amount: amount,
      toAmount: toAmount,
      currency: currency,
      occurredAt: occurredAt,
      amountRub: currency == 'RUB' ? amount : fx?.toRub(amount, currency),
      note: _clean(note),
    );
    await repo.saveTransaction(row);
    return row.id;
  }

  /// Изменение операции из UI (пересчёт ₽ и проверки).
  Future<void> update(FinTransactionRow row) async {
    final fx = await _rates();
    final fixed = row.copyWith(
      amountRub: Value(row.currency == 'RUB' ? row.amount : fx?.toRub(row.amount, row.currency)),
    );
    await repo.saveTransaction(fixed);
    await afterWrite(fixed);
  }

  static String? _clean(String? s) {
    final t = s?.trim();
    return t == null || t.isEmpty ? null : t;
  }

  Future<FinAccountRow> _resolveAccount(TxDraft d) async {
    final explicit = d.accountId;
    if (explicit != null) {
      final a = await repo.account(explicit);
      if (a != null) return a;
    }
    final all = (await repo.accounts())
        .where((a) => !a.archived && a.kind != FinAccountKind.crypto.name)
        .toList();
    final last4 = d.cardLast4;
    if (last4 != null && last4.isNotEmpty) {
      for (final a in all) {
        if (a.cardLast4 == last4) return a;
      }
    }
    final bank = d.bank;
    if (bank != null && bank.isNotEmpty) {
      final byBank = all.where((a) => a.bank == bank).toList();
      for (final a in byBank) {
        if (a.currency == d.currency) return a;
      }
      if (byBank.isNotEmpty) return byBank.first;
    }
    for (final a in all) {
      if (a.currency == d.currency) return a;
    }
    // Нет счёта в валюте — создаём «Наличные <валюта>» (имя пустое → подпись из l10n).
    final id = finSid('acc:cash:${d.currency}');
    final existing = await repo.account(id);
    if (existing != null) return existing;
    final created = repo.newAccount(id: id, kind: FinAccountKind.cash, currency: d.currency, sortIndex: 100);
    await repo.saveAccount(created);
    return created;
  }

  Future<String> _resolveCategory(TxDraft d) async {
    final explicit = d.categoryId;
    if (explicit != null && await repo.category(explicit) != null) return explicit;
    final key = d.categoryKey ?? guessCategoryKey(d.merchant, d.kind) ?? guessCategoryKey(d.note, d.kind);
    if (key != null) {
      final c = await repo.categoryByKey(key);
      if (c != null) return c.id;
    }
    final fallback = d.kind == FinTxKind.income ? FinCat.otherIncome : FinCat.other;
    return (await repo.categoryByKey(fallback))?.id ?? builtinCategoryId(fallback);
  }

  // ---------------- Лимиты ----------------

  /// Потрачено (копейки) по категории за [start, end).
  Future<int> spentRub(String categoryId, DateTime start, DateTime end) async {
    final txs = await repo.transactions(from: start, to: end, kind: FinTxKind.expense.name);
    final fx = await _rates();
    var sum = 0;
    for (final t in txs) {
      if (t.categoryId != categoryId) continue;
      sum += t.amountRub ?? fx?.toRub(t.amount, t.currency) ?? 0;
    }
    return sum;
  }

  /// Текущий период: превышение → штраф. Прошедший период: уложился → награда (ref общий — одно из двух).
  Future<void> checkBudgets({DateTime? at}) async {
    final q = quests();
    if (q == null) return;
    final now = repo.now();
    for (final b in await repo.budgets()) {
      if (b.status != 'active') continue;
      final p = finPeriodOf(b.period);
      final cur = periodRange(p, now);
      // Операция в текущем периоде — проверка превышения.
      if (at == null || !at.isBefore(cur.start)) {
        final spent = await spentRub(b.categoryId, cur.start, cur.end);
        if (spent > b.limitRub && b.penaltyDiamonds > 0) {
          await q.award(
            diamonds: -b.penaltyDiamonds,
            reasonKey: FinReasons.budgetOver,
            ref: 'fin:budget:${b.id}:${periodKey(p, cur.start)}',
            at: now,
          );
        }
      }
      // Итоги прошедшего периода (если лимит уже действовал с его начала).
      final prev = shiftPeriod(p, cur.start, -1);
      if (!dayOf(b.startsOn).isAfter(prev.start)) {
        final spent = await spentRub(b.categoryId, prev.start, prev.end);
        final over = spent > b.limitRub;
        final diamonds = over ? -b.penaltyDiamonds : b.rewardDiamonds;
        if (diamonds != 0) {
          await q.award(
            diamonds: diamonds,
            reasonKey: over ? FinReasons.budgetOver : FinReasons.budgetKept,
            ref: 'fin:budget:${b.id}:${periodKey(p, prev.start)}',
            at: now,
          );
        }
      }
    }
  }

  // ---------------- Подписки ----------------

  /// Наступившие списания → операции source=subscription, дата сдвигается вперёд.
  Future<void> processSubscriptions() async {
    final now = repo.now();
    for (final s in await repo.subscriptions()) {
      if (!s.active || s.amount <= 0) continue;
      var next = s.nextChargeOn;
      var guard = 0;
      while (!next.isAfter(now) && guard++ < 24) {
        final ref = 'sub:${s.id}:${isoDay(next)}';
        final id = finSid('tx:$ref');
        if (!await repo.txExists(id)) {
          final cat = s.categoryId ?? (await repo.categoryByKey(FinCat.subscriptions))?.id;
          String accountId;
          final acc = s.accountId == null ? null : await repo.account(s.accountId!);
          if (acc != null) {
            accountId = acc.id;
          } else {
            accountId = (await _resolveAccount(TxDraft(
              kind: FinTxKind.expense,
              amount: s.amount,
              currency: s.currency,
              occurredAt: next,
              source: FinTxSource.subscription,
            )))
                .id;
          }
          final fx = await _rates();
          final row = repo.newTransaction(
            id: id,
            kind: FinTxKind.expense,
            accountId: accountId,
            amount: s.amount,
            currency: s.currency,
            occurredAt: next,
            amountRub: s.currency == 'RUB' ? s.amount : fx?.toRub(s.amount, s.currency),
            categoryId: cat,
            merchant: s.title,
            source: FinTxSource.subscription,
            externalRef: ref,
            subscriptionId: s.id,
          );
          await repo.saveTransaction(row);
        }
        next = nextCharge(next, s.period);
      }
      if (next != s.nextChargeOn) await repo.saveSubscription(s.copyWith(nextChargeOn: next));
    }
  }

  /// При открытии раздела: посев, подписки, итоги лимитов.
  Future<void> maintenance() async {
    try {
      await repo.seedCategories();
      await processSubscriptions();
      await checkBudgets();
    } catch (e) {
      debugPrint('FinanceLedger.maintenance: $e');
    }
  }
}
