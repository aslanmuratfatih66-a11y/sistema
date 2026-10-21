// Spotify (SPEC §8.5: SDK App Remote, Client ID из конфига) — точка подключения SDK.
//
// TODO(этап 4+/интеграция Spotify): реализовать SpotifyBridge поверх pub-пакета spotify_sdk (App Remote).
// Сейчас SDK в сборку НЕ подключён: нужны ручные шаги вне CI — регистрация приложения в Spotify Developer
// Dashboard (Bundle ID, SHA-1 ключа подписи Android, Redirect URI), схема Redirect URI в Info.plist,
// RedirectUriReceiverActivity в AndroidManifest, проверка на устройстве с установленным Spotify.
// API SDK здесь сознательно не описываем (SPEC §13 — не выдумывать API сторонних сервисов).
import 'audio_api.dart';

/// Мост к Spotify App Remote. Реализация с SDK подменяет [UnavailableSpotifyBridge].
abstract interface class SpotifyBridge {
  /// SDK собран в приложение.
  bool get supported;

  /// Подключиться к приложению Spotify (авторизация через приложение Spotify).
  Future<bool> connect(String clientId);

  bool get isConnected;

  /// Трек Spotify (source = spotify); null — не подключены / ничего не играет.
  Stream<NowPlaying?> watch();

  Future<void> playPause();
  Future<void> next();
  Future<void> previous();
}

/// Spotify недоступен (SDK не подключён). Всё — no-op.
class UnavailableSpotifyBridge implements SpotifyBridge {
  const UnavailableSpotifyBridge();

  @override
  bool get supported => false;

  @override
  bool get isConnected => false;

  @override
  Future<bool> connect(String clientId) async => false;

  @override
  Stream<NowPlaying?> watch() => const Stream.empty();

  @override
  Future<void> playPause() async {}

  @override
  Future<void> next() async {}

  @override
  Future<void> previous() async {}
}
