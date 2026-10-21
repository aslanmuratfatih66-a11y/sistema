/// Часовые пояса в виде «UTC+3» / «UTC-5» / «UTC+5:30» (хранение — ASCII-минус).
library;

/// Смещение → метка пояса.
String timezoneFromOffset(Duration offset) {
  final minutes = offset.inMinutes;
  final sign = minutes < 0 ? '-' : '+';
  final abs = minutes.abs();
  final h = abs ~/ 60;
  final m = abs % 60;
  return m == 0 ? 'UTC$sign$h' : 'UTC$sign$h:${m.toString().padLeft(2, '0')}';
}

/// Часовой пояс устройства сейчас.
String deviceTimezone() => timezoneFromOffset(DateTime.now().timeZoneOffset);

/// Целочасовые пояса UTC−12 … UTC+14.
final List<String> timezoneOptions = [for (var h = -12; h <= 14; h++) timezoneFromOffset(Duration(hours: h))];

/// Для показа: типографский минус.
String displayTimezone(String tz) => tz.replaceAll('-', '−');
