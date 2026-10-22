// Android: персонаж поверх других приложений (SPEC §9.2, §12 — SYSTEM_ALERT_WINDOW, по разрешению).
// Реализация Android — system_overlay_android.dart (канал "sistema/overlay", OverlayChannel.kt /
// OverlayBubble.kt / OverlayService.kt). Когда показывать — SystemOverlayController
// (system_overlay_controller.dart). На iOS и прочих платформах — UnsupportedCharacterSystemOverlay.
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'system_overlay_android.dart';

/// Тексты нативной части (уведомление foreground service) — из l10n, натив строк не знает.
@immutable
class SystemOverlayTexts {
  const SystemOverlayTexts({
    required this.notificationTitle,
    required this.notificationBody,
    required this.hideAction,
    required this.avatarLabel,
  });

  final String notificationTitle;
  final String notificationBody;

  /// Кнопка уведомления «Скрыть».
  final String hideAction;

  /// Описание аватара для TalkBack.
  final String avatarLabel;

  Map<String, String> toMap() => {
        'notificationTitle': notificationTitle,
        'notificationBody': notificationBody,
        'hideAction': hideAction,
        'avatarLabel': avatarLabel,
      };
}

abstract interface class CharacterSystemOverlay {
  /// Ключ AppSettings: пользователь включил режим ('true'/'false').
  static const settingKey = 'character.systemOverlay';

  /// Поддерживает ли платформа режим (Android — да).
  bool get isSupported;

  /// Выдано ли разрешение оверлея.
  Future<bool> hasPermission();

  /// Открыть системный экран разрешения; true — если после возврата разрешение есть.
  Future<bool> requestPermission();

  /// Показать персонажа поверх других приложений (когда наше приложение свёрнуто).
  /// [avatar] — PNG круглого аватара (см. renderCharacterAvatar), [texts] — строки уведомления.
  Future<void> show({Uint8List? avatar, SystemOverlayTexts? texts});

  Future<void> hide();

  /// Облачко с репликой рядом с аватаром на [duration]. Если оверлей не показан — игнорируется.
  Future<void> say(String text, {Duration duration = const Duration(seconds: 7)});

  /// Заменить картинку аватара (смена состояния персонажа).
  Future<void> setAvatar(Uint8List png);
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
  Future<void> show({Uint8List? avatar, SystemOverlayTexts? texts}) async {}

  @override
  Future<void> hide() async {}

  @override
  Future<void> say(String text, {Duration duration = const Duration(seconds: 7)}) async {}

  @override
  Future<void> setAvatar(Uint8List png) async {}
}

/// Реализация для текущей платформы: Android — нативный оверлей, иначе — заглушка.
CharacterSystemOverlay createCharacterSystemOverlay() =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android
        ? AndroidCharacterSystemOverlay()
        : const UnsupportedCharacterSystemOverlay();

final characterSystemOverlayProvider = Provider<CharacterSystemOverlay>((ref) => createCharacterSystemOverlay());
