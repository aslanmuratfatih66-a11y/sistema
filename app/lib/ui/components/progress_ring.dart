import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

/// Кольцо прогресса/таймер со свечением; [center] — содержимое внутри.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 72,
    this.strokeWidth = 5,
    this.color = SysColors.accent,
    this.center,
    this.semanticLabel,
    this.semanticValue,
  });

  /// 0..1
  final double progress;
  final double size;
  final double strokeWidth;
  final Color color;
  final Widget? center;

  /// Подпись и значение для скринридера (необязательно).
  final String? semanticLabel;
  final String? semanticValue;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final c = center;
    Widget ring = SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(end: progress.clamp(0.0, 1.0)),
            duration: reduce ? Duration.zero : SysDims.barFill,
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => CustomPaint(painter: _RingPainter(v, color, strokeWidth)),
          ),
          if (c != null)
            Padding(
              padding: EdgeInsets.all(strokeWidth * 2),
              child: Center(
                child: FittedBox(fit: BoxFit.scaleDown, child: c),
              ),
            ),
        ],
      ),
    );
    if (semanticLabel != null || semanticValue != null) {
      ring = Semantics(label: semanticLabel, value: semanticValue, child: ring);
    }
    return ring;
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.progress, this.color, this.stroke);
  final double progress;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final r = (math.min(size.width, size.height) - stroke) / 2 - 2;
    if (r <= 0) return;
    final center = size.center(Offset.zero);
    final rect = Rect.fromCircle(center: center, radius: r);

    // Трек.
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = color.withValues(alpha: .14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    // Тонкие риски по треку — «приборный» вид.
    final tick = Paint()
      ..color = color.withValues(alpha: .25)
      ..strokeWidth = 1;
    for (var i = 0; i < 24; i++) {
      final a = i * math.pi / 12;
      final inner = r - stroke / 2 - 3;
      final outer = r - stroke / 2 - 1;
      canvas.drawLine(
        center + Offset(math.cos(a), math.sin(a)) * inner,
        center + Offset(math.cos(a), math.sin(a)) * outer,
        tick,
      );
    }

    if (progress <= 0) return;
    final sweep = 2 * math.pi * progress;
    const start = -math.pi / 2;
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..color = color.withValues(alpha: .6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke + 2
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.color != color || old.stroke != stroke;
}
