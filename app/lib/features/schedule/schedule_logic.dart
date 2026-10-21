// КОНТРАКТ каркаса (сигнатуры фиксированы главным агентом). Тела реализует сабагент C.
// Чистая логика без Flutter/БД — покрывается юнит-тестами. Используется планом (D) и главным экраном.
import '../../core/db/database.dart';
import '../../core/models/enums.dart';

const int _dayMinutes = 24 * 60;

/// Общие параметры расписания (из ScheduleSettingsRow).
class ScheduleConfig {
  const ScheduleConfig({
    this.alternationEnabled = false,
    this.week1Anchor,
    this.wakeMinute = 7 * 60,
    this.bedMinute = 23 * 60,
    this.commuteMinutes = 0,
    this.weekendDays = const {DateTime.saturday, DateTime.sunday},
    this.institutionType,
    this.institutionName,
  });

  /// null (настроек ещё нет) → значения по умолчанию.
  factory ScheduleConfig.fromRow(ScheduleSettingsRow? row) {
    if (row == null) return const ScheduleConfig();
    return ScheduleConfig(
      alternationEnabled: row.alternationEnabled,
      week1Anchor: row.week1Anchor,
      wakeMinute: row.wakeMinute,
      bedMinute: row.bedMinute,
      commuteMinutes: row.commuteMinutes,
      weekendDays: parseWeekendDays(row.weekendDays),
      institutionType: enumByName(InstitutionType.values, row.institutionType),
      institutionName: row.institutionName,
    );
  }

  /// '6,7' → {6, 7}. Мусор и значения вне 1..7 отбрасываются; пустая строка → пустое множество.
  static Set<int> parseWeekendDays(String raw) => {
        for (final p in raw.split(','))
          if (int.tryParse(p.trim()) case final d? when d >= DateTime.monday && d <= DateTime.sunday) d,
      };

  /// {7, 6} → '6,7' (формат колонки ScheduleSettings.weekendDays).
  static String formatWeekendDays(Set<int> days) => (days.toList()..sort()).join(',');

  final bool alternationEnabled;

  /// Понедельник «недели 1» (дата без времени).
  /// null — «неделя 1 всегда» (функции чистые, «текущую неделю» взять неоткуда). При включении чередования
  /// репозиторий обязан записать якорь (понедельник текущей недели).
  final DateTime? week1Anchor;
  final int wakeMinute;
  final int bedMinute;
  final int commuteMinutes;
  final Set<int> weekendDays;
  final InstitutionType? institutionType;
  final String? institutionName;

  bool isWeekend(DateTime date) => weekendDays.contains(date.weekday);
}

/// Пункт расписания (из ScheduleItemRow).
class ScheduleEntry {
  const ScheduleEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.weekday,
    required this.startMinute,
    required this.durationMinutes,
    this.weekParity = 0,
    this.location,
    this.requiresCommute = true,
  });

  factory ScheduleEntry.fromRow(ScheduleItemRow row) => ScheduleEntry(
        id: row.id,
        kind: enumByName(ScheduleItemKind.values, row.kind) ?? ScheduleItemKind.other,
        title: row.title,
        weekday: row.weekday,
        startMinute: row.startMinute,
        durationMinutes: row.durationMinutes,
        weekParity: row.weekParity,
        location: row.location,
        requiresCommute: row.requiresCommute,
      );

  final String id;
  final ScheduleItemKind kind;
  final String title;
  final int weekday; // DateTime.monday..sunday
  final int startMinute;
  final int durationMinutes;
  final int weekParity; // 0 — каждую неделю, 1 / 2 — только эту
  final String? location;
  final bool requiresCommute;

  int get endMinute => startMinute + durationMinutes;

  ScheduleEntry copyWith({
    String? id,
    ScheduleItemKind? kind,
    String? title,
    int? weekday,
    int? startMinute,
    int? durationMinutes,
    int? weekParity,
    String? Function()? location,
    bool? requiresCommute,
  }) =>
      ScheduleEntry(
        id: id ?? this.id,
        kind: kind ?? this.kind,
        title: title ?? this.title,
        weekday: weekday ?? this.weekday,
        startMinute: startMinute ?? this.startMinute,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        weekParity: weekParity ?? this.weekParity,
        location: location != null ? location() : this.location,
        requiresCommute: requiresCommute ?? this.requiresCommute,
      );
}

/// Отрезок дня в минутах суток [start, end).
class ScheduleWindow {
  const ScheduleWindow(this.startMinute, this.endMinute);
  final int startMinute;
  final int endMinute;

  int get minutes => endMinute - startMinute;

  @override
  bool operator ==(Object other) =>
      other is ScheduleWindow && other.startMinute == startMinute && other.endMinute == endMinute;

  @override
  int get hashCode => Object.hash(startMinute, endMinute);

  @override
  String toString() => 'ScheduleWindow($startMinute–$endMinute)';
}

/// Тип отрезка ленты дня.
enum ScheduleSlotType { sleep, commute, entry, free }

/// Отрезок ленты дня (сон / дорога / пункт расписания / свободно).
class ScheduleSlot {
  const ScheduleSlot(this.type, this.startMinute, this.endMinute, {this.entry});
  final ScheduleSlotType type;
  final int startMinute;
  final int endMinute;

  /// Для [ScheduleSlotType.entry].
  final ScheduleEntry? entry;
}

abstract final class ScheduleLogic {
  /// Понедельник недели даты (локальная дата без времени).
  static DateTime mondayOf(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return DateTime(d.year, d.month, d.day - (d.weekday - DateTime.monday));
  }

  /// Число календарных дней между датами (b − a). Считается по UTC-датам — без влияния перехода на летнее время.
  static int daysBetween(DateTime a, DateTime b) =>
      DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

  /// Номер недели (1 или 2) для даты. Без чередования — всегда 1.
  /// Якорь null — тоже 1 (см. [ScheduleConfig.week1Anchor]).
  static int weekNumber(DateTime date, ScheduleConfig config) {
    final anchor = config.week1Anchor;
    if (!config.alternationEnabled || anchor == null) return 1;
    final days = daysBetween(mondayOf(anchor), mondayOf(date)); // кратно 7, может быть < 0
    final weeks = days ~/ 7;
    return weeks.isEven ? 1 : 2; // isEven корректен и для отрицательных
  }

  /// Пункты на дату (с учётом дня недели и чётности), по времени начала.
  /// Без чередования неделя всегда 1: пункты «только неделя 2» не показываются.
  /// В выходные (weekendDays) явно заведённые пункты всё равно показываются.
  static List<ScheduleEntry> entriesFor(DateTime date, ScheduleConfig config, List<ScheduleEntry> all) {
    final week = weekNumber(date, config);
    final res = [
      for (final e in all)
        if (e.weekday == date.weekday && (e.weekParity == 0 || e.weekParity == week)) e,
    ]..sort((a, b) {
        final c = a.startMinute.compareTo(b.startMinute);
        return c != 0 ? c : a.endMinute.compareTo(b.endMinute);
      });
    return res;
  }

  /// Время выхода из дома (минута суток) = начало первого пункта с requiresCommute − дорога (не меньше 0).
  /// null — в этот день выходить не нужно.
  static int? leaveHomeMinute(DateTime date, ScheduleConfig config, List<ScheduleEntry> all) {
    for (final e in entriesFor(date, config, all)) {
      if (e.requiresCommute) {
        final m = e.startMinute - config.commuteMinutes;
        return m < 0 ? 0 : m;
      }
    }
    return null;
  }

  /// Время возвращения домой: конец последнего пункта с дорогой + дорога. null — не выходили.
  static int? returnHomeMinute(DateTime date, ScheduleConfig config, List<ScheduleEntry> all) {
    int? lastEnd;
    for (final e in entriesFor(date, config, all)) {
      if (e.requiresCommute && (lastEnd == null || e.endMinute > lastEnd)) lastEnd = e.endMinute;
    }
    if (lastEnd == null) return null;
    final m = lastEnd + config.commuteMinutes;
    return m > _dayMinutes ? _dayMinutes : m;
  }

  /// Ручное переключение недели: новый якорь, при котором текущая неделя [today] сменит номер.
  /// Якоря нет → берётся понедельник недели [today] (сейчас она «неделя 1») и сдвигается на 7 дней назад —
  /// [today] становится «неделей 2». Повторный вызов возвращает номер обратно.
  /// Имеет смысл при включённом чередовании.
  static DateTime switchedAnchor(DateTime today, ScheduleConfig config) {
    final anchor = mondayOf(config.week1Anchor ?? today);
    return DateTime(anchor.year, anchor.month, anchor.day - 7);
  }

  /// Конец бодрствования (минута суток). Отбой после полуночи (bed ≤ wake) — до конца суток.
  static int _dayEnd(ScheduleConfig c) => c.bedMinute > c.wakeMinute ? c.bedMinute : _dayMinutes;

  /// Занятые отрезки дня: пункты + дорога туда/обратно; слиты и отсортированы, обрезаны до суток.
  static List<ScheduleWindow> busyWindows(DateTime date, ScheduleConfig config, List<ScheduleEntry> all) {
    final raw = <ScheduleWindow>[
      for (final e in entriesFor(date, config, all)) ScheduleWindow(e.startMinute, e.endMinute),
    ];
    final leave = leaveHomeMinute(date, config, all);
    final back = returnHomeMinute(date, config, all);
    if (config.commuteMinutes > 0 && leave != null && back != null) {
      raw
        ..add(ScheduleWindow(leave, leave + config.commuteMinutes))
        ..add(ScheduleWindow(back - config.commuteMinutes, back));
    }
    return _merge(raw);
  }

  /// Свободные окна между пунктами в пределах подъём..отбой (с учётом дороги). Окна короче [minMinutes] отбрасываются.
  static List<ScheduleWindow> freeWindows(
    DateTime date,
    ScheduleConfig config,
    List<ScheduleEntry> all, {
    int minMinutes = 1,
  }) {
    final from = config.wakeMinute;
    final to = _dayEnd(config);
    final res = <ScheduleWindow>[];
    var cursor = from;
    for (final b in busyWindows(date, config, all)) {
      if (b.endMinute <= cursor) continue;
      if (b.startMinute >= to) break;
      if (b.startMinute > cursor) res.add(ScheduleWindow(cursor, b.startMinute));
      cursor = b.endMinute;
    }
    if (cursor < to) res.add(ScheduleWindow(cursor, to));
    return [for (final w in res) if (w.minutes >= minMinutes) w];
  }

  /// Свободных минут за день (в пределах подъём..отбой).
  static int freeMinutes(DateTime date, ScheduleConfig config, List<ScheduleEntry> all) =>
      freeWindows(date, config, all).fold(0, (s, w) => s + w.minutes);

  /// Лента дня 00:00–24:00: сон, дорога, пункты, свободно. Для экрана расписания и главного экрана.
  static List<ScheduleSlot> dayTimeline(DateTime date, ScheduleConfig config, List<ScheduleEntry> all) {
    final slots = <ScheduleSlot>[];
    final wake = config.wakeMinute.clamp(0, _dayMinutes);
    final bed = config.bedMinute.clamp(0, _dayMinutes);
    if (bed > wake) {
      if (wake > 0) slots.add(ScheduleSlot(ScheduleSlotType.sleep, 0, wake));
      if (bed < _dayMinutes) slots.add(ScheduleSlot(ScheduleSlotType.sleep, bed, _dayMinutes));
    } else if (wake > bed) {
      slots.add(ScheduleSlot(ScheduleSlotType.sleep, bed, wake));
    }
    final leave = leaveHomeMinute(date, config, all);
    final back = returnHomeMinute(date, config, all);
    if (config.commuteMinutes > 0 && leave != null && back != null) {
      final first = entriesFor(date, config, all).firstWhere((e) => e.requiresCommute);
      if (first.startMinute > leave) slots.add(ScheduleSlot(ScheduleSlotType.commute, leave, first.startMinute));
      final start = back - config.commuteMinutes;
      if (back > start) slots.add(ScheduleSlot(ScheduleSlotType.commute, start, back));
    }
    for (final e in entriesFor(date, config, all)) {
      slots.add(ScheduleSlot(ScheduleSlotType.entry, e.startMinute, e.endMinute.clamp(0, _dayMinutes), entry: e));
    }
    for (final w in freeWindows(date, config, all)) {
      slots.add(ScheduleSlot(ScheduleSlotType.free, w.startMinute, w.endMinute));
    }
    slots.sort((a, b) => a.startMinute.compareTo(b.startMinute));
    return slots;
  }

  static List<ScheduleWindow> _merge(List<ScheduleWindow> raw) {
    final list = [
      for (final w in raw)
        if (w.endMinute > w.startMinute) ScheduleWindow(w.startMinute.clamp(0, _dayMinutes), w.endMinute.clamp(0, _dayMinutes)),
    ]..sort((a, b) => a.startMinute.compareTo(b.startMinute));
    final res = <ScheduleWindow>[];
    for (final w in list) {
      if (res.isNotEmpty && w.startMinute <= res.last.endMinute) {
        final last = res.removeLast();
        res.add(ScheduleWindow(last.startMinute, w.endMinute > last.endMinute ? w.endMinute : last.endMinute));
      } else {
        res.add(w);
      }
    }
    return res;
  }
}
