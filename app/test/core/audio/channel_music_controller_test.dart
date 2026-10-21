import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/audio/audio_api.dart';
import 'package:sistema/core/audio/channel_music_controller.dart';
import 'package:sistema/core/audio/spotify_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const method = MethodChannel(ChannelMusicController.channelName);
  const codec = StandardMethodCodec();

  group('parseNowPlaying', () {
    test('Apple Music с названием', () {
      final np = ChannelMusicController.parseNowPlaying(
          {'source': 'appleMusic', 'title': ' Song ', 'artist': 'Band', 'isPlaying': true})!;
      expect(np.source, MusicSource.appleMusic);
      expect(np.title, 'Song');
      expect(np.artist, 'Band');
      expect(np.isPlaying, isTrue);
    });

    test('other — без названия', () {
      final np = ChannelMusicController.parseNowPlaying({'source': 'other', 'title': 'X', 'isPlaying': true})!;
      expect(np.source, MusicSource.other);
      expect(np.title, isNull);
      expect(np.artist, isNull);
    });

    test('мусор → null', () {
      expect(ChannelMusicController.parseNowPlaying(null), isNull);
      expect(ChannelMusicController.parseNowPlaying('x'), isNull);
      expect(ChannelMusicController.parseNowPlaying({'source': 'yandex'}), isNull);
    });

    test('пустой title → null, isPlaying по умолчанию false', () {
      final np = ChannelMusicController.parseNowPlaying({'source': 'appleMusic', 'title': ''})!;
      expect(np.title, isNull);
      expect(np.isPlaying, isFalse);
    });
  });

  group('merge', () {
    const am = NowPlaying(source: MusicSource.appleMusic, title: 'a', isPlaying: true);
    const amPaused = NowPlaying(source: MusicSource.appleMusic, title: 'a');
    const sp = NowPlaying(source: MusicSource.spotify, title: 's', isPlaying: true);
    const otherPaused = NowPlaying(source: MusicSource.other);

    test('играющий Spotify важнее', () => expect(ChannelMusicController.merge(system: am, spotify: sp), sp));
    test('играющий системный важнее паузы Spotify', () {
      const spPaused = NowPlaying(source: MusicSource.spotify, title: 's');
      expect(ChannelMusicController.merge(system: am, spotify: spPaused), am);
    });
    test('Apple Music на паузе показывается', () => expect(ChannelMusicController.merge(system: amPaused), amPaused));
    test('other на паузе — ничего', () => expect(ChannelMusicController.merge(system: otherPaused), isNull));
  });

  group('контроллер на мок-канале', () {
    late List<String> calls;

    setUp(() {
      calls = [];
      messenger.setMockMethodCallHandler(method, (call) async {
        calls.add(call.method);
        return switch (call.method) {
          'requestAccess' => true,
          'isSpotifyInstalled' => true,
          _ => null,
        };
      });
    });

    tearDown(() {
      messenger.setMockMethodCallHandler(method, null);
      messenger.setMockMessageHandler(ChannelMusicController.eventsName, null);
    });

    test('управление уходит в канал', () async {
      final c = ChannelMusicController(supported: true);
      await c.playPause();
      await c.next();
      await c.previous();
      expect(calls, ['playPause', 'next', 'previous']);
    });

    test('неподдерживаемая платформа — канал не трогаем', () async {
      final c = ChannelMusicController(supported: false);
      await c.playPause();
      expect(await c.watch().first, isNull);
      expect(calls, isEmpty);
    });

    test('Spotify недоступен без Client ID и без SDK', () async {
      expect(await ChannelMusicController(supported: true, clientId: '').spotifyAvailable(), isFalse);
      expect(await ChannelMusicController(supported: true, clientId: 'id').spotifyAvailable(), isFalse);
      expect(await ChannelMusicController(supported: true, clientId: 'id').connectSpotify(), isFalse);
    });

    test('Spotify доступен при SDK, Client ID и установленном приложении', () async {
      final c = ChannelMusicController(supported: true, clientId: 'id', spotify: _FakeSpotify());
      expect(await c.spotifyAvailable(), isTrue);
      expect(calls, ['isSpotifyInstalled']);
    });

    test('watch: запрос доступа, события из EventChannel, дубликаты отбрасываются', () async {
      messenger.setMockMessageHandler(ChannelMusicController.eventsName, (msg) async {
        final call = codec.decodeMethodCall(msg);
        if (call.method == 'listen') {
          Future<void> emit(Object? v) => messenger.handlePlatformMessage(
              ChannelMusicController.eventsName, codec.encodeSuccessEnvelope(v), (_) {});
          scheduleMicrotask(() async {
            await emit({'source': 'appleMusic', 'title': 'A', 'isPlaying': true});
            await emit({'source': 'appleMusic', 'title': 'A', 'isPlaying': true});
            await emit({'source': 'appleMusic', 'title': 'A', 'isPlaying': false});
            await emit(null);
          });
        }
        return codec.encodeSuccessEnvelope(null);
      });
      final c = ChannelMusicController(supported: true);
      final values = await c.watch().take(3).toList();
      expect(calls.first, 'requestAccess');
      expect(values[0]!.isPlaying, isTrue);
      expect(values[1]!.isPlaying, isFalse);
      expect(values[2], isNull);
      expect(c.current, isNull);
    });
  });
}

class _FakeSpotify implements SpotifyBridge {
  @override
  bool get supported => true;
  @override
  bool get isConnected => false;
  @override
  Future<bool> connect(String clientId) async => true;
  @override
  Stream<NowPlaying?> watch() => const Stream.empty();
  @override
  Future<void> playPause() async {}
  @override
  Future<void> next() async {}
  @override
  Future<void> previous() async {}
}
