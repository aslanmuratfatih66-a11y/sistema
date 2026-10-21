// Сон (SPEC §8.3): окно сна по минутам суток, длительность через полночь, «Энергия» для «Статуса».
import 'dart:math' as math;

import '../../../core/models/daily.dart';

const _dayMinutes = 24 * 60;

/// Локальная полночь даты.
DateTime dayOf(DateTime t) {
  final l = t.toLocal();
  return DateTime(l.year, l.month, l.day);
}

/// Минута суток (0..1439) момента в локальном времени.
int minuteOfDay(DateTime t) {
  final l = t.toLocal();
  return l.hour * 60 + l.minute;
}

/// Длительность сна по минутам суток отбоя и подъёма (через полночь — нормально): 23:30 → 07:00 = 450.
/// Одинаковые минуты — 0 (сутки сна не считаем).
int sleepMinutesBetween(int bedMinute, int wakeMinute) =>
    (wakeMinute % _dayMinutes - bedMinute % _dayMinutes + _dayMinutes) % _dayMinutes;

/// Отбой и подъём ночи, закончившейся утром [wakeDay]. Подъём — в [wakeDay]; отбой — в тот же день,
/// если он раньше подъёма (лёг после полуночи), иначе — накануне.
({DateTime bedAt, DateTime wakeAt}) sleepWindow(DateTime wakeDay, {required int bedMinute, required int wakeMinute}) {
  final d = dayOf(wakeDay);
  final w = wakeMinute % _dayMinutes;
  final b = bedMinute % _dayMinutes;
  final wakeAt = DateTime(d.year, d.month, d.day, 0, w);
  final bedDay = b < w ? d : DateTime(d.year, d.month, d.day - 1);
  final bedAt = DateTime(bedDay.year, bedDay.month, bedDay.day, 0, b);
  return (bedAt: bedAt, wakeAt: wakeAt);
}

/// Насколько отбой позже планового, минут (отрицательное — раньше). Разница приводится к ±12 ч,
/// чтобы 00:30 против 23:00 давало +90, а не −1350.
int bedDeviationMinutes(DateTime bedAt, int plannedBedMinute) {
  var diff = (minuteOfDay(bedAt) - plannedBedMinute % _dayMinutes) % _dayMinutes;
  if (diff > _dayMinutes ~/ 2) diff -= _dayMinutes;
  return diff;
}

/// «Энергия» (0–100) по ночи сна. Формула (без медицины, игровая шкала):
/// 1. База = 100 × min(длительность / цель, 1). Недосып снижает энергию пропорционально.
/// 2. Пересып: за каждый час сверх 120% цели −5, не больше −15.
/// 3. Поздний отбой: если лёг позже планового больше чем на 30 мин — −5 за каждые полные 30 мин
///    сверх этого допуска, не больше −20 (режим важнее суммы часов). Ранний отбой не штрафуется.
/// 4. Качество (1–5, если отмечено): (качество − 3) × 4, то есть от −8 до +8.
/// Итог округляется и ограничивается 0..100.
/// [targetMinutes] — цель плана (PlanNorms.sleepTargetMinutes); [plannedBedMinute] — отбой из плана/расписания,
/// null — штраф за поздний отбой не считается.
int energyPercent(SleepDay sleep, {required int targetMinutes, int? plannedBedMinute}) {
  final minutes = sleep.duration.inMinutes;
  if (minutes <= 0 || targetMinutes <= 0) return 0;
  final ratio = minutes / targetMinutes;
  var score = 100 * math.min(ratio, 1.0);

  final overMinutes = minutes - targetMinutes * 1.2;
  if (overMinutes > 0) score -= math.min(15, 5 * (overMinutes / 60));

  if (plannedBedMinute != null) {
    final late = bedDeviationMinutes(sleep.bedAt, plannedBedMinute) - 30;
    if (late > 0) score -= math.min(20, 5 * (late ~/ 30));
  }

  final q = sleep.quality;
  if (q != null) score += (q.clamp(1, 5) - 3) * 4;

  return score.round().clamp(0, 100);
}

/// Сводка по нескольким ночам (для графика и сравнения с целью).
class SleepStats {
  const SleepStats({required this.nights, required this.averageMinutes, required this.nightsOnTarget});

  final int nights;

  /// null — ночей нет.
  final int? averageMinutes;

  /// Ночей не короче цели.
  final int nightsOnTarget;

  factory SleepStats.of(Iterable<SleepDay> days, {required int targetMinutes}) {
    final list = days.where((d) => d.duration.inMinutes > 0).toList();
    if (list.isEmpty) return const SleepStats(nights: 0, averageMinutes: null, nightsOnTarget: 0);
    final total = list.fold<int>(0, (s, d) => s + d.duration.inMinutes);
    return SleepStats(
      nights: list.length,
      averageMinutes: (total / list.length).round(),
      nightsOnTarget: list.where((d) => d.duration.inMinutes >= targetMinutes).length,
    );
  }
}
