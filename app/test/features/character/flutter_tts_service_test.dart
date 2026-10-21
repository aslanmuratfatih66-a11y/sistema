import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/voice/tts_service.dart';
import 'package:sistema/features/character/voice/flutter_tts_service.dart';

class FakeEngine implements TtsEngine {
  FakeEngine({this.voiceList = const [], this.languages = const {}, this.failConfigure = false});

  final List<Map<String, String>> voiceList;
  final Set<String> languages;
  final bool failConfigure;
  final calls = <String>[];
  Map<String, String>? voice;
  double? pitch;
  double? rate;
  String? language;
  Completer<void>? speaking;
  bool holdSpeak = false;

  @override
  Future<void> configure({required bool ios}) async {
    calls.add('configure:$ios');
    if (failConfigure) throw StateError('нет движка');
  }

  @override
  Future<List<Map<String, String>>> voices() async => voiceList;

  @override
  Future<bool> isLanguageAvailable(String languageTag) async => languages.contains(languageTag);

  @override
  Future<void> setLanguage(String languageTag) async => language = languageTag;

  @override
  Future<void> setVoice(Map<String, String> v) async => voice = v;

  @override
  Future<void> setPitch(double p) async => pitch = p;

  @override
  Future<void> setSpeechRate(double r) async => rate = r;

  @override
  Future<void> speak(String text) async {
    calls.add('speak:$text');
    if (holdSpeak) {
      speaking = Completer<void>();
      await speaking!.future;
    }
  }

  @override
  Future<void> stop() async => calls.add('stop');
}

const iosVoices = [
  {'name': 'Milena', 'locale': 'ru-RU', 'gender': 'female', 'quality': 'default', 'identifier': 'com.apple.voice.compact.ru-RU.Milena'},
  {'name': 'Yuri', 'locale': 'ru-RU', 'gender': 'male', 'quality': 'enhanced', 'identifier': 'com.apple.voice.enhanced.ru-RU.Yuri'},
  {'name': 'Yelda', 'locale': 'tr-TR', 'gender': 'female', 'quality': 'default', 'identifier': 'com.apple.voice.compact.tr-TR.Yelda'},
  {'name': 'Samantha', 'locale': 'en-US', 'gender': 'female', 'quality': 'default', 'identifier': 'x'},
];

void main() {
  group('выбор голоса', () {
    test('по языку и полу (iOS, поле gender)', () {
      expect(FlutterTtsService.pickVoice(iosVoices, 'ru', preferFemale: true)!['name'], 'Milena');
      expect(FlutterTtsService.pickVoice(iosVoices, 'ru', preferFemale: false)!['name'], 'Yuri');
      expect(FlutterTtsService.pickVoice(iosVoices, 'tr', preferFemale: false)!['name'], 'Yelda');
      final v = FlutterTtsService.pickVoice(iosVoices, 'ru', preferFemale: false)!;
      expect(v['locale'], 'ru-RU');
      expect(v['identifier'], 'com.apple.voice.enhanced.ru-RU.Yuri');
    });

    test('Android: локальный голос лучше сетевого, нет голосов языка — null', () {
      const android = [
        {'name': 'ru-ru-x-ruf-network', 'locale': 'ru-RU', 'network_required': 'true'},
        {'name': 'ru-ru-x-ruc-local', 'locale': 'ru-RU', 'network_required': 'false'},
      ];
      final v = FlutterTtsService.pickVoice(android, 'ru', preferFemale: true)!;
      expect(v['name'], 'ru-ru-x-ruc-local');
      expect(v.containsKey('identifier'), isFalse);
      expect(FlutterTtsService.pickVoice(android, 'tr'), isNull);
    });

    test('пол по имени, если нет поля gender', () {
      const named = [
        {'name': 'tr-tr-male-1', 'locale': 'tr_TR'},
        {'name': 'tr-tr-female-1', 'locale': 'tr_TR'},
      ];
      expect(FlutterTtsService.pickVoice(named, 'tr', preferFemale: true)!['name'], 'tr-tr-female-1');
      expect(FlutterTtsService.pickVoice(named, 'tr', preferFemale: false)!['name'], 'tr-tr-male-1');
    });
  });

  group('сервис', () {
    test('speak настраивает движок один раз и применяет голос, тон, скорость', () async {
      final engine = FakeEngine(voiceList: iosVoices, languages: {'ru-RU', 'tr-TR'});
      final tts = FlutterTtsService(engine: engine, supported: true, isIos: true);
      const voice = VoiceProfile(id: 'stoicStrongman.deep', pitch: .62, rate: .4, preferFemale: false);

      expect(await tts.isAvailable('ru'), isTrue);
      await tts.speak('Новый день.', languageCode: 'ru', voice: voice);
      await tts.speak('Ещё.', languageCode: 'ru', voice: voice);

      expect(engine.calls.where((c) => c.startsWith('configure')), ['configure:true']);
      expect(engine.language, 'ru-RU');
      expect(engine.voice!['name'], 'Yuri');
      expect(engine.pitch, closeTo(.62, 1e-9));
      expect(engine.rate, closeTo(.4, 1e-9));
      expect(engine.calls, containsAllInOrder(['speak:Новый день.', 'stop', 'speak:Ещё.']));
    });

    test('женский голос для турецкого', () async {
      final engine = FakeEngine(voiceList: iosVoices);
      final tts = FlutterTtsService(engine: engine, supported: true, isIos: false);
      await tts.speak('Merhaba', languageCode: 'tr', voice: const VoiceProfile(id: 'animeGirl.bright', preferFemale: true));
      expect(engine.calls.first, 'configure:false');
      expect(engine.language, 'tr-TR');
      expect(engine.voice!['name'], 'Yelda');
    });

    test('неподдерживаемая платформа (веб) — недоступен и молчит', () async {
      final engine = FakeEngine(voiceList: iosVoices, languages: {'ru-RU'});
      final tts = FlutterTtsService(engine: engine, supported: false);
      expect(await tts.isAvailable('ru'), isFalse);
      await tts.speak('Привет', languageCode: 'ru');
      await tts.stop();
      expect(engine.calls, isEmpty);
    });

    test('нет голосов языка или ошибка движка — недоступен без исключений', () async {
      final noVoices = FlutterTtsService(engine: FakeEngine(voiceList: const []), supported: true);
      expect(await noVoices.isAvailable('tr'), isFalse);
      final broken = FlutterTtsService(engine: FakeEngine(failConfigure: true), supported: true);
      expect(await broken.isAvailable('ru'), isFalse);
      await broken.speak('Привет', languageCode: 'ru');
    });

    test('stop прерывает фразу: speak завершается', () async {
      final engine = FakeEngine(voiceList: iosVoices)..holdSpeak = true;
      final tts = FlutterTtsService(engine: engine, supported: true);
      var done = false;
      final f = tts.speak('Долгая фраза', languageCode: 'ru').then((_) => done = true);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(engine.calls, contains('speak:Долгая фраза'));
      expect(done, isFalse);
      await tts.stop();
      await f;
      expect(done, isTrue);
    });
  });
}
