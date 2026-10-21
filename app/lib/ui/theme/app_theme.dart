// КАРКАС: заглушка. Реализует сабагент A (публичное API сохранить).
import 'package:flutter/material.dart';

import 'tokens.dart';

/// Единственная (тёмная) тема приложения.
ThemeData buildSystemTheme() => ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SysColors.background,
      fontFamily: SysFonts.body,
    );

/// Готовые стили текста. Заголовки — капс: вызывающий передаёт текст как есть,
/// компоненты сами делают toUpperCase.
abstract final class SysText {
  static const TextStyle heading = TextStyle(fontFamily: SysFonts.heading, fontSize: 16, letterSpacing: 2, color: SysColors.textPrimary);
  static const TextStyle title = TextStyle(fontFamily: SysFonts.heading, fontSize: 13, letterSpacing: 1.7, color: SysColors.textPrimary);
  static const TextStyle body = TextStyle(fontFamily: SysFonts.body, fontSize: 14, color: SysColors.textPrimary);
  static const TextStyle secondary = TextStyle(fontFamily: SysFonts.body, fontSize: 13, color: SysColors.textSecondary);
  static const TextStyle caption = TextStyle(fontFamily: SysFonts.body, fontSize: 11, color: SysColors.textCaption);
  static const TextStyle mono = TextStyle(fontFamily: SysFonts.mono, fontSize: 13, color: SysColors.textPrimary);
  static const TextStyle monoLarge = TextStyle(fontFamily: SysFonts.mono, fontSize: 22, color: SysColors.textPrimary);
}
