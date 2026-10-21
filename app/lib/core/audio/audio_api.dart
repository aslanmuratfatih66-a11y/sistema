// Аудио (SPEC §8.5, §12): голос поверх музыки с приглушением, Now Playing, Spotify. КОНТРАКТ каркаса этапа 4.
// Реализация — сабагент B (core/audio + ios/Runner/NowPlayingChannel.swift, канал `sistema/audio`).
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Голосовые подсказки поверх музыки: на время фразы музыка приглушается (duckOthers / AudioFocus MAY_DUCK).
abstract interface class VoicePrompter {
  /// Сказать [text] на языке [languageCode]. [interrupt] — прервать текущую фразу.
  Future<void> say(String text, {required String languageCode, bool interrupt = false});

  Future<void> stop();
}

/// Источник музыки.
enum MusicSource { appleMusic, spotify, other }

@immutable
class NowPlaying {
  const NowPlaying({required this.source, this.title, this.artist, this.isPlaying = false});

  final MusicSource source;

  /// Для [MusicSource.other] — null (название трека не показываем, SPEC §8.5).
  final String? title;
  final String? artist;
  final bool isPlaying;
}

/// Now Playing + управление (Apple Music; Spotify — App Remote, Client ID из конфига: --dart-define=SPOTIFY_CLIENT_ID).
abstract interface class MusicController {
  /// Текущий трек; null — ничего не играет / нет доступа.
  Stream<NowPlaying?> watch();

  Future<void> playPause();
  Future<void> next();
  Future<void> previous();

  /// Spotify настроен (есть Client ID и приложение Spotify).
  Future<bool> spotifyAvailable();
  Future<bool> connectSpotify();
}

/// Client ID Spotify из конфига сборки (секретом не является, но в репозиторий не кладём).
const spotifyClientId = String.fromEnvironment('SPOTIFY_CLIENT_ID');

/// Переопределяются в main реализацией B. По умолчанию — тишина (тесты, предпросмотр).
final voicePrompterProvider = Provider<VoicePrompter>((ref) => const SilentVoicePrompter());
final musicControllerProvider = Provider<MusicController>((ref) => const NoMusicController());

class SilentVoicePrompter implements VoicePrompter {
  const SilentVoicePrompter();

  @override
  Future<void> say(String text, {required String languageCode, bool interrupt = false}) async {}

  @override
  Future<void> stop() async {}
}

class NoMusicController implements MusicController {
  const NoMusicController();

  @override
  Stream<NowPlaying?> watch() => Stream.value(null);

  @override
  Future<void> playPause() async {}

  @override
  Future<void> next() async {}

  @override
  Future<void> previous() async {}

  @override
  Future<bool> spotifyAvailable() async => false;

  @override
  Future<bool> connectSpotify() async => false;
}
