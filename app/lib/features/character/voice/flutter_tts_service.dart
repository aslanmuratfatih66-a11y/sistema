import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/voice/tts_service.dart';

/// Тонкая обёртка над платформенным движком синтеза (подменяется в тестах).
abstract interface class TtsEngine {
  Future<void> configure({required bool ios});
  Future<List<Map<String, String>>> voices();
  Future<bool> isLanguageAvailable(String languageTag);
  Future<void> setLanguage(String languageTag);
  Future<void> setVoice(Map<String, String> voice);
  Future<void> setPitch(double pitch);
  Future<void> setSpeechRate(double rate);

  /// Завершается, когда фраза договорена (awaitSpeakCompletion включён в [configure]).
  Future<void> speak(String text);
  Future<void> stop();
}

/// Реальный движок на flutter_tts 4.2.x.
class FlutterTtsEngine implements TtsEngine {
  FlutterTtsEngine();

  // FlutterTts() регистрирует обработчик канала — создаём лениво.
  late final FlutterTts _tts = FlutterTts();

  @override
  Future<void> configure({required bool ios}) async {
    await _tts.awaitSpeakCompletion(true);
    if (ios) {
      // Голос поверх музыки: playback + приглушение других (SPEC §3).
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [IosTextToSpeechAudioCategoryOptions.duckOthers],
        IosTextToSpeechAudioMode.defaultMode,
      );
    }
  }

  @override
  Future<List<Map<String, String>>> voices() async {
    final raw = await _tts.getVoices;
    if (raw is! List) return const [];
    return [
      for (final v in raw)
        if (v is Map) {for (final e in v.entries) '${e.key}': '${e.value}'},
    ];
  }

  @override
  Future<bool> isLanguageAvailable(String languageTag) async => await _tts.isLanguageAvailable(languageTag) == true;

  @override
  Future<void> setLanguage(String languageTag) => _tts.setLanguage(languageTag);

  @override
  Future<void> setVoice(Map<String, String> voice) => _tts.setVoice(voice);

  @override
  Future<void> setPitch(double pitch) => _tts.setPitch(pitch);

  @override
  Future<void> setSpeechRate(double rate) => _tts.setSpeechRate(rate);

  @override
  Future<void> speak(String text) => _tts.speak(text);

  @override
  Future<void> stop() => _tts.stop();
}

/// Синтез речи на системных голосах телефона (ru-RU / tr-TR).
///
/// На вебе и платформах кроме iOS/Android — недоступен (isAvailable=false, speak ничего не делает).
/// Любые ошибки платформы глушатся: персонаж просто молчит.
class FlutterTtsService implements TtsService {
  FlutterTtsService({TtsEngine? engine, bool? supported, bool? isIos})
      : _engine = engine ?? FlutterTtsEngine(),
        _supported = supported ??
            (!kIsWeb &&
                (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)),
        _isIos = isIos ?? (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS);

  final TtsEngine _engine;
  final bool _supported;
  final bool _isIos;

  Future<bool>? _configured;
  List<Map<String, String>>? _voices;
  final _available = <String, bool>{};
  Completer<void>? _current;

  static String languageTag(String languageCode) => switch (languageCode) {
        'tr' => 'tr-TR',
        _ => 'ru-RU',
      };

  Future<bool> _configure() => _configured ??= () async {
        try {
          await _engine.configure(ios: _isIos);
          return true;
        } catch (e) {
          debugPrint('TTS: настройка не удалась: $e');
          return false;
        }
      }();

  Future<List<Map<String, String>>> _allVoices() async {
    final cached = _voices;
    if (cached != null) return cached;
    try {
      return _voices = await _engine.voices();
    } catch (_) {
      return _voices = const [];
    }
  }

  @override
  Future<bool> isAvailable(String languageCode) async {
    if (!_supported) return false;
    final cached = _available[languageCode];
    if (cached != null) return cached;
    if (!await _configure()) return _available[languageCode] = false;
    final tag = languageTag(languageCode);
    var ok = false;
    try {
      ok = await _engine.isLanguageAvailable(tag);
    } catch (_) {}
    if (!ok) ok = voicesFor(await _allVoices(), languageCode).isNotEmpty;
    return _available[languageCode] = ok;
  }

  @override
  Future<void> speak(String text, {required String languageCode, VoiceProfile? voice}) async {
    if (text.trim().isEmpty || !await isAvailable(languageCode)) return;
    await stop();
    final done = Completer<void>();
    _current = done;
    try {
      final tag = languageTag(languageCode);
      await _engine.setLanguage(tag);
      final chosen = pickVoice(await _allVoices(), languageCode, preferFemale: voice?.preferFemale);
      if (chosen != null) await _engine.setVoice(chosen);
      await _engine.setPitch((voice?.pitch ?? 1).clamp(.5, 2.0));
      await _engine.setSpeechRate((voice?.rate ?? .5).clamp(0.0, 1.0));
      if (done.isCompleted) return;
      // Завершаемся по окончании фразы или при прерывании (stop/новая фраза).
      await Future.any([_engine.speak(text), done.future]);
    } catch (e) {
      debugPrint('TTS: ошибка синтеза: $e');
    } finally {
      if (!done.isCompleted) done.complete();
      if (identical(_current, done)) _current = null;
    }
  }

  @override
  Future<void> stop() async {
    final c = _current;
    _current = null;
    if (c != null && !c.isCompleted) c.complete();
    if (!_supported) return;
    try {
      await _engine.stop();
    } catch (_) {}
  }

  /// Голоса языка [languageCode] (по полю locale: 'ru-RU', 'ru_RU', 'ru').
  @visibleForTesting
  static List<Map<String, String>> voicesFor(List<Map<String, String>> voices, String languageCode) => [
        for (final v in voices)
          if ((v['locale'] ?? '').toLowerCase().replaceAll('_', '-').split('-').first == languageCode) v,
      ];

  /// Выбор системного голоса: язык, затем пол (поле gender на iOS или подсказка в имени),
  /// затем качество (enhanced/premium на iOS, без сети на Android). Результат — карта для setVoice.
  @visibleForTesting
  static Map<String, String>? pickVoice(
    List<Map<String, String>> voices,
    String languageCode, {
    bool? preferFemale,
  }) {
    final candidates = voicesFor(voices, languageCode);
    if (candidates.isEmpty) return null;
    final region = languageTag(languageCode).toLowerCase();
    int score(Map<String, String> v) {
      var s = 0;
      final locale = (v['locale'] ?? '').toLowerCase().replaceAll('_', '-');
      if (locale == region) s += 4;
      final g = _gender(v);
      if (preferFemale != null && g != null) s += (g == preferFemale) ? 20 : -20;
      final q = (v['quality'] ?? '').toLowerCase();
      if (q == 'premium' || q == 'enhanced') s += 2;
      if (q.contains('high')) s += 1;
      if ((v['network_required'] ?? '').toLowerCase() == 'true' || (v['name'] ?? '').contains('network')) s -= 3;
      return s;
    }

    final sorted = [...candidates]..sort((a, b) {
        final d = score(b) - score(a);
        return d != 0 ? d : (a['name'] ?? '').compareTo(b['name'] ?? '');
      });
    final best = sorted.first;
    return {
      'name': best['name'] ?? '',
      'locale': best['locale'] ?? '',
      if ((best['identifier'] ?? '').isNotEmpty) 'identifier': best['identifier']!,
    };
  }

  /// true — женский, false — мужской, null — неизвестно.
  static bool? _gender(Map<String, String> v) {
    final g = (v['gender'] ?? '').toLowerCase();
    if (g == 'female') return true;
    if (g == 'male') return false;
    final name = (v['name'] ?? '').toLowerCase();
    if (name.contains('female') || name.contains('#female')) return true;
    if (RegExp(r'(^|[^e])male').hasMatch(name)) return false;
    return null;
  }
}
