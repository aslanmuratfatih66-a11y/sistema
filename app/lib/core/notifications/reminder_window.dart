// Чистый планировщик окна уведомлений (SPEC §7): без плагина, полностью покрыт тестами.
// По списку квестов, настройкам и текущему времени считает, что и когда должно прозвенеть.
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'notification_api.dart';

/// iOS держит максимум 64 запланированных уведомления; держим запас.
const reminderWindowCapacity = 60;

/// Шаг «надоедать».
const nagStep = Duration(minutes: 1);

/// Сколько ещё надоедать после дедлайна, пока квест не закрыт.
const nagOverrun = Duration(hours: 1);

/// Упрёк — через 15 мин после дедлайна.
const reproachDelay = Duration(minutes: 15);

/// Диапазон id окна: [0, 2^30). Немедленные уведомления — [2^30, 2^31) (без пересечений).
const _windowIdMask = 0x3FFFFFFF;
const _immediateIdBit = 0x40000000;

/// Вид запланированного уведомления.
enum ReminderSlot { due, nag, reproach }

/// Одно уведомление окна.
@immutable
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.instanceId,
    required this.slot,
    required this.seq,
    required this.at,
    required this.title,
    required this.body,
  });

  /// Стабильный id (FNV от instanceId, вида и порядкового номера).
  final int id;
  final String instanceId;
  final ReminderSlot slot;

  /// Порядковый номер: для повторов — минута от dueAt, для остальных 0.
  final int seq;
  final DateTime at;
  final String title;
  final String body;

  /// Канал «надоедать» (Android) — для повторов.
  bool get isNag => slot == ReminderSlot.nag;

  /// Полезная нагрузка: по ней [diffReminderWindow] узнаёт, не изменилось ли уже поставленное.
  String get payload => ReminderPayload(
        instanceId: instanceId,
        slot: slot,
        at: at,
        hash: fnv1a32('$title\u0000$body\u0000${slot.name}'),
      ).encode();

  @override
  String toString() => 'PlannedReminder($id, $instanceId, ${slot.name}#$seq, $at)';
}

/// Разобранная полезная нагрузка уведомления окна.
@immutable
class ReminderPayload {
  const ReminderPayload({required this.instanceId, required this.slot, required this.at, required this.hash});

  final String instanceId;
  final ReminderSlot slot;
  final DateTime at;
  final int hash;

  String encode() => jsonEncode({
        'v': 1,
        'i': instanceId,
        'k': slot.name,
        't': at.millisecondsSinceEpoch,
        'h': hash,
      });

  /// null — не наше уведомление (или битая нагрузка).
  static ReminderPayload? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final m = jsonDecode(raw);
      if (m is! Map || m['v'] != 1) return null;
      final i = m['i'], k = m['k'], t = m['t'], h = m['h'];
      if (i is! String || k is! String || t is! int || h is! int) return null;
      final slot = ReminderSlot.values.where((s) => s.name == k).firstOrNull;
      if (slot == null) return null;
      return ReminderPayload(instanceId: i, slot: slot, at: DateTime.fromMillisecondsSinceEpoch(t), hash: h);
    } on FormatException {
      return null;
    }
  }
}

/// Уже поставленное в систему уведомление (из getPendingNotificationRequests).
@immutable
class PendingReminder {
  const PendingReminder({required this.id, required this.payload});
  final int id;
  final String? payload;
}

/// Что снять и что поставить, чтобы система совпала с планом.
@immutable
class ReminderWindowDiff {
  const ReminderWindowDiff({required this.plan, required this.cancel, required this.schedule, required this.kept});

  /// Итоговое окно (без сохранённых упрёков).
  final List<PlannedReminder> plan;
  final List<int> cancel;
  final List<PlannedReminder> schedule;

  /// id упрёков, оставленных без изменений (квест уже провален движком, но не выполнен).
  final List<int> kept;
}

/// FNV-1a 32 бит по UTF-8. Стабилен между запусками (в отличие от String.hashCode).
int fnv1a32(String s) {
  var h = 0x811C9DC5;
  for (final b in utf8.encode(s)) {
    h ^= b;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h;
}

/// Базовый id слота (до разрешения коллизий).
int reminderBaseId(String instanceId, ReminderSlot slot, int seq) =>
    fnv1a32('$instanceId#${slot.name}#$seq') & _windowIdMask;

/// id немедленного уведомления (showNow) — вне диапазона окна.
int immediateNotificationId(String key) => _immediateIdBit | (fnv1a32(key) & _windowIdMask);

int _minuteOfDay(DateTime t) => t.hour * 60 + t.minute;

/// Попадает ли [t] в тихие часы. start == end — тихих часов нет.
bool isQuietAt(DateTime t, QuietHours? q) {
  if (q == null || q.startMinute == q.endMinute) return false;
  final m = _minuteOfDay(t);
  return q.startMinute < q.endMinute
      ? m >= q.startMinute && m < q.endMinute
      : m >= q.startMinute || m < q.endMinute; // через полночь
}

/// Ближайший конец тихих часов после [t].
DateTime quietEndAfter(DateTime t, QuietHours q) {
  final end = DateTime(t.year, t.month, t.day, 0, q.endMinute);
  return end.isAfter(t) ? end : DateTime(t.year, t.month, t.day + 1, 0, q.endMinute);
}

/// Окно уведомлений: ближайшие по времени [capacity] штук (ближайшее важнее), прошлое не планируется.
/// [reservedIds] — id, занятые вне плана (сохранённые упрёки): новые id с ними не совпадут.
List<PlannedReminder> planReminderWindow(
  List<ReminderRequest> requests,
  ReminderPrefs prefs, {
  required DateTime now,
  int capacity = reminderWindowCapacity,
  Set<int> reservedIds = const {},
}) {
  if (!prefs.enabled || capacity <= 0) return const [];
  final slots = <_Slot>[];
  final seen = <String>{};
  for (final r in requests) {
    if (!seen.add(r.instanceId)) continue;
    _collect(r, prefs, now, capacity, slots);
  }
  slots.sort(_Slot.compare);
  final used = {...reservedIds};
  final out = <PlannedReminder>[];
  for (final s in slots.take(capacity)) {
    var id = reminderBaseId(s.req.instanceId, s.slot, s.seq);
    while (!used.add(id)) {
      id = (id + 1) & _windowIdMask; // коллизия — следующий свободный, детерминированно
    }
    final reproach = s.slot == ReminderSlot.reproach;
    out.add(PlannedReminder(
      id: id,
      instanceId: s.req.instanceId,
      slot: s.slot,
      seq: s.seq,
      at: s.at,
      title: reproach ? s.req.reproachTitle ?? s.req.title : s.req.title,
      body: reproach ? s.req.reproachBody ?? '' : s.req.body,
    ));
  }
  return out;
}

void _collect(ReminderRequest r, ReminderPrefs prefs, DateTime now, int limit, List<_Slot> out) {
  final quiet = prefs.quiet;
  if (prefs.nag && r.nag) {
    // Каждую минуту от dueAt до дедлайна и ещё [nagOverrun]; тихие минуты пропускаются.
    final lastDeadline = r.deadlineAt.isAfter(r.dueAt) ? r.deadlineAt : r.dueAt;
    final end = lastDeadline.add(nagOverrun);
    var k = r.dueAt.isAfter(now) ? 0 : now.difference(r.dueAt).inMinutes + 1;
    var added = 0;
    while (added < limit) {
      final at = r.dueAt.add(nagStep * k);
      if (at.isAfter(end)) break;
      if (!isQuietAt(at, quiet)) {
        out.add(_Slot(r, k == 0 ? ReminderSlot.due : ReminderSlot.nag, k, at));
        added++;
      }
      k++;
    }
  } else {
    // Одно напоминание; из тихих часов — на их конец, если ещё до дедлайна.
    var at = r.dueAt;
    if (quiet != null && isQuietAt(at, quiet)) at = quietEndAfter(at, quiet);
    if (at.isAfter(now) && !at.isAfter(r.deadlineAt)) out.add(_Slot(r, ReminderSlot.due, 0, at));
  }
  if (prefs.reproach && r.reproachTitle != null) {
    var at = r.deadlineAt.add(reproachDelay);
    if (quiet != null && isQuietAt(at, quiet)) at = quietEndAfter(at, quiet);
    if (at.isAfter(now)) out.add(_Slot(r, ReminderSlot.reproach, 0, at));
  }
}

class _Slot {
  _Slot(this.req, this.slot, this.seq, this.at);
  final ReminderRequest req;
  final ReminderSlot slot;
  final int seq;
  final DateTime at;

  static int compare(_Slot a, _Slot b) {
    final t = a.at.compareTo(b.at);
    if (t != 0) return t;
    // При равном времени упрёк важнее повтора.
    final s = _rank(a.slot).compareTo(_rank(b.slot));
    if (s != 0) return s;
    final i = a.req.instanceId.compareTo(b.req.instanceId);
    return i != 0 ? i : a.seq.compareTo(b.seq);
  }

  static int _rank(ReminderSlot s) => switch (s) {
        ReminderSlot.reproach => 0,
        ReminderSlot.due => 1,
        ReminderSlot.nag => 2,
      };
}

/// Перепланирование: по уже поставленным [pending] и новому списку квестов — что снять и что поставить.
/// Упрёки квестов, которых больше нет в списке (движок закрыл их провалом), сохраняются до срабатывания:
/// SPEC §7 — упрёк отменяется только при выполнении (это делает cancelInstance).
ReminderWindowDiff diffReminderWindow(
  List<PendingReminder> pending,
  List<ReminderRequest> requests,
  ReminderPrefs prefs, {
  required DateTime now,
  int capacity = reminderWindowCapacity,
}) {
  final current = {for (final r in requests) r.instanceId};
  final ours = <int, ReminderPayload>{};
  for (final p in pending) {
    final payload = ReminderPayload.decode(p.payload);
    if (payload != null) ours[p.id] = payload; // чужие уведомления (будущие этапы) не трогаем
  }
  final kept = <int>[];
  if (prefs.enabled && prefs.reproach) {
    for (final e in ours.entries) {
      final p = e.value;
      if (p.slot == ReminderSlot.reproach && !current.contains(p.instanceId) && p.at.isAfter(now)) kept.add(e.key);
    }
    kept.sort();
    if (kept.length > capacity) kept.removeRange(capacity, kept.length);
  }
  final plan = planReminderWindow(
    requests,
    prefs,
    now: now,
    capacity: capacity - kept.length,
    reservedIds: kept.toSet(),
  );
  final planIds = {for (final p in plan) p.id};
  final keptIds = kept.toSet();
  final cancel = [
    for (final id in ours.keys)
      if (!planIds.contains(id) && !keptIds.contains(id)) id,
  ]..sort();
  final schedule = [
    for (final p in plan)
      if (ours[p.id]?.encode() != p.payload) p,
  ];
  return ReminderWindowDiff(plan: plan, cancel: cancel, schedule: schedule, kept: kept);
}
