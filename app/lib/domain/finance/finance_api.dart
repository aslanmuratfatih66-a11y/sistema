// Финансы (SPEC §8.7) — КОНТРАКТ каркаса этапа 7 (правит главный агент).
// Реализации: A (features/finance) — журнал операций, курсы, советник бюджета; B, C и фото еды пишут операции
// только через [FinanceLedger]. Суммы — целые в минимальных единицах валюты (копейки/куруши/центы).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';

/// Позиция чека.
class TxItem {
  const TxItem({required this.name, this.qty = 1, required this.price});

  final String name;
  final double qty;

  /// Цена за позицию целиком, мин. единицы.
  final int price;

  Map<String, Object?> toJson() => {'name': name, 'qty': qty, 'price': price};
}

/// Черновик операции от любого источника ввода.
class TxDraft {
  const TxDraft({
    required this.kind,
    required this.amount,
    required this.currency,
    required this.occurredAt,
    required this.source,
    this.accountId,
    this.categoryId,
    this.categoryKey,
    this.merchant,
    this.note,
    this.externalRef,
    this.items = const [],
    this.photoId,
    this.cardLast4,
    this.bank,
  });

  final FinTxKind kind;
  final int amount;
  final String currency;
  final DateTime occurredAt;
  final FinTxSource source;

  /// null — счёт подберёт журнал (по [cardLast4]/[bank], иначе счёт по умолчанию для валюты).
  final String? accountId;

  /// Явная категория или встроенный ключ (groceries, cafe, fastfood, transport…); null — угадает журнал по мерчанту.
  final String? categoryId;
  final String? categoryKey;
  final String? merchant;
  final String? note;

  /// Ключ дедупа: повтор с тем же ref не создаёт вторую операцию.
  final String? externalRef;
  final List<TxItem> items;
  final String? photoId;
  final String? cardLast4;
  final String? bank;
}

abstract interface class FinanceLedger {
  /// Создаёт операцию (курс в ₽ на дату, «налог на фастфуд», проверка лимитов). null — дубль по externalRef.
  Future<String?> add(TxDraft draft);
}

/// Курсы: ₽ за 1 единицу. Ключи — ISO-коды (USD, EUR, TRY) и крипта как `cg:<coinId>`.
class FxRates {
  const FxRates({required this.rubPer, required this.updatedAt});

  final Map<String, double> rubPer;
  final DateTime updatedAt;

  /// Перевод суммы (мин. единицы фиатной валюты) в копейки; null — курса нет. Крипта — `amount * rubPer['cg:id']`.
  int? toRub(int amount, String currency) {
    if (currency == 'RUB') return amount;
    final r = rubPer[currency];
    return r == null ? null : (amount * r).round();
  }
}

abstract interface class FxRatesSource {
  /// Последние известные курсы (кэш, обновление с сервера GET /api/v1/finance/rates). null — ещё ни разу не было.
  Future<FxRates?> latest({bool refresh = false});
}

/// Пометка «можно купить / после поступления денег / не по бюджету» для маркета (C).
abstract interface class BudgetAdvisor {
  /// [priceRub] — в копейках. null — данных мало (нет счетов/операций).
  Future<MarketBudget?> judge(int priceRub, {DateTime? at});
}

final financeLedgerProvider = Provider<FinanceLedger>((ref) => throw UnimplementedError('financeLedgerProvider (A)'));
final fxRatesSourceProvider = Provider<FxRatesSource>((ref) => throw UnimplementedError('fxRatesSourceProvider (A)'));
final budgetAdvisorProvider = Provider<BudgetAdvisor>((ref) => throw UnimplementedError('budgetAdvisorProvider (A)'));
