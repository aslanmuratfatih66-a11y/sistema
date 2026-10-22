// Будильник-квест (SPEC §8.11): расчёт срабатываний по маске дней. Чистые функции, локальное время.
import 'package:flutter/foundation.dart';

import '../db/database.dart';

/// Бит дня недели в маске Alarms.weekdays: пн=1 … вс=64 ([weekday] — DateTime.monday..sunday).
int alarmWeekdayBit(int weekday) => 1 << (weekday - 1);

const alarmAllDays = 127;
const alarmWorkDays = 31;

/// Время срабатывания в день [day] (локальная полночь) — с учётом перехода на летнее время.
DateTime alarmAtDay(DateTime day, int minute) => DateTime(day.year, day.month, day.day, minute ~/ 60, minute % 60);

bool _dayMatches(int weekdays, DateTime day) => weekdays == 0 || (weekdays & alarmWeekdayBit(day.weekday)) != 0;

/// Ближайшие срабатывания строго позже [from] до [from] + [horizon]. Разовый (weekdays=0) — одно.
List<DateTime> alarmNextOccurrences(AlarmRow a, DateTime from, {Duration horizon = const Duration(days: 8), int max = 8}) {
  final out = <DateTime>[];
  final until = from.add(horizon);
  var day = DateTime(from.year, from.month, from.day);
  for (var i = 0; i < 9 && out.length < max; i++) {
    final at = alarmAtDay(day, a.minute);
    if (at.isAfter(until)) break;
    if (at.isAfter(from) && _dayMatches(a.weekdays, day)) {
      out.add(at);
      if (a.weekdays == 0) break;
    }
    day = DateTime(day.year, day.month, day.day + 1);
  }
  return out;
}

/// Последнее срабатывание не позже [now] (за последние 8 дней) или null.
DateTime? alarmLastOccurrence(AlarmRow a, DateTime now) {
  var day = DateTime(now.year, now.month, now.day);
  for (var i = 0; i < 8; i++) {
    final at = alarmAtDay(day, a.minute);
    if (!at.isAfter(now) && _dayMatches(a.weekdays, day)) return at;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return null;
}

/// Ключ дня для идемпотентности награды: «2026-10-22».
String alarmDayKey(DateTime t) =>
    '${t.year.toString().padLeft(4, '0')}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

/// Одно запланированное срабатывание (уходит в нативный канал).
@immutable
class AlarmPlanEntry {
  const AlarmPlanEntry({required this.alarmId, required this.at, required this.title, required this.body});

  final String alarmId;
  final DateTime at;
  final String title;
  final String body;

  String get key => '$alarmId@${at.millisecondsSinceEpoch}';

  Map<String, Object?> toMap() => {
        'key': key,
        'id': alarmId,
        'atMs': at.millisecondsSinceEpoch,
        'title': title,
        'body': body,
      };
}
