// Распознавание речи на телефоне (SPEC §9.3): ru/tr, обёртка над speech_to_text.
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

abstract interface class SpeechInput {
  /// Запросить разрешения/инициализировать. false — недоступно (нет разрешения/движка).
  Future<bool> init();

  /// Начать распознавание. [onText] — текущий текст (частичные результаты), [isFinal] — окончательный.
  /// [onDone] — распознавание закончилось (тишина/стоп/ошибка).
  Future<void> start({
    required String languageCode,
    required void Function(String text, bool isFinal) onText,
    required void Function() onDone,
  });

  Future<void> stop();
  Future<void> cancel();
}

class NoSpeechInput implements SpeechInput {
  const NoSpeechInput();

  @override
  Future<bool> init() async => false;

  @override
  Future<void> start({
    required String languageCode,
    required void Function(String text, bool isFinal) onText,
    required void Function() onDone,
  }) async =>
      onDone();

  @override
  Future<void> stop() async {}

  @override
  Future<void> cancel() async {}
}

class SttSpeechInput implements SpeechInput {
  SttSpeechInput();

  late final SpeechToText _stt = SpeechToText();
  Future<bool>? _init;
  void Function()? _onDone;

  void _finish() {
    final d = _onDone;
    _onDone = null;
    d?.call();
  }

  @override
  Future<bool> init() => _init ??= () async {
        try {
          return await _stt.initialize(
            onError: (e) {
              debugPrint('STT: $e');
              _finish();
            },
            onStatus: (s) {
              if (s == SpeechToText.doneStatus || s == SpeechToText.notListeningStatus) _finish();
            },
          );
        } catch (e) {
          debugPrint('STT: инициализация не удалась: $e');
          return false;
        }
      }();

  @override
  Future<void> start({
    required String languageCode,
    required void Function(String text, bool isFinal) onText,
    required void Function() onDone,
  }) async {
    if (!await init()) return onDone();
    _onDone = onDone;
    try {
      await _stt.listen(
        onResult: (r) => onText(r.recognizedWords, r.finalResult),
        listenOptions: SpeechListenOptions(
          localeId: languageCode == 'tr' ? 'tr_TR' : 'ru_RU',
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
          listenFor: const Duration(minutes: 1),
          pauseFor: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      debugPrint('STT: $e');
      _finish();
    }
  }

  @override
  Future<void> stop() => _stt.stop();

  @override
  Future<void> cancel() async {
    _onDone = null;
    await _stt.cancel();
  }
}
