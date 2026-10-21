import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';

/// Шестиугольник с уровнем: светящийся контур, внутри «LV» и число моно.
class LevelHexagon extends StatelessWidget {
  const LevelHexagon({super.key, required this.level, this.size = 68});

  final int level;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      label: l.homeLevelSemantics(level),
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size * 1.1,
        child: CustomPaint(
          painter: const HexagonPainter(),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: EdgeInsets.all(size * 0.16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l.homeLevelShort,
                      style: SysText.caption.copyWith(
                        fontFamily: SysFonts.heading,
                        letterSpacing: 1.6,
                        color: SysColors.accentLight,
                        height: 1,
                      ),
                    ),
                    Text(
                      '$level',
                      style: SysText.monoLarge.copyWith(
                        fontSize: size * 0.36,
                        height: 1.1,
                        fontWeight: FontWeight.w700,
                        shadows: const [Shadow(color: SysColors.accent, blurRadius: 10)],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Шестиугольник «на вершине»: заливка-градиент, внешнее свечение, двойной контур.
class HexagonPainter extends CustomPainter {
  const HexagonPainter({this.color = SysColors.accent, this.lightColor = SysColors.accentLighter});

  final Color color;
  final Color lightColor;

  static Path hexPath(Rect r) {
    final c = r.center;
    final rad = math.min(r.width / 2, r.height / 2);
    final p = Path();
    for (var i = 0; i < 6; i++) {
      final a = -math.pi / 2 + i * math.pi / 3;
      final pt = Offset(c.dx + rad * math.cos(a), c.dy + rad * math.sin(a));
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    return p..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final outer = hexPath(Offset.zero & size);
    final inner = hexPath((Offset.zero & size).deflate(size.shortestSide * 0.1));

    canvas.drawPath(
      outer,
      Paint()
        ..color = color.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(
      outer,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [SysColors.panelTop, SysColors.panelBottom],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = lightColor,
    );
    canvas.drawPath(
      inner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(HexagonPainter old) => old.color != color || old.lightColor != lightColor;
}
