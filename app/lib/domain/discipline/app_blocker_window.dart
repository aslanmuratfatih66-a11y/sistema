// Окно блокировки «отбой → подъём» (SPEC §6, §8.6) и его хранение в AppSettings.
import 'package:flutter/foundation.dart';

import '../../core/db/database.dart';
import 'discipline_rules.dart';

/// Интервал блокировки [from, until).
@immutable
class BlockWindow {
  const BlockWindow(this.from, this.until);

  final DateTime from;
  final DateTime until;

  bool contains(DateTime t) => !t.isBefore(from) && t.isBefore(until);

  /// Календарный день начала ночи «2026-10-22» — ключ для подсчёта попыток и идемпотентности штрафа.
  String get nightKey =>
      '${from.year.toString().padLeft(4, '0')}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) => other is BlockWindow && other.from == from && other.until == until;

  @override
  int get hashCode => Object.hash(from, until);
}

/// Ночь, которая идёт сейчас, или ближайшая следующая. [bedMinute]/[wakeMinute] — уже целевые
/// минуты режима (DisciplineRules.targetBed/targetWake).
BlockWindow blockWindowAt(DateTime now, {required int bedMinute, required int wakeMinute}) {
  final sleep = DisciplineRules.sleepMinutes(bedMinute, wakeMinute);
  BlockWindow night(int dayOffset) {
    // DateTime(…, minute: N) сам переносит переполнение минут на следующий день и учитывает DST.
    final from = DateTime(now.year, now.month, now.day + dayOffset, 0, bedMinute);
    final until = DateTime(now.year, now.month, now.day + dayOffset, 0, bedMinute + sleep);
    return BlockWindow(from, until);
  }

  for (final offset in const [-1, 0, 1]) {
    final w = night(offset);
    if (now.isBefore(w.until)) return w;
  }
  return night(2);
}

/// Окно режима дисциплины по обычным отбою/подъёму из расписания.
BlockWindow disciplineBlockWindow(DateTime now, {required int usualBedMinute, required int usualWakeMinute}) =>
    blockWindowAt(
      now,
      bedMinute: DisciplineRules.targetBed(usualBedMinute),
      wakeMinute: DisciplineRules.targetWake(usualWakeMinute),
    );

/// Хранение активного окна (его запоминает AppBlocker.blockFrom, читает BlockedScreen).
abstract final class BlockWindowStore {
  static const key = 'blocker.window';

  static Future<BlockWindow?> read(AppDatabase db) async {
    final raw = await db.getSetting(key);
    if (raw == null) return null;
    final parts = raw.split(',');
    if (parts.length != 2) return null;
    final from = int.tryParse(parts[0]);
    final until = int.tryParse(parts[1]);
    if (from == null || until == null || until <= from) return null;
    return BlockWindow(DateTime.fromMillisecondsSinceEpoch(from), DateTime.fromMillisecondsSinceEpoch(until));
  }

  static Future<void> write(AppDatabase db, BlockWindow w) =>
      db.setSetting(key, '${w.from.millisecondsSinceEpoch},${w.until.millisecondsSinceEpoch}');

  static Future<void> clear(AppDatabase db) => db.deleteSetting(key);
}
