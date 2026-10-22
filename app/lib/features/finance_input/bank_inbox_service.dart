// Входящие уведомления/SMS банков (SPEC §8.7, Android): нативная очередь → BankInbox → шаблон или ИИ → операция.
// Запуск — [startBankInbox] из main (главный агент); на iOS/web — ничего не делает.
import 'dart:async';
import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/ai/ai_api.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../domain/finance/finance_api.dart';
import 'fni_api.dart';
import 'fni_banks.dart';
import 'fni_channel.dart';
import 'fni_parsers.dart';

/// Удаление операции журнала (для «Исправить» уже созданной из уведомления). Контракт ledger умеет только add —
/// пока null, и исправление созданной операции делается в разделе «Финансы». Переопределяет главный агент/A.
final bankTxRemoverProvider = Provider<Future<void> Function(String transactionId)?>((ref) => null);

final bankChannelProvider = Provider<BankChannel>((ref) => const BankChannel());

final bankInboxServiceProvider = Provider<BankInboxService>((ref) {
  final s = BankInboxService(ref);
  ref.onDispose(s.dispose);
  return s;
});

/// Последние входящие (для экрана источников).
final bankInboxProvider = StreamProvider<List<BankInboxRow>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.bankInbox)
        ..where((t) => t.deletedAt.isNull() & t.channel.isIn(const ['notification', 'sms']))
        ..orderBy([(t) => OrderingTerm.desc(t.receivedAt)])
        ..limit(100))
      .watch();
});

/// Подключение в main: `unawaited(startBankInbox(container));` после инициализации БД.
Future<void> startBankInbox(ProviderContainer container) => container.read(bankInboxServiceProvider).start();

/// Разбор строки BankInbox.parsed.
({BankParsed? parsed, bool review, bool duplicate}) inboxParsed(BankInboxRow row) {
  final s = row.parsed;
  if (s == null || s.isEmpty) return (parsed: null, review: false, duplicate: false);
  try {
    final j = jsonDecode(s) as Map<String, dynamic>;
    return (
      parsed: (j['amount'] as num? ?? 0) > 0 ? BankParsed.fromJson(j) : null,
      review: j['review'] == true,
      duplicate: j['duplicate'] == true,
    );
  } catch (_) {
    return (parsed: null, review: false, duplicate: false);
  }
}

class BankInboxService {
  BankInboxService(this._ref);

  final Ref _ref;
  static const _settingsKey = 'fni.sources';
  static const _uuid = Uuid();
  static const _aiBatch = 30;

  AppLifecycleListener? _life;
  StreamSubscription<BankIncoming>? _sub;
  Timer? _debounce;
  Future<void>? _running;
  bool _again = false;
  bool _started = false;

  AppDatabase get _db => _ref.read(databaseProvider);
  BankChannel get _channel => _ref.read(bankChannelProvider);

  bool get supported => _channel.supported;

  Future<void> start() async {
    if (_started || !supported) return;
    _started = true;
    _life = AppLifecycleListener(onResume: () => unawaited(process()));
    _sub = _channel.events().listen((_) => _schedule());
    try {
      await _push(await loadSources());
    } catch (_) {}
    await process();
  }

  void dispose() {
    _debounce?.cancel();
    _sub?.cancel();
    _life?.dispose();
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), () => unawaited(process()));
  }

  Future<BankSources> loadSources() async => BankSources.decode(await _db.getSetting(_settingsKey));

  Future<void> saveSources(BankSources s) async {
    await _db.setSetting(_settingsKey, s.encode());
    await _push(s);
  }

  Future<void> _push(BankSources s) => _channel.setSources(packages: s.enabledPackages, smsSenders: s.enabledSenders);

  /// SMS из истории за [days] дней (нужно разрешение READ_SMS). Возвращает число найденных.
  Future<int> importSmsHistory({int days = 30}) async {
    final list = await _channel.readSmsHistory(DateTime.now().subtract(Duration(days: days)));
    await _store(list, await loadSources());
    await process();
    return list.length;
  }

  /// Забрать очередь и разобрать ожидающие. Параллельные вызовы склеиваются.
  Future<void> process() {
    final r = _running;
    if (r != null) {
      _again = true;
      return r;
    }
    final f = _process().whenComplete(() {
      _running = null;
      if (_again) {
        _again = false;
        unawaited(process());
      }
    });
    _running = f;
    return f;
  }

  Future<void> _process() async {
    try {
      final sources = await loadSources();
      await _store(await _channel.drain(), sources);
      await _parsePending();
    } catch (_) {
      // Ошибка одной итерации не должна ронять приложение; повтор при следующем возврате.
    }
  }

  static String refOf(String channel, String sender, String body, DateTime receivedAt) {
    final minute = receivedAt.toUtc().millisecondsSinceEpoch ~/ 60000;
    return 'bank:${stableHash('$channel|$sender|${body.trim()}|$minute')}';
  }

  static String refOfRow(BankInboxRow r) => refOf(r.channel, r.sender, r.body, r.receivedAt);

  Future<void> _store(List<BankIncoming> list, BankSources sources) async {
    if (list.isEmpty) return;
    final dev = await _db.deviceId();
    final now = DateTime.now().toUtc();
    await _db.batch((b) {
      for (final m in list) {
        if (m.body.trim().isEmpty) continue;
        final ref = refOf(m.channel, m.sender, m.body, m.receivedAt);
        b.insert(
          _db.bankInbox,
          BankInboxCompanion.insert(
            id: _uuid.v5(Namespace.url.value, 'sistema:$ref'),
            updatedAt: now,
            deviceId: dev,
            channel: m.channel,
            sender: m.sender,
            bank: Value(sources.bankFor(m.channel, m.sender)),
            body: m.body,
            receivedAt: m.receivedAt,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Future<void> _parsePending() async {
    final rows = await (_db.select(_db.bankInbox)
          ..where((t) => t.status.equals('pending') & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.receivedAt)])
          ..limit(200))
        .get();
    final ai = <BankInboxRow>[];
    for (final row in rows) {
      final r = parseBankMessage(row.body, bank: row.bank);
      switch (r.verdict) {
        case BankVerdict.parsed:
          await _create(row, r.parsed!, 'template', review: false);
        case BankVerdict.notTransaction:
          await _update(row, status: 'ignored', parser: 'template');
        case BankVerdict.unknown:
          ai.add(row);
      }
    }
    if (ai.isEmpty) return;
    final api = _ref.read(financeInputApiProvider);
    final lang = PlatformDispatcher.instance.locale.languageCode == 'tr' ? 'tr' : 'ru';
    for (var i = 0; i < ai.length; i += _aiBatch) {
      final chunk = ai.sublist(i, (i + _aiBatch).clamp(0, ai.length));
      final Map<String, BankParsed?> res;
      try {
        res = await api.bankParse(lang, [
          for (final r in chunk) BankAiItem(id: r.id, sender: r.sender, bank: bankByKey(r.bank)?.name, body: r.body),
        ]);
      } on AiException catch (e) {
        if (e.failure == AiFailure.server) {
          for (final r in chunk) {
            await _update(r, status: 'failed', parser: 'ai');
          }
          continue;
        }
        return; // офлайн / не вошли / лимит — оставить pending до следующего раза
      }
      for (final r in chunk) {
        if (!res.containsKey(r.id)) continue;
        final p = res[r.id];
        if (p == null) {
          await _update(r, status: 'ignored', parser: 'ai');
        } else {
          await _create(r, p, 'ai', review: true);
        }
      }
    }
  }

  Future<void> _update(BankInboxRow row,
      {String? status, String? parser, Map<String, Object?>? parsed, Value<String?> transactionId = const Value.absent()}) async {
    final dev = await _db.deviceId();
    await (_db.update(_db.bankInbox)..where((t) => t.id.equals(row.id))).write(BankInboxCompanion(
      status: status == null ? const Value.absent() : Value(status),
      parser: parser == null ? const Value.absent() : Value(parser),
      parsed: parsed == null ? const Value.absent() : Value(jsonEncode(parsed)),
      transactionId: transactionId,
      updatedAt: Value(DateTime.now().toUtc()),
      deviceId: Value(dev),
      version: Value(row.version + 1),
    ));
  }

  /// Дубль того же события из другого канала (уведомление + SMS) в пределах 3 минут.
  Future<bool> _crossDuplicate(BankInboxRow row, BankParsed p) async {
    final from = row.receivedAt.subtract(const Duration(minutes: 3));
    final to = row.receivedAt.add(const Duration(minutes: 3));
    final near = await (_db.select(_db.bankInbox)
          ..where((t) =>
              t.status.equals('parsed') &
              t.id.equals(row.id).not() &
              t.channel.equals(row.channel).not() &
              t.receivedAt.isBetweenValues(from, to)))
        .get();
    for (final n in near) {
      final q = inboxParsed(n).parsed;
      if (q != null && q.amount == p.amount && q.kind == p.kind && q.currency == p.currency) return true;
    }
    return false;
  }

  Future<void> _create(BankInboxRow row, BankParsed p, String parser, {required bool review, String? refSuffix}) async {
    final json = {...p.toJson(), 'review': review};
    if (refSuffix == null && await _crossDuplicate(row, p)) {
      await _update(row, status: 'ignored', parser: parser, parsed: {...json, 'duplicate': true});
      return;
    }
    final String? txId;
    try {
      txId = await _ref.read(financeLedgerProvider).add(TxDraft(
            kind: p.kind,
            amount: p.amount,
            currency: p.currency,
            occurredAt: row.receivedAt,
            source: row.channel == 'sms' ? FinTxSource.sms : FinTxSource.bankNotification,
            merchant: p.merchant,
            cardLast4: p.cardLast4,
            bank: row.bank,
            externalRef: refOfRow(row) + (refSuffix ?? ''),
          ));
    } catch (_) {
      await _update(row, status: 'failed', parser: parser, parsed: json);
      return;
    }
    if (txId == null) {
      await _update(row, status: 'ignored', parser: parser, parsed: {...json, 'duplicate': true});
    } else {
      await _update(row, status: 'parsed', parser: parser, parsed: json, transactionId: Value(txId));
    }
  }

  // ---------- действия пользователя ----------

  /// «Верно» — снять пометку «проверьте».
  Future<void> confirm(BankInboxRow row) async {
    final p = inboxParsed(row).parsed;
    if (p == null) return;
    await _update(row, parsed: {...p.toJson(), 'review': false});
  }

  /// «Не операция». Если операция уже создана — удаляется через [bankTxRemoverProvider] (если он есть).
  Future<bool> ignore(BankInboxRow row) async {
    final tx = row.transactionId;
    if (tx != null) {
      final remove = _ref.read(bankTxRemoverProvider);
      if (remove == null) return false;
      await remove(tx);
    }
    await _update(row, status: 'ignored', transactionId: const Value(null));
    return true;
  }

  /// Ручной разбор/исправление: создаёт операцию с исправленными данными.
  Future<bool> correct(BankInboxRow row, BankParsed p) async {
    final tx = row.transactionId;
    if (tx != null) {
      final remove = _ref.read(bankTxRemoverProvider);
      if (remove == null) return false;
      await remove(tx);
    }
    // Новый ref: старый мог остаться у удалённой операции.
    await _create(row, p, 'manual', review: false, refSuffix: ':m${row.version}');
    return true;
  }
}
