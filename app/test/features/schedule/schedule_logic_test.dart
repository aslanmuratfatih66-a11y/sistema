import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/schedule/schedule_logic.dart';

ScheduleEntry entry(
  String id,
  int weekday,
  int start, {
  int duration = 90,
  int parity = 0,
  bool commute = true,
  ScheduleItemKind kind = ScheduleItemKind.lesson,
}) =>
    ScheduleEntry(
      id: id,
      kind: kind,
      title: id,
      weekday: weekday,
      startMinute: start,
      durationMinutes: duration,
      weekParity: parity,
      requiresCommute: commute,
    );

void main() {
  // 2026-10-19 — понедельник.
  final anchor = DateTime(2026, 10, 19);
  final alt = ScheduleConfig(alternationEnabled: true, week1Anchor: anchor);

  group('ScheduleConfig.fromRow / weekendDays', () {
    test('null → дефолты', () {
      final c = ScheduleConfig.fromRow(null);
      expect(c.alternationEnabled, isFalse);
      expect(c.wakeMinute, 420);
      expect(c.weekendDays, {6, 7});
    });

    test('разбор строки выходных', () {
      expect(ScheduleConfig.parseWeekendDays('6,7'), {6, 7});
      expect(ScheduleConfig.parseWeekendDays(''), <int>{});
      expect(ScheduleConfig.parseWeekendDays(' 7, x, 9,1'), {1, 7});
      expect(ScheduleConfig.formatWeekendDays({7, 6}), '6,7');
    });
  });

  group('weekNumber', () {
    test('без чередования — всегда 1', () {
      final c = ScheduleConfig(week1Anchor: anchor);
      expect(ScheduleLogic.weekNumber(DateTime(2026, 10, 27), c), 1);
      expect(ScheduleLogic.weekNumber(DateTime(2026, 10, 21), const ScheduleConfig()), 1);
    });

    test('чередование без якоря — 1', () {
      expect(ScheduleLogic.weekNumber(DateTime(2026, 10, 27), const ScheduleConfig(alternationEnabled: true)), 1);
    });

    test('с якорем: неделя якоря 1, следующая 2, через одну 1', () {
      expect(ScheduleLogic.weekNumber(DateTime(2026, 10, 19), alt), 1);
      expect(ScheduleLogic.weekNumber(DateTime(2026, 10, 25, 23, 59), alt), 1); // воскресенье
      expect(ScheduleLogic.weekNumber(DateTime(2026, 10, 26), alt), 2);
      expect(ScheduleLogic.weekNumber(DateTime(2026, 11, 1), alt), 2);
      expect(ScheduleLogic.weekNumber(DateTime(2026, 11, 2), alt), 1);
    });

    test('якорь не понедельник — нормализуется', () {
      final c = ScheduleConfig(alternationEnabled: true, week1Anchor: DateTime(2026, 10, 22, 15, 30));
      expect(ScheduleLogic.weekNumber(DateTime(2026, 10, 19), c), 1);
      expect(ScheduleLogic.weekNumber(DateTime(2026, 10, 26), c), 2);
    });

    test('даты до якоря — чётность корректна', () {
      expect(ScheduleLogic.weekNumber(DateTime(2026, 10, 18), alt), 2); // воскресенье прошлой недели
      expect(ScheduleLogic.weekNumber(DateTime(2026, 10, 12), alt), 2);
      expect(ScheduleLogic.weekNumber(DateTime(2026, 10, 5), alt), 1);
      expect(ScheduleLogic.weekNumber(DateTime(2026, 9, 30), alt), 2);
    });

    test('через границу года', () {
      // 2026-12-28 — понедельник; 2027-01-04 — следующий понедельник.
      final c = ScheduleConfig(alternationEnabled: true, week1Anchor: DateTime(2026, 12, 28));
      expect(ScheduleLogic.weekNumber(DateTime(2027, 1, 1), c), 1);
      expect(ScheduleLogic.weekNumber(DateTime(2027, 1, 4), c), 2);
      expect(ScheduleLogic.weekNumber(DateTime(2027, 1, 11), c), 1);
      expect(ScheduleLogic.weekNumber(DateTime(2026, 12, 27), c), 2);
      // 52 недели спустя — чётная разница → неделя 1.
      expect(ScheduleLogic.weekNumber(DateTime(2027, 12, 27), c), 1);
    });

    test('через переход на летнее/зимнее время (конец марта и октября)', () {
      // Европа: 29.03.2026 и 25.10.2026 — дни перевода часов (воскресенья).
      final c = ScheduleConfig(alternationEnabled: true, week1Anchor: DateTime(2026, 3, 23));
      expect(ScheduleLogic.weekNumber(DateTime(2026, 3, 29, 23), c), 1);
      expect(ScheduleLogic.weekNumber(DateTime(2026, 3, 30, 0, 30), c), 2);
      expect(ScheduleLogic.weekNumber(DateTime(2026, 4, 6), c), 1);

      final o = ScheduleConfig(alternationEnabled: true, week1Anchor: DateTime(2026, 10, 19));
      expect(ScheduleLogic.weekNumber(DateTime(2026, 10, 25, 23, 59), o), 1);
      expect(ScheduleLogic.weekNumber(DateTime(2026, 10, 26, 0, 0), o), 2);
      // Полгода через оба перехода: 2026-03-23 → 2026-10-26 = 31 неделя → неделя 2.
      expect(ScheduleLogic.weekNumber(DateTime(2026, 10, 26), c), 2);
      // Якорь в UTC тоже работает (берутся только календарные поля).
      final u = ScheduleConfig(alternationEnabled: true, week1Anchor: DateTime.utc(2026, 3, 23));
      expect(ScheduleLogic.weekNumber(DateTime(2026, 3, 30), u), 2);
    });

    test('mondayOf и daysBetween', () {
      expect(ScheduleLogic.mondayOf(DateTime(2026, 10, 25, 22)), DateTime(2026, 10, 19));
      expect(ScheduleLogic.mondayOf(DateTime(2027, 1, 1)), DateTime(2026, 12, 28));
      expect(ScheduleLogic.daysBetween(DateTime(2026, 3, 28), DateTime(2026, 3, 30)), 2);
      expect(ScheduleLogic.daysBetween(DateTime(2026, 10, 26), DateTime(2026, 10, 24)), -2);
    });
  });

  group('entriesFor', () {
    final all = [
      entry('b', DateTime.wednesday, 10 * 60 + 40),
      entry('a', DateTime.wednesday, 9 * 60),
      entry('w1', DateTime.wednesday, 12 * 60 + 40, parity: 1),
      entry('w2', DateTime.wednesday, 12 * 60 + 40, parity: 2),
      entry('thu', DateTime.thursday, 9 * 60),
      entry('sat', DateTime.saturday, 11 * 60),
    ];

    test('день недели + чётность, сортировка по началу', () {
      final w1 = ScheduleLogic.entriesFor(DateTime(2026, 10, 21), alt, all);
      expect(w1.map((e) => e.id), ['a', 'b', 'w1']);
      final w2 = ScheduleLogic.entriesFor(DateTime(2026, 10, 28), alt, all);
      expect(w2.map((e) => e.id), ['a', 'b', 'w2']);
    });

    test('без чередования — только «каждую» и «неделя 1»', () {
      final r = ScheduleLogic.entriesFor(DateTime(2026, 10, 28), const ScheduleConfig(), all);
      expect(r.map((e) => e.id), ['a', 'b', 'w1']);
    });

    test('в выходной явно заведённые пункты показываются', () {
      final r = ScheduleLogic.entriesFor(DateTime(2026, 10, 24), alt, all);
      expect(r.map((e) => e.id), ['sat']);
      expect(ScheduleLogic.entriesFor(DateTime(2026, 10, 25), alt, all), isEmpty);
    });
  });

  group('leaveHomeMinute', () {
    final wed = DateTime(2026, 10, 21);

    test('с дорогой: первый пункт с requiresCommute − дорога', () {
      final all = [
        entry('home', DateTime.wednesday, 8 * 60, duration: 30, commute: false),
        entry('lesson', DateTime.wednesday, 9 * 60),
      ];
      const c = ScheduleConfig(commuteMinutes: 40);
      expect(ScheduleLogic.leaveHomeMinute(wed, c, all), 8 * 60 + 20);
    });

    test('без дороги (0 минут) — время начала', () {
      final all = [entry('lesson', DateTime.wednesday, 9 * 60)];
      expect(ScheduleLogic.leaveHomeMinute(wed, const ScheduleConfig(), all), 9 * 60);
    });

    test('нет пунктов с дорогой — null', () {
      final all = [entry('online', DateTime.wednesday, 9 * 60, commute: false)];
      expect(ScheduleLogic.leaveHomeMinute(wed, const ScheduleConfig(commuteMinutes: 30), all), isNull);
      expect(ScheduleLogic.leaveHomeMinute(wed, const ScheduleConfig(), const []), isNull);
    });

    test('рано утром — не меньше 0', () {
      final all = [entry('early', DateTime.wednesday, 20)];
      expect(ScheduleLogic.leaveHomeMinute(wed, const ScheduleConfig(commuteMinutes: 60), all), 0);
    });

    test('учитывает чётность', () {
      final all = [
        entry('w2', DateTime.wednesday, 8 * 60, parity: 2),
        entry('every', DateTime.wednesday, 10 * 60),
      ];
      final c = ScheduleConfig(alternationEnabled: true, week1Anchor: anchor, commuteMinutes: 30);
      expect(ScheduleLogic.leaveHomeMinute(DateTime(2026, 10, 21), c, all), 9 * 60 + 30);
      expect(ScheduleLogic.leaveHomeMinute(DateTime(2026, 10, 28), c, all), 7 * 60 + 30);
    });
  });

  group('switchedAnchor', () {
    test('номер недели меняется и обратно', () {
      final today = DateTime(2026, 10, 21, 10, 46);
      var c = ScheduleConfig(alternationEnabled: true, week1Anchor: anchor);
      expect(ScheduleLogic.weekNumber(today, c), 1);
      c = ScheduleConfig(alternationEnabled: true, week1Anchor: ScheduleLogic.switchedAnchor(today, c));
      expect(ScheduleLogic.weekNumber(today, c), 2);
      c = ScheduleConfig(alternationEnabled: true, week1Anchor: ScheduleLogic.switchedAnchor(today, c));
      expect(ScheduleLogic.weekNumber(today, c), 1);
    });

    test('без якоря: сегодня становится неделей 2', () {
      final today = DateTime(2026, 10, 21);
      const c = ScheduleConfig(alternationEnabled: true);
      expect(ScheduleLogic.weekNumber(today, c), 1);
      final a = ScheduleLogic.switchedAnchor(today, c);
      expect(a.weekday, DateTime.monday);
      expect(ScheduleLogic.weekNumber(today, ScheduleConfig(alternationEnabled: true, week1Anchor: a)), 2);
    });

    test('старый якорь далеко в прошлом', () {
      final today = DateTime(2027, 2, 10);
      final c = ScheduleConfig(alternationEnabled: true, week1Anchor: DateTime(2025, 9, 1));
      final before = ScheduleLogic.weekNumber(today, c);
      final after = ScheduleLogic.weekNumber(
        today,
        ScheduleConfig(alternationEnabled: true, week1Anchor: ScheduleLogic.switchedAnchor(today, c)),
      );
      expect(after, isNot(before));
    });
  });

  group('свободные окна и лента дня', () {
    final wed = DateTime(2026, 10, 21);
    const c = ScheduleConfig(wakeMinute: 7 * 60, bedMinute: 23 * 60, commuteMinutes: 30);
    final all = [
      entry('a', DateTime.wednesday, 9 * 60), // 9:00–10:30
      entry('b', DateTime.wednesday, 10 * 60 + 40), // 10:40–12:10
      entry('c', DateTime.wednesday, 10 * 60 + 50, duration: 20), // внутри b
      entry('gym', DateTime.wednesday, 18 * 60, duration: 60, commute: false),
    ];

    test('freeWindows: дорога туда/обратно, слияние пересечений', () {
      final w = ScheduleLogic.freeWindows(wed, c, all);
      expect(w, const [
        ScheduleWindow(7 * 60, 8 * 60 + 30),
        ScheduleWindow(10 * 60 + 30, 10 * 60 + 40),
        ScheduleWindow(12 * 60 + 40, 18 * 60),
        ScheduleWindow(19 * 60, 23 * 60),
      ]);
      expect(ScheduleLogic.freeWindows(wed, c, all, minMinutes: 15).length, 3);
      expect(ScheduleLogic.returnHomeMinute(wed, c, all), 12 * 60 + 40);
    });

    test('пустой день — одно окно подъём..отбой', () {
      expect(ScheduleLogic.freeWindows(wed, c, const []), const [ScheduleWindow(420, 1380)]);
      expect(ScheduleLogic.freeMinutes(wed, c, const []), 960);
    });

    test('отбой после полуночи — окно до конца суток', () {
      const late = ScheduleConfig(wakeMinute: 9 * 60, bedMinute: 60);
      expect(ScheduleLogic.freeWindows(wed, late, const []), const [ScheduleWindow(540, 1440)]);
    });

    test('dayTimeline: сон, дорога, пункты, свободно — по порядку', () {
      final t = ScheduleLogic.dayTimeline(wed, c, all);
      expect(t.first.type, ScheduleSlotType.sleep);
      expect(t.last.type, ScheduleSlotType.sleep);
      expect(t.where((s) => s.type == ScheduleSlotType.commute).length, 2);
      expect(t.where((s) => s.type == ScheduleSlotType.entry).length, 4);
      for (var i = 1; i < t.length; i++) {
        expect(t[i].startMinute, greaterThanOrEqualTo(t[i - 1].startMinute));
      }
    });
  });
}
