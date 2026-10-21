// MusicController: системный плеер через канал `sistema/audio` (iOS — Apple Music, MPMusicPlayerController;
// Android — медиа-кнопки AudioManager, без названия трека) + Spotify через [SpotifyBridge].
//
// Протокол канала (NowPlayingChannel.swift / AudioChannel.kt):
//   MethodChannel `sistema/audio`:
//     requestAccess → bool        (iOS: MPMediaLibrary.requestAuthorization; Android: true)
//     getNowPlaying → Map? / null (см. [parseNowPlaying])
//     playPause / next / previous → null
//     isSpotifyInstalled → bool   (iOS: canOpenURL spotify:, Android: PackageManager)
//   EventChannel `sistema/audio/events`: Map? при каждой смене трека/состояния (первое — сразу при подписке).
//   Map: {source: 'appleMusic' | 'other', title: String?, artist: String?, isPlaying: bool}
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_api.dart';
import 'spotify_bridge.dart';

class ChannelMusicController implements MusicController {
  ChannelMusicController({
    MethodChannel? channel,
    EventChannel? events,
    this._spotify = const UnavailableSpotifyBridge(),
    this._clientId = spotifyClientId,
    bool? supported,
  })  : _channel = channel ?? const MethodChannel(channelName),
        _eventChannel = events ?? const EventChannel(eventsName),
        _supported = supported ??
            (!kIsWeb &&
                (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android));

  static const channelName = 'sistema/audio';
  static const eventsName = 'sistema/audio/events';

  final MethodChannel _channel;
  final EventChannel _eventChannel;
  final SpotifyBridge _spotify;
  final String _clientId;
  final bool _supported;

  /// Один нативный слушатель на все watch() (EventChannel поддерживает только одну подписку).
  late final Stream<dynamic> _events = _eventChannel.receiveBroadcastStream();

  NowPlaying? _current;
  Future<void>? _access;

  /// Последнее известное состояние (для выбора, кем управлять).
  NowPlaying? get current => _current;

  @override
  Stream<NowPlaying?> watch() {
    if (!_supported) return Stream.value(null);
    NowPlaying? system;
    NowPlaying? spotify;
    NowPlaying? last;
    var emitted = false;
    var cancelled = false;
    StreamSubscription<dynamic>? systemSub;
    StreamSubscription<NowPlaying?>? spotifySub;
    late final StreamController<NowPlaying?> out;

    void emit() {
      final value = merge(system: system, spotify: spotify);
      if (emitted && sameNowPlaying(value, last)) return;
      emitted = true;
      last = value;
      _current = value;
      out.add(value);
    }

    out = StreamController<NowPlaying?>(
      onListen: () async {
        await (_access ??= _requestAccess());
        if (cancelled) return;
        systemSub = _events.listen(
          (e) {
            system = parseNowPlaying(e);
            emit();
          },
          onError: (Object e) {
            debugPrint('Музыка: ошибка событий: $e');
            system = null;
            emit();
          },
        );
        spotifySub = _spotify.watch().listen((v) {
          spotify = v;
          emit();
        });
      },
      onCancel: () async {
        cancelled = true;
        await systemSub?.cancel();
        await spotifySub?.cancel();
      },
    );
    return out.stream;
  }

  Future<void> _requestAccess() async {
    try {
      await _channel.invokeMethod<bool>('requestAccess');
    } catch (e) {
      debugPrint('Музыка: доступ не получен: $e');
    }
  }

  bool get _controlSpotify => _current?.source == MusicSource.spotify && _spotify.isConnected;

  @override
  Future<void> playPause() => _control('playPause', _spotify.playPause);

  @override
  Future<void> next() => _control('next', _spotify.next);

  @override
  Future<void> previous() => _control('previous', _spotify.previous);

  Future<void> _control(String method, Future<void> Function() spotifyAction) async {
    if (!_supported) return;
    try {
      if (_controlSpotify) {
        await spotifyAction();
      } else {
        await _channel.invokeMethod<void>(method);
      }
    } catch (e) {
      debugPrint('Музыка: $method не удался: $e');
    }
  }

  @override
  Future<bool> spotifyAvailable() async {
    if (!_supported || _clientId.isEmpty || !_spotify.supported) return false;
    try {
      return await _channel.invokeMethod<bool>('isSpotifyInstalled') ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> connectSpotify() async {
    if (!await spotifyAvailable()) return false;
    try {
      return await _spotify.connect(_clientId);
    } catch (e) {
      debugPrint('Spotify: подключение не удалось: $e');
      return false;
    }
  }

  /// Что показывать: играющий источник важнее; Spotify важнее системного при равенстве.
  @visibleForTesting
  static NowPlaying? merge({NowPlaying? system, NowPlaying? spotify}) {
    if (spotify != null && spotify.isPlaying) return spotify;
    if (system != null && system.isPlaying) return system;
    if (spotify != null) return spotify;
    // «Другой» источник на паузе — показывать нечего.
    if (system != null && system.source != MusicSource.other) return system;
    return null;
  }

  /// Разбор Map из канала; некорректное → null. У [MusicSource.other] название не показываем (SPEC §8.5).
  @visibleForTesting
  static NowPlaying? parseNowPlaying(Object? raw) {
    if (raw is! Map) return null;
    final source = switch (raw['source']) {
      'appleMusic' => MusicSource.appleMusic,
      'spotify' => MusicSource.spotify,
      'other' => MusicSource.other,
      _ => null,
    };
    if (source == null) return null;
    final isPlaying = raw['isPlaying'] == true;
    if (source == MusicSource.other) return NowPlaying(source: source, isPlaying: isPlaying);
    String? text(Object? v) => v is String && v.trim().isNotEmpty ? v.trim() : null;
    return NowPlaying(source: source, title: text(raw['title']), artist: text(raw['artist']), isPlaying: isPlaying);
  }

  static bool sameNowPlaying(NowPlaying? a, NowPlaying? b) {
    if (a == null || b == null) return a == b;
    return a.source == b.source && a.title == b.title && a.artist == b.artist && a.isPlaying == b.isPlaying;
  }
}
