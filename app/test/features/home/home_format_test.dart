import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/features/home/utils/home_format.dart';
import 'package:sistema/ui/ui.dart' show formatMinuteOfDay;
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/quests/quest_format.dart';

import '../quests/fake_quest_service.dart';

void main() {
  group('formatCountdown', () {
    test('минуты и секунды', () {
      expect(formatCountdown(const Duration(minutes: 38, seconds: 5)), '38:05');
      expect(formatCountdown(Duration.zero), '00:00');
    });
    test('с часами', () {
      expect(formatCountdown(const Duration(hours: 1, minutes: 2, seconds: 3)), '1:02:03');
    });
    test('просрочено — нули', () {
      expect(formatCountdown(const Duration(seconds: -5)), '00:00');
    });
  });

  test('formatHoursMinutes округляет вверх до минуты', () {
    expect(formatHoursMinutes(const Duration(hours: 1, minutes: 24)), '1:24');
    expect(formatHoursMinutes(const Duration(seconds: 1)), '0:01');
    expect(formatHoursMinutes(const Duration(minutes: -1)), '0:00');
  });

  group('dayFraction — позиция «сейчас» на ленте 07:00–23:00', () {
    const s = 7 * 60, e = 23 * 60;
    test('внутри дня', () {
      expect(dayFraction(DateTime(2026, 10, 21, 15), startMinute: s, endMinute: e), 0.5);
      expect(dayFraction(DateTime(2026, 10, 21, 7), startMinute: s, endMinute: e), 0);
      expect(dayFraction(DateTime(2026, 10, 21, 10, 46), startMinute: s, endMinute: e), closeTo(226 / 960, 1e-9));
    });
    test('зажим за пределами', () {
      expect(dayFraction(DateTime(2026, 10, 21, 5), startMinute: s, endMinute: e), 0);
      expect(dayFraction(DateTime(2026, 10, 21, 23, 30), startMinute: s, endMinute: e), 1);
    });
  });

  test('programWeekDay', () {
    final start = DateTime(2026, 10, 21);
    expect(programWeekDay(start, DateTime(2026, 10, 21, 10)), (week: 1, day: 1));
    expect(programWeekDay(start, DateTime(2026, 10, 27, 23)), (week: 1, day: 7));
    expect(programWeekDay(start, DateTime(2026, 10, 28)), (week: 2, day: 8));
    expect(programWeekDay(start, DateTime(2026, 10, 1)), (week: 1, day: 1));
  });

  test('remainingFraction', () {
    final a = DateTime(2026, 1, 1, 10);
    final b = DateTime(2026, 1, 1, 11);
    expect(remainingFraction(a, b, DateTime(2026, 1, 1, 10, 30)), 0.5);
    expect(remainingFraction(a, b, DateTime(2026, 1, 1, 12)), 0);
  });

  test('formatSigned и formatMinuteOfDay', () {
    expect(formatSigned(1), '+1');
    expect(formatSigned(-2), '−2');
    expect(formatSigned(0), '0');
    expect(formatMinuteOfDay(8 * 60 + 5), '08:05');
  });

  test('upperFor учитывает турецкую İ', () {
    expect(upperFor('Sistem · çevrimiçi', const Locale('tr')), 'SİSTEM · ÇEVRİMİÇİ');
    expect(upperFor('Система', const Locale('ru')), 'СИСТЕМА');
  });

  test('dayPenaltyTotal: штрафы незакрытых квестов дня, без босса', () {
    final now = DateTime(2026, 10, 21, 10, 46);
    final quests = [...fakeDayQuests(now), fakeBoss(now)];
    final base = dayPenaltyTotal(quests);
    expect(base, 85);
    final done = [for (final q in quests) q.instanceId == 'water' ? copyQuest(q, status: QuestStatus.done) : q];
    expect(dayPenaltyTotal(done), base - 15);
  });
}
