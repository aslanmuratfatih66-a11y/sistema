// Подписи перечислений вкладки «Квесты» (строки — во фрагменте l10n_parts/qst_*.arb).
import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import 'quest_format.dart';

String kindFilterLabel(AppLocalizations l, QuestKindFilter k) => switch (k) {
      QuestKindFilter.daily => l.qstKindDaily,
      QuestKindFilter.schedule => l.qstKindSchedule,
      QuestKindFilter.goal => l.qstKindGoal,
      QuestKindFilter.penalty => l.qstKindPenalty,
      QuestKindFilter.boss => l.qstKindBoss,
    };

String questStatusLabel(AppLocalizations l, QuestStatus s) => switch (s) {
      QuestStatus.pending => l.qstStatusPending,
      QuestStatus.done => l.qstStatusDone,
      QuestStatus.failed => l.qstStatusFailed,
      QuestStatus.refused => l.qstStatusRefused,
      QuestStatus.excused => l.qstStatusExcused,
    };

String pauseReasonLabel(AppLocalizations l, PauseReason r) => switch (r) {
      PauseReason.illness => l.qstPauseReasonIllness,
      PauseReason.vacation => l.qstPauseReasonVacation,
      PauseReason.holidays => l.qstPauseReasonHolidays,
      PauseReason.other => l.qstPauseReasonOther,
    };

String dayMarkLabel(AppLocalizations l, DayMark m) => switch (m) {
      DayMark.walkedWithFriends => l.qstMarkWalked,
      DayMark.alcohol => l.qstMarkAlcohol,
      DayMark.relapse => l.qstMarkRelapse,
    };

String historyTypeLabel(AppLocalizations l, QuestEventType t) => switch (t) {
      QuestEventType.completed => l.qstHistCompleted,
      QuestEventType.failed => l.qstHistFailed,
      QuestEventType.refused => l.qstHistRefused,
      QuestEventType.penalty => l.qstHistPenalty,
      QuestEventType.bonus => l.qstHistBonus,
      QuestEventType.purchase => l.qstHistPurchase,
      QuestEventType.mark => l.qstHistMark,
      QuestEventType.pauseStarted => l.qstHistPauseStarted,
      QuestEventType.pauseEnded => l.qstHistPauseEnded,
      QuestEventType.statPointSpent => l.qstHistStatPoint,
      QuestEventType.bossCompleted => l.qstHistBossCompleted,
      QuestEventType.bossFailed => l.qstHistBossFailed,
      QuestEventType.disciplineOn => l.qstHistDisciplineOn,
      QuestEventType.disciplineOff => l.qstHistDisciplineOff,
      QuestEventType.adjustment => l.qstHistAdjustment,
    };
