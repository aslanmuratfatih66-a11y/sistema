// Маркет покупок (SPEC §8.8): клиент /api/v1/market/*, хранилище MarketItems, контекст для подбора,
// пересчёт пометки по бюджету. Поля синхронизации: updatedAt (UTC), deviceId, version+1, удаление мягкое.
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_api.dart';
import '../../core/data/profile_repository.dart';
import '../../core/data/questionnaire_repository.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../domain/finance/finance_api.dart';
import '../plan/data/plan_repository.dart';

/// Категории маркета (значение колонки MarketItems.category и параметр сервера).
const marketCategories = ['skin', 'nutrition', 'equipment', 'other'];

/// Статусы MarketItems.status.
abstract final class MarketStatus {
  static const suggested = 'suggested';
  static const saved = 'saved';
  static const bought = 'bought';
  static const dismissed = 'dismissed';
}

class MarketLink {
  const MarketLink({required this.store, required this.url, required this.search});

  final String store;
  final String url;
  final bool search;

  Map<String, Object?> toJson() => {'store': store, 'url': url, 'search': search};

  static List<MarketLink> decode(String raw) {
    try {
      final v = jsonDecode(raw);
      if (v is! List) return const [];
      return listFrom(v);
    } on FormatException {
      return const [];
    }
  }

  static List<MarketLink> listFrom(Object? v) => [
        if (v is List)
          for (final e in v)
            if (e is Map && e['url'] is String && (e['url'] as String).startsWith('https://'))
              MarketLink(
                store: e['store'] as String? ?? '',
                url: e['url'] as String,
                search: e['search'] == true,
              ),
      ];
}

/// Товар из ответа сервера.
class MarketSuggestion {
  const MarketSuggestion({
    required this.title,
    required this.category,
    required this.reason,
    required this.price,
    required this.currency,
    required this.priceSource,
    required this.priceAt,
    required this.links,
  });

  final String title;
  final String category;
  final String reason;
  final int? price;
  final String currency;
  final String? priceSource;
  final DateTime? priceAt;
  final List<MarketLink> links;

  static MarketSuggestion? fromJson(Object? e) {
    if (e is! Map) return null;
    final title = (e['title'] as String? ?? '').trim();
    if (title.isEmpty) return null;
    final price = (e['price'] as num?)?.round();
    final at = (e['price_at'] as num?)?.toInt();
    final cat = e['category'] as String?;
    return MarketSuggestion(
      title: title,
      category: marketCategories.contains(cat) ? cat! : 'other',
      reason: (e['reason'] as String? ?? '').trim(),
      price: price != null && price > 0 ? price : null,
      currency: e['currency'] as String? ?? 'RUB',
      priceSource: (e['price_source'] as String?)?.trim(),
      priceAt: at != null && at > 0 ? DateTime.fromMillisecondsSinceEpoch(at * 1000, isUtc: true) : null,
      links: MarketLink.listFrom(e['links']),
    );
  }
}

class MarketPrice {
  const MarketPrice({required this.price, required this.currency, this.source, required this.at, this.url});

  final int price;
  final String currency;
  final String? source;
  final DateTime at;
  final String? url;
}

/// Клиент эндпоинтов /api/v1/market/*. Ошибки — [AiException].
class MarketApi {
  const MarketApi(this._gw);

  final AiGateway _gw;

  Future<List<MarketSuggestion>> suggest({
    required String lang,
    required String country,
    String? category,
    required Map<String, Object?> context,
    required List<String> exclude,
  }) async {
    final r = await _gw.json('POST', '/api/v1/market/suggest', body: {
      'lang': lang,
      'country': country,
      'category': category ?? '',
      'context': context,
      'exclude': exclude,
    });
    return [
      for (final e in (r['items'] as List? ?? const []))
        ?MarketSuggestion.fromJson(e),
    ];
  }

  /// null — цена не найдена.
  Future<MarketPrice?> price({required String title, required String country, bool force = false}) async {
    final r = await _gw.json('POST', '/api/v1/market/price', body: {'title': title, 'country': country, 'force': force});
    final p = (r['price'] as num?)?.round() ?? 0;
    if (p <= 0) return null;
    final at = (r['price_at'] as num?)?.toInt() ?? 0;
    final url = r['url'] as String?;
    return MarketPrice(
      price: p,
      currency: r['currency'] as String? ?? 'RUB',
      source: (r['price_source'] as String?)?.trim(),
      at: at > 0 ? DateTime.fromMillisecondsSinceEpoch(at * 1000, isUtc: true) : DateTime.now().toUtc(),
      url: url != null && url.startsWith('https://') ? url : null,
    );
  }
}

final marketApiProvider = Provider<MarketApi>((ref) => MarketApi(ref.watch(aiGatewayProvider)));

class MarketRepository {
  MarketRepository(this._db, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final DateTime Function() _clock;

  Stream<List<MarketItemRow>> watchAll() => (_db.select(_db.marketItems)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();

  Future<List<MarketItemRow>> all() => (_db.select(_db.marketItems)..where((t) => t.deletedAt.isNull())).get();

  Future<MarketItemRow?> byId(String id) =>
      (_db.select(_db.marketItems)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Добавляет новые товары (дубли по названию среди неудалённых пропускаются). Возвращает число добавленных.
  Future<int> addSuggestions(List<MarketSuggestion> list) async {
    final existing = {for (final r in await all()) _norm(r.title)};
    final deviceId = await _db.deviceId();
    final now = _clock();
    var added = 0;
    await _db.transaction(() async {
      for (final s in list) {
        if (!existing.add(_norm(s.title))) continue;
        await _db.into(_db.marketItems).insert(MarketItemsCompanion.insert(
              id: newId(),
              updatedAt: now.toUtc(),
              deviceId: deviceId,
              title: s.title,
              category: s.category,
              reason: Value(s.reason.isEmpty ? null : s.reason),
              price: Value(s.price),
              currency: Value(s.currency),
              priceSource: Value(s.price == null ? null : s.priceSource),
              priceAt: Value(s.price == null ? null : s.priceAt),
              links: Value(jsonEncode([for (final l in s.links) l.toJson()])),
              createdAt: now.toUtc(),
            ));
        added++;
      }
    });
    return added;
  }

  Future<void> _update(MarketItemRow row, MarketItemsCompanion patch) async {
    final deviceId = await _db.deviceId();
    await (_db.update(_db.marketItems)..where((t) => t.id.equals(row.id))).write(patch.copyWith(
      updatedAt: Value(_clock().toUtc()),
      deviceId: Value(deviceId),
      version: Value(row.version + 1),
    ));
  }

  Future<void> setStatus(MarketItemRow row, String status) => _update(row, MarketItemsCompanion(status: Value(status)));

  Future<void> setBudget(MarketItemRow row, MarketBudget? budget) =>
      _update(row, MarketItemsCompanion(budget: Value(budget?.name)));

  Future<void> setPrice(MarketItemRow row, MarketPrice p) {
    var links = MarketLink.decode(row.links);
    final url = p.url;
    if (url != null && !links.any((l) => l.url == url)) {
      final store = links.where((l) => url.contains(_storeHost(l.store))).firstOrNull?.store ?? '';
      links = [MarketLink(store: store, url: url, search: false), ...links.where((l) => !(l.store == store && !l.search))];
    }
    return _update(
        row,
        MarketItemsCompanion(
          price: Value(p.price),
          currency: Value(p.currency),
          priceSource: Value(p.source),
          priceAt: Value(p.at),
          links: Value(jsonEncode([for (final l in links) l.toJson()])),
        ));
  }

  /// «Купил»: фактическая цена, связь с операцией финансов.
  Future<void> markBought(MarketItemRow row, {required int paid, required String currency, String? transactionId}) =>
      _update(
          row,
          MarketItemsCompanion(
            status: const Value(MarketStatus.bought),
            price: Value(paid),
            currency: Value(currency),
            transactionId: Value(transactionId),
          ));

  static String _norm(String s) => s.toLowerCase().split(RegExp(r'\s+')).where((x) => x.isNotEmpty).join(' ');

  static String _storeHost(String store) => switch (store) {
        'ozon' => 'ozon.ru',
        'wildberries' => 'wildberries.ru',
        'yandex_market' => 'market.yandex.ru',
        'pyaterochka' => '5ka.ru',
        'trendyol' => 'trendyol.com',
        _ => '\u0000',
      };
}

final marketRepositoryProvider = Provider<MarketRepository>((ref) => MarketRepository(ref.watch(databaseProvider)));

final marketItemsProvider = StreamProvider<List<MarketItemRow>>((ref) => ref.watch(marketRepositoryProvider).watchAll());

/// Язык и страна пользователя: язык — из профиля (иначе системы), страна tr → TR, иначе RU.
({String lang, String country}) marketRegion(String? profileLocale, String systemLang) {
  final lang = (profileLocale == null || profileLocale.isEmpty) ? systemLang : profileLocale;
  final tr = lang.toLowerCase().startsWith('tr');
  return (lang: tr ? 'tr' : 'ru', country: tr ? 'TR' : 'RU');
}

/// Контекст для подбора: нормы и квесты принятого плана, анкета (кожа, питание, тренировки, финансы), цели.
class MarketContextBuilder {
  MarketContextBuilder(this._ref);

  final Ref _ref;

  static const _maxBytes = 10 << 10;

  Future<Map<String, Object?>> build() async {
    final ctx = <String, Object?>{};
    try {
      final plan = await _ref.read(planRepositoryProvider).latestAccepted();
      if (plan != null) {
        ctx['plan'] = {
          'norms': plan.plan.norms.toJson(),
          'quests': {for (final q in plan.plan.quests) q.key.name}.toList(),
        };
      }
    } catch (_) {}
    final q = _ref.read(questionnaireRepositoryProvider);
    for (final s in [
      QuestionnaireSection.skin,
      QuestionnaireSection.nutrition,
      QuestionnaireSection.training,
      QuestionnaireSection.finance,
    ]) {
      try {
        final m = await q.read(s);
        if (m.isNotEmpty) ctx[s.name] = m;
      } catch (_) {}
    }
    try {
      final db = _ref.read(databaseProvider);
      final goals = await (db.select(db.goals)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm(expression: t.priority)]))
          .get();
      if (goals.isNotEmpty) ctx['goals'] = [for (final g in goals) g.title ?? g.kind];
    } catch (_) {}
    // Ограничение размера: сначала убираем список квестов, затем разделы анкеты по одному.
    String enc() => jsonEncode(ctx, toEncodable: (o) => o.toString());
    if (utf8.encode(enc()).length > _maxBytes) {
      final p = ctx['plan'];
      if (p is Map) p.remove('quests');
    }
    for (final k in ['finance', 'training', 'nutrition', 'skin']) {
      if (utf8.encode(enc()).length <= _maxBytes) break;
      ctx.remove(k);
    }
    return jsonDecode(enc()) as Map<String, Object?>;
  }
}

final marketContextBuilderProvider = Provider<MarketContextBuilder>((ref) => MarketContextBuilder(ref));

/// Профиль (для языка/страны).
final marketProfileLocaleProvider = Provider<String?>((ref) => ref.watch(profileProvider).value?.locale);

/// Пересчёт пометки по бюджету: цена → ₽ по курсу → BudgetAdvisor.judge. Реализации финансов может не быть —
/// тогда пометки не меняются.
class MarketBudgetUpdater {
  MarketBudgetUpdater(this._ref);

  final Ref _ref;

  Future<void> refresh(List<MarketItemRow> items) async {
    BudgetAdvisor advisor;
    try {
      advisor = _ref.read(budgetAdvisorProvider);
    } catch (_) {
      return;
    }
    FxRates? fx;
    if (items.any((r) => r.currency != 'RUB')) {
      try {
        fx = await _ref.read(fxRatesSourceProvider).latest();
      } catch (_) {}
    }
    final repo = _ref.read(marketRepositoryProvider);
    for (final r in items) {
      if (r.status == MarketStatus.bought || r.status == MarketStatus.dismissed) continue;
      final price = r.price;
      if (price == null) continue;
      final rub = r.currency == 'RUB' ? price : fx?.toRub(price, r.currency);
      if (rub == null) continue;
      MarketBudget? b;
      try {
        b = await advisor.judge(rub);
      } catch (_) {
        return;
      }
      if (b?.name != r.budget) await repo.setBudget(r, b);
    }
  }
}

final marketBudgetUpdaterProvider = Provider<MarketBudgetUpdater>((ref) => MarketBudgetUpdater(ref));

/// Запись покупки в финансы. ok=false — финансы недоступны (реализации нет или ошибка); id=null при ok — дубль.
class MarketPurchaseRecorder {
  MarketPurchaseRecorder(this._ref);

  final Ref _ref;

  Future<({bool ok, String? id})> record(MarketItemRow row, {required int paid, required String currency, String? store}) async {
    try {
      final ledger = _ref.read(financeLedgerProvider);
      final id = await ledger.add(TxDraft(
        kind: FinTxKind.expense,
        amount: paid,
        currency: currency,
        occurredAt: DateTime.now(),
        source: FinTxSource.market,
        categoryKey: row.category == 'nutrition' ? 'groceries' : null,
        merchant: store,
        note: row.title,
        externalRef: 'market:${row.id}',
      ));
      return (ok: true, id: id);
    } catch (_) {
      return (ok: false, id: null);
    }
  }
}

final marketPurchaseRecorderProvider = Provider<MarketPurchaseRecorder>((ref) => MarketPurchaseRecorder(ref));
