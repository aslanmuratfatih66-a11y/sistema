import 'dart:async';

import 'package:sistema/core/voice/tts_service.dart';

class Spoken {
  Spoken(this.text, this.languageCode, this.voice);
  final String text;
  final String languageCode;
  final VoiceProfile? voice;
}

/// Фейковый синтез: запоминает фразы; при [hold] фраза «звучит», пока не вызвать [finish] или stop.
class FakeTts implements TtsService {
  FakeTts({this.available = true});

  bool available;
  bool hold = false;
  final spoken = <Spoken>[];
  int stops = 0;
  Completer<void>? _pending;

  void finish() {
    final p = _pending;
    _pending = null;
    if (p != null && !p.isCompleted) p.complete();
  }

  @override
  Future<bool> isAvailable(String languageCode) async => available;

  @override
  Future<void> speak(String text, {required String languageCode, VoiceProfile? voice}) async {
    if (!available) return;
    spoken.add(Spoken(text, languageCode, voice));
    if (hold) {
      final c = _pending = Completer<void>();
      await c.future;
    }
  }

  @override
  Future<void> stop() async {
    stops++;
    finish();
  }
}
