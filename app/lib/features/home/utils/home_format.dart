// Чистые функции форматирования и расчётов главного экрана (покрыты юнит-тестами).
import 'dart:ui' show Locale;

/// Знак минуса из типографики (U+2212), как в SPEC: «−10%».
const String kMinus = '−';

/// Таймер: «MM:SS» до часа, «H:MM:SS» дальше. Отрицательное — «00:00».
String formatCountdown(Duration d) {
  if (d.isNegative) return '00:00';
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

/// Короткий остаток «H:MM» (для эффектов и босса, обновляется раз в минуту).
/// Округляет вверх до минуты, чтобы «0:00» не висело, пока время ещё есть.
String formatHoursMinutes(Duration d) {
  if (d.isNegative || d == Duration.zero) return '0:00';
  final totalMinutes = (d.inSeconds + 59) ~/ 60;
  final h = totalMinutes ~/ 60;
  final m = totalMinutes % 60;
  return '$h:${m.toString().padLeft(2, '0')}';
}

int minuteOfDay(DateTime t) => t.hour * 60 + t.minute;

/// Позиция момента на ленте дня [startMinute..endMinute] в долях 0..1 (с зажимом).
double dayFraction(DateTime now, {required int startMinute, required int endMinute}) =>
    minuteFraction(now.hour * 60 + now.minute + now.second / 60, startMinute: startMinute, endMinute: endMinute);

double minuteFraction(num minute, {required int startMinute, required int endMinute}) {
  if (endMinute <= startMinute) return 0;
  return ((minute - startMinute) / (endMinute - startMinute)).clamp(0.0, 1.0).toDouble();
}

/// Неделя и день программы (с 1). До начала программы — неделя 1, день 1.
({int week, int day}) programWeekDay(DateTime start, DateTime now) {
  final s = DateTime(start.year, start.month, start.day);
  final n = DateTime(now.year, now.month, now.day);
  // Через UTC, чтобы переход на летнее время не сдвигал дни.
  final days = DateTime.utc(n.year, n.month, n.day).difference(DateTime.utc(s.year, s.month, s.day)).inDays;
  if (days < 0) return (week: 1, day: 1);
  return (week: days ~/ 7 + 1, day: days + 1);
}

/// Число со знаком: «+1», «−2», «0».
String formatSigned(int v) => v > 0 ? '+$v' : (v < 0 ? '$kMinus${-v}' : '0');

/// Прогресс таймера квеста: доля оставшегося времени 0..1.
double remainingFraction(DateTime start, DateTime deadline, DateTime now) {
  final total = deadline.difference(start).inMilliseconds;
  if (total <= 0) return 0;
  return (deadline.difference(now).inMilliseconds / total).clamp(0.0, 1.0).toDouble();
}

/// Капс с учётом языка: в турецком/азербайджанском «i» → «İ».
String upperFor(String s, Locale locale) {
  final lang = locale.languageCode;
  if (lang == 'tr' || lang == 'az') return s.replaceAll('i', 'İ').toUpperCase();
  return s.toUpperCase();
}
