import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

/// Анимация появления окна: масштаб 0.96→1 + прозрачность + «скан» сверху вниз 250 мс.
/// Уважает «Уменьшение движения» (MediaQuery.disableAnimations): тогда показывает
/// содержимое сразу.
class WindowAppear extends StatefulWidget {
  const WindowAppear({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = SysDims.windowAppear,
    this.scanColor = SysColors.accentLighter,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Цвет полосы-«скана».
  final Color scanColor;

  @override
  State<WindowAppear> createState() => _WindowAppearState();
}

class _WindowAppearState extends State<WindowAppear> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    final total = widget.delay + widget.duration;
    // Задержка реализована интервалом внутри одного контроллера — без Timer.
    _controller = AnimationController(vsync: this, duration: total);
    final start = total.inMicroseconds == 0 ? 0.0 : widget.delay.inMicroseconds / total.inMicroseconds;
    _t = CurvedAnimation(parent: _controller, curve: Interval(start, 1));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.value = 1;
    } else if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Структура дерева постоянна, чтобы состояние потомков не сбрасывалось.
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) {
        final v = _t.value;
        final eased = Curves.easeOutCubic.transform(v);
        return Opacity(
          opacity: eased,
          child: Transform.scale(
            scale: 0.96 + 0.04 * eased,
            child: CustomPaint(
              foregroundPainter: _ScanPainter(v, widget.scanColor),
              child: ClipRect(
                clipper: _RevealClipper(v),
                clipBehavior: v >= 1 ? Clip.none : Clip.hardEdge,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Открывает содержимое сверху вниз вслед за «сканом» (с небольшим опережением).
class _RevealClipper extends CustomClipper<Rect> {
  _RevealClipper(this.t);
  final double t;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(-40, -40, size.width + 80, (size.height + 40) * (t * 1.3).clamp(0, 1) + 40);

  @override
  bool shouldReclip(_RevealClipper oldClipper) => oldClipper.t != t;
}

class _ScanPainter extends CustomPainter {
  _ScanPainter(this.t, this.color);
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1 || size.isEmpty) return;
    final y = size.height * t;
    final fade = (1 - t).clamp(0.0, 1.0);
    // Шлейф над линией.
    const trail = 28.0;
    final trailRect = Rect.fromLTRB(0, (y - trail).clamp(0, size.height), size.width, y);
    if (trailRect.height > 0) {
      canvas.drawRect(
        trailRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0),
              color.withValues(alpha: .22 * fade),
            ],
          ).createShader(trailRect),
      );
    }
    // Яркая линия.
    canvas.drawRect(Rect.fromLTWH(0, y - 1, size.width, 2), Paint()..color = color.withValues(alpha: .85 * fade));
  }

  @override
  bool shouldRepaint(_ScanPainter old) => old.t != t || old.color != color;
}
