// КАРКАС: заглушка. Реализует сабагент A: линейные иконки stroke 1.7, CustomPainter.
import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

/// Единый набор линейных иконок приложения.
enum SysGlyph {
  bell, settings, status, quests, nutrition, shop, more, mic, check, close, plus, clock,
  water, flame, bolt, diamond, shield, sword, crown, moon, book, dumbbell, walk, wallet,
  heart, star, arrowUp, arrowDown, timer, home, warning, info, send, sparkle,
}

class SysIcon extends StatelessWidget {
  const SysIcon(this.glyph, {super.key, this.size = 20, this.color = SysColors.accentLight, this.semanticLabel});

  final SysGlyph glyph;
  final double size;
  final Color color;

  /// Подпись для скринридера (обязательна для интерактивных иконок без текста).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => SizedBox.square(dimension: size);
}
