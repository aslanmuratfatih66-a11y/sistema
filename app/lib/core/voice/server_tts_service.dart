// Голос персонажа через сервер (SPEC §9.3): готовые голоса TTS-провайдера, кэш аудио во временной папке,
// воспроизведение just_audio. Нет провайдера (503) / офлайн / не вошли / бюджет — системный синтез (фолбэк).
// ignore_for_file: prefer_initializing_formals
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../ai/ai_api.dart';
import 'tts_service.dart';

/// Голос из библиотеки сервера (GET /api/v1/ai/voices).
class ServerVoice {
  const ServerVoice({required this.id, required this.name, required this.lang, this.gender});

  factory ServerVoice.fromJson(Map<String, dynamic> j) => ServerVoice(
        id: '${j['id']}',
        name: '${j['name'] ?? j['id']}',
        lang: '${j['lang'] ?? ''}',
        gender: j['gender'] as String?,
      );

  final String id;
  final String name;

  /// 'ru' / 'tr' / '' (многоязычный).
  final String lang;
  final String? gender;
}

/// Клиент TTS-эндпоинтов сервера. Ошибки — [AiException].
class ServerTtsApi {
  const ServerTtsApi(this._gateway);

  final AiGateway _gateway;

  Future<List<ServerVoice>> voices() async {
    final j = await _gateway.json('GET', '/api/v1/ai/voices');
    final list = j['voices'];
    if (list is! List) return const [];
    return [
      for (final v in list)
        if (v is Map<String, dynamic>) ServerVoice.fromJson(v),
    ];
  }

  Future<List<int>> synthesize(String text, {required String voice, required String lang, String format = 'mp3'}) =>
      _gateway.bytes('POST', '/api/v1/ai/tts', body: {'text': text, 'voice': voice, 'lang': lang, 'format': format});
}

/// Стабильный ключ кэша (FNV-1a, две 32-битные половины). Только для VM (на вебе кэша нет).
String ttsCacheKey(String voice, String lang, String format, String text) {
  final bytes = utf8.encode('$voice|$lang|$format|$text');
  var a = 0x811c9dc5, b = 0x01000193 ^ bytes.length;
  for (final x in bytes) {
    a = ((a ^ x) * 0x01000193) & 0xFFFFFFFF;
    b = ((b ^ x) * 0x0100019d) & 0xFFFFFFFF;
  }
  return '${a.toRadixString(16).padLeft(8, '0')}${b.toRadixString(16).padLeft(8, '0')}';
}

/// Синтез голосом сервера с файловым кэшем во временной папке. Возвращает путь к файлу.
class ServerTtsCache {
  ServerTtsCache(this._api, {Future<Directory> Function()? dir}) : _dir = dir ?? getTemporaryDirectory;

  final ServerTtsApi _api;
  final Future<Directory> Function() _dir;

  Future<File> file(String text, {required String voice, required String lang, String format = 'mp3'}) async {
    final base = await _dir();
    final folder = Directory('${base.path}${Platform.pathSeparator}tts_cache');
    if (!await folder.exists()) await folder.create(recursive: true);
    final f = File('${folder.path}${Platform.pathSeparator}${ttsCacheKey(voice, lang, format, text)}.$format');
    if (await f.exists() && await f.length() > 0) return f;
    final data = await _api.synthesize(text, voice: voice, lang: lang, format: format);
    if (data.isEmpty) throw const AiException(AiFailure.server, 'empty_audio');
    final tmp = File('${f.path}.part');
    await tmp.writeAsBytes(data, flush: true);
    return tmp.rename(f.path);
  }
}

/// TTS персонажа: голос сервера ([serverVoice] — id выбранного голоса, null — только системный),
/// иначе/при сбое — [fallback] (системный синтез с [VoiceProfile] персонажа).
class ServerTtsService implements TtsService {
  ServerTtsService({
    required ServerTtsCache cache,
    required TtsService fallback,
    required String? Function() serverVoice,
    AudioPlayer Function()? player,
    this.cooldown = const Duration(minutes: 5),
  })  : _cache = cache,
        _fallback = fallback,
        _serverVoice = serverVoice,
        _newPlayer = player ?? AudioPlayer.new;

  final ServerTtsCache _cache;
  final TtsService _fallback;
  final String? Function() _serverVoice;
  final AudioPlayer Function() _newPlayer;

  /// После «нет провайдера/офлайн/бюджет» сервер не дёргаем это время — сразу системный голос.
  final Duration cooldown;

  AudioPlayer? _player;
  DateTime? _serverDownUntil;
  int _serial = 0;
  bool _fallbackSpeaking = false;

  bool get _serverAllowed {
    final until = _serverDownUntil;
    return !kIsWeb && (until == null || DateTime.now().isAfter(until));
  }

  @override
  Future<void> speak(String text, {required String languageCode, VoiceProfile? voice}) =>
      speakWith(text, languageCode: languageCode, voice: voice, serverVoiceId: _serverVoice());

  /// Произнести конкретным голосом сервера (прослушивание в выборе голоса). Без фолбэка, если [strict].
  Future<void> speakWith(
    String text, {
    required String languageCode,
    VoiceProfile? voice,
    String? serverVoiceId,
    bool strict = false,
  }) async {
    if (text.trim().isEmpty) return;
    await stop();
    final serial = ++_serial;
    if (serverVoiceId != null && serverVoiceId.isNotEmpty && (strict || _serverAllowed)) {
      try {
        final f = await _cache.file(text, voice: serverVoiceId, lang: languageCode);
        if (serial != _serial) return; // прервали, пока качали
        final p = _player ??= _newPlayer();
        await p.setFilePath(f.path);
        if (serial != _serial) return;
        await p.play(); // завершается по окончании или при stop
        return;
      } on AiException catch (e) {
        if (strict) rethrow;
        if (e.failure != AiFailure.server) _serverDownUntil = DateTime.now().add(cooldown);
        debugPrint('TTS сервера недоступен: $e — системный голос');
      } catch (e) {
        if (strict) rethrow;
        debugPrint('TTS сервера: ошибка воспроизведения: $e — системный голос');
      }
      if (serial != _serial) return;
    }
    _fallbackSpeaking = true;
    try {
      await _fallback.speak(text, languageCode: languageCode, voice: voice);
    } finally {
      if (serial == _serial) _fallbackSpeaking = false;
    }
  }

  @override
  Future<void> stop() async {
    _serial++;
    final p = _player;
    if (p != null && p.playing) {
      try {
        await p.stop();
      } catch (_) {}
    }
    // Лишний stop системного движка тормозит главный поток (см. FlutterTtsService) — только если говорит.
    if (_fallbackSpeaking) {
      _fallbackSpeaking = false;
      await _fallback.stop();
    }
  }

  @override
  Future<bool> isAvailable(String languageCode) async =>
      (_serverVoice() != null && _serverAllowed) || await _fallback.isAvailable(languageCode);

  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
  }
}
