// Голосовые подсказки поверх музыки (SPEC §8.5, §12): очередь фраз, прерывание,
// приглушение других приложений на время речи. Синтез — существующий TtsService (тот же голос, что у ассистента).
import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../voice/tts_service.dart';
import 'audio_api.dart';

/// Обёртка над системной аудиосессией (в приложении — audio_session, в тестах — фейк).
abstract interface class DuckingSession {
  /// Выставить категорию/атрибуты (iOS: playback + mixWithOthers + duckOthers). Вызывается перед каждой
  /// серией фраз: другие плагины (камера, сканер, flutter_tts) могли переписать категорию.
  Future<void> prepare();

  /// Захватить звук с приглушением других. false — система отказала (например, идёт звонок).
  Future<bool> activate();

  /// Отпустить звук и вернуть громкость другим (notifyOthersOnDeactivation / abandonAudioFocus).
  Future<void> deactivate();
}

class _Phrase {
  _Phrase(this.text, this.languageCode);

  final String text;
  final String languageCode;
  final done = Completer<void>();

  void finish() {
    if (!done.isCompleted) done.complete();
  }
}

/// Реализация [VoicePrompter]: «активировать сессию → сказать фразы очереди → деактивировать».
///
/// - [say] ставит фразу в очередь и завершается, когда она договорена (или выброшена из очереди);
/// - `interrupt: true` — очередь очищается, звучащая фраза обрывается, новая звучит сразу;
/// - между фразами серии сессия не отпускается; после последней — ждём [releaseDelay]
///   (чтобы `await say(a); await say(b);` не «качал» громкость музыки) и возвращаем громкость.
/// - stop движка — только если фраза действительно звучит (договорённость по TTS: лишний stop даёт лаг).
class DuckingVoicePrompter implements VoicePrompter {
  DuckingVoicePrompter({
    required this._tts,
    required this._session,
    this._voice,
    this.releaseDelay = const Duration(milliseconds: 400),
  });

  final TtsService _tts;
  final DuckingSession _session;
  final VoiceProfile? Function()? _voice;

  /// Пауза перед возвратом громкости после последней фразы.
  final Duration releaseDelay;

  final _queue = Queue<_Phrase>();
  bool _running = false;
  bool _active = false;
  bool _speaking = false;
  bool _releaseNow = false;

  /// Сейчас звучит фраза (для тестов и UI).
  bool get isSpeaking => _speaking;

  /// Музыка сейчас приглушена нами.
  bool get isDucking => _active;

  @override
  Future<void> say(String text, {required String languageCode, bool interrupt = false}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final phrase = _Phrase(trimmed, languageCode);
    if (interrupt) {
      _dropQueue();
      _queue.add(phrase);
      if (_speaking) await _stopEngine();
    } else {
      _queue.add(phrase);
    }
    _ensureRunning();
    return phrase.done.future;
  }

  @override
  Future<void> stop() async {
    _dropQueue();
    _releaseNow = true;
    if (_speaking) await _stopEngine();
    if (!_running && _active) await _release();
  }

  void _dropQueue() {
    while (_queue.isNotEmpty) {
      _queue.removeFirst().finish();
    }
  }

  Future<void> _stopEngine() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('VoicePrompter: stop не удался: $e');
    }
  }

  void _ensureRunning() {
    if (_running) return;
    _running = true;
    unawaited(_run());
  }

  Future<void> _run() async {
    try {
      while (true) {
        if (_queue.isEmpty) {
          if (_active && !_releaseNow && releaseDelay > Duration.zero) await Future<void>.delayed(releaseDelay);
          if (_queue.isEmpty) break;
        }
        _releaseNow = false;
        if (!_active && !await _acquire()) {
          // Система не дала звук (звонок и т. п.) — фразу не произносим.
          _queue.removeFirst().finish();
          continue;
        }
        if (_queue.isEmpty) continue; // очередь сбросили, пока захватывали сессию
        final phrase = _queue.removeFirst();
        _speaking = true;
        try {
          await _tts.speak(phrase.text, languageCode: phrase.languageCode, voice: _voice?.call());
        } catch (e) {
          debugPrint('VoicePrompter: ошибка синтеза: $e');
        } finally {
          _speaking = false;
          phrase.finish();
        }
      }
      if (_active) await _release();
    } finally {
      _running = false;
      _releaseNow = false;
      // Фраза могла прийти, пока отпускали сессию.
      if (_queue.isNotEmpty) _ensureRunning();
    }
  }

  Future<bool> _acquire() async {
    try {
      await _session.prepare();
    } catch (e) {
      debugPrint('VoicePrompter: настройка сессии не удалась: $e');
    }
    try {
      final ok = await _session.activate();
      _active = ok;
      return ok;
    } catch (e) {
      // Сбой плагина — говорим без приглушения, но потом всё равно отпускаем сессию.
      debugPrint('VoicePrompter: активация сессии не удалась: $e');
      _active = true;
      return true;
    }
  }

  Future<void> _release() async {
    _active = false;
    try {
      await _session.deactivate();
    } catch (e) {
      debugPrint('VoicePrompter: деактивация сессии не удалась: $e');
    }
  }
}
