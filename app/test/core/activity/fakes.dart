import 'package:sistema/core/activity/activity_api.dart';
import 'package:sistema/core/models/daily.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/quests/section_hooks.dart';

/// Счётчик шагов для тестов: значения задаются полями.
class FakeStepCounter implements StepCounter {
  FakeStepCounter({this.available = true, this.granted = true, this.steps = 0, this.kind = StepSourceKind.coreMotion});

  bool available;
  bool granted;
  int steps;
  double? distanceM;
  int? floors;
  bool grantOnRequest = true;

  @override
  StepSourceKind kind;

  final queries = <(DateTime, DateTime)>[];
  int permissionRequests = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    if (grantOnRequest) granted = true;
    return granted;
  }

  @override
  Future<StepDay?> query(DateTime from, DateTime to) async {
    queries.add((from, to));
    if (!granted) return null;
    return StepDay(day: from, steps: steps, distanceM: distanceM, floors: floors);
  }
}

/// Хуки квестов: запоминают вызовы stepsUpdated.
class RecordingHooks extends NoopSectionQuestHooks {
  final steps = <int>[];

  @override
  Future<void> stepsUpdated({required int stepsToday, DateTime? at}) async => steps.add(stepsToday);
}
