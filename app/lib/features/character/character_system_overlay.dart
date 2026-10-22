// Android: персонаж поверх других приложений (SPEC §9.2, опционально). Только интерфейс.
// TODO(этап позже): реализация через SYSTEM_ALERT_WINDOW (разрешение «Поверх других приложений»,
// Settings.ACTION_MANAGE_OVERLAY_PERMISSION) и отдельный Flutter-движок/сервис оверлея — нативный код,
// AndroidManifest и выбор пакета правит главный агент. На iOS не поддерживается.
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class CharacterSystemOverlay {
  /// Ключ AppSettings: пользователь включил режим ('true'/'false').
  static const settingKey = 'character.systemOverlay';

  /// Поддерживает ли платформа режим (Android — да, когда появится реализация).
  bool get isSupported;

  /// Выдано ли разрешение оверлея.
  Future<bool> hasPermission();

  /// Открыть системный экран разрешения; true — если после возврата разрешение есть.
  Future<bool> requestPermission();

  /// Показать персонажа поверх других приложений (когда наше приложение свёрнуто).
  Future<void> show();

  Future<void> hide();
}

/// Заглушка: режим недоступен.
class UnsupportedCharacterSystemOverlay implements CharacterSystemOverlay {
  const UnsupportedCharacterSystemOverlay();

  @override
  bool get isSupported => false;

  @override
  Future<bool> hasPermission() async => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> show() async {}

  @override
  Future<void> hide() async {}
}

final characterSystemOverlayProvider =
    Provider<CharacterSystemOverlay>((ref) => const UnsupportedCharacterSystemOverlay());
