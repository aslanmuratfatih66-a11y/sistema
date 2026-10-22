// Клиент серверных эндпоинтов ввода финансов (server/internal/finance): чек по QR, разбор банков ИИ, выписка.
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_api.dart';
import '../../core/models/enums.dart';
import '../../domain/finance/finance_api.dart';
import 'fni_parsers.dart';

/// Ответ /finance/receipt/qr. status "unavailable" — ФНС не подключена, есть только сумма и дата из QR.
class QrReceiptReply {
  const QrReceiptReply({required this.ok, required this.total, this.occurredAt, this.store, this.items = const []});

  factory QrReceiptReply.fromJson(Map<String, dynamic> j) => QrReceiptReply(
        ok: j['status'] == 'ok',
        total: (j['total'] as num?)?.round() ?? 0,
        occurredAt: DateTime.tryParse('${j['occurred_at'] ?? ''}'),
        store: (j['store'] as String?)?.trim().isEmpty ?? true ? null : (j['store'] as String).trim(),
        items: [
          for (final i in (j['items'] as List? ?? const []))
            if (i is Map<String, dynamic>)
              TxItem(name: '${i['name'] ?? ''}', qty: (i['qty'] as num?)?.toDouble() ?? 1, price: (i['price'] as num?)?.round() ?? 0),
        ],
      );

  final bool ok;
  final int total;
  final DateTime? occurredAt;
  final String? store;
  final List<TxItem> items;
}

/// Строка выписки.
class StatementRow {
  const StatementRow({
    required this.ref,
    required this.occurredAt,
    required this.kind,
    required this.amount,
    required this.currency,
    required this.description,
    this.merchant,
  });

  factory StatementRow.fromJson(Map<String, dynamic> j) => StatementRow(
        ref: '${j['ref'] ?? ''}',
        occurredAt: DateTime.tryParse('${j['occurred_at'] ?? ''}') ?? DateTime.now(),
        kind: FinTxKind.values.asNameMap()['${j['kind']}'] ?? FinTxKind.expense,
        amount: (j['amount'] as num?)?.round() ?? 0,
        currency: '${j['currency'] ?? 'RUB'}',
        description: '${j['description'] ?? ''}',
        merchant: (j['merchant'] as String?)?.trim().isEmpty ?? true ? null : (j['merchant'] as String).trim(),
      );

  final String ref;
  final DateTime occurredAt;
  final FinTxKind kind;
  final int amount;
  final String currency;
  final String description;
  final String? merchant;
}

/// Вход для ИИ-разбора банка.
class BankAiItem {
  const BankAiItem({required this.id, required this.sender, this.bank, required this.body});

  final String id;
  final String sender;
  final String? bank;
  final String body;

  Map<String, Object?> toJson() => {'id': id, 'sender': sender, 'bank': bank ?? '', 'body': body};
}

class FinanceInputApi {
  FinanceInputApi(this._gw);

  final AiGateway _gw;

  Future<QrReceiptReply> receiptQr(String qr) async =>
      QrReceiptReply.fromJson(await _gw.json('POST', '/api/v1/finance/receipt/qr', body: {'qr': qr}));

  /// id → разбор (null — не операция).
  Future<Map<String, BankParsed?>> bankParse(String lang, List<BankAiItem> items) async {
    final r = await _gw.json('POST', '/api/v1/finance/bank/parse', body: {
      'lang': lang,
      'items': [for (final i in items) i.toJson()],
    });
    final out = <String, BankParsed?>{};
    for (final i in (r['items'] as List? ?? const [])) {
      if (i is! Map<String, dynamic>) continue;
      final id = '${i['id']}';
      out[id] = i['ok'] == true && ((i['amount'] as num?) ?? 0) > 0 ? BankParsed.fromJson(i) : null;
    }
    return out;
  }

  Future<List<StatementRow>> statement({
    required String filename,
    required String mime,
    required List<int> bytes,
    required String lang,
  }) async {
    final r = await _gw.json('POST', '/api/v1/finance/statement', body: {
      'filename': filename,
      'mime': mime,
      'data': base64Encode(bytes),
      'lang': lang,
    });
    return [
      for (final row in (r['rows'] as List? ?? const []))
        if (row is Map<String, dynamic>) StatementRow.fromJson(row),
    ].where((r) => r.amount > 0 && r.ref.isNotEmpty).toList();
  }
}

final financeInputApiProvider = Provider<FinanceInputApi>((ref) => FinanceInputApi(ref.watch(aiGatewayProvider)));
