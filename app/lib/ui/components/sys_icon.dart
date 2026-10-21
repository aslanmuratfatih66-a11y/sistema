import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

/// Единый набор линейных иконок приложения.
enum SysGlyph {
  bell,
  settings,
  status,
  quests,
  nutrition,
  shop,
  more,
  mic,
  check,
  close,
  plus,
  clock,
  water,
  flame,
  bolt,
  diamond,
  shield,
  sword,
  crown,
  moon,
  book,
  dumbbell,
  walk,
  wallet,
  heart,
  star,
  arrowUp,
  arrowDown,
  timer,
  home,
  warning,
  info,
  send,
  sparkle,
}

/// Линейная иконка (stroke 1.7 на сетке 24×24, масштабируется по [size]).
class SysIcon extends StatelessWidget {
  const SysIcon(this.glyph, {super.key, this.size = 20, this.color = SysColors.accentLight, this.semanticLabel});

  final SysGlyph glyph;
  final double size;
  final Color color;

  /// Подпись для скринридера (обязательна для интерактивных иконок без текста).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final icon = SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: SysGlyphPainter(glyph, color)),
    );
    final label = semanticLabel;
    if (label == null) return ExcludeSemantics(child: icon);
    return Semantics(label: label, image: true, excludeSemantics: true, child: icon);
  }
}

/// Рисует [SysGlyph] в любом прямоугольнике (базовая сетка 24×24).
class SysGlyphPainter extends CustomPainter {
  const SysGlyphPainter(this.glyph, this.color, {this.strokeWidth = SysDims.iconStroke});

  final SysGlyph glyph;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) / 24;
    canvas.save();
    canvas.translate((size.width - 24 * s) / 2, (size.height - 24 * s) / 2);
    canvas.scale(s);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    _draw(canvas, stroke, fill);
    canvas.restore();
  }

  void _line(Canvas c, Paint p, double x1, double y1, double x2, double y2) =>
      c.drawLine(Offset(x1, y1), Offset(x2, y2), p);

  Path _poly(List<double> xy, {bool close = false}) {
    final path = Path()..moveTo(xy[0], xy[1]);
    for (var i = 2; i < xy.length; i += 2) {
      path.lineTo(xy[i], xy[i + 1]);
    }
    if (close) path.close();
    return path;
  }

  void _draw(Canvas c, Paint p, Paint f) {
    switch (glyph) {
      case SysGlyph.bell:
        c.drawPath(
          Path()
            ..moveTo(6, 16.5)
            ..lineTo(6, 11)
            ..arcToPoint(const Offset(18, 11), radius: const Radius.circular(6))
            ..lineTo(18, 16.5)
            ..lineTo(19.5, 18.5)
            ..lineTo(4.5, 18.5)
            ..close(),
          p,
        );
        c.drawPath(
          Path()
            ..moveTo(10, 21)
            ..quadraticBezierTo(12, 22.6, 14, 21),
          p,
        );
        _line(c, p, 12, 3, 12, 5);
      case SysGlyph.settings:
        c.drawCircle(const Offset(12, 12), 3, p);
        c.drawCircle(const Offset(12, 12), 6.5, p);
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          _line(c, p, 12 + 6.5 * math.cos(a), 12 + 6.5 * math.sin(a), 12 + 9 * math.cos(a), 12 + 9 * math.sin(a));
        }
      case SysGlyph.status:
        final hex = <double>[];
        for (var i = 0; i < 6; i++) {
          final a = -math.pi / 2 + i * math.pi / 3;
          hex
            ..add(12 + 9.5 * math.cos(a))
            ..add(12 + 9.5 * math.sin(a));
        }
        c.drawPath(_poly(hex, close: true), p);
        c.drawPath(_poly([6.5, 12.5, 9.5, 12.5, 11, 9, 13, 15.5, 14.5, 11.5, 17.5, 11.5]), p);
      case SysGlyph.quests:
        c.drawRRect(RRect.fromLTRBR(4.5, 3, 19.5, 21, const Radius.circular(2)), p);
        c.drawPath(_poly([7.5, 8.5, 9, 10, 11.5, 7.5]), p);
        _line(c, p, 13.5, 9, 16.5, 9);
        c.drawPath(_poly([7.5, 14.5, 9, 16, 11.5, 13.5]), p);
        _line(c, p, 13.5, 15, 16.5, 15);
      case SysGlyph.nutrition:
        c.drawPath(
          Path()
            ..moveTo(6, 3)
            ..lineTo(6, 8.5)
            ..arcToPoint(const Offset(11, 8.5), radius: const Radius.circular(2.5), clockwise: false)
            ..lineTo(11, 3),
          p,
        );
        _line(c, p, 8.5, 3, 8.5, 21);
        c.drawPath(
          Path()
            ..moveTo(17, 21)
            ..lineTo(17, 3)
            ..cubicTo(14.8, 4.5, 14, 7.5, 14, 12)
            ..lineTo(17, 12),
          p,
        );
      case SysGlyph.shop:
        c.drawPath(_poly([4.5, 8, 19.5, 8, 18.5, 20.5, 5.5, 20.5], close: true), p);
        c.drawPath(
          Path()
            ..moveTo(9, 10.5)
            ..lineTo(9, 6.5)
            ..arcToPoint(const Offset(15, 6.5), radius: const Radius.circular(3))
            ..lineTo(15, 10.5),
          p,
        );
      case SysGlyph.more:
        for (final x in const [5.5, 12.0, 18.5]) {
          c.drawCircle(Offset(x, 12), 1.6, f);
        }
      case SysGlyph.mic:
        c.drawRRect(RRect.fromLTRBR(9, 3, 15, 14.5, const Radius.circular(3)), p);
        c.drawPath(
          Path()
            ..moveTo(5.5, 11)
            ..arcToPoint(const Offset(18.5, 11), radius: const Radius.circular(6.5), clockwise: false),
          p,
        );
        _line(c, p, 12, 17.5, 12, 21);
        _line(c, p, 9, 21, 15, 21);
      case SysGlyph.check:
        c.drawPath(_poly([5, 12.5, 9.5, 17, 19, 7]), p);
      case SysGlyph.close:
        _line(c, p, 6, 6, 18, 18);
        _line(c, p, 18, 6, 6, 18);
      case SysGlyph.plus:
        _line(c, p, 12, 5, 12, 19);
        _line(c, p, 5, 12, 19, 12);
      case SysGlyph.clock:
        c.drawCircle(const Offset(12, 12), 9, p);
        c.drawPath(_poly([12, 7, 12, 12, 15.5, 14]), p);
      case SysGlyph.water:
        c.drawPath(
          Path()
            ..moveTo(12, 3)
            ..cubicTo(9, 7, 6, 10.5, 6, 14)
            ..arcToPoint(const Offset(18, 14), radius: const Radius.circular(6), clockwise: false)
            ..cubicTo(18, 10.5, 15, 7, 12, 3)
            ..close(),
          p,
        );
        c.drawPath(
          Path()
            ..moveTo(9, 14.5)
            ..quadraticBezierTo(9.3, 16.8, 11.5, 17.5),
          p,
        );
      case SysGlyph.flame:
        c.drawPath(
          Path()
            ..moveTo(12, 3)
            ..cubicTo(13, 7, 18, 9, 18, 14.5)
            ..arcToPoint(const Offset(6, 14.5), radius: const Radius.circular(6))
            ..cubicTo(6, 11.5, 7.5, 10, 8.5, 8.5)
            ..cubicTo(9.5, 10, 10, 11, 11, 11.5)
            ..cubicTo(11.5, 9, 12, 6, 12, 3)
            ..close(),
          p,
        );
      case SysGlyph.bolt:
        c.drawPath(_poly([13.5, 2.5, 5, 13.5, 11, 13.5, 10.5, 21.5, 19, 10.5, 13, 10.5], close: true), p);
      case SysGlyph.diamond:
        c.drawPath(_poly([12, 3, 20, 12, 12, 21, 4, 12], close: true), p);
        c.drawPath(_poly([8, 7.5, 12, 12, 16, 7.5]), p);
      case SysGlyph.shield:
        c.drawPath(
          Path()
            ..moveTo(12, 3)
            ..lineTo(19, 6)
            ..lineTo(19, 11)
            ..cubicTo(19, 16, 16, 19.5, 12, 21)
            ..cubicTo(8, 19.5, 5, 16, 5, 11)
            ..lineTo(5, 6)
            ..close(),
          p,
        );
        c.drawPath(_poly([9, 12, 11.2, 14.2, 15, 10]), p);
      case SysGlyph.sword:
        c.drawPath(_poly([20.5, 3.5, 20, 7.5, 11, 16.5, 7.5, 13, 16.5, 4], close: true), p);
        _line(c, p, 6, 12, 12, 18);
        _line(c, p, 8.8, 15.2, 4, 20);
      case SysGlyph.crown:
        c.drawPath(_poly([4.5, 17.5, 3, 7, 8, 11, 12, 5, 16, 11, 21, 7, 19.5, 17.5], close: true), p);
        _line(c, p, 5, 20.5, 19, 20.5);
      case SysGlyph.moon:
        c.drawPath(
          Path()
            ..moveTo(19.5, 14.5)
            ..arcToPoint(const Offset(9.5, 4.5), radius: const Radius.circular(8.5), largeArc: true)
            ..arcToPoint(const Offset(19.5, 14.5), radius: const Radius.circular(7), clockwise: false)
            ..close(),
          p,
        );
      case SysGlyph.book:
        c.drawPath(
          Path()
            ..moveTo(12, 6.5)
            ..cubicTo(10, 5, 7, 4.5, 3.5, 5)
            ..lineTo(3.5, 19)
            ..cubicTo(7, 18.5, 10, 19, 12, 20.5)
            ..cubicTo(14, 19, 17, 18.5, 20.5, 19)
            ..lineTo(20.5, 5)
            ..cubicTo(17, 4.5, 14, 5, 12, 6.5)
            ..close(),
          p,
        );
        _line(c, p, 12, 6.5, 12, 20.5);
      case SysGlyph.dumbbell:
        _line(c, p, 8, 12, 16, 12);
        c.drawRRect(RRect.fromLTRBR(4.5, 7.5, 8, 16.5, const Radius.circular(1)), p);
        c.drawRRect(RRect.fromLTRBR(16, 7.5, 19.5, 16.5, const Radius.circular(1)), p);
        _line(c, p, 2.5, 12, 4.5, 12);
        _line(c, p, 19.5, 12, 21.5, 12);
      case SysGlyph.walk:
        c.drawCircle(const Offset(13.5, 4.5), 1.8, p);
        c.drawPath(_poly([13, 8, 11.5, 14, 8.5, 20.5]), p);
        c.drawPath(_poly([11.5, 14, 14.5, 16.5, 15.5, 20.5]), p);
        c.drawPath(_poly([8, 11.5, 10.5, 8.5, 13, 8, 15, 11, 17.5, 11.5]), p);
      case SysGlyph.wallet:
        c.drawRRect(RRect.fromLTRBR(3, 6, 21, 19.5, const Radius.circular(2)), p);
        _line(c, p, 3, 9.5, 15, 9.5);
        c.drawRRect(RRect.fromLTRBR(15, 10.5, 21, 15.5, const Radius.circular(1.5)), p);
        c.drawCircle(const Offset(17.6, 13), 0.9, f);
      case SysGlyph.heart:
        c.drawPath(
          Path()
            ..moveTo(12, 20)
            ..cubicTo(6, 16, 3, 12.5, 3, 9)
            ..cubicTo(3, 6, 5.2, 4, 7.6, 4)
            ..cubicTo(9.6, 4, 11, 5.2, 12, 7)
            ..cubicTo(13, 5.2, 14.4, 4, 16.4, 4)
            ..cubicTo(18.8, 4, 21, 6, 21, 9)
            ..cubicTo(21, 12.5, 18, 16, 12, 20)
            ..close(),
          p,
        );
      case SysGlyph.star:
        final pts = <double>[];
        for (var i = 0; i < 10; i++) {
          final r = i.isEven ? 9.0 : 3.9;
          final a = -math.pi / 2 + i * math.pi / 5;
          pts
            ..add(12 + r * math.cos(a))
            ..add(12.8 + r * math.sin(a));
        }
        c.drawPath(_poly(pts, close: true), p);
      case SysGlyph.arrowUp:
        _line(c, p, 12, 19, 12, 5);
        c.drawPath(_poly([6, 11, 12, 5, 18, 11]), p);
      case SysGlyph.arrowDown:
        _line(c, p, 12, 5, 12, 19);
        c.drawPath(_poly([6, 13, 12, 19, 18, 13]), p);
      case SysGlyph.timer:
        c.drawCircle(const Offset(12, 13.5), 7.5, p);
        _line(c, p, 12, 13.5, 12, 9.5);
        _line(c, p, 10, 2.5, 14, 2.5);
        _line(c, p, 12, 2.5, 12, 6);
        _line(c, p, 18, 6.5, 19.5, 5);
      case SysGlyph.home:
        c.drawPath(_poly([3.5, 11, 12, 4, 20.5, 11]), p);
        c.drawPath(_poly([6, 9.5, 6, 20, 18, 20, 18, 9.5]), p);
        c.drawPath(_poly([10, 20, 10, 15, 14, 15, 14, 20]), p);
      case SysGlyph.warning:
        c.drawPath(_poly([12, 3.5, 21.5, 20, 2.5, 20], close: true), p);
        _line(c, p, 12, 10, 12, 14.5);
        c.drawCircle(const Offset(12, 17.2), 1, f);
      case SysGlyph.info:
        c.drawCircle(const Offset(12, 12), 9, p);
        _line(c, p, 12, 11, 12, 16.5);
        c.drawCircle(const Offset(12, 7.8), 1, f);
      case SysGlyph.send:
        c.drawPath(_poly([21, 3, 3, 10.5, 10, 13.5, 13.5, 21], close: true), p);
        _line(c, p, 21, 3, 10, 13.5);
      case SysGlyph.sparkle:
        c.drawPath(
          Path()
            ..moveTo(11, 4)
            ..cubicTo(11.7, 9, 14, 11.3, 19, 12)
            ..cubicTo(14, 12.7, 11.7, 15, 11, 20)
            ..cubicTo(10.3, 15, 8, 12.7, 3, 12)
            ..cubicTo(8, 11.3, 10.3, 9, 11, 4)
            ..close(),
          p,
        );
        _line(c, p, 19, 2.5, 19, 6.5);
        _line(c, p, 17, 4.5, 21, 4.5);
    }
  }

  @override
  bool shouldRepaint(SysGlyphPainter old) => old.glyph != glyph || old.color != color || old.strokeWidth != strokeWidth;
}
