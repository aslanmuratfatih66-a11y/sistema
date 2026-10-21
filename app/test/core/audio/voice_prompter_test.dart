import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/audio/voice_prompter.dart';
import 'package:sistema/core/voice/tts_service.dart';

/// TTS, фраза которого «звучит», пока тест не вызовет [finishCurrent] или stop.
class FakeTts implements TtsService {
  final log = <String>[];
  Completer<void>? _current;
  int stops = 0;

  bool get speaking => _current != null && !_current!.isCompleted;

  @override
  Future<void> speak(String text, {required String languageCode, VoiceProfile? voice}) {
    log.add('$languageCode:$text');
    final c = Completer<void>();
    _current = c;
    return c.future;
  }

  void finishCurrent() {
    final c = _current;
    if (c != null && !c.isCompleted) c.complete();
  }

  @override
  Future<void> stop() async {
    stops++;
    finishCurrent();
  }

  @override
  Future<bool> isAvailable(String languageCode) async => true;
}

class FakeSession implements DuckingSession {
  FakeSession({this.grant = true});

  bool grant;
  final log = <String>[];

  @override
  Future<void> prepare() async => log.add('prepare');

  @override
  Future<bool> activate() async {
    log.add('activate');
    return grant;
  }

  @override
  Future<void> deactivate() async => log.add('deactivate');
}

Future<void> pump() => Future<void>.delayed(Duration.zero);

void main() {
  late FakeTts tts;
  late FakeSession session;
  late DuckingVoicePrompter prompter;

  setUp(() {
    tts = FakeTts();
    session = FakeSession();
    prompter = DuckingVoicePrompter(tts: tts, session: session, releaseDelay: Duration.zero);
  });

  test('фразы звучат по очереди, сессия захватывается один раз и отпускается в конце', () async {
    final a = prompter.say('раз', languageCode: 'ru');
    final b = prompter.say('два', languageCode: 'ru');
    await pump();
    expect(tts.log, ['ru:раз']);
    expect(prompter.isDucking, isTrue);
    tts.finishCurrent();
    await a;
    await pump();
    expect(tts.log, ['ru:раз', 'ru:два']);
    tts.finishCurrent();
    await b;
    await pump();
    expect(session.log, ['prepare', 'activate', 'deactivate']);
    expect(prompter.isDucking, isFalse);
    expect(tts.stops, 0);
  });

  test('interrupt обрывает звучащую фразу и сбрасывает очередь', () async {
    final a = prompter.say('первая', languageCode: 'ru');
    final b = prompter.say('вторая', languageCode: 'ru');
    await pump();
    final c = prompter.say('срочно', languageCode: 'tr', interrupt: true);
    await a;
    await b;
    await pump();
    expect(tts.stops, 1);
    expect(tts.log, ['ru:первая', 'tr:срочно']);
    tts.finishCurrent();
    await c;
    await pump();
    expect(session.log.last, 'deactivate');
  });

  test('stop без звучащей фразы не дёргает движок', () async {
    await prompter.stop();
    expect(tts.stops, 0);
    expect(session.log, isEmpty);
  });

  test('stop во время речи останавливает и отпускает сессию', () async {
    final a = prompter.say('фраза', languageCode: 'ru');
    final b = prompter.say('ещё', languageCode: 'ru');
    await pump();
    await prompter.stop();
    await a;
    await b;
    await pump();
    expect(tts.stops, 1);
    expect(tts.log, ['ru:фраза']);
    expect(session.log.last, 'deactivate');
    expect(prompter.isDucking, isFalse);
  });

  test('система не дала звук — фраза пропускается', () async {
    session.grant = false;
    await prompter.say('звонок', languageCode: 'ru');
    expect(tts.log, isEmpty);
    expect(session.log, ['prepare', 'activate']);
  });

  test('пустая фраза игнорируется', () async {
    await prompter.say('   ', languageCode: 'ru');
    expect(session.log, isEmpty);
  });
}
