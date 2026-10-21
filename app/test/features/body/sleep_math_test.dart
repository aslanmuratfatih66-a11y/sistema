import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/models/daily.dart';
import 'package:sistema/features/body/domain/sleep_math.dart';

SleepDay _night(DateTime bed, DateTime wake, {int? quality}) =>
    SleepDay(day: dayOf(wake), bedAt: bed, wakeAt: wake, quality: quality);

void main() {
  group('длительность сна', () {
    test('через полночь', () {
      expect(sleepMinutesBetween(23 * 60 + 30, 7 * 60), 450);
      expect(sleepMinutesBetween(22 * 60, 6 * 60), 480);
    });

    test('лёг после полуночи', () => expect(sleepMinutesBetween(60, 9 * 60), 480));
    test('одинаковое время — 0', () => expect(sleepMinutesBetween(420, 420), 0));

    test('окно сна: отбой накануне, если позже подъёма', () {
      final w = sleepWindow(DateTime(2026, 10, 21), bedMinute: 23 * 60, wakeMinute: 7 * 60);
      expect(w.bedAt, DateTime(2026, 10, 20, 23));
      expect(w.wakeAt, DateTime(2026, 10, 21, 7));
      expect(w.wakeAt.difference(w.bedAt), const Duration(hours: 8));
    });

    test('окно сна: отбой после полуночи — тот же день', () {
      final w = sleepWindow(DateTime(2026, 10, 21, 15), bedMinute: 90, wakeMinute: 8 * 60);
      expect(w.bedAt, DateTime(2026, 10, 21, 1, 30));
      expect(w.wakeAt, DateTime(2026, 10, 21, 8));
    });

    test('окно сна через смену месяца', () {
      final w = sleepWindow(DateTime(2026, 11, 1), bedMinute: 23 * 60, wakeMinute: 7 * 60);
      expect(w.bedAt, DateTime(2026, 10, 31, 23));
      expect(_night(w.bedAt, w.wakeAt).duration.inMinutes, 480);
    });

    test('отклонение отбоя приводится к ±12 ч', () {
      expect(bedDeviationMinutes(DateTime(2026, 10, 21, 0, 30), 23 * 60), 90);
      expect(bedDeviationMinutes(DateTime(2026, 10, 20, 22), 23 * 60), -60);
      expect(bedDeviationMinutes(DateTime(2026, 10, 20, 23, 10), 23 * 60), 10);
    });
  });

  group('Энергия', () {
    final wake = DateTime(2026, 10, 21, 7);

    int e(int minutes, {int? quality, int? bedMinute}) => energyPercent(
          _night(wake.subtract(Duration(minutes: minutes)), wake, quality: quality),
          targetMinutes: 480,
          plannedBedMinute: bedMinute,
        );

    test('сон по цели — 100', () => expect(e(480), 100));
    test('недосып пропорционален', () => expect(e(360, bedMinute: null), 75));
    test('качество ±8', () {
      expect(e(360, quality: 5, bedMinute: null), 83);
      expect(e(240, quality: 1, bedMinute: null), 42);
      expect(e(480, quality: 5), 100, reason: 'не выше 100');
    });

    test('пересып сверх 120% цели штрафуется слегка', () {
      // 660 мин: сверх 576 на 84 мин → −7.
      expect(e(660, bedMinute: null), 93);
      expect(e(24 * 60 - 60, bedMinute: null), 85, reason: 'штраф не больше −15');
    });

    test('поздний отбой: −5 за каждые 30 мин сверх получаса', () {
      // Лёг в 23:00 при плане 23:00 — без штрафа; план 21:00 → +120 мин → (120−30)~/30 = 3 → −15.
      expect(e(480, bedMinute: 23 * 60), 100);
      expect(e(480, bedMinute: 21 * 60), 85);
      expect(e(480, bedMinute: 23 * 60 - 50), 100, reason: '50 мин: допуск 30 + неполные 30');
      expect(e(480, bedMinute: 12 * 60), 80, reason: 'не больше −20');
    });

    test('нулевой сон — 0', () => expect(energyPercent(_night(wake, wake), targetMinutes: 480), 0));
  });

  test('сводка ночей', () {
    final nights = [
      _night(DateTime(2026, 10, 19, 23), DateTime(2026, 10, 20, 7)),
      _night(DateTime(2026, 10, 21, 0), DateTime(2026, 10, 21, 6)),
    ];
    final s = SleepStats.of(nights, targetMinutes: 480);
    expect(s.nights, 2);
    expect(s.averageMinutes, 420);
    expect(s.nightsOnTarget, 1);
    expect(SleepStats.of(const [], targetMinutes: 480).averageMinutes, isNull);
  });
}
