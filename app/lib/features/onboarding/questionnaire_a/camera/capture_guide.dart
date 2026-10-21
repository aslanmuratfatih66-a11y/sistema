import 'package:flutter/widgets.dart';

import '../../../../ui/ui.dart';

/// Контурная подсказка поверх камеры.
enum CaptureGuide { bodyFront, bodySide, bodyBack, faceFront, faceLeft, faceRight, closeup }

/// Рисует контур (линейный стиль, свечение акцента) по центру области превью.
class CaptureGuidePainter extends CustomPainter {
  const CaptureGuidePainter(this.guide, {this.color = SysColors.accentLighter, this.glow = SysColors.accent});

  final CaptureGuide guide;
  final Color color;
  final Color glow;

  @override
  void paint(Canvas canvas, Size size) {
    final path = switch (guide) {
      CaptureGuide.bodyFront || CaptureGuide.bodyBack => _bodyFront(_box(size, .46, .88)),
      CaptureGuide.bodySide => _bodySide(_box(size, .46, .88)),
      CaptureGuide.faceFront => _face(_box(size, .72, .7), turn: 0),
      CaptureGuide.faceLeft => _face(_box(size, .72, .7), turn: -1),
      CaptureGuide.faceRight => _face(_box(size, .72, .7), turn: 1),
      CaptureGuide.closeup => _closeup(_box(size, 1, .6)),
    };
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = glow.withValues(alpha: .45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  /// Прямоугольник с соотношением [aspect] (ширина/высота), занимающий [fill] высоты (или ширины), по центру.
  static Rect _box(Size size, double aspect, double fill) {
    var h = size.height * fill;
    var w = h * aspect;
    if (w > size.width * fill) {
      w = size.width * fill;
      h = w / aspect;
    }
    return Rect.fromCenter(center: size.center(Offset.zero), width: w, height: h);
  }

  static Offset _pt(Rect r, double x, double y) => Offset(r.left + r.width * x, r.top + r.height * y);

  static Path _poly(Rect r, List<(double, double)> pts, {bool close = true}) {
    final p = Path()..moveTo(_pt(r, pts.first.$1, pts.first.$2).dx, _pt(r, pts.first.$1, pts.first.$2).dy);
    for (final (x, y) in pts.skip(1)) {
      final o = _pt(r, x, y);
      p.lineTo(o.dx, o.dy);
    }
    if (close) p.close();
    return p;
  }

  static Path _bodyFront(Rect r) {
    // Правая половина от шеи до промежности, левая — зеркально.
    const half = [
      (.56, .135), (.56, .165), (.78, .2), (.86, .32), (.9, .5), (.88, .545), (.84, .535), (.8, .36),
      (.73, .28), (.69, .42), (.73, .53), (.69, .76), (.63, .95), (.56, .975), (.545, .76), (.5, .57),
    ];
    final pts = [...half, for (final (x, y) in half.reversed.skip(1)) (1 - x, y)];
    return _poly(r, pts)..addOval(Rect.fromCenter(center: _pt(r, .5, .075), width: r.width * .24, height: r.height * .12));
  }

  static Path _bodySide(Rect r) {
    const outline = [
      (.46, .14), (.4, .2), (.38, .35), (.42, .45), (.36, .56), (.42, .76), (.42, .955), (.64, .975),
      (.53, .93), (.55, .76), (.59, .58), (.61, .45), (.63, .28), (.58, .2), (.54, .14),
    ];
    return _poly(r, outline)
      ..addPath(_poly(r, const [(.5, .21), (.53, .38), (.5, .53)], close: false), Offset.zero)
      ..addOval(Rect.fromCenter(center: _pt(r, .5, .075), width: r.width * .26, height: r.height * .12));
  }

  /// [turn]: 0 — анфас, −1 / 1 — профиль (шеврон показывает сторону поворота).
  static Path _face(Rect r, {required int turn}) {
    final p = Path()
      ..addOval(Rect.fromCenter(center: _pt(r, .5, .42), width: r.width * .66, height: r.height * .76))
      ..addPath(_poly(r, const [(.36, .74), (.33, 1)], close: false), Offset.zero)
      ..addPath(_poly(r, const [(.64, .74), (.67, 1)], close: false), Offset.zero);
    if (turn != 0) {
      final x = turn < 0 ? .06 : .94;
      final d = turn < 0 ? .06 : -.06;
      p.addPath(_poly(r, [(x + d, .34), (x, .42), (x + d, .5)], close: false), Offset.zero);
    }
    return p;
  }

  static Path _closeup(Rect r) {
    const c = .16;
    final p = Path();
    for (final (x, y, dx, dy) in const [(0.0, 0.0, 1, 1), (1.0, 0.0, -1, 1), (0.0, 1.0, 1, -1), (1.0, 1.0, -1, -1)]) {
      p.addPath(_poly(r, [(x, y + dy * c), (x, y), (x + dx * c, y)], close: false), Offset.zero);
    }
    p.addPath(_poly(r, const [(.46, .5), (.54, .5)], close: false), Offset.zero);
    p.addPath(_poly(r, const [(.5, .46), (.5, .54)], close: false), Offset.zero);
    return p;
  }

  @override
  bool shouldRepaint(CaptureGuidePainter old) => old.guide != guide || old.color != color || old.glow != glow;
}
