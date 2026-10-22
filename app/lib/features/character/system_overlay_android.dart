// Android-реализация CharacterSystemOverlay: канал "sistema/overlay" (OverlayChannel.kt).
//   hasPermission → bool
//   requestPermission — открыть Settings.ACTION_MANAGE_OVERLAY_PERMISSION
//   show {avatar: bytes?, texts: {notificationTitle, notificationBody, hideAction, avatarLabel}} → bool
//   hide
//   say {text, durationMs}
//   setAvatar {avatar: bytes}
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'character_system_overlay.dart';

class AndroidCharacterSystemOverlay implements CharacterSystemOverlay {
  AndroidCharacterSystemOverlay({MethodChannel? channel}) : _ch = channel ?? const MethodChannel('sistema/overlay');

  final MethodChannel _ch;

  @override
  bool get isSupported => true;

  @override
  Future<bool> hasPermission() async {
    try {
      return await _ch.invokeMethod<bool>('hasPermission') ?? false;
    } on PlatformException catch (e) {
      _log(e);
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    if (await hasPermission()) return true;
    final back = Completer<void>();
    final listener = AppLifecycleListener(onResume: () {
      if (!back.isCompleted) back.complete();
    });
    try {
      await _ch.invokeMethod<void>('requestPermission');
      // Ждём возврата из системного экрана (не дольше 5 минут).
      await back.future.timeout(const Duration(minutes: 5), onTimeout: () {});
    } on PlatformException catch (e) {
      _log(e);
    } on MissingPluginException {
      return false;
    } finally {
      listener.dispose();
    }
    // Система иногда применяет разрешение с задержкой — одна повторная проверка.
    if (await hasPermission()) return true;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return hasPermission();
  }

  @override
  Future<void> show({Uint8List? avatar, SystemOverlayTexts? texts}) =>
      _call('show', {'avatar': avatar, 'texts': texts?.toMap()});

  @override
  Future<void> hide() => _call('hide');

  @override
  Future<void> say(String text, {Duration duration = const Duration(seconds: 7)}) {
    final t = text.trim();
    if (t.isEmpty) return Future.value();
    return _call('say', {'text': t, 'durationMs': duration.inMilliseconds});
  }

  @override
  Future<void> setAvatar(Uint8List png) => _call('setAvatar', {'avatar': png});

  Future<void> _call(String method, [Map<String, Object?>? args]) async {
    try {
      await _ch.invokeMethod<Object?>(method, args);
    } on PlatformException catch (e) {
      _log(e);
    } on MissingPluginException {
      // Канал не зарегистрирован (тесты / старая сборка) — молча.
    }
  }

  static void _log(Object e) => debugPrint('CharacterSystemOverlay: $e');
}
