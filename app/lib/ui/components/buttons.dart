import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'sys_icon.dart';

enum SysButtonVariant { primary, secondary, danger }

/// Кнопка ≥44px: основная / вторичная / опасная. Подпись рисуется капсом.
class SysButton extends StatelessWidget {
  const SysButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SysButtonVariant.primary,
    this.icon,
    this.expand = false,
  });
  const SysButton.primary({super.key, required this.label, required this.onPressed, this.icon, this.expand = false})
    : variant = SysButtonVariant.primary;
  const SysButton.secondary({super.key, required this.label, required this.onPressed, this.icon, this.expand = false})
    : variant = SysButtonVariant.secondary;
  const SysButton.danger({super.key, required this.label, required this.onPressed, this.icon, this.expand = false})
    : variant = SysButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final SysButtonVariant variant;
  final SysGlyph? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final radius = BorderRadius.circular(SysDims.radius);

    final (Color fg, Color accent, BoxDecoration deco) = switch (variant) {
      SysButtonVariant.primary => (
        SysColors.background,
        SysColors.accent,
        BoxDecoration(
          borderRadius: radius,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [SysColors.accentLight, SysColors.accent],
          ),
          border: Border.all(color: SysColors.accentLighter),
          boxShadow: enabled ? const [BoxShadow(color: Color.fromRGBO(63, 180, 255, .45), blurRadius: 16)] : null,
        ),
      ),
      SysButtonVariant.secondary => (
        SysColors.accentLighter,
        SysColors.accent,
        BoxDecoration(
          borderRadius: radius,
          color: SysColors.accent.withValues(alpha: .08),
          border: Border.all(color: SysColors.panelBorder),
          boxShadow: enabled ? const [BoxShadow(color: Color.fromRGBO(30, 120, 255, .18), blurRadius: 12)] : null,
        ),
      ),
      SysButtonVariant.danger => (
        SysColors.dangerLight,
        SysColors.danger,
        BoxDecoration(
          borderRadius: radius,
          color: SysColors.danger.withValues(alpha: .14),
          border: Border.all(color: SysColors.danger.withValues(alpha: .75)),
          boxShadow: enabled ? const [BoxShadow(color: Color.fromRGBO(255, 40, 60, .28), blurRadius: 14)] : null,
        ),
      ),
    };

    final ic = icon;
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (ic != null) ...[SysIcon(ic, size: 18, color: fg), const SizedBox(width: 8)],
        Flexible(
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: SysText.label.copyWith(color: fg, fontSize: 14, letterSpacing: SysDims.headingSpacing(14)),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      onTap: onPressed,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : .42,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: SysDims.minTap, minWidth: expand ? double.infinity : SysDims.minTap),
          child: DecoratedBox(
            decoration: deco,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onPressed,
                borderRadius: radius,
                splashColor: (variant == SysButtonVariant.primary ? Colors.white : accent).withValues(alpha: .22),
                highlightColor: (variant == SysButtonVariant.primary ? Colors.white : accent).withValues(alpha: .12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  child: Center(widthFactor: 1, heightFactor: 1, child: content),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Кнопка подтверждения удержанием (по умолчанию 5 сек) — для отказа от квеста.
/// Заполняется по мере удержания; отпустил раньше — сброс.
/// Работает и при «Уменьшении движения»: отсчёт идёт всегда, сброс — мгновенный.
class HoldButton extends StatefulWidget {
  const HoldButton({
    super.key,
    required this.label,
    required this.onCompleted,
    this.duration = SysDims.holdToConfirm,
    this.tone = PanelTone.danger,
    this.expand = false,
    this.semanticHint,
  });

  final String label;
  final VoidCallback onCompleted;
  final Duration duration;
  final PanelTone tone;
  final bool expand;

  /// Подсказка для скринридера, например «Удерживайте 5 секунд».
  final String? semanticHint;

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<HoldButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
    // Отсчёт — функциональный, не декоративный: не ускорять при disableAnimations.
    animationBehavior: AnimationBehavior.preserve,
  )..addStatusListener(_onStatus);

  bool _fired = false;
  bool _holding = false;

  @override
  void didUpdateWidget(HoldButton old) {
    super.didUpdateWidget(old);
    if (old.duration != widget.duration) _c.duration = widget.duration;
  }

  void _onStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed && _holding && !_fired) {
      _fired = true;
      HapticFeedback.heavyImpact();
      widget.onCompleted();
    }
  }

  void _start() {
    _holding = true;
    _fired = false;
    HapticFeedback.selectionClick();
    _c.forward();
  }

  void _release() {
    if (!_holding) return;
    _holding = false;
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce || _fired) {
      _c.value = 0;
    } else {
      _c.animateBack(0, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.tone.palette;
    final radius = BorderRadius.circular(SysDims.radius);
    final totalMs = widget.duration.inMilliseconds;

    final body = AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final v = _c.value;
        final remainingMs = (totalMs * (1 - v)).ceil();
        final seconds = (remainingMs / 1000).ceil();
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: p.main.withValues(alpha: .08),
            border: Border.all(color: p.border),
            boxShadow: [
              BoxShadow(
                color: p.glow.withValues(alpha: .4 + .6 * v),
                blurRadius: 10 + 10 * v,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: CustomPaint(
              painter: _HoldFillPainter(v, p.main),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: SysDims.minTap),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  child: Row(
                    mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          widget.label.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: SysText.label.copyWith(color: p.light),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$seconds',
                        style: SysText.mono.copyWith(
                          color: _holding ? SysColors.textPrimary : p.light.withValues(alpha: .7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    return Semantics(
      button: true,
      label: widget.label,
      hint: widget.semanticHint,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _start(),
        onTapUp: (_) => _release(),
        onTapCancel: _release,
        child: body,
      ),
    );
  }
}

class _HoldFillPainter extends CustomPainter {
  _HoldFillPainter(this.value, this.color);
  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (value <= 0) return;
    final w = size.width * value;
    final rect = Rect.fromLTWH(0, 0, w, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(colors: [color.withValues(alpha: .18), color.withValues(alpha: .42)])
            .createShader(rect),
    );
    // Светящийся фронт заполнения.
    canvas.drawRect(Rect.fromLTWH(w - 1.5, 0, 1.5, size.height), Paint()..color = color.withValues(alpha: .9));
  }

  @override
  bool shouldRepaint(_HoldFillPainter old) => old.value != value || old.color != color;
}
