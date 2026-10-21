// Голосовые подсказки тренировки поверх TtsService (голос выбранного ассистента).
// TTS вызывается только на события runner (старт подхода, 3-2-1, отдых/следующее, конец) — не на каждый тик.
// stop() — только если фраза ещё звучит (иначе лишний вызов даёт лаг на Android/iOS; см. PROGRESS, TTS).
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/voice/tts_service.dart';
import '../wrk_l10n.dart';
import 'workout_runner.dart';

class WorkoutVoice {
  WorkoutVoice({
    required this.tts,
    required this.phrases,
    required this.languageCode,
    this.voice,
    this.enabled = true,
    this.speakTimeout = const Duration(seconds: 8),
  });

  final TtsService tts;
  WorkoutPhrases phrases;
  final String languageCode;
  VoiceProfile? voice;
  bool enabled;
  final Duration speakTimeout;

  bool _speaking = false;
  int _gen = 0;

  bool get speaking => _speaking;

  void onCue(WorkoutCue cue) {
    if (!enabled) return;
    final text = phrases.phrase(cue);
    if (text == null || text.isEmpty) return;
    unawaited(_say(text));
  }

  Future<void> _say(String text) async {
    final gen = ++_gen;
    _speaking = true;
    try {
      await tts.speak(text, languageCode: languageCode, voice: voice).timeout(speakTimeout, onTimeout: () {});
    } catch (e) {
      debugPrint('WorkoutVoice.say: $e');
    } finally {
      if (gen == _gen) _speaking = false;
    }
  }

  /// Замолчать (выключили голос, ушли с экрана).
  Future<void> silence() async {
    if (!_speaking) return;
    _speaking = false;
    _gen++;
    try {
      await tts.stop();
    } catch (e) {
      debugPrint('WorkoutVoice.stop: $e');
    }
  }
}
