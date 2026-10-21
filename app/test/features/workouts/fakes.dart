import 'package:sistema/core/models/enums.dart';
import 'package:sistema/core/voice/tts_service.dart';
import 'package:sistema/domain/quests/section_hooks.dart';
import 'package:sistema/features/workouts/domain/workout_runner.dart';
import 'package:sistema/features/workouts/workouts_providers.dart';

class FakeClock {
  FakeClock(this.now);

  DateTime now;

  DateTime call() => now;

  void advance(Duration d) => now = now.add(d);
}

class ManualTicker implements WorkoutTicker {
  void Function()? _cb;
  int starts = 0;
  int stops = 0;

  bool get active => _cb != null;

  @override
  void start(void Function() onTick) {
    starts++;
    _cb = onTick;
  }

  @override
  void stop() {
    stops++;
    _cb = null;
  }

  void tick() => _cb?.call();
}

class FakeTts implements TtsService {
  final spoken = <String>[];
  final voices = <VoiceProfile?>[];
  final languages = <String>[];
  int stops = 0;

  @override
  Future<void> speak(String text, {required String languageCode, VoiceProfile? voice}) async {
    spoken.add(text);
    voices.add(voice);
    languages.add(languageCode);
  }

  @override
  Future<void> stop() async => stops++;

  @override
  Future<bool> isAvailable(String languageCode) async => true;
}

class FakeHooks implements SectionQuestHooks {
  final workouts = <int>[];

  @override
  Future<void> workoutFinished({required int activeMinutes, DateTime? at}) async => workouts.add(activeMinutes);

  @override
  Future<void> waterAdded({required int ml, required int totalTodayMl, DateTime? at}) async {}

  @override
  Future<void> mealLogged({required int mealsToday, DateTime? at}) async {}

  @override
  Future<void> stepsUpdated({required int stepsToday, DateTime? at}) async {}

  @override
  Future<void> careRoutineDone(CareRoutine routine, {DateTime? at}) async {}

  @override
  Future<void> sleepLogged({required DateTime bedAt, required DateTime wakeAt}) async {}
}

class FakeWakelock implements WorkoutWakelock {
  bool on = false;
  int enables = 0;

  @override
  Future<void> enable() async {
    on = true;
    enables++;
  }

  @override
  Future<void> disable() async => on = false;
}
