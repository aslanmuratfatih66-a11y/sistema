import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'window_appear.dart';

/// Голографическая панель: градиент, рамка, свечение, L-уголки (левый верхний и
/// правый нижний), опциональная полоса-заголовок с ромбом.
class SysPanel extends StatelessWidget {
  const SysPanel({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.tone = PanelTone.accent,
    this.padding = const EdgeInsets.all(14),
    this.animateIn = true,
    this.appearDelay = Duration.zero,
  });

  final Widget child;

  /// Текст полосы-заголовка (рисуется капсом). null — без заголовка.
  final String? title;

  /// Виджет справа в полосе-заголовке (таймер, счётчик).
  final Widget? trailing;
  final PanelTone tone;
  final EdgeInsetsGeometry padding;

  /// Анимация появления окна (WindowAppear) при первом показе.
  final bool animateIn;

  /// Задержка анимации появления (для каскада панелей).
  final Duration appearDelay;

  @override
  Widget build(BuildContext context) {
    final p = tone.palette;
    final radius = BorderRadius.circular(SysDims.radius);
    final cornerColor = tone == PanelTone.accent ? SysColors.panelCorner : p.light;

    Widget body = Padding(padding: padding, child: child);
    final t = title;
    if (t != null) {
      body = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanelHeader(title: t, tone: tone, trailing: trailing),
          body,
        ],
      );
    }

    Widget panel = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [BoxShadow(color: p.glow, blurRadius: 24)],
      ),
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: p.border),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [p.top, p.bottom],
              ),
            ),
            child: CustomPaint(painter: _InnerGlowPainter(_innerGlow(p)), child: body),
          ),
        ),
      ),
    );

    panel = CustomPaint(foregroundPainter: _CornersPainter(cornerColor), child: panel);

    if (animateIn) {
      panel = WindowAppear(delay: appearDelay, scanColor: p.light, child: panel);
    }
    return panel;
  }

  static Color _innerGlow(TonePalette p) =>
      identical(p.main, SysColors.accent) ? SysColors.panelInnerGlow : p.main.withValues(alpha: .10);
}

/// Полоса-заголовок панели: ромб 7px, текст Oswald капсом, градиент слева,
/// [trailing] справа. Отдельно — для собственных компоновок.
class SysPanelHeader extends StatelessWidget {
  const SysPanelHeader({super.key, required this.title, this.tone = PanelTone.accent, this.trailing});

  final String title;
  final PanelTone tone;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = tone.palette;
    final diamond = tone == PanelTone.accent ? SysColors.panelHeaderDiamond : p.light;
    final stripe = tone == PanelTone.accent ? SysColors.panelHeaderStripe : p.main.withValues(alpha: .18);
    final tr = trailing;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [stripe, stripe.withValues(alpha: 0)], stops: const [0, .85]),
        border: Border(bottom: BorderSide(color: p.border.withValues(alpha: .25))),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 9, 12, 9),
        child: Row(
          children: [
            SysDiamond(color: diamond),
            const SizedBox(width: 9),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  title.toUpperCase(),
                  style: SysText.title.copyWith(
                    color: tone == PanelTone.accent ? SysColors.textPrimary : p.light,
                    shadows: [Shadow(color: p.main.withValues(alpha: .55), blurRadius: 8)],
                  ),
                ),
              ),
            ),
            if (tr != null) ...[
              const SizedBox(width: 8),
              DefaultTextStyle.merge(
                style: SysText.mono.copyWith(color: p.light),
                child: tr,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Ромб-маркер со свечением (по умолчанию 7px).
class SysDiamond extends StatelessWidget {
  const SysDiamond({super.key, this.color = SysColors.panelHeaderDiamond, this.size = SysDims.headerDiamond});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Ромб — квадрат, повёрнутый на 45°: диагональ = size.
    final side = size / 1.41421356;
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: Transform.rotate(
          angle: 0.785398163,
          child: Container(
            width: side,
            height: side,
            decoration: BoxDecoration(
              color: color,
              boxShadow: [BoxShadow(color: color.withValues(alpha: .7), blurRadius: 6)],
            ),
          ),
        ),
      ),
    );
  }
}

/// Внутреннее inset-свечение: градиенты от краёв внутрь (дешевле blur).
class _InnerGlowPainter extends CustomPainter {
  _InnerGlowPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    const depth = 30.0;
    final transparent = color.withValues(alpha: 0);
    final dx = depth.clamp(0, size.width / 2).toDouble();
    final dy = depth.clamp(0, size.height / 2).toDouble();
    void edge(Rect r, Alignment from, Alignment to) {
      canvas.drawRect(
        r,
        Paint()..shader = LinearGradient(begin: from, end: to, colors: [color, transparent]).createShader(r),
      );
    }

    edge(Rect.fromLTWH(0, 0, size.width, dy), Alignment.topCenter, Alignment.bottomCenter);
    edge(Rect.fromLTWH(0, size.height - dy, size.width, dy), Alignment.bottomCenter, Alignment.topCenter);
    edge(Rect.fromLTWH(0, 0, dx, size.height), Alignment.centerLeft, Alignment.centerRight);
    edge(Rect.fromLTWH(size.width - dx, 0, dx, size.height), Alignment.centerRight, Alignment.centerLeft);
  }

  @override
  bool shouldRepaint(_InnerGlowPainter old) => old.color != color;
}

/// L-образные уголки 12×12, 2px, со свечением: левый верхний и правый нижний.
class _CornersPainter extends CustomPainter {
  _CornersPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    const c = SysDims.cornerSize;
    const w = SysDims.cornerStroke;
    const o = -1.0; // поверх рамки, чуть снаружи
    final path = Path()
      ..moveTo(o, o + c)
      ..lineTo(o, o)
      ..lineTo(o + c, o)
      ..moveTo(size.width - o - c, size.height - o)
      ..lineTo(size.width - o, size.height - o)
      ..lineTo(size.width - o, size.height - o - c);
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: .65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w + 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..strokeCap = StrokeCap.square,
    );
  }

  @override
  bool shouldRepaint(_CornersPainter old) => old.color != color;
}
