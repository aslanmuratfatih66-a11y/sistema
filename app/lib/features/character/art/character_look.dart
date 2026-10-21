import 'dart:ui';

import '../../../core/models/enums.dart';

enum HairStyle { sidePonytail, spiky, buzzBeard, longTied }

enum EyeStyle { bigRound, bright, narrowCalm, sharp }

/// Внешний вид архетипа: пропорции, палитра, детали. Все персонажи оригинальные.
class CharacterLook {
  const CharacterLook({
    required this.skin,
    required this.hair,
    required this.hairShade,
    required this.iris,
    required this.top,
    required this.topShade,
    required this.bottom,
    required this.shoes,
    required this.accent,
    required this.sleeve,
    required this.hairStyle,
    required this.eyeStyle,
    this.shoulderHalf = 13,
    this.waistHalf = 9,
    this.hipHalf = 7,
    this.armWidth = 6,
    this.legWidth = 7,
    this.headRx = 15,
    this.headRy = 16,
    this.skirt = false,
    this.scarf = false,
    this.cloak = false,
    this.sword = false,
    this.scar = false,
    this.belt = false,
    this.bareForearms = false,
  });

  final Color skin;
  final Color hair;
  final Color hairShade;
  final Color iris;
  final Color top;
  final Color topShade;
  final Color bottom;
  final Color shoes;
  final Color accent;

  /// Цвет рукава (верх руки); null-эквивалент — кожа (майка без рукавов).
  final Color sleeve;
  final HairStyle hairStyle;
  final EyeStyle eyeStyle;
  final double shoulderHalf;
  final double waistHalf;
  final double hipHalf;
  final double armWidth;
  final double legWidth;
  final double headRx;
  final double headRy;
  final bool skirt;
  final bool scarf;
  final bool cloak;
  final bool sword;
  final bool scar;
  final bool belt;

  /// Короткие рукава: предплечья открыты.
  final bool bareForearms;

  static CharacterLook of(CharacterArchetype a) => switch (a) {
        CharacterArchetype.animeGirl => _girl,
        CharacterArchetype.animeGuy => _guy,
        CharacterArchetype.stoicStrongman => _strongman,
        CharacterArchetype.grimSwordsman => _swordsman,
      };

  /// Жизнерадостная спортсменка: розовые волосы с боковым хвостом, бирюзовая куртка, юбка-шорты.
  static const _girl = CharacterLook(
    skin: Color(0xFFFFD9C4),
    hair: Color(0xFFFF7FB0),
    hairShade: Color(0xFFD9548C),
    iris: Color(0xFF34C6E8),
    top: Color(0xFF2EC4B6),
    topShade: Color(0xFF1B8F86),
    bottom: Color(0xFF26324F),
    shoes: Color(0xFFF5F7FF),
    accent: Color(0xFFFFE066),
    sleeve: Color(0xFF2EC4B6),
    hairStyle: HairStyle.sidePonytail,
    eyeStyle: EyeStyle.bigRound,
    shoulderHalf: 11,
    waistHalf: 7.5,
    hipHalf: 6,
    armWidth: 5,
    legWidth: 6,
    skirt: true,
    bareForearms: true,
  );

  /// Азартный соперник: острые тёмно-синие волосы, красный шарф, худи чёрное с оранжевым.
  static const _guy = CharacterLook(
    skin: Color(0xFFF6C9A8),
    hair: Color(0xFF3A5BD9),
    hairShade: Color(0xFF243A99),
    iris: Color(0xFFFF9F1C),
    top: Color(0xFF242A38),
    topShade: Color(0xFF151923),
    bottom: Color(0xFF4A5468),
    shoes: Color(0xFFFF9F1C),
    accent: Color(0xFFE63946),
    sleeve: Color(0xFF242A38),
    hairStyle: HairStyle.spiky,
    eyeStyle: EyeStyle.bright,
    scarf: true,
  );

  /// Спокойный силач: короткая стрижка и борода, широкие плечи, серая майка, пояс.
  static const _strongman = CharacterLook(
    skin: Color(0xFFC98E66),
    hair: Color(0xFF3B2A20),
    hairShade: Color(0xFF261A13),
    iris: Color(0xFF3B2A20),
    top: Color(0xFF8D99AE),
    topShade: Color(0xFF6B768C),
    bottom: Color(0xFF2B2D42),
    shoes: Color(0xFF5C4033),
    accent: Color(0xFFFFC857),
    sleeve: Color(0xFFC98E66),
    hairStyle: HairStyle.buzzBeard,
    eyeStyle: EyeStyle.narrowCalm,
    shoulderHalf: 18,
    waistHalf: 13,
    hipHalf: 9,
    armWidth: 9,
    legWidth: 9,
    headRx: 14.5,
    headRy: 15.5,
    belt: true,
    bareForearms: true,
  );

  /// Мрачный мечник: длинные чёрные волосы в хвосте, шрам, тёмно-фиолетовый плащ, меч за спиной.
  static const _swordsman = CharacterLook(
    skin: Color(0xFFEBC8B0),
    hair: Color(0xFF1E1E2C),
    hairShade: Color(0xFF0E0E16),
    iris: Color(0xFFE63946),
    top: Color(0xFF3D2C5A),
    topShade: Color(0xFF2A1E40),
    bottom: Color(0xFF22222E),
    shoes: Color(0xFF3A2E2A),
    accent: Color(0xFFB06CFF),
    sleeve: Color(0xFF3D2C5A),
    hairStyle: HairStyle.longTied,
    eyeStyle: EyeStyle.sharp,
    shoulderHalf: 13.5,
    cloak: true,
    sword: true,
    scar: true,
  );
}
