// Хранилище раздела «Финансы»: CRUD всех таблиц Fin* и CryptoHoldings, посев категорий.
// Запись: updatedAt (UTC), deviceId, version+1; удаление — мягкое (deletedAt). Синхронизация — автоматически.
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../domain/fin_categories.dart';
import '../domain/fin_math.dart';

class FinanceRepository {
  FinanceRepository(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  AppDatabase get db => _db;
  DateTime now() => _clock();

  Future<(DateTime, String)> _meta() async => (_clock().toUtc(), await _db.deviceId());

  // ---------------- Категории ----------------

  bool _seeded = false;

  /// Посев встроенных категорий (идемпотентно: id детерминированные, существующие — даже удалённые — не трогаем).
  Future<void> seedCategories() async {
    if (_seeded) return;
    final (at, dev) = await _meta();
    await _db.batch((b) {
      for (var i = 0; i < builtinCategories.length; i++) {
        final c = builtinCategories[i];
        b.insert(
          _db.finCategories,
          FinCategoriesCompanion.insert(
            id: c.id,
            updatedAt: at,
            deviceId: dev,
            kind: c.kind.name,
            builtinKey: Value(c.key),
            icon: Value(c.glyph.name),
            junkFood: Value(c.junkFood),
            sortIndex: Value(i),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
    _seeded = true;
  }

  SimpleSelectStatement<$FinCategoriesTable, FinCategoryRow> _cats() => _db.select(_db.finCategories)
    ..where((t) => t.deletedAt.isNull())
    ..orderBy([(t) => OrderingTerm.asc(t.sortIndex), (t) => OrderingTerm.asc(t.name)]);

  Stream<List<FinCategoryRow>> watchCategories() => _cats().watch();
  Future<List<FinCategoryRow>> categories() => _cats().get();

  Future<FinCategoryRow?> category(String id) =>
      (_db.select(_db.finCategories)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();

  Future<FinCategoryRow?> categoryByKey(String key) async {
    final rows = await (_db.select(_db.finCategories)
          ..where((t) => t.builtinKey.equals(key) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sortIndex)]))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> saveCategory(FinCategoryRow r) async {
    final (at, dev) = await _meta();
    await _db.into(_db.finCategories).insertOnConflictUpdate(
          r.copyWith(updatedAt: at, deviceId: dev, version: r.version + 1).toCompanion(false),
        );
  }

  Future<void> deleteCategory(FinCategoryRow r) => saveCategory(r.copyWith(deletedAt: Value(_clock().toUtc())));

  FinCategoryRow newCategory(FinTxKind kind, String name, {String? icon, bool junkFood = false}) => FinCategoryRow(
        id: newId(),
        updatedAt: _clock().toUtc(),
        deviceId: '',
        version: 0,
        kind: kind.name,
        name: name,
        icon: icon,
        junkFood: junkFood,
        sortIndex: 1000,
        archived: false,
      );

  // ---------------- Счета ----------------

  SimpleSelectStatement<$FinAccountsTable, FinAccountRow> _accs() => _db.select(_db.finAccounts)
    ..where((t) => t.deletedAt.isNull())
    ..orderBy([(t) => OrderingTerm.asc(t.sortIndex), (t) => OrderingTerm.asc(t.name)]);

  Stream<List<FinAccountRow>> watchAccounts() => _accs().watch();
  Future<List<FinAccountRow>> accounts() => _accs().get();

  Future<FinAccountRow?> account(String id) =>
      (_db.select(_db.finAccounts)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();

  Future<void> saveAccount(FinAccountRow r) async {
    final (at, dev) = await _meta();
    await _db.into(_db.finAccounts).insertOnConflictUpdate(
          r.copyWith(updatedAt: at, deviceId: dev, version: r.version + 1).toCompanion(false),
        );
  }

  Future<void> deleteAccount(FinAccountRow r) => saveAccount(r.copyWith(deletedAt: Value(_clock().toUtc())));

  FinAccountRow newAccount({
    String? id,
    String name = '',
    FinAccountKind kind = FinAccountKind.card,
    String currency = 'RUB',
    String? bank,
    String? cardLast4,
    int openingBalance = 0,
    int sortIndex = 0,
  }) =>
      FinAccountRow(
        id: id ?? newId(),
        updatedAt: _clock().toUtc(),
        deviceId: '',
        version: 0,
        name: name,
        kind: kind.name,
        bank: bank,
        currency: currency,
        openingBalance: openingBalance,
        cardLast4: cardLast4,
        sortIndex: sortIndex,
        archived: false,
      );

  /// Счета из анкеты (раздел finance: accounts, crypto, debts) — один раз, если счетов ещё нет.
  Future<void> importFromQuestionnaire(Map<String, Object?> q) async {
    if (await _db.getSetting('fin.importedQuestionnaire') != null) return;
    final existing = await accounts();
    if (existing.isEmpty) {
      var i = 0;
      for (final a in _list(q['accounts'])) {
        final kind = a['kind'] == 'cash' ? FinAccountKind.cash : FinAccountKind.card;
        final cur = finCurrencies.contains(a['currency']) ? a['currency']! as String : 'RUB';
        final bal = a['balance'];
        final bank = (a['bank'] as String?)?.trim();
        await saveAccount(newAccount(
          id: finSid('acc:q:${a['id'] ?? i}'),
          kind: kind,
          currency: cur,
          name: kind == FinAccountKind.cash || bank == null || bank.isEmpty ? '' : bank,
          openingBalance: bal is num ? toMinor(bal) : 0,
          sortIndex: i++,
        ));
      }
      for (final c in _list(q['crypto'])) {
        final sym = (c['symbol'] as String?)?.trim().toUpperCase() ?? '';
        final amt = c['amount'];
        if (sym.isEmpty || amt is! num) continue;
        await saveCrypto(newCrypto(id: finSid('cr:q:${c['id'] ?? sym}'), symbol: sym, coinId: coinIdGuess(sym), amount: amt.toDouble()));
      }
      for (final d in _list(q['debts'])) {
        final amt = d['amount'];
        if (amt is! num) continue;
        final due = DateTime.tryParse('${d['dueDate'] ?? ''}');
        await saveDebt(newDebt(
          id: finSid('debt:q:${d['id'] ?? d['person']}'),
          person: (d['person'] as String?) ?? '',
          owe: d['direction'] != 'oweMe',
          amount: toMinor(amt),
          currency: finCurrencies.contains(d['currency']) ? d['currency']! as String : 'RUB',
          dueOn: due,
        ));
      }
    }
    await _db.setSetting('fin.importedQuestionnaire', '1');
  }

  static List<Map<String, Object?>> _list(Object? v) =>
      v is List ? [for (final e in v) if (e is Map) e.cast<String, Object?>()] : const [];

  // ---------------- Операции ----------------

  /// Все операции (новые сверху). Объёмы личных финансов небольшие — фильтры считаются в Dart.
  Stream<List<FinTransactionRow>> watchTransactions() => (_db.select(_db.finTransactions)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
      .watch();

  Future<List<FinTransactionRow>> transactions({DateTime? from, DateTime? to, String? kind}) =>
      (_db.select(_db.finTransactions)
            ..where((t) {
              Expression<bool> e = t.deletedAt.isNull();
              if (from != null) e = e & t.occurredAt.isBiggerOrEqualValue(from);
              if (to != null) e = e & t.occurredAt.isSmallerThanValue(to);
              if (kind != null) e = e & t.kind.equals(kind);
              return e;
            })
            ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
          .get();

  /// Есть ли операция с таким ключом дедупа (включая удалённые — удалённое не возвращаем повторным импортом).
  Future<bool> hasExternalRef(String ref) async =>
      (await (_db.select(_db.finTransactions)..where((t) => t.externalRef.equals(ref))).get()).isNotEmpty;

  Future<bool> txExists(String id) async =>
      (await (_db.select(_db.finTransactions)..where((t) => t.id.equals(id))).getSingleOrNull()) != null;

  Future<FinTransactionRow?> firstTransaction() async {
    final rows = await (_db.select(_db.finTransactions)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.occurredAt)])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> saveTransaction(FinTransactionRow r) async {
    final (at, dev) = await _meta();
    await _db.into(_db.finTransactions).insertOnConflictUpdate(
          r.copyWith(updatedAt: at, deviceId: dev, version: r.version + 1).toCompanion(false),
        );
  }

  Future<void> deleteTransaction(FinTransactionRow r) =>
      saveTransaction(r.copyWith(deletedAt: Value(_clock().toUtc())));

  /// Мягкое удаление по id (для других модулей, напр. bankTxRemoverProvider B). Нет такой — ничего не делает.
  Future<void> removeTransaction(String id) async {
    final r = await (_db.select(_db.finTransactions)..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (r != null) await deleteTransaction(r);
  }

  FinTransactionRow newTransaction({
    String? id,
    required FinTxKind kind,
    required String accountId,
    required int amount,
    required String currency,
    required DateTime occurredAt,
    String? toAccountId,
    int? toAmount,
    int? amountRub,
    String? categoryId,
    String? merchant,
    String? note,
    FinTxSource source = FinTxSource.manual,
    String? externalRef,
    String? items,
    String? photoId,
    String? subscriptionId,
    String? debtId,
    String? goalId,
  }) =>
      FinTransactionRow(
        id: id ?? newId(),
        updatedAt: _clock().toUtc(),
        deviceId: '',
        version: 0,
        kind: kind.name,
        accountId: accountId,
        toAccountId: toAccountId,
        amount: amount,
        currency: currency,
        toAmount: toAmount,
        amountRub: amountRub,
        categoryId: categoryId,
        occurredAt: occurredAt,
        merchant: merchant,
        note: note,
        source: source.name,
        externalRef: externalRef,
        items: items,
        photoId: photoId,
        subscriptionId: subscriptionId,
        debtId: debtId,
        goalId: goalId,
      );

  // ---------------- Лимиты ----------------

  SimpleSelectStatement<$FinBudgetsTable, FinBudgetRow> _budgets() => _db.select(_db.finBudgets)
    ..where((t) => t.deletedAt.isNull() & t.status.isNotValue('rejected'))
    ..orderBy([(t) => OrderingTerm.asc(t.startsOn)]);

  Stream<List<FinBudgetRow>> watchBudgets() => _budgets().watch();
  Future<List<FinBudgetRow>> budgets() => _budgets().get();

  Future<void> saveBudget(FinBudgetRow r) async {
    final (at, dev) = await _meta();
    await _db.into(_db.finBudgets).insertOnConflictUpdate(
          r.copyWith(updatedAt: at, deviceId: dev, version: r.version + 1).toCompanion(false),
        );
  }

  Future<void> deleteBudget(FinBudgetRow r) => saveBudget(r.copyWith(deletedAt: Value(_clock().toUtc())));

  FinBudgetRow newBudget({
    String? id,
    required String categoryId,
    required int limitRub,
    String period = 'month',
    String status = 'active',
    String source = 'user',
    String? reason,
    DateTime? startsOn,
    int rewardDiamonds = 10,
    int penaltyDiamonds = 10,
  }) =>
      FinBudgetRow(
        id: id ?? newId(),
        updatedAt: _clock().toUtc(),
        deviceId: '',
        version: 0,
        categoryId: categoryId,
        period: period,
        limitRub: limitRub,
        status: status,
        source: source,
        reason: reason,
        startsOn: startsOn ?? periodRange(finPeriodOf(period), _clock()).start,
        rewardDiamonds: rewardDiamonds,
        penaltyDiamonds: penaltyDiamonds,
      );

  // ---------------- Цели ----------------

  Stream<List<FinGoalRow>> watchGoals() => (_db.select(_db.finGoals)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.title)]))
      .watch();

  Future<void> saveGoal(FinGoalRow r) async {
    final (at, dev) = await _meta();
    await _db.into(_db.finGoals).insertOnConflictUpdate(
          r.copyWith(updatedAt: at, deviceId: dev, version: r.version + 1).toCompanion(false),
        );
  }

  Future<void> deleteGoal(FinGoalRow r) => saveGoal(r.copyWith(deletedAt: Value(_clock().toUtc())));

  FinGoalRow newGoal({String title = '', int target = 0, String currency = 'RUB'}) => FinGoalRow(
        id: newId(),
        updatedAt: _clock().toUtc(),
        deviceId: '',
        version: 0,
        title: title,
        target: target,
        currency: currency,
      );

  // ---------------- Подписки ----------------

  SimpleSelectStatement<$FinSubscriptionsTable, FinSubscriptionRow> _subs() => _db.select(_db.finSubscriptions)
    ..where((t) => t.deletedAt.isNull())
    ..orderBy([(t) => OrderingTerm.asc(t.nextChargeOn)]);

  Stream<List<FinSubscriptionRow>> watchSubscriptions() => _subs().watch();
  Future<List<FinSubscriptionRow>> subscriptions() => _subs().get();

  Future<void> saveSubscription(FinSubscriptionRow r) async {
    final (at, dev) = await _meta();
    await _db.into(_db.finSubscriptions).insertOnConflictUpdate(
          r.copyWith(updatedAt: at, deviceId: dev, version: r.version + 1).toCompanion(false),
        );
  }

  Future<void> deleteSubscription(FinSubscriptionRow r) =>
      saveSubscription(r.copyWith(deletedAt: Value(_clock().toUtc())));

  FinSubscriptionRow newSubscription() {
    final d = dayOf(_clock());
    return FinSubscriptionRow(
      id: newId(),
      updatedAt: _clock().toUtc(),
      deviceId: '',
      version: 0,
      title: '',
      amount: 0,
      currency: 'RUB',
      period: 'month',
      // По умолчанию — через месяц: наступившая дата сразу создаёт операцию.
      nextChargeOn: nextCharge(DateTime(d.year, d.month, d.day, 9), 'month'),
      active: true,
    );
  }

  // ---------------- Долги ----------------

  Stream<List<FinDebtRow>> watchDebts() => (_db.select(_db.finDebts)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.dueOn)]))
      .watch();

  Future<List<FinDebtRow>> debts() => (_db.select(_db.finDebts)..where((t) => t.deletedAt.isNull())).get();

  Future<void> saveDebt(FinDebtRow r) async {
    final (at, dev) = await _meta();
    await _db.into(_db.finDebts).insertOnConflictUpdate(
          r.copyWith(updatedAt: at, deviceId: dev, version: r.version + 1).toCompanion(false),
        );
  }

  Future<void> deleteDebt(FinDebtRow r) => saveDebt(r.copyWith(deletedAt: Value(_clock().toUtc())));

  FinDebtRow newDebt({String? id, String person = '', bool owe = true, int amount = 0, String currency = 'RUB', DateTime? dueOn}) =>
      FinDebtRow(
        id: id ?? newId(),
        updatedAt: _clock().toUtc(),
        deviceId: '',
        version: 0,
        person: person,
        direction: owe ? 'owe' : 'lent',
        amount: amount,
        currency: currency,
        dueOn: dueOn,
      );

  // ---------------- Крипта ----------------

  Stream<List<CryptoHoldingRow>> watchCrypto() => (_db.select(_db.cryptoHoldings)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.symbol)]))
      .watch();

  Future<List<CryptoHoldingRow>> crypto() => (_db.select(_db.cryptoHoldings)..where((t) => t.deletedAt.isNull())).get();

  Future<void> saveCrypto(CryptoHoldingRow r) async {
    final (at, dev) = await _meta();
    await _db.into(_db.cryptoHoldings).insertOnConflictUpdate(
          r.copyWith(updatedAt: at, deviceId: dev, version: r.version + 1).toCompanion(false),
        );
  }

  Future<void> deleteCrypto(CryptoHoldingRow r) => saveCrypto(r.copyWith(deletedAt: Value(_clock().toUtc())));

  CryptoHoldingRow newCrypto({String? id, String symbol = '', String coinId = '', double amount = 0, String? accountId}) =>
      CryptoHoldingRow(
        id: id ?? newId(),
        updatedAt: _clock().toUtc(),
        deviceId: '',
        version: 0,
        symbol: symbol,
        coinId: coinId,
        amount: amount,
        accountId: accountId,
      );

  // ---------------- Настройки раздела ----------------

  Future<FinSettings> settings() async {
    final raw = await _db.getSetting(_settingsKey);
    if (raw == null) return const FinSettings();
    try {
      return FinSettings.fromJson((jsonDecode(raw) as Map).cast<String, Object?>());
    } catch (_) {
      return const FinSettings();
    }
  }

  Future<void> saveSettings(FinSettings s) => _db.setSetting(_settingsKey, jsonEncode(s.toJson()));

  static const _settingsKey = 'fin.settings';
}

/// Настройки «Финансов» (локальные).
class FinSettings {
  const FinSettings({this.junkTax = 5, this.junkTaxEnabled = true});

  /// «Налог на фастфуд», ◆ за покупку.
  final int junkTax;
  final bool junkTaxEnabled;

  FinSettings copyWith({int? junkTax, bool? junkTaxEnabled}) =>
      FinSettings(junkTax: junkTax ?? this.junkTax, junkTaxEnabled: junkTaxEnabled ?? this.junkTaxEnabled);

  Map<String, Object?> toJson() => {'junkTax': junkTax, 'junkTaxEnabled': junkTaxEnabled};

  factory FinSettings.fromJson(Map<String, Object?> j) => FinSettings(
        junkTax: (j['junkTax'] as num?)?.toInt() ?? 5,
        junkTaxEnabled: j['junkTaxEnabled'] as bool? ?? true,
      );
}

/// Популярные монеты: символ → id CoinGecko (для подсказки; иначе id = символ в нижнем регистре).
const knownCoins = <String, String>{
  'BTC': 'bitcoin',
  'ETH': 'ethereum',
  'USDT': 'tether',
  'USDC': 'usd-coin',
  'BNB': 'binancecoin',
  'SOL': 'solana',
  'XRP': 'ripple',
  'TON': 'the-open-network',
  'DOGE': 'dogecoin',
  'ADA': 'cardano',
  'TRX': 'tron',
  'LTC': 'litecoin',
  'DOT': 'polkadot',
  'AVAX': 'avalanche-2',
  'NOT': 'notcoin',
};

String coinIdGuess(String symbol) => knownCoins[symbol.toUpperCase()] ?? symbol.toLowerCase();
