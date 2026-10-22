// Финансы — ввод (SPEC §8.7): разбор QR чека ФНС, сумм и шаблоны уведомлений/SMS известных банков.
// Чистые функции без зависимостей от Flutter.
import '../../core/models/enums.dart';

// ---------- QR чека ФНС ----------

/// Поля QR кассового чека: «t=20240101T1230&s=123.45&fn=…&i=…&fp=…&n=1».
class FnsQr {
  const FnsQr({required this.at, required this.total, required this.fn, required this.fd, required this.fp, this.n});

  final DateTime at;

  /// Сумма, копейки.
  final int total;
  final String fn;
  final String fd;
  final String fp;

  /// Тип: 1 приход, 2 возврат прихода, 3 расход, 4 возврат расхода.
  final int? n;

  /// Ключ дедупа операции.
  String get ref => 'fns:$fn:$fd:$fp';

  /// Возврат покупки — деньги вернулись.
  FinTxKind get kind => n == 2 ? FinTxKind.income : FinTxKind.expense;

  static final _digits = RegExp(r'^\d{1,20}$');
  static final _t = RegExp(r'^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})?$');

  /// null — строка не похожа на QR чека.
  static FnsQr? tryParse(String raw) {
    final s = raw.trim();
    if (!s.contains('fn=') || !s.contains('s=')) return null;
    final Map<String, String> q;
    try {
      q = Uri.splitQueryString(s);
    } catch (_) {
      return null;
    }
    final m = _t.firstMatch(q['t'] ?? '');
    final sum = double.tryParse((q['s'] ?? '').replaceAll(',', '.'));
    final fn = q['fn'] ?? '', fd = q['i'] ?? '', fp = q['fp'] ?? '';
    if (m == null || sum == null || sum <= 0 || sum > 1e9) return null;
    if (!_digits.hasMatch(fn) || !_digits.hasMatch(fd) || !_digits.hasMatch(fp)) return null;
    final at = DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!), int.parse(m[4]!), int.parse(m[5]!),
        m[6] == null ? 0 : int.parse(m[6]!));
    return FnsQr(at: at, total: (sum * 100).round(), fn: fn, fd: fd, fp: fp, n: int.tryParse(q['n'] ?? ''));
  }
}

// ---------- суммы ----------

/// «-1 234,56», «1.234,56», «1,234.56» → число; null — не число.
double? parseAmount(String s) {
  final b = StringBuffer();
  var neg = false;
  for (final r in s.trim().runes) {
    final c = String.fromCharCode(r);
    if ('0123456789,.'.contains(c)) {
      b.write(c);
    } else if ((c == '-' || c == '−' || c == '–') && b.isEmpty) {
      neg = true;
    }
  }
  var n = b.toString();
  if (n.isEmpty) return null;
  final lc = n.lastIndexOf(','), ld = n.lastIndexOf('.');
  if (lc >= 0 && ld >= 0) {
    n = lc > ld ? '${n.substring(0, lc).replaceAll('.', '')}.${n.substring(lc + 1)}' : n.replaceAll(',', '');
  } else if (lc >= 0) {
    n = ','.allMatches(n).length > 1 ? n.replaceAll(',', '') : n.replaceFirst(',', '.');
  } else if ('.'.allMatches(n).length > 1) {
    n = n.replaceAll('.', '');
  }
  final v = double.tryParse(n);
  if (v == null || v.isNaN || v.isInfinite) return null;
  return neg ? -v : v;
}

/// Основные единицы → минимальные.
int toMinor(double v) => (v.abs() * 100).round();

/// Валюта по символу/коду.
String? currencyOf(String token) => switch (token.toLowerCase().replaceAll('.', '')) {
      '₽' || 'р' || 'руб' || 'рубль' || 'рубля' || 'рублей' || 'rub' || 'rur' => 'RUB',
      'tl' || 'try' || '₺' => 'TRY',
      r'$' || 'usd' => 'USD',
      '€' || 'eur' => 'EUR',
      _ => null,
    };

/// Короткий стабильный хэш (FNV-1a 32 ×2) — для ключей дедупа.
String stableHash(String s) {
  var h1 = 0x811c9dc5, h2 = 0x01000193 ^ 0x5bd1e995;
  for (final c in s.codeUnits) {
    h1 = ((h1 ^ c) * 0x01000193) & 0xffffffff;
    h2 = ((h2 ^ c) * 0x01000193 + 0x9e37) & 0xffffffff;
  }
  return h1.toRadixString(16).padLeft(8, '0') + h2.toRadixString(16).padLeft(8, '0');
}

// ---------- уведомления и SMS банков ----------

/// Разобранное сообщение банка.
class BankParsed {
  const BankParsed({
    required this.kind,
    required this.amount,
    required this.currency,
    this.merchant,
    this.cardLast4,
    this.occurredAt,
  });

  factory BankParsed.fromJson(Map<String, dynamic> j) => BankParsed(
        kind: FinTxKind.values.asNameMap()[j['kind']] ?? FinTxKind.expense,
        amount: (j['amount'] as num?)?.round() ?? 0,
        currency: (j['currency'] as String?) ?? 'RUB',
        merchant: _nz(j['merchant']),
        cardLast4: _nz(j['card_last4']),
        occurredAt: DateTime.tryParse((j['occurred_at'] as String?) ?? ''),
      );

  final FinTxKind kind;

  /// Мин. единицы.
  final int amount;
  final String currency;
  final String? merchant;
  final String? cardLast4;
  final DateTime? occurredAt;

  Map<String, Object?> toJson() => {
        'kind': kind.name,
        'amount': amount,
        'currency': currency,
        'merchant': merchant,
        'card_last4': cardLast4,
        if (occurredAt != null) 'occurred_at': occurredAt!.toIso8601String(),
      };

  BankParsed copyWith({FinTxKind? kind, int? amount, String? currency, String? merchant}) => BankParsed(
        kind: kind ?? this.kind,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        merchant: merchant ?? this.merchant,
        cardLast4: cardLast4,
        occurredAt: occurredAt,
      );
}

String? _nz(Object? v) => v is String && v.trim().isNotEmpty ? v.trim() : null;

enum BankVerdict {
  /// Шаблон уверенно разобрал операцию.
  parsed,

  /// Точно не операция (код, реклама, отказ, нет суммы).
  notTransaction,

  /// Не понятно — на ИИ.
  unknown,
}

class BankTemplateResult {
  const BankTemplateResult(this.verdict, [this.parsed]);

  final BankVerdict verdict;
  final BankParsed? parsed;
}

final _skip = RegExp(
  r'(код\b|код:|code|şifre|sifre|парол|parola|otp|отклон|недостаточно|отказ|не выполнен|неуспеш|reddedil|başarısız|basarisiz|onay kodu|вход в|giriş)',
  caseSensitive: false,
  unicode: true,
);
final _income = RegExp(
  r'(зачислен|пополнен|поступлен|перевод от|входящий перевод|получен перевод|вам перевел|возврат|кэшбэк|cashback|gelen|yatırıldı|yatirildi|yatan|iade|maaş)',
  caseSensitive: false,
  unicode: true,
);
final _transfer = RegExp(r'(между своими|между счетами|hesaplar arası|kendi hesab)', caseSensitive: false, unicode: true);
final _expense = RegExp(
  r'(покупк|оплат|списан|снят|выдача|перевод|платеж|платёж|harcama|ödeme|odeme|alışveriş|alisveris|çekim|cekim|çekildi|gönderil|pos\b)',
  caseSensitive: false,
  unicode: true,
);
const _num = r'\d{1,3}(?:[   .,]\d{3})*(?:[.,]\d{1,2})?|\d+(?:[.,]\d{1,2})?';
const _cur = r'₽|рублей|рубля|рубль|руб\.?|р\.?|RUB|RUR|TL|TRY|₺|USD|\$|EUR|€';
final _amountAfter = RegExp('($_num)\\s?($_cur)(?![A-Za-zА-Яа-я])', caseSensitive: false, unicode: true);
final _amountBefore = RegExp('($_cur)\\s?($_num)', caseSensitive: false, unicode: true);
final _balance = RegExp(r'(баланс|остаток|доступно|bakiye|kullanılabilir|kullanilabilir|limit)', caseSensitive: false, unicode: true);
final _card = RegExp(
  r'(?:[*•]|x{2,}|карт\p{L}*\s*\*?|сч[её]т\p{L}*\s*\*?|kart\p{L}*\s*\*?|mir|visa|ecmc|mc|maestro)[\s\-*•]*(\d{4})(?!\d)',
  caseSensitive: false,
  unicode: true,
);
final _cardTr = RegExp(r'(\d{4})\s+ile\s+biten', caseSensitive: false, unicode: true);
final _merchantTr = RegExp(r'([^\s,.;:]+(?:\s+[^\s,.;:]+){0,3})\s+i[şs]yerinden', caseSensitive: false, unicode: true);
final _date = RegExp(r'(\d{2})[./](\d{2})[./](\d{2,4})(?:\s+(\d{1,2}):(\d{2}))?');
final _time = RegExp(r'\b\d{1,2}:\d{2}(?::\d{2})?\b');

/// Шаблонный разбор уведомления/SMS (русские и турецкие банки).
BankTemplateResult parseBankMessage(String body, {String? bank}) {
  final text = body.replaceAll('\n', ' ');
  if (_skip.hasMatch(text)) return const BankTemplateResult(BankVerdict.notTransaction);

  // Сумма: первая, перед которой (≤20 символов) нет «Баланс/Остаток/Bakiye».
  ({double v, String cur, int start, int end})? amount;
  final cands = <({double v, String cur, int start, int end})>[];
  for (final m in _amountAfter.allMatches(text)) {
    final v = parseAmount(m[1]!);
    final c = currencyOf(m[2]!);
    if (v != null && c != null && v != 0) cands.add((v: v, cur: c, start: m.start, end: m.end));
  }
  for (final m in _amountBefore.allMatches(text)) {
    final v = parseAmount(m[2]!);
    final c = currencyOf(m[1]!);
    if (v != null && c != null && v != 0) cands.add((v: v, cur: c, start: m.start, end: m.end));
  }
  cands.sort((a, b) => a.start.compareTo(b.start));
  for (final c in cands) {
    final before = text.substring((c.start - 20).clamp(0, c.start), c.start);
    if (!_balance.hasMatch(before)) {
      amount = c;
      break;
    }
  }
  if (cands.isEmpty) return const BankTemplateResult(BankVerdict.notTransaction);
  if (amount == null) return const BankTemplateResult(BankVerdict.unknown);

  final FinTxKind? kind;
  if (_transfer.hasMatch(text)) {
    kind = FinTxKind.transfer;
  } else if (_income.hasMatch(text)) {
    kind = FinTxKind.income;
  } else if (_expense.hasMatch(text)) {
    kind = FinTxKind.expense;
  } else {
    kind = null;
  }
  if (kind == null) return const BankTemplateResult(BankVerdict.unknown);

  final card = _cardTr.firstMatch(text)?[1] ?? _card.firstMatch(text)?[1];
  return BankTemplateResult(
    BankVerdict.parsed,
    BankParsed(
      kind: kind,
      amount: toMinor(amount.v),
      currency: amount.cur,
      cardLast4: card,
      merchant: _merchant(text, amount.end),
      occurredAt: _dateIn(text),
    ),
  );
}

String? _merchant(String text, int afterAmount) {
  final tr = _merchantTr.firstMatch(text);
  if (tr != null) {
    final words = tr[1]!.split(RegExp(r'\s+')).where((w) => !RegExp(r'\d').hasMatch(w) && !w.toLowerCase().startsWith('tarih'));
    final m = words.join(' ').trim();
    if (m.isNotEmpty) return m;
  }
  var rest = text.substring(afterAmount);
  final b = _balance.firstMatch(rest);
  if (b != null) rest = rest.substring(0, b.start);
  rest = rest.replaceAll(_card, ' ').replaceAll(_time, ' ').replaceAll(_date, ' ');
  rest = rest.replaceAll(RegExp(r'^[\s.,:;\-–—]+|[\s.,:;\-–—]+$'), '');
  final dot = rest.indexOf('. ');
  if (dot > 0) rest = rest.substring(0, dot);
  rest = rest.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (rest.isEmpty || rest.length > 60 || !RegExp(r'[A-Za-zА-Яа-яЁёÇĞİÖŞÜçğıöşü]').hasMatch(rest)) return null;
  return rest;
}

DateTime? _dateIn(String text) {
  final m = _date.firstMatch(text);
  if (m == null) return null;
  var y = int.parse(m[3]!);
  if (y < 100) y += 2000;
  final d = int.parse(m[1]!), mo = int.parse(m[2]!);
  if (mo < 1 || mo > 12 || d < 1 || d > 31 || y < 2000) return null;
  return DateTime(y, mo, d, m[4] == null ? 0 : int.parse(m[4]!), m[5] == null ? 0 : int.parse(m[5]!));
}
