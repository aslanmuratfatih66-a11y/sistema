// Локализация раздела: названия и подсказки упражнений, фразы голосовых подсказок.
import '../../l10n/app_localizations.dart';
import 'domain/workout_runner.dart';
import 'model/exercise_catalog.dart';

/// Название упражнения; неизвестный ключ (программа ИИ) — сам ключ.
String exerciseName(AppLocalizations l, String key) => switch (key) {
      'marchInPlace' => l.wrkExMarchInPlace,
      'armCircles' => l.wrkExArmCircles,
      'jumpingJacks' => l.wrkExJumpingJacks,
      'chairSquat' => l.wrkExChairSquat,
      'gluteBridge' => l.wrkExGluteBridge,
      'squat' => l.wrkExSquat,
      'wallSit' => l.wrkExWallSit,
      'reverseLunge' => l.wrkExReverseLunge,
      'gobletSquat' => l.wrkExGobletSquat,
      'kettlebellSwing' => l.wrkExKettlebellSwing,
      'jumpSquat' => l.wrkExJumpSquat,
      'wallPushUp' => l.wrkExWallPushUp,
      'kneePushUp' => l.wrkExKneePushUp,
      'pushUp' => l.wrkExPushUp,
      'dumbbellPress' => l.wrkExDumbbellPress,
      'diamondPushUp' => l.wrkExDiamondPushUp,
      'superman' => l.wrkExSuperman,
      'reverseSnowAngel' => l.wrkExReverseSnowAngel,
      'bandRow' => l.wrkExBandRow,
      'dumbbellRow' => l.wrkExDumbbellRow,
      'pullUp' => l.wrkExPullUp,
      'deadBug' => l.wrkExDeadBug,
      'birdDog' => l.wrkExBirdDog,
      'plank' => l.wrkExPlank,
      'crunch' => l.wrkExCrunch,
      'sidePlank' => l.wrkExSidePlank,
      'legRaise' => l.wrkExLegRaise,
      'stepTouch' => l.wrkExStepTouch,
      'shadowBoxing' => l.wrkExShadowBoxing,
      'highKnees' => l.wrkExHighKnees,
      'mountainClimber' => l.wrkExMountainClimber,
      'burpee' => l.wrkExBurpee,
      'fullBodyStretch' => l.wrkExFullBodyStretch,
      _ => key,
    };

/// Техника по шагам (строки через перевод строки); неизвестный ключ — пусто.
String exerciseHint(AppLocalizations l, String key) => switch (key) {
      'marchInPlace' => l.wrkExMarchInPlaceHint,
      'armCircles' => l.wrkExArmCirclesHint,
      'jumpingJacks' => l.wrkExJumpingJacksHint,
      'chairSquat' => l.wrkExChairSquatHint,
      'gluteBridge' => l.wrkExGluteBridgeHint,
      'squat' => l.wrkExSquatHint,
      'wallSit' => l.wrkExWallSitHint,
      'reverseLunge' => l.wrkExReverseLungeHint,
      'gobletSquat' => l.wrkExGobletSquatHint,
      'kettlebellSwing' => l.wrkExKettlebellSwingHint,
      'jumpSquat' => l.wrkExJumpSquatHint,
      'wallPushUp' => l.wrkExWallPushUpHint,
      'kneePushUp' => l.wrkExKneePushUpHint,
      'pushUp' => l.wrkExPushUpHint,
      'dumbbellPress' => l.wrkExDumbbellPressHint,
      'diamondPushUp' => l.wrkExDiamondPushUpHint,
      'superman' => l.wrkExSupermanHint,
      'reverseSnowAngel' => l.wrkExReverseSnowAngelHint,
      'bandRow' => l.wrkExBandRowHint,
      'dumbbellRow' => l.wrkExDumbbellRowHint,
      'pullUp' => l.wrkExPullUpHint,
      'deadBug' => l.wrkExDeadBugHint,
      'birdDog' => l.wrkExBirdDogHint,
      'plank' => l.wrkExPlankHint,
      'crunch' => l.wrkExCrunchHint,
      'sidePlank' => l.wrkExSidePlankHint,
      'legRaise' => l.wrkExLegRaiseHint,
      'stepTouch' => l.wrkExStepTouchHint,
      'shadowBoxing' => l.wrkExShadowBoxingHint,
      'highKnees' => l.wrkExHighKneesHint,
      'mountainClimber' => l.wrkExMountainClimberHint,
      'burpee' => l.wrkExBurpeeHint,
      'fullBodyStretch' => l.wrkExFullBodyStretchHint,
      _ => '',
    };

String levelLabel(AppLocalizations l, WorkoutLevel level) => switch (level) {
      WorkoutLevel.beginner => l.qbLevelBeginner,
      WorkoutLevel.intermediate => l.qbLevelIntermediate,
      WorkoutLevel.advanced => l.qbLevelAdvanced,
    };

/// Короткие подписи дней недели (DateTime.weekday 1..7).
String weekdayShort(AppLocalizations l, int weekday) => switch (weekday) {
      DateTime.monday => l.qbDayMon,
      DateTime.tuesday => l.qbDayTue,
      DateTime.wednesday => l.qbDayWed,
      DateTime.thursday => l.qbDayThu,
      DateTime.friday => l.qbDayFri,
      DateTime.saturday => l.qbDaySat,
      _ => l.qbDaySun,
    };

/// Фразы голосовых подсказок (в тестах — свои).
abstract interface class WorkoutPhrases {
  /// null — событие не озвучивается.
  String? phrase(WorkoutCue cue);
}

class L10nWorkoutPhrases implements WorkoutPhrases {
  const L10nWorkoutPhrases(this.l);

  final AppLocalizations l;

  @override
  String? phrase(WorkoutCue cue) => switch (cue) {
        CuePrepare(:final exerciseKey) => l.wrkSayPrepare(exerciseName(l, exerciseKey)),
        CueWorkStart(:final step) => l.wrkSaySet(
            step.set,
            step.sets,
            step.timed ? l.wrkSecondsAmount(step.item.seconds!) : l.wrkRepsTarget(step.item.reps ?? 0),
          ),
        CueCountdown(:final seconds) => '$seconds',
        CueRest(:final seconds, :final nextExerciseKey) => nextExerciseKey == null
            ? l.wrkSayRest(l.wrkSecondsAmount(seconds))
            : '${l.wrkSayRest(l.wrkSecondsAmount(seconds))} ${l.wrkSayNext(exerciseName(l, nextExerciseKey))}',
        CueFinished() => l.wrkSayFinished,
      };
}
