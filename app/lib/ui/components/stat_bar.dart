import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'sys_icon.dart';

/// Горизонтальная шкала с подписью и числом (JetBrains Mono), плавное заполнение.
class StatBar extends StatelessWidget {
  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    this.color = SysColors.accent,
    this.valueText,
    this.icon,
    this.height = 6,
  });

  final String label;
  final double value;
  final double max;
  final Color color;

  /// Текст справа; по умолчанию «value / max».
  final String? valueText;
  final SysGlyph? icon;
  final double height;

  static String _num(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final fraction = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    final text = valueText ?? '${_num(value)} / ${_num(max)}';
    final ic = icon;
    return Semantics(
      label: label,
      value: text,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (ic != null) ...[SysIcon(ic, size: 16, color: color), const SizedBox(width: 6)],
              Expanded(
                child: Text(label, style: SysText.secondary, overflow: TextOverflow.ellipsis, maxLines: 1),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: SysText.mono.copyWith(color: SysColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          SysBar(value: fraction, color: color, height: height),
        ],
      ),
    );
  }
}

/// Голая полоса прогресса (трек + заполнение со свечением), плавно анимируется.
class SysBar extends StatelessWidget {
  const SysBar({super.key, required this.value, this.color = SysColors.accent, this.height = 6});

  /// 0..1
  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0.0, 1.0)),
      duration: reduce ? Duration.zero : SysDims.barFill,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => CustomPaint(size: Size(double.infinity, height), painter: _BarPainter(v, color)),
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter(this.value, this.color);
  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final r = Radius.circular(h / 2 < 2 ? h / 2 : 2);
    final track = RRect.fromRectAndRadius(Offset.zero & size, r);
    canvas.drawRRect(track, Paint()..color = color.withValues(alpha: .12));
    canvas.drawRRect(
      track.deflate(.25),
      Paint()
        ..color = color.withValues(alpha: .28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .5,
    );
    if (value <= 0) return;
    final fillRect = Rect.fromLTWH(0, 0, size.width * value, h);
    final fill = RRect.fromRectAndRadius(fillRect, r);
    canvas.drawRRect(
      fill,
      Paint()
        ..color = color.withValues(alpha: .55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(
      fill,
      Paint()..shader = LinearGradient(colors: [color.withValues(alpha: .65), color]).createShader(fillRect),
    );
    // Блик сверху.
    canvas.save();
    canvas.clipRRect(fill);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, fillRect.width, h * .35),
      Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: .18),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.value != value || old.color != color;
}
