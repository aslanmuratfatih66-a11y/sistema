import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/core/voice/tts_service.dart';
import 'package:sistema/features/onboarding/questionnaire_a/camera/guided_session.dart';

class _FakeTts implements TtsService {
  final said = <String>[];
  final langs = <String>{};
  final voices = <String?>{};
  int stops = 0;

  @override
  Future<void> speak(String text, {required String languageCode, VoiceProfile? voice}) async {
    said.add(text);
    langs.add(languageCode);
    voices.add(voice?.id);
  }

  @override
  Future<void> stop() async => stops++;

  @override
  Future<bool> isAvailable(String languageCode) async => true;
}

class _FakeSource implements ShotSource {
  int n = 0;
  bool fail = false;
  final discarded = <String>[];

  @override
  Future<String?> capture() async => fail ? null : 'shot${n++}';

  @override
  Future<void> discard(String path) async => discarded.add(path);
}

class _Phrases implements SessionPhrases {
  @override
  String instruction(SessionShot shot, {required bool first}) => 'go:${shot.pose.name}';

  @override
  String count(int n) => '$n';

  @override
  String taken(SessionShot? next) => 'taken>${next?.pose.name ?? 'end'}';

  @override
  String failed() => 'failed';
}

/// Ожидание, которое пишет длительность и завершается сразу (или по [gate], если задан).
class _Clock {
  final waits = <Duration>[];
  Completer<void>? gate;

  Future<void> call(Duration d) {
    waits.add(d);
    final g = gate;
    return g == null ? Future<void>.value() : g.future;
  }
}

Future<void> _settle() async {
  for (var i = 0; i < 200; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late _FakeTts tts;
  late _FakeSource source;
  late _Clock clock;
  final ticks = <int>[];
  var flashes = 0;

  GuidedSessionController make({int delay = 3, List<SessionShot> shots = SessionShot.body}) {
    ticks.clear();
    flashes = 0;
    return GuidedSessionController(
      shots: shots,
      source: source,
      tts: tts,
      phrases: _Phrases(),
      languageCode: 'tr',
      countdownSeconds: delay,
      wait: clock.call,
      onTick: ticks.add,
      onCaptured: () => flashes++,
    );
  }

  setUp(() {
    tts = _FakeTts();
    source = _FakeSource();
    clock = _Clock();
  });

  test('полная серия тела: инструкция → отсчёт → снимок → «следующий» × 3 → обзор', () async {
    final s = make(delay: 5);
    expect(s.phase, SessionPhase.preparing);
    final phases = <SessionPhase>[];
    s.addListener(() {
      if (phases.isEmpty || phases.last != s.phase) phases.add(s.phase);
    });

    s.start();
    await _settle();

    expect(s.phase, SessionPhase.review);
    expect(tts.said, [
      'go:bodyFront', '3', '2', '1', 'taken>bodySide', //
      'go:bodySide', '3', '2', '1', 'taken>bodyBack',
      'go:bodyBack', '3', '2', '1', 'taken>end',
    ]);
    expect(tts.langs, {'tr'});
    expect(ticks, [5, 4, 3, 2, 1, 5, 4, 3, 2, 1, 5, 4, 3, 2, 1]);
    expect(flashes, 3);
    // 5 секунд отсчёта × 3 + пауза 2 с между ракурсами (после последнего — нет).
    expect(clock.waits.where((d) => d == const Duration(seconds: 1)).length, 15);
    expect(clock.waits.where((d) => d == const Duration(seconds: 2)).length, 2);
    expect(s.results, ['shot0', 'shot1', 'shot2']);
    expect(phases, [
      SessionPhase.instruction, SessionPhase.countdown, SessionPhase.capturing, SessionPhase.captured, //
      SessionPhase.instruction, SessionPhase.countdown, SessionPhase.capturing, SessionPhase.captured,
      SessionPhase.instruction, SessionPhase.countdown, SessionPhase.capturing, SessionPhase.captured,
      SessionPhase.review,
    ]);
    s.dispose();
  });

  test('лицо: порядок ракурсов анфас → профиль слева → профиль справа', () async {
    final s = make(shots: SessionShot.face);
    s.start();
    await _settle();
    expect(tts.said.where((t) => t.startsWith('go:')), ['go:faceFront', 'go:faceLeft', 'go:faceRight']);
    final map = s.takeResults();
    expect(map, {PhotoPose.faceFront: 'shot0', PhotoPose.faceLeft: 'shot1', PhotoPose.faceRight: 'shot2'});
    s.dispose();
  });

  test('фразы звучат голосом выбранного персонажа; speaking — пока идёт фраза', () async {
    final s = make(shots: SessionShot.face)..voice = const VoiceProfile(id: 'v1', pitch: 1.2);
    final speaking = <bool>[];
    s.addListener(() {
      if (speaking.isEmpty || speaking.last != s.speaking) speaking.add(s.speaking);
    });
    s.start();
    await _settle();
    expect(tts.voices, {'v1'});
    expect(speaking, contains(true));
    expect(s.speaking, isFalse);
    s.dispose();
  });

  test('переснять один ракурс: только он, старый файл удаляется, затем обзор', () async {
    final s = make();
    s.start();
    await _settle();
    tts.said.clear();

    s.retake(1);
    await _settle();
    expect(s.phase, SessionPhase.review);
    expect(tts.said, ['go:bodySide', '3', '2', '1', 'taken>end']);
    expect(s.results, ['shot0', 'shot3', 'shot2']);
    expect(source.discarded, ['shot1']);
    s.dispose();
  });

  test('отмена во время отсчёта: остановка речи, временные файлы удалены, дальше не идёт', () async {
    final s = make();
    s.start();
    await _settle();
    // Первый прогон завершился мгновенно — запустим заново через переснять и остановим на отсчёте.
    clock.gate = Completer<void>();
    s.retake(0);
    await _settle();
    expect(s.phase, SessionPhase.countdown);
    expect(s.remaining, 3);

    await s.cancel();
    clock.gate!.complete();
    await _settle();
    expect(s.phase, SessionPhase.cancelled);
    expect(tts.stops, greaterThan(0));
    expect(source.discarded.toSet(), {'shot0', 'shot1', 'shot2'});
    expect(source.n, 3, reason: 'после отмены снимок не делается');
    s.dispose();
  });

  test('пауза останавливает отсчёт; продолжение начинает текущий ракурс заново', () async {
    final s = make();
    clock.gate = Completer<void>();
    s.start();
    await _settle();
    expect(s.phase, SessionPhase.countdown);
    s.pause();
    expect(s.paused, isTrue);
    final gate = clock.gate!;
    clock.gate = null;
    gate.complete();
    await _settle();
    expect(source.n, 0, reason: 'на паузе снимок не делается');
    tts.said.clear();

    s.resume();
    await _settle();
    expect(s.phase, SessionPhase.review);
    expect(tts.said.first, 'go:bodyFront');
    expect(s.results, ['shot0', 'shot1', 'shot2']);
    s.dispose();
  });

  test('без отсчёта (снимает другой человек): ждёт кнопку', () async {
    final s = make(delay: 0);
    s.start();
    await _settle();
    expect(s.phase, SessionPhase.waitingShutter);
    expect(ticks, isEmpty);
    for (var i = 0; i < 3; i++) {
      s.shutter();
      await _settle();
    }
    expect(s.phase, SessionPhase.review);
    expect(s.results, ['shot0', 'shot1', 'shot2']);
    s.dispose();
  });

  test('ошибка снимка → failed, «Повторить» снимает тот же ракурс', () async {
    final s = make();
    source.fail = true;
    s.start();
    await _settle();
    expect(s.phase, SessionPhase.failed);
    expect(tts.said.last, 'failed');
    source.fail = false;
    s.retry();
    await _settle();
    expect(s.phase, SessionPhase.review);
    expect(s.results, ['shot0', 'shot1', 'shot2']);
    s.dispose();
  });
}
