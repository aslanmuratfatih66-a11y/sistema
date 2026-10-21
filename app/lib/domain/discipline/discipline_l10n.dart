// Локализация режима дисциплины: названия квестов (подключается в quest_l10n.questTitleText) и статус.
import '../../l10n/app_localizations.dart';
import 'discipline_rules.dart';

/// Название квеста дисциплины по ключу; null — ключ не из режима дисциплины.
String? disciplineQuestTitle(AppLocalizations l, String key, Map<String, Object?> params) {
  int minutes(int fallback) => params['minutes'] is num ? (params['minutes']! as num).round() : fallback;
  String time(int fallback) => params['time'] is String ? params['time']! as String : disciplineTime(fallback);
  return switch (key) {
    DisciplineQuestKeys.wake => l.dscQuestWake(time(DisciplineRules.wakeMinute)),
    DisciplineQuestKeys.bed => l.dscQuestBed(time(DisciplineRules.bedMinute)),
    DisciplineQuestKeys.workout => l.dscQuestWorkout(minutes(DisciplineRules.extraMinutesByLevel.values.first)),
    DisciplineQuestKeys.walk => l.dscQuestWalk(minutes(DisciplineRules.walkMinutes)),
    _ => null,
  };
}

String disciplineReasonLabel(AppLocalizations l, DisciplineReason r) => switch (r) {
      DisciplineReason.debt => l.dscReasonDebt,
      DisciplineReason.manual => l.dscReasonManual,
      DisciplineReason.ai => l.dscReasonAi,
    };

String disciplineExitLabel(AppLocalizations l, DisciplineExit e) => switch (e) {
      DisciplineExit.balancePositive => l.dscExitBalancePositive,
      DisciplineExit.manual => l.dscExitManual,
    };
