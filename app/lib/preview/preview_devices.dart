// Устройства и горячие клавиши веб-предпросмотра (только lib/main_preview.dart).
import 'dart:ui' as ui;

import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// iPhone 15 Pro: 393×852 @3x, Dynamic Island — геометрия как у iPhone 16,
/// которого пресет есть в device_preview 3.0 (15 Pro в каталоге нет).
final DevicePreset iPhone15Pro = DevicePreset(
  id: 'apple-iphone-15-pro',
  name: 'iPhone 15 Pro',
  brand: 'Apple',
  year: 2023,
  platform: TargetPlatform.iOS,
  portraitSize: const ui.Size(393, 852),
  devicePixelRatio: 3.0,
  portraitPadding: const EdgeInsets.only(top: 59, bottom: 34),
  landscapePadding: const EdgeInsets.only(left: 59, right: 59, bottom: 20),
  portraitKeyboardHeight: 335,
  landscapeKeyboardHeight: 208,
  frame: DevicePresets.iPhone16.frame,
  systemUi: DevicePresets.iPhone16.systemUi,
);

/// Alt+1 / Alt+2 / Alt+3.
final previewDevices = <DevicePreset>[iPhone15Pro, DevicePresets.pixel9, DevicePresets.galaxyS25];

const previewLocales = [Locale('ru'), Locale('tr')];

/// Крупный шрифт: Alt+T по кругу.
const previewTextScales = [1.0, 1.3, 1.5];

/// Переключение устройства/языка/шрифта и платформа выбранного устройства ('ios' / 'android').
class PreviewDevices {
  PreviewDevices(this.controller);

  final DevicePreviewController controller;

  /// Вызывается при смене платформы (iPhone ↔ Android) — обновить возможности.
  VoidCallback? onPlatformChanged;

  /// Alt+R — сбросить демо-данные (очистить БД и перезагрузить страницу).
  Future<void> Function()? onReset;

  String _platform = 'ios';
  String get platform => _platform;

  Future<void> init({bool android = false}) async {
    for (final p in previewDevices) {
      if (!controller.presets.any((e) => e.id == p.id)) controller.registerPreset(p);
    }
    await _apply(previewDevices[android ? 1 : 0]);
    await controller.update((s) => s.copyWith(locales: [previewLocales.first], textScaleFactor: 1.0));
    // Устройство могли сменить и во вкладке device_preview в DevTools — платформа идёт за ним.
    controller.simulationListenable.addListener(_syncPlatform);
    HardwareKeyboard.instance.addHandler(_onKey);
    debugPrint(help);
  }

  static const help = 'Предпросмотр: Alt+1 iPhone 15 Pro, Alt+2 Pixel 9, Alt+3 Galaxy S25, '
      'Alt+L язык ru/tr, Alt+T шрифт 100/130/150%, Alt+R сбросить демо-данные. '
      'В терминале: r — hot reload, R — hot restart, q — выход.';

  DevicePreset? get _current {
    final id = controller.simulation?.presetId;
    for (final p in controller.presets) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> _apply(DevicePreset p) async {
    await controller.applyPreset(p);
    await _syncTargetPlatform(p.platform);
    _syncPlatform();
    debugPrint('Предпросмотр: устройство ${p.name}');
  }

  /// Оформление Material/Cupertino по устройству (только debug: в profile/release платформа зашита компилятором).
  Future<void> _syncTargetPlatform(TargetPlatform platform) async {
    if (!kDebugMode || controller.simulation?.targetPlatform == platform) return;
    await controller.update((s) => s.copyWith(targetPlatform: platform));
  }

  void _syncPlatform() {
    final p = _current;
    if (p == null) return;
    final next = p.platform == TargetPlatform.android ? 'android' : 'ios';
    if (next == _platform) return;
    _platform = next;
    onPlatformChanged?.call();
    // Устройство сменили не горячей клавишей — подтянуть и оформление.
    Future.microtask(() => _syncTargetPlatform(p.platform));
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || !HardwareKeyboard.instance.isAltPressed) return false;
    final key = event.logicalKey;
    final index = [LogicalKeyboardKey.digit1, LogicalKeyboardKey.digit2, LogicalKeyboardKey.digit3].indexOf(key);
    if (index >= 0) {
      _apply(previewDevices[index]);
      return true;
    }
    if (key == LogicalKeyboardKey.keyL) {
      final current = controller.simulation?.locales?.first ?? previewLocales.first;
      final next = current.languageCode == 'ru' ? previewLocales[1] : previewLocales[0];
      controller.update((s) => s.copyWith(locales: [next]));
      debugPrint('Предпросмотр: язык ${next.languageCode}');
      return true;
    }
    if (key == LogicalKeyboardKey.keyT) {
      final current = controller.simulation?.textScaleFactor ?? 1.0;
      final i = previewTextScales.indexWhere((s) => (s - current).abs() < 0.01);
      final next = previewTextScales[(i + 1) % previewTextScales.length];
      controller.update((s) => s.copyWith(textScaleFactor: next));
      debugPrint('Предпросмотр: шрифт ×$next');
      return true;
    }
    if (key == LogicalKeyboardKey.keyR) {
      final reset = onReset;
      if (reset != null) {
        debugPrint('Предпросмотр: сброс демо-данных…');
        reset().catchError((Object e) => debugPrint('Предпросмотр: сброс не удался: $e'));
      }
      return true;
    }
    return false;
  }
}
