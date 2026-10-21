// Локализация ключей плана (квесты, распорядок, предупреждения) при показе.
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../onboarding/onboarding_step.dart';
import 'model/plan.dart';
import 'norms/plan_calculator.dart';

String planWeekdayShort(AppLocalizations l, int weekday) => switch (weekday) {
      DateTime.monday => l.planWdMon,
      DateTime.tuesday => l.planWdTue,
      DateTime.wednesday => l.planWdWed,
      DateTime.thursday => l.planWdThu,
      DateTime.friday => l.planWdFri,
      DateTime.saturday => l.planWdSat,
      _ => l.planWdSun,
    };

String planDuration(AppLocalizations l, int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? l.planHours('$h') : l.planHoursMinutes('$h', '$m');
}

String _hours(num h) => h == h.roundToDouble() ? '${h.toInt()}' : h.toStringAsFixed(1);

String planQuestTitle(AppLocalizations l, QuestDraft q) {
  final p = q.params;
  final time = q.minute == null ? '' : formatMinuteOfDay(q.minute!);
  String s(String key) => '${p[key] ?? ''}';
  return switch (q.key) {
    QuestKey.leaveHome => l.planQuestLeaveHome(time),
    QuestKey.attendLesson => l.planQuestAttendLesson(s('title')),
    QuestKey.attendWork => l.planQuestAttendWork(s('title')),
    QuestKey.water => l.planQuestWater(s('ml')),
    QuestKey.sleepOnTime => l.planQuestSleep(time, _hours((p['hours'] as num?) ?? 8)),
    QuestKey.meals => l.planQuestMeals(s('count')),
    QuestKey.training => l.planQuestTraining(s('minutes')),
    QuestKey.skincareMorning => l.planQuestSkincareMorning,
    QuestKey.skincareEvening => l.planQuestSkincareEvening,
    QuestKey.wakeOnTime => l.planQuestWakeOnTime(time),
    QuestKey.study => l.planQuestStudy(s('minutes')),
    QuestKey.trackExpenses => l.planQuestTrackExpenses,
  };
}

/// Когда: «Пн, Ср · 08:30 · неделя 2» / «каждый день».
String planQuestWhen(AppLocalizations l, QuestDraft q) {
  final parts = <String>[
    if (q.weekdays.isEmpty || q.weekdays.length == 7)
      l.planQuestEveryDay
    else
      q.weekdays.map((d) => planWeekdayShort(l, d)).join(', '),
    if (q.minute != null && q.key != QuestKey.leaveHome && q.key != QuestKey.sleepOnTime && q.key != QuestKey.wakeOnTime)
      formatMinuteOfDay(q.minute!),
    if (q.week != 0) l.planQuestWeekOnly('${q.week}'),
  ];
  return parts.join(' · ');
}

String planRoutineLabel(AppLocalizations l, RoutineItem i) => switch (i.kind) {
      RoutineKind.wake => l.planRoutineWake,
      RoutineKind.skincareAm => l.planRoutineSkincareAm,
      RoutineKind.meal => l.planRoutineMeal('${i.index ?? 1}'),
      RoutineKind.leaveHome => l.planRoutineLeaveHome,
      RoutineKind.lesson => i.title?.isNotEmpty == true ? i.title! : l.planRoutineLesson,
      RoutineKind.work => i.title?.isNotEmpty == true ? i.title! : l.planRoutineWork,
      RoutineKind.other => i.title?.isNotEmpty == true ? i.title! : l.planRoutineOther,
      RoutineKind.returnHome => l.planRoutineReturnHome,
      RoutineKind.training => l.planRoutineTraining,
      RoutineKind.skincarePm => l.planRoutineSkincarePm,
      RoutineKind.bed => l.planRoutineBed,
    };

SysGlyph planRoutineGlyph(RoutineKind k) => switch (k) {
      RoutineKind.wake => SysGlyph.bolt,
      RoutineKind.skincareAm || RoutineKind.skincarePm => SysGlyph.sparkle,
      RoutineKind.meal => SysGlyph.nutrition,
      RoutineKind.leaveHome || RoutineKind.returnHome => SysGlyph.home,
      RoutineKind.lesson => SysGlyph.book,
      RoutineKind.work => SysGlyph.wallet,
      RoutineKind.other => SysGlyph.clock,
      RoutineKind.training => SysGlyph.dumbbell,
      RoutineKind.bed => SysGlyph.moon,
    };

String planWarningText(AppLocalizations l, PlanWarning w) {
  final p = w.params;
  int i(String k) => (p[k] as num?)?.toInt() ?? 0;
  return switch (w.kind) {
    PlanWarningKind.sleepShort => l.planWarnSleepShort(
        planDuration(l, i('scheduledMinutes')),
        planDuration(l, i('targetMinutes')),
        formatMinuteOfDay(i('recommendedBed')),
      ),
    PlanWarningKind.deficitFloor => l.planWarnDeficitFloor,
    PlanWarningKind.activityDefaulted => l.planWarnActivityDefaulted,
    PlanWarningKind.noTrainingWindow => l.planWarnNoTrainingWindow(
        p['week'] != null
            ? '${planWeekdayShort(l, i('weekday'))} (${l.planWeek('${i('week')}')})'
            : planWeekdayShort(l, i('weekday')),
      ),
    PlanWarningKind.injuries => l.planWarnInjuries,
  };
}

String planMissingLabel(AppLocalizations l, MissingField f) => switch (f) {
      MissingField.sex => l.planMissingSex,
      MissingField.birthDate => l.planMissingBirthDate,
      MissingField.heightCm => l.planMissingHeight,
      MissingField.weightKg => l.planMissingWeight,
    };

/// Раздел анкеты, где заполняется поле.
OnboardingStep planMissingStep(MissingField f) => switch (f) {
      MissingField.sex || MissingField.birthDate => OnboardingStep.profile,
      MissingField.heightCm || MissingField.weightKg => OnboardingStep.body,
    };
