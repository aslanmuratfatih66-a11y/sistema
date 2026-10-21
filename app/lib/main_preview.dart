// Режим предпросмотра в браузере: `flutter run -d chrome -t lib/main_preview.dart`.
// Рамка iPhone 15 Pro (device_preview), заглушки нативных функций, Alt+L — ru/tr.
// В релизную сборку телефона не попадает: там точка входа lib/main.dart.
import 'dart:ui' as ui;

import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/capabilities/capability_service.dart';
import 'core/capabilities/preview_capability_service.dart';

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

const _locales = [Locale('ru'), Locale('tr')];

Future<void> main() async {
  DevicePreview.enable(enabled: true);
  final controller = DevicePreview.controller;
  controller.registerPreset(iPhone15Pro);
  await controller.applyPreset(iPhone15Pro);
  await controller.update((s) => s.copyWith(locales: [_locales.first]));

  HardwareKeyboard.instance.addHandler(_toggleLocaleOnAltL);
  debugPrint('Предпросмотр: Alt+L — ru/tr; остальное — вкладка device_preview в DevTools.');

  runApp(ProviderScope(
    overrides: [
      capabilityServiceProvider.overrideWithValue(PreviewCapabilityService()),
    ],
    child: const SistemaApp(),
  ));
}

bool _toggleLocaleOnAltL(KeyEvent event) {
  if (event is! KeyDownEvent ||
      event.logicalKey != LogicalKeyboardKey.keyL ||
      !HardwareKeyboard.instance.isAltPressed) {
    return false;
  }
  final controller = DevicePreview.controller;
  final current = controller.simulation?.locales?.first ?? _locales.first;
  final next = current.languageCode == 'ru' ? _locales[1] : _locales[0];
  controller.update((s) => s.copyWith(locales: [next]));
  debugPrint('Предпросмотр: язык ${next.languageCode}');
  return true;
}
