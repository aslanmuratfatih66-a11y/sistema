// Финансы: деньги, периоды, агрегаты (чистые функции без БД).
import 'dart:math' as math;

import 'package:uuid/uuid.dart';

/// Валюты (SPEC §8.7). RUB — база отчётов.
const finCurrencies = ['RUB', 'TRY', 'USD', 'EUR'];

String currencySymbol(String c) => switch (c) {
      'RUB' => '₽',
      'TRY' => '₺',
      'USD' => r'$',
      'EUR' => '€',
      _ => c,
    };

const _uuid = Uuid();

/// Детерминированный id (UUID v5): посев категорий, операции с externalRef, подписки.
String finSid(String key) => _uuid.v5(Namespace.url.value, 'sistema:fin:$key');

/// Мин. единицы → «1 234,56 ₽» (дробная часть — только если не ноль, либо [forceCents]).
String formatMoney(int minor, String currency, {bool forceCents = false, bool sign = false}) {
  final neg = minor < 0;
  final abs = minor.abs();
  final major = abs ~/ 100;
  final cents = abs % 100;
  final s = major.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  final frac = (cents != 0 || forceCents) ? ',${cents.toString().padLeft(2, '0')}' : '';
  final prefix = neg ? '−' : (sign && minor > 0 ? '+' : '');
  return '$prefix$b$frac ${currencySymbol(currency)}';
}

/// Копейки → «1 234 ₽» (округление до рубля).
String formatRub(int kopecks, {bool sign = false}) => formatMoney((kopecks / 100).round() * 100, 'RUB', sign: sign);

/// Ввод суммы (основные единицы, число) → мин. единицы.
int toMinor(num v) => (v * 100).round();

/// Мин. единицы → основные (для полей ввода).
double toMajor(int minor) => minor / 100;

/// Количество крипты: до 8 знаков без хвостовых нулей.
String formatQty(double v) {
  var s = v.toStringAsFixed(8);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '');
    if (s.endsWith('.')) s = s.substring(0, s.length - 1);
  }
  return s;
}

DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

String isoDay(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// «21.10.2026».
String formatDay(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

/// «21.10».
String formatDayShort(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';

enum FinPeriod { week, month }

FinPeriod finPeriodOf(String s) => s == 'week' ? FinPeriod.week : FinPeriod.month;

/// Полуинтервал [start, end) периода, содержащего [t].
({DateTime start, DateTime end}) periodRange(FinPeriod p, DateTime t) {
  switch (p) {
    case FinPeriod.week:
      final d = dayOf(t);
      final start = DateTime(d.year, d.month, d.day - (d.weekday - DateTime.monday));
      return (start: start, end: DateTime(start.year, start.month, start.day + 7));
    case FinPeriod.month:
      final start = DateTime(t.year, t.month);
      return (start: start, end: DateTime(t.year, t.month + 1));
  }
}

/// Сдвиг периода на [n] (отрицательный — назад).
({DateTime start, DateTime end}) shiftPeriod(FinPeriod p, DateTime start, int n) => switch (p) {
      FinPeriod.week => periodRange(p, DateTime(start.year, start.month, start.day + 7 * n)),
      FinPeriod.month => periodRange(p, DateTime(start.year, start.month + n)),
    };

/// Ключ периода для идемпотентности наград: `m2026-10`, `w2026-10-19`.
String periodKey(FinPeriod p, DateTime start) => switch (p) {
      FinPeriod.week => 'w${isoDay(start)}',
      FinPeriod.month => 'm${start.year}-${start.month.toString().padLeft(2, '0')}',
    };

/// Следующая дата списания: неделя / месяц (с прижатием к концу месяца) / год.
DateTime nextCharge(DateTime from, String period) {
  switch (period) {
    case 'week':
      return DateTime(from.year, from.month, from.day + 7, from.hour, from.minute);
    case 'year':
      return _clampDay(from.year + 1, from.month, from.day, from);
    default:
      return _clampDay(from.year, from.month + 1, from.day, from);
  }
}

DateTime _clampDay(int y, int m, int d, DateTime tpl) {
  final norm = DateTime(y, m);
  final last = DateTime(norm.year, norm.month + 1, 0).day;
  return DateTime(norm.year, norm.month, math.min(d, last), tpl.hour, tpl.minute);
}

/// Дней между днями (без учёта времени).
int daysBetween(DateTime a, DateTime b) => (dayOf(b).difference(dayOf(a)).inHours / 24).round();
