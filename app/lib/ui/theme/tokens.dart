// Токены дизайн-системы (SPEC §4). Контракт каркаса: имена публичных членов
// не переименовывать — на них опираются фичи. Добавлять новые можно.
import 'package:flutter/painting.dart';

abstract final class SysColors {
  // Фон
  static const background = Color(0xFF03050B);
  static const backgroundGlow = Color.fromRGBO(20, 70, 160, .55);
  static const gridLine = Color.fromRGBO(63, 180, 255, .045);
  static const double gridStep = 22;
  static const scanline = Color.fromRGBO(120, 190, 255, .035);
  static const double scanlineStep = 3;
  static const barrier = Color.fromRGBO(1, 3, 8, .78);

  // Панель
  static const panelTop = Color.fromRGBO(13, 32, 68, .94);
  static const panelBottom = Color.fromRGBO(5, 14, 32, .94);
  static const panelBorder = Color.fromRGBO(63, 180, 255, .55);
  static const panelOuterGlow = Color.fromRGBO(30, 120, 255, .28);
  static const panelInnerGlow = Color.fromRGBO(46, 139, 255, .10);
  static const panelCorner = Color(0xFF9FE2FF);
  static const panelHeaderDiamond = Color(0xFF7FD4FF);
  static const panelHeaderStripe = Color.fromRGBO(63, 180, 255, .18);

  // Текст
  static const textPrimary = Color(0xFFE6F3FF);
  static const textSecondary = Color(0xFFB9D3EE);
  static const textCaption = Color(0xFF8FB0D4);
  static const textInactive = Color(0xFF6F8FB4);

  // Акцент
  static const accent = Color(0xFF3FB4FF);
  static const accentLight = Color(0xFF7FD4FF);
  static const accentLighter = Color(0xFF9FE2FF);

  // Смысловые
  static const success = Color(0xFF5BE3A0);
  static const danger = Color(0xFFFF4D5E);
  static const dangerLight = Color(0xFFFF7A85);
  static const gold = Color(0xFFFFC857);
  static const boss = Color(0xFFB06CFF);
  static const bossLight = Color(0xFFC79BFF);

  // Шкалы
  static const energy = Color(0xFF5BE3A0);
  static const water = Color(0xFF3FB4FF);
  static const calories = Color(0xFFFFC857);
}

abstract final class SysFonts {
  static const heading = 'Oswald'; // КАПС, letterSpacing 0.12–0.14em
  static const body = 'Inter';
  static const mono = 'JetBrainsMono'; // все числа, таймеры, счётчики
}

abstract final class SysDims {
  static const double radius = 3;
  static const double cornerSize = 12;
  static const double cornerStroke = 2;
  static const double headerDiamond = 7;
  static const double iconStroke = 1.7;
  static const double minTap = 44;
  static const Duration windowAppear = Duration(milliseconds: 250);
  static const Duration holdToConfirm = Duration(seconds: 5);
  static const Duration barFill = Duration(milliseconds: 600);

  /// Межбуквенный интервал заголовков: 0.13em.
  static double headingSpacing(double fontSize) => fontSize * 0.13;
}

/// Смысловая тема панели/пилюли/кнопки: штрафы — красная, награды — золотая,
/// боссы — фиолетовая.
enum PanelTone { accent, gold, danger, boss, success }

/// Палитра конкретной темы панели.
class TonePalette {
  const TonePalette({
    required this.main,
    required this.light,
    required this.border,
    required this.glow,
    required this.top,
    required this.bottom,
  });

  final Color main;
  final Color light;
  final Color border;
  final Color glow;
  final Color top;
  final Color bottom;
}

extension PanelToneX on PanelTone {
  TonePalette get palette => switch (this) {
    PanelTone.accent => const TonePalette(
      main: SysColors.accent,
      light: SysColors.accentLighter,
      border: SysColors.panelBorder,
      glow: SysColors.panelOuterGlow,
      top: SysColors.panelTop,
      bottom: SysColors.panelBottom,
    ),
    PanelTone.gold => const TonePalette(
      main: SysColors.gold,
      light: Color(0xFFFFDE95),
      border: Color.fromRGBO(255, 200, 87, .55),
      glow: Color.fromRGBO(255, 170, 40, .24),
      top: Color.fromRGBO(52, 38, 12, .94),
      bottom: Color.fromRGBO(22, 15, 4, .94),
    ),
    PanelTone.danger => const TonePalette(
      main: SysColors.danger,
      light: SysColors.dangerLight,
      border: Color.fromRGBO(255, 77, 94, .55),
      glow: Color.fromRGBO(255, 40, 60, .26),
      top: Color.fromRGBO(60, 12, 20, .94),
      bottom: Color.fromRGBO(26, 4, 8, .94),
    ),
    PanelTone.boss => const TonePalette(
      main: SysColors.boss,
      light: SysColors.bossLight,
      border: Color.fromRGBO(176, 108, 255, .55),
      glow: Color.fromRGBO(140, 70, 255, .28),
      top: Color.fromRGBO(38, 18, 66, .94),
      bottom: Color.fromRGBO(15, 6, 30, .94),
    ),
    PanelTone.success => const TonePalette(
      main: SysColors.success,
      light: Color(0xFF9CF0C6),
      border: Color.fromRGBO(91, 227, 160, .55),
      glow: Color.fromRGBO(40, 200, 130, .24),
      top: Color.fromRGBO(10, 46, 34, .94),
      bottom: Color.fromRGBO(4, 20, 14, .94),
    ),
  };
}
