// КОНТРАКТ каркаса (сигнатуры фиксированы главным агентом). Тела реализует сабагент C.
// Чистая логика без Flutter/БД — покрывается юнит-тестами. Используется планом (D) и главным экраном.
import '../../core/db/database.dart';
import '../../core/models/enums.dart';

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

  factory ScheduleConfig.fromRow(ScheduleSettingsRow? row) => throw UnimplementedError('C');

  final bool alternationEnabled;

  /// Понедельник «недели 1» (дата без времени). null — неделя 1 = текущая.
  final DateTime? week1Anchor;
  final int wakeMinute;
  final int bedMinute;
  final int commuteMinutes;
  final Set<int> weekendDays;
  final InstitutionType? institutionType;
  final String? institutionName;
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

  factory ScheduleEntry.fromRow(ScheduleItemRow row) => throw UnimplementedError('C');

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
}

abstract final class ScheduleLogic {
  /// Номер недели (1 или 2) для даты. Без чередования — всегда 1.
  static int weekNumber(DateTime date, ScheduleConfig config) => throw UnimplementedError('C');

  /// Пункты на дату (с учётом дня недели и чётности), по времени начала.
  static List<ScheduleEntry> entriesFor(DateTime date, ScheduleConfig config, List<ScheduleEntry> all) =>
      throw UnimplementedError('C');

  /// Время выхода из дома (минута суток) = начало первого пункта с requiresCommute − дорога.
  /// null — в этот день выходить не нужно.
  static int? leaveHomeMinute(DateTime date, ScheduleConfig config, List<ScheduleEntry> all) =>
      throw UnimplementedError('C');

  /// Ручное переключение недели: новый якорь, при котором текущая неделя [today] сменит номер.
  static DateTime switchedAnchor(DateTime today, ScheduleConfig config) => throw UnimplementedError('C');
}
