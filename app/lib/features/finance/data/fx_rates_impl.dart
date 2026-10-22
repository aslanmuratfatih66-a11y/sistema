// Курсы валют и крипты: кэш в AppSettings (JSON), обновление с сервера не чаще раза в час, офлайн — последний кэш.
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/ai/ai_api.dart';
import '../../../core/db/database.dart';
import '../../../domain/finance/finance_api.dart';

class CachedFxRatesSource implements FxRatesSource {
  CachedFxRatesSource(this._db, this._gateway, {required this.coins, DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final AiGateway Function() _gateway;

  /// id монет CoinGecko, для которых нужен курс (из CryptoHoldings).
  final Future<Set<String>> Function() coins;
  final DateTime Function() _clock;

  static const _key = 'fin.fx';
  static const refreshEvery = Duration(hours: 1);
  static const _retryAfterFailure = Duration(minutes: 5);

  FxRates? _mem;
  DateTime? _fetchedAt;
  DateTime? _lastAttempt;
  Future<FxRates?>? _inflight;

  /// Последняя ошибка обновления (для подсказки «курсы устарели»), null — последнее обновление удалось.
  AiFailure? lastFailure;

  @override
  Future<FxRates?> latest({bool refresh = false}) async {
    await _loadCache();
    final now = _clock();
    final want = await coins();
    final cached = _mem;
    final missingCoin = cached != null && want.any((c) => !cached.rubPer.containsKey('cg:$c'));
    final stale = _fetchedAt == null || now.difference(_fetchedAt!) >= refreshEvery;
    final recentlyFailed = _lastAttempt != null && now.difference(_lastAttempt!) < _retryAfterFailure;
    if (refresh || ((stale || missingCoin || cached == null) && !recentlyFailed)) {
      return _inflight ??= _fetch(want).whenComplete(() => _inflight = null);
    }
    return cached;
  }

  Future<FxRates?> _fetch(Set<String> want) async {
    _lastAttempt = _clock();
    try {
      final r = await _gateway().json(
        'GET',
        '/api/v1/finance/rates',
        query: want.isEmpty ? null : {'coins': (want.toList()..sort()).join(',')},
      );
      final raw = r['rates'];
      if (raw is! Map) throw const FormatException('rates');
      final rubPer = <String, double>{
        for (final e in raw.entries)
          if (e.value is num && (e.value as num) > 0) '${e.key}': (e.value as num).toDouble(),
      };
      final ts = r['updated_at'];
      final updated = ts is num ? DateTime.fromMillisecondsSinceEpoch(ts.toInt() * 1000) : _clock();
      // Старые курсы монет, которых не прислали, сохраняем (сервер мог не знать монету временно).
      final merged = {...?_mem?.rubPer, ...rubPer};
      _mem = FxRates(rubPer: merged, updatedAt: updated);
      _fetchedAt = _clock();
      lastFailure = null;
      await _db.setSetting(
        _key,
        jsonEncode({
          'rubPer': merged,
          'updatedAt': updated.toUtc().toIso8601String(),
          'fetchedAt': _fetchedAt!.toUtc().toIso8601String(),
        }),
      );
    } on AiException catch (e) {
      lastFailure = e.failure;
    } catch (e) {
      lastFailure = AiFailure.server;
      debugPrint('FxRates: $e');
    }
    return _mem;
  }

  bool _loaded = false;

  Future<void> _loadCache() async {
    if (_loaded) return;
    _loaded = true;
    final raw = await _db.getSetting(_key);
    if (raw == null) return;
    try {
      final j = (jsonDecode(raw) as Map).cast<String, Object?>();
      final m = (j['rubPer'] as Map).cast<String, Object?>();
      _mem = FxRates(
        rubPer: {for (final e in m.entries) if (e.value is num) e.key: (e.value! as num).toDouble()},
        updatedAt: DateTime.tryParse('${j['updatedAt']}')?.toLocal() ?? _clock(),
      );
      _fetchedAt = DateTime.tryParse('${j['fetchedAt']}')?.toLocal();
    } catch (e) {
      debugPrint('FxRates cache: $e');
    }
  }
}

/// Стоимость крипты в копейках по курсу `cg:<coinId>`; null — курса нет.
int? cryptoRub(FxRates? rates, String coinId, double amount) {
  final r = rates?.rubPer['cg:$coinId'];
  return r == null ? null : (amount * r * 100).round();
}

/// Перевод суммы между валютами через рубль; null — курса нет.
int? convertMinor(FxRates? rates, int amount, String from, String to) {
  if (from == to) return amount;
  final rub = from == 'RUB' ? amount : rates?.toRub(amount, from);
  if (rub == null) return null;
  if (to == 'RUB') return rub;
  final r = rates?.rubPer[to];
  return r == null ? null : (rub / r).round();
}
