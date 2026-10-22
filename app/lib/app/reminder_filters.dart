// Правка окна напоминаний перед планированием (ReminderCoordinator.templateFilter): без шаблонного упрёка там,
// где упрекает ИИ (этап 6), + напоминания финансов о подписках и долгах (этап 7, instanceId с префиксом 'fin:'),
// + режимы дня (§8.13): во время занятости напоминания тихие и переносятся на её конец; «Итоги дня» перед отбоем.
import '../core/db/database.dart';
import '../domain/day_modes/day_modes.dart';
import '../features/day_summary/day_summary_screen.dart' show daySummaryReminderPrefix;
import '../features/schedule/data/schedule_repository.dart';
import '../l10n/app_localizations.dart';
import '../core/notifications/ai_messages_sync.dart';
import '../core/notifications/notification_api.dart';
import '../core/notifications/reminder_texts.dart';
import '../features/finance/data/finance_repository.dart';
import '../features/finance/finance_summary.dart';

export '../features/finance/finance_summary.dart' show financeReminderPrefix;

Future<List<ReminderRequest>> Function(List<ReminderRequest>) reminderTemplateFilter(AppDatabase db) {
  final ai = aiReproachFilter(db);
  final finance = FinanceRepository(db);
  final modes = DayModesService(db);
  return (requests) async {
    var out = await ai(requests);
    try {
      out = await _quietDuringBusy(modes, out);
    } catch (_) {}
    try {
      out = [...out, ...await financeReminderRequests(finance, await reminderL10n(db), DateTime.now())];
    } catch (_) {
      // финансы не должны ломать напоминания квестов
    }
    try {
      final summary = await _daySummaryRequest(db, modes, await reminderL10n(db), DateTime.now());
      if (summary != null) out = [...out, summary];
    } catch (_) {}
    return out;
  };
}

/// Напоминание, попавшее на занятость, — тихое (без повторов) и в конце занятости.
Future<List<ReminderRequest>> _quietDuringBusy(DayModesService modes, List<ReminderRequest> requests) async {
  final byDay = <DateTime, List<(DateTime, DateTime)>>{};
  final out = <ReminderRequest>[];
  for (final r in requests) {
    final day = DateTime(r.dueAt.year, r.dueAt.month, r.dueAt.day);
    final windows = byDay[day] ??= await modes.busyWindows(day);
    DateTime? end;
    for (final (s, e) in windows) {
      if (!r.dueAt.isBefore(s) && r.dueAt.isBefore(e)) end = e;
    }
    if (end == null || !end.isBefore(r.deadlineAt)) {
      out.add(r);
      continue;
    }
    out.add(ReminderRequest(
      instanceId: r.instanceId,
      title: r.title,
      body: r.body,
      dueAt: end,
      deadlineAt: r.deadlineAt,
      nag: false,
      reproachTitle: r.reproachTitle,
      reproachBody: r.reproachBody,
    ));
  }
  return out;
}

/// «Итоги дня» за 30 минут до отбоя (сегодня или, если уже поздно, завтра).
Future<ReminderRequest?> _daySummaryRequest(
  AppDatabase db,
  DayModesService modes,
  AppLocalizations l,
  DateTime now,
) async {
  if (!(await modes.prefs()).daySummary) return null;
  final bed = (await ScheduleRepository(db).getConfig()).bedMinute;
  var day = DateTime(now.year, now.month, now.day);
  var at = day.add(Duration(minutes: bed - 30));
  if (!at.isAfter(now)) {
    day = DateTime(day.year, day.month, day.day + 1);
    at = day.add(Duration(minutes: bed - 30));
  }
  final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  return ReminderRequest(
    instanceId: '$daySummaryReminderPrefix$key',
    title: l.sumNotifTitle,
    body: l.sumNotifBody,
    dueAt: at,
    deadlineAt: at.add(const Duration(hours: 1)),
    nag: false,
  );
}
