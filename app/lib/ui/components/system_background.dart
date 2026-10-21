import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

/// Фон: #03050B, радиальное свечение сверху, сетка 22px, сканлайны.
///
/// Статичный слой в собственном RepaintBoundary: перерисовывается только при
/// смене размера, анимации контента его не задевают.
class SystemBackground extends StatelessWidget {
  const SystemBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: SysColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: RepaintBoundary(
              child: IgnorePointer(child: CustomPaint(painter: SystemBackgroundPainter())),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Рисует фон системы (можно использовать отдельно, например в виджетах-превью).
class SystemBackgroundPainter extends CustomPainter {
  const SystemBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = Offset.zero & size;

    // Радиальное свечение сверху.
    final glowRadius = size.width * 0.95;
    final glowCenter = Offset(size.width / 2, -size.width * 0.12);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            SysColors.backgroundGlow,
            SysColors.backgroundGlow.withValues(alpha: .18),
            SysColors.backgroundGlow.withValues(alpha: 0),
          ],
          stops: const [0, .55, 1],
        ).createShader(Rect.fromCircle(center: glowCenter, radius: glowRadius)),
    );

    // Сетка 22px — одним путём.
    const step = SysColors.gridStep;
    final grid = Path();
    for (var x = step; x < size.width; x += step) {
      grid
        ..moveTo(x, 0)
        ..lineTo(x, size.height);
    }
    for (var y = step; y < size.height; y += step) {
      grid
        ..moveTo(0, y)
        ..lineTo(size.width, y);
    }
    canvas.drawPath(
      grid,
      Paint()
        ..color = SysColors.gridLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Сканлайны — тонкие горизонтальные полосы.
    const scanStep = SysColors.scanlineStep;
    final scan = Path();
    for (var y = 0.5; y < size.height; y += scanStep) {
      scan
        ..moveTo(0, y)
        ..lineTo(size.width, y);
    }
    canvas.drawPath(
      scan,
      Paint()
        ..color = SysColors.scanline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Лёгкое затемнение к низу — глубина.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [SysColors.background.withValues(alpha: 0), SysColors.background.withValues(alpha: .5)],
          stops: const [.6, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(SystemBackgroundPainter oldDelegate) => false;
}
