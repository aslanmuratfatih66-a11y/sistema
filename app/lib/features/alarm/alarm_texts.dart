// Общие подписи будильников (дни недели, задание).
import '../../core/alarm/alarm_schedule.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';

List<String> almDayNames(AppLocalizations l) =>
    [l.almDayMon, l.almDayTue, l.almDayWed, l.almDayThu, l.almDayFri, l.almDaySat, l.almDaySun];

String almDaysText(AppLocalizations l, int mask) {
  if (mask == 0) return l.almDaysOnce;
  if (mask == alarmAllDays) return l.almDaysEveryday;
  if (mask == alarmWorkDays) return l.almDaysWeekdays;
  if (mask == 96) return l.almDaysWeekend;
  final names = almDayNames(l);
  return [
    for (var d = 1; d <= 7; d++)
      if (mask & alarmWeekdayBit(d) != 0) names[d - 1],
  ].join(', ');
}

AlarmTask almTaskOf(AlarmRow a) => AlarmTask.values.where((t) => t.name == a.task).firstOrNull ?? AlarmTask.squats;

String almTaskText(AppLocalizations l, AlarmRow a) =>
    almTaskOf(a) == AlarmTask.qr ? l.almTaskQr : l.almTaskSquatsShort(a.squats);
