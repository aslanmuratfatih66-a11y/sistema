// КОНТРАКТ каркаса: синтез речи. Реализацию на системном TTS (flutter_tts) пишет сабагент F
// в lib/features/character/voice/. Позже (этап 6) — провайдер с готовыми голосами через сервер,
// системный TTS остаётся офлайн-запасным (SPEC §9.2–9.3).
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Параметры голоса персонажа для системного синтеза.
class VoiceProfile {
  const VoiceProfile({required this.id, this.pitch = 1.0, this.rate = 0.5, this.preferFemale});

  /// Стабильный id (хранится в character.voice).
  final String id;

  /// 0.5..2.0
  final double pitch;

  /// 0.0..1.0 (как в flutter_tts; 0.5 — обычная скорость).
  final double rate;

  /// Предпочесть женский/мужской системный голос, если платформа позволяет выбрать.
  final bool? preferFemale;
}

abstract interface class TtsService {
  /// Произнести [text] на языке [languageCode] ('ru'/'tr'). Завершается, когда фраза договорена
  /// (или сразу, если синтез недоступен). Предыдущая фраза прерывается.
  Future<void> speak(String text, {required String languageCode, VoiceProfile? voice});

  Future<void> stop();

  /// Доступен ли синтез речи на устройстве для языка.
  Future<bool> isAvailable(String languageCode);
}

/// Немой синтез (тесты, платформы без TTS).
class SilentTtsService implements TtsService {
  const SilentTtsService();

  @override
  Future<void> speak(String text, {required String languageCode, VoiceProfile? voice}) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<bool> isAvailable(String languageCode) async => false;
}

/// Переопределяется в main реальной реализацией.
final ttsServiceProvider = Provider<TtsService>((ref) => const SilentTtsService());
