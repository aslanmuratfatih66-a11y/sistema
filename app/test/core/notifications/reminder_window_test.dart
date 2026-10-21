import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/notifications/notification_api.dart';
import 'package:sistema/core/notifications/reminder_window.dart';

ReminderRequest req(
  String id,
  DateTime due,
  DateTime deadline, {
  bool nag = true,
  bool reproach = true,
}) =>
    ReminderRequest(
      instanceId: id,
      title: 'T $id',
      body: 'B $id',
      dueAt: due,
      deadlineAt: deadline,
      nag: nag,
      reproachTitle: reproach ? 'R $id' : null,
      reproachBody: reproach ? 'RB $id' : null,
    );

const noNag = ReminderPrefs(nag: false);

void main() {
  final now = DateTime(2026, 10, 21, 12, 0);

  group('planReminderWindow', () {
    test('ёмкость: не больше 60 и ближайшие по времени', () {
      final requests = [
        for (var i = 0; i < 5; i++) req('q$i', now.add(Duration(minutes: 5 + i)), now.add(const Duration(hours: 2))),
      ];
      final plan = planReminderWindow(requests, const ReminderPrefs(), now: now);
      expect(plan.length, reminderWindowCapacity);
      expect(reminderWindowCapacity, lessThanOrEqualTo(64));
      for (var i = 1; i < plan.length; i++) {
        expect(plan[i].at.isBefore(plan[i - 1].at), isFalse);
      }
      // Дальше последнего в окне ничего не осталось за бортом раньше него.
      final last = plan.last.at;
      expect(last.isBefore(now.add(const Duration(minutes: 25))), isTrue);
    });

    test('ближайшее важнее: дальний квест вытесняется', () {
      final near = [
        for (var i = 0; i < 70; i++) req('n$i', now.add(Duration(minutes: 1 + i)), now.add(Duration(minutes: 2 + i))),
      ];
      final far = req('far', now.add(const Duration(hours: 10)), now.add(const Duration(hours: 11)));
      final plan = planReminderWindow([far, ...near], noNag, now: now);
      expect(plan.length, reminderWindowCapacity);
      expect(plan.any((p) => p.instanceId == 'far'), isFalse);
      expect(plan.first.instanceId, 'n0');
    });

    test('повтор каждую минуту от dueAt', () {
      final due = now.add(const Duration(minutes: 10));
      final plan = planReminderWindow(
        [req('a', due, due.add(const Duration(minutes: 5)), reproach: false)],
        const ReminderPrefs(),
        now: now,
        capacity: 100,
      );
      expect(plan.first.slot, ReminderSlot.due);
      expect(plan.first.at, due);
      expect(plan.skip(1).every((p) => p.slot == ReminderSlot.nag), isTrue);
      for (var i = 1; i < plan.length; i++) {
        expect(plan[i].at.difference(plan[i - 1].at), const Duration(minutes: 1));
      }
      // До дедлайна и ещё час после (пока не выполнено).
      expect(plan.last.at, due.add(const Duration(minutes: 5)).add(nagOverrun));
      expect(plan.length, 5 + 60 + 1);
    });

    test('прошлое не планируется: повтор продолжается со следующей минуты', () {
      final due = now.subtract(const Duration(minutes: 3, seconds: 30));
      final plan = planReminderWindow(
        [req('a', due, now.add(const Duration(minutes: 5)), reproach: false)],
        const ReminderPrefs(),
        now: now,
      );
      expect(plan.every((p) => p.at.isAfter(now)), isTrue);
      expect(plan.first.at, due.add(const Duration(minutes: 4)));
      expect(plan.first.seq, 4);
    });

    test('без «надоедать» — одно напоминание и упрёк на дедлайн+15', () {
      final due = now.add(const Duration(minutes: 10));
      final deadline = now.add(const Duration(minutes: 40));
      final plan = planReminderWindow([req('a', due, deadline)], noNag, now: now);
      expect(plan.map((p) => p.slot), [ReminderSlot.due, ReminderSlot.reproach]);
      expect(plan.last.at, deadline.add(const Duration(minutes: 15)));
      expect(plan.last.title, 'R a');
      expect(plan.last.body, 'RB a');
      // Флаг квеста тоже выключает повтор.
      final own = planReminderWindow([req('a', due, deadline, nag: false)], const ReminderPrefs(), now: now);
      expect(own.length, 2);
    });

    test('упрёк выключен в настройках', () {
      final plan = planReminderWindow(
        [req('a', now.add(const Duration(minutes: 1)), now.add(const Duration(minutes: 2)))],
        const ReminderPrefs(nag: false, reproach: false),
        now: now,
      );
      expect(plan.map((p) => p.slot), [ReminderSlot.due]);
    });

    test('выключено — пустое окно', () {
      final plan = planReminderWindow(
        [req('a', now.add(const Duration(minutes: 1)), now.add(const Duration(minutes: 2)))],
        const ReminderPrefs(enabled: false),
        now: now,
      );
      expect(plan, isEmpty);
    });

    test('тихие часы через полночь: внутри ничего не звенит', () {
      const quiet = QuietHours(startMinute: 23 * 60, endMinute: 7 * 60);
      final evening = DateTime(2026, 10, 21, 22, 50);
      final plan = planReminderWindow(
        [req('a', evening, DateTime(2026, 10, 21, 23, 30), reproach: false)],
        const ReminderPrefs(quiet: quiet),
        now: DateTime(2026, 10, 21, 22, 0),
      );
      expect(plan, isNotEmpty);
      for (final p in plan) {
        expect(isQuietAt(p.at, quiet), isFalse, reason: '${p.at}');
      }
      expect(plan.last.at, DateTime(2026, 10, 21, 22, 59));
    });

    test('isQuietAt: обычный и через полночь, start == end — нет тихих часов', () {
      const night = QuietHours(startMinute: 23 * 60, endMinute: 7 * 60);
      expect(isQuietAt(DateTime(2026, 1, 1, 23, 0), night), isTrue);
      expect(isQuietAt(DateTime(2026, 1, 1, 3, 0), night), isTrue);
      expect(isQuietAt(DateTime(2026, 1, 1, 7, 0), night), isFalse);
      expect(isQuietAt(DateTime(2026, 1, 1, 12, 0), night), isFalse);
      const day = QuietHours(startMinute: 13 * 60, endMinute: 14 * 60);
      expect(isQuietAt(DateTime(2026, 1, 1, 13, 30), day), isTrue);
      expect(isQuietAt(DateTime(2026, 1, 1, 14, 0), day), isFalse);
      expect(isQuietAt(DateTime(2026, 1, 1, 3, 0), const QuietHours(startMinute: 60, endMinute: 60)), isFalse);
    });

    test('упрёк из тихих часов переносится на их конец (на следующий день)', () {
      const quiet = QuietHours(startMinute: 23 * 60, endMinute: 7 * 60);
      final deadline = DateTime(2026, 10, 21, 22, 50); // упрёк в 23:05 — тихо
      final plan = planReminderWindow(
        [req('a', DateTime(2026, 10, 21, 22, 0), deadline)],
        const ReminderPrefs(nag: false, quiet: quiet),
        now: DateTime(2026, 10, 21, 21, 0),
      );
      final reproach = plan.singleWhere((p) => p.slot == ReminderSlot.reproach);
      expect(reproach.at, DateTime(2026, 10, 22, 7, 0));
      // После полуночи — на конец тихих часов того же дня.
      final late = planReminderWindow(
        [req('b', DateTime(2026, 10, 22, 0, 30), DateTime(2026, 10, 22, 1, 0))],
        const ReminderPrefs(nag: false, quiet: quiet),
        now: DateTime(2026, 10, 21, 21, 0),
      );
      expect(late.map((p) => (p.slot, p.at)), [(ReminderSlot.reproach, DateTime(2026, 10, 22, 7, 0))]);
    });

    test('стабильные id: одинаковые между вызовами и без коллизий', () {
      final requests = [
        for (var i = 0; i < 30; i++) req('id-$i', now.add(Duration(minutes: i)), now.add(Duration(minutes: 30 + i))),
      ];
      final a = planReminderWindow(requests, const ReminderPrefs(), now: now);
      final b = planReminderWindow(requests.reversed.toList(), const ReminderPrefs(), now: now);
      expect(a.map((p) => p.id), b.map((p) => p.id));
      expect(a.map((p) => p.id).toSet().length, a.length);
      for (final p in a) {
        expect(p.id, inInclusiveRange(0, 0x3FFFFFFF));
      }
      // Детерминированный хэш (не String.hashCode).
      expect(fnv1a32(''), 0x811C9DC5);
      expect(fnv1a32('a'), 0xE40C292C);
      expect(reminderBaseId('x', ReminderSlot.nag, 3), reminderBaseId('x', ReminderSlot.nag, 3));
    });

    test('коллизия с зарезервированным id разрешается сдвигом', () {
      final due = now.add(const Duration(minutes: 1));
      final base = reminderBaseId('a', ReminderSlot.due, 0);
      final plan = planReminderWindow([req('a', due, due)], noNag, now: now, reservedIds: {base});
      expect(plan.first.id, base + 1);
    });

    test('немедленные id вне диапазона окна', () {
      expect(immediateNotificationId('x') & 0x40000000, 0x40000000);
      expect(immediateNotificationId('x'), lessThan(0x80000000));
    });
  });

  group('diffReminderWindow', () {
    final due = now.add(const Duration(minutes: 10));
    final deadline = now.add(const Duration(minutes: 30));

    List<PendingReminder> asPending(List<PlannedReminder> plan) =>
        [for (final p in plan) PendingReminder(id: p.id, payload: p.payload)];

    test('первый раз — ставит всё', () {
      final d = diffReminderWindow(const [], [req('a', due, deadline)], noNag, now: now);
      expect(d.cancel, isEmpty);
      expect(d.schedule.length, 2);
    });

    test('без изменений — ничего не трогает', () {
      final first = diffReminderWindow(const [], [req('a', due, deadline)], noNag, now: now);
      final d = diffReminderWindow(asPending(first.plan), [req('a', due, deadline)], noNag, now: now);
      expect(d.cancel, isEmpty);
      expect(d.schedule, isEmpty);
    });

    test('«+10 мин» — то же id, новое время → переставляется', () {
      final first = diffReminderWindow(const [], [req('a', due, deadline)], noNag, now: now);
      final later = req('a', due.add(const Duration(minutes: 10)), deadline.add(const Duration(minutes: 10)));
      final d = diffReminderWindow(asPending(first.plan), [later], noNag, now: now);
      expect(d.cancel, isEmpty);
      expect(d.schedule.map((p) => p.id), first.plan.map((p) => p.id));
    });

    test('квест закрыт движком: повторы снимаются, упрёк остаётся', () {
      final first = diffReminderWindow(const [], [req('a', due, deadline)], const ReminderPrefs(), now: now);
      final reproach = first.plan.singleWhere((p) => p.slot == ReminderSlot.reproach);
      final d = diffReminderWindow(asPending(first.plan), const [], const ReminderPrefs(), now: now);
      expect(d.kept, [reproach.id]);
      expect(d.cancel, isNot(contains(reproach.id)));
      expect(d.cancel.length, first.plan.length - 1);
      // Упрёки выключили — снимается и он.
      final off = diffReminderWindow(asPending(first.plan), const [], const ReminderPrefs(reproach: false), now: now);
      expect(off.cancel, contains(reproach.id));
    });

    test('отмена при выполнении: после cancelInstance упрёка в системе нет — и не появляется снова', () {
      final first = diffReminderWindow(const [], [req('a', due, deadline)], noNag, now: now);
      // cancelInstance снял всё по instanceId → pending пуст; квест закрыт → в списке его нет.
      final d = diffReminderWindow(const [], const [], noNag, now: now);
      expect(first.plan, isNotEmpty);
      expect(d.schedule, isEmpty);
      expect(d.kept, isEmpty);
    });

    test('чужие уведомления (без нашей нагрузки) не снимаются', () {
      final d = diffReminderWindow(
        const [PendingReminder(id: 5, payload: null), PendingReminder(id: 6, payload: '{"x":1}')],
        const [],
        noNag,
        now: now,
      );
      expect(d.cancel, isEmpty);
    });

    test('сохранённые упрёки занимают ёмкость', () {
      final pending = [
        for (var i = 0; i < 10; i++)
          PendingReminder(
            id: 100 + i,
            payload: ReminderPayload(
              instanceId: 'old$i',
              slot: ReminderSlot.reproach,
              at: now.add(Duration(minutes: 5 + i)),
              hash: 0,
            ).encode(),
          ),
      ];
      final d = diffReminderWindow(pending, [req('a', due, deadline)], const ReminderPrefs(), now: now);
      expect(d.kept.length, 10);
      expect(d.plan.length, reminderWindowCapacity - 10);
    });
  });

  test('ReminderPayload: туда-обратно и битые данные', () {
    final p = ReminderPayload(instanceId: 'i', slot: ReminderSlot.nag, at: DateTime(2026, 1, 1, 10), hash: 7);
    final back = ReminderPayload.decode(p.encode())!;
    expect(back.instanceId, 'i');
    expect(back.slot, ReminderSlot.nag);
    expect(back.at, DateTime(2026, 1, 1, 10));
    expect(ReminderPayload.decode('not json'), isNull);
    expect(ReminderPayload.decode('{"v":1,"i":"a","k":"zzz","t":1,"h":1}'), isNull);
  });
}
