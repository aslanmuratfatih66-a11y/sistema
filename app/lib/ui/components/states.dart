// Состояния экранов: загрузка, скелетон, пусто, ошибка; кнопка-иконка, «назад»,
// отклик на нажатие. Строки — от вызывающего (дизайн-система без l10n).
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'buttons.dart';
import 'panel.dart';
import 'sys_icon.dart';

/// Включено ли «Уменьшение движения» (MediaQuery.disableAnimations).
bool sysReduceMotion(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Индикатор загрузки дизайн-системы: светящаяся дуга вокруг ромба.
/// При «Уменьшении движения» — статичный.
class SysLoader extends StatefulWidget {
  const SysLoader({super.key, this.size = 28, this.color = SysColors.accentLight, this.label, this.semanticLabel});

  final double size;
  final Color color;

  /// Подпись под индикатором (видимая).
  final String? label;

  /// Подпись для скринридера, если [label] не задан.
  final String? semanticLabel;

  @override
  State<SysLoader> createState() => _SysLoaderState();
}

class _SysLoaderState extends State<SysLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (sysReduceMotion(context)) {
      _c
        ..stop()
        ..value = .2;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ring = RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: CustomPaint(painter: _LoaderPainter(_c, widget.color)),
      ),
    );
    final label = widget.label;
    final Widget body = label == null
        ? ring
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ring,
              const SizedBox(height: 12),
              Text(label, style: SysText.secondary, textAlign: TextAlign.center),
            ],
          );
    return Semantics(
      liveRegion: true,
      label: label ?? widget.semanticLabel,
      excludeSemantics: label != null,
      child: body,
    );
  }
}

class _LoaderPainter extends CustomPainter {
  _LoaderPainter(this.t, this.color) : super(repaint: t);
  final Animation<double> t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 2;
    final stroke = math.max(1.6, size.shortestSide / 16);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color.withValues(alpha: .16),
    );
    final rect = Rect.fromCircle(center: c, radius: r);
    final start = t.value * 2 * math.pi - math.pi / 2;
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke + 2
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: .45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, start, math.pi * .55, false, glow);
    canvas.drawArc(rect, start, math.pi * .55, false, arc);
    // Ромб в центре.
    final d = size.shortestSide * .16;
    final diamond = Path()
      ..moveTo(c.dx, c.dy - d)
      ..lineTo(c.dx + d, c.dy)
      ..lineTo(c.dx, c.dy + d)
      ..lineTo(c.dx - d, c.dy)
      ..close();
    canvas.drawPath(diamond, Paint()..color = color.withValues(alpha: .5 + .5 * math.sin(t.value * math.pi)));
  }

  @override
  bool shouldRepaint(_LoaderPainter old) => old.color != color || old.t != t;
}

/// Загрузка на всю область: индикатор по центру с отступом.
class SysLoadingView extends StatelessWidget {
  const SysLoadingView({super.key, this.label, this.padding = const EdgeInsets.all(32)});

  final String? label;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: Center(child: SysLoader(label: label)),
      );
}

/// Скелетон загрузки: «дышащая» плашка. При «Уменьшении движения» — статичная.
class SysSkeleton extends StatefulWidget {
  const SysSkeleton({super.key, this.width, this.height = 12});

  final double? width;
  final double height;

  @override
  State<SysSkeleton> createState() => _SysSkeletonState();
}

class _SysSkeletonState extends State<SysSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (sysReduceMotion(context)) {
      _c
        ..stop()
        ..value = .5;
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween<double>(begin: .45, end: 1).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: SysColors.accent.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(SysDims.radius),
            border: Border.all(color: SysColors.accent.withValues(alpha: .10)),
          ),
        ),
      );
}

/// Скелетон панели: заголовок и несколько строк — пока грузятся данные экрана.
class SysSkeletonPanel extends StatelessWidget {
  const SysSkeletonPanel({super.key, this.lines = 3, this.semanticLabel});

  final int lines;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
        label: semanticLabel,
        liveRegion: semanticLabel != null,
        child: ExcludeSemantics(
          child: SysPanel(
            animateIn: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SysSkeleton(width: 120, height: 14),
                for (var i = 0; i < lines; i++) ...[
                  const SizedBox(height: 12),
                  FractionallySizedBox(widthFactor: i.isEven ? 1 : .7, child: const SysSkeleton()),
                ],
              ],
            ),
          ),
        ),
      );
}

/// Пустое состояние: иконка + заголовок + подсказка + действие.
/// [compact] — строкой внутри панели (иконка слева, текст справа).
class SysEmptyState extends StatelessWidget {
  const SysEmptyState({
    super.key,
    required this.title,
    this.hint,
    this.glyph = SysGlyph.inbox,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.compact = false,
    this.color = SysColors.textSecondary,
  });

  /// Компактный вариант (строка) — для пустых списков внутри панелей.
  const SysEmptyState.inline(
    this.title, {
    super.key,
    this.hint,
    this.glyph = SysGlyph.inbox,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
    this.color = SysColors.textSecondary,
  }) : compact = true;

  final String title;
  final String? hint;
  final SysGlyph glyph;
  final String? actionLabel;
  final VoidCallback? onAction;
  final SysGlyph? actionIcon;
  final bool compact;

  /// Цвет текста заголовка (в компактном виде).
  final Color color;

  @override
  Widget build(BuildContext context) {
    final h = hint;
    final label = actionLabel;
    final action = label != null && onAction != null
        ? SysButton.secondary(label: label, icon: actionIcon, onPressed: onAction)
        : null;
    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: SysIcon(glyph, size: 18, color: SysColors.textInactive),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: SysText.secondary.copyWith(color: color)),
                      if (h != null) ...[
                        const SizedBox(height: 2),
                        Text(h, style: SysText.caption),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (action != null) ...[const SizedBox(height: 10), action],
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: SysColors.accent.withValues(alpha: .06),
              border: Border.all(color: SysColors.panelBorder.withValues(alpha: .4)),
              boxShadow: const [BoxShadow(color: SysColors.panelOuterGlow, blurRadius: 18)],
            ),
            child: SysIcon(glyph, size: 30, color: SysColors.accentLight),
          ),
          const SizedBox(height: 14),
          Semantics(
            header: true,
            child: Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: SysText.title.copyWith(color: SysColors.textPrimary),
            ),
          ),
          if (h != null) ...[
            const SizedBox(height: 6),
            Text(h, textAlign: TextAlign.center, style: SysText.secondary),
          ],
          if (action != null) ...[const SizedBox(height: 16), action],
        ],
      ),
    );
  }
}

/// Ошибка (сеть/ИИ/загрузка): панель смысловой темы с иконкой, текстом и «Повторить».
class SysErrorState extends StatelessWidget {
  const SysErrorState({
    super.key,
    required this.message,
    this.title,
    this.glyph = SysGlyph.warning,
    this.tone = PanelTone.danger,
    this.onRetry,
    this.retryLabel,
    this.extra,
    this.animateIn = true,
  });

  final String message;
  final String? title;
  final SysGlyph glyph;
  final PanelTone tone;

  /// null — без кнопки (например, «войдите в аккаунт»).
  final VoidCallback? onRetry;
  final String? retryLabel;

  /// Дополнительное содержимое под текстом (например, запасная реплика).
  final Widget? extra;
  final bool animateIn;

  @override
  Widget build(BuildContext context) {
    final p = tone.palette;
    final t = title;
    final ex = extra;
    final retry = retryLabel;
    return Semantics(
      liveRegion: true,
      container: true,
      child: SysPanel(
        tone: tone,
        animateIn: animateIn,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SysIcon(glyph, size: 22, color: p.light),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (t != null) ...[
                        Text(t.toUpperCase(), style: SysText.title.copyWith(color: p.light)),
                        const SizedBox(height: 4),
                      ],
                      Text(message, style: SysText.body),
                    ],
                  ),
                ),
              ],
            ),
            if (ex != null) ...[const SizedBox(height: 8), ex],
            if (onRetry != null && retry != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: SysButton.secondary(label: retry, icon: SysGlyph.refresh, onPressed: onRetry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Кнопка-иконка дизайн-системы: зона нажатия ≥48, подсказка и подпись для скринридера.
class SysIconButton extends StatelessWidget {
  const SysIconButton({
    super.key,
    required this.glyph,
    required this.tooltip,
    required this.onPressed,
    this.color = SysColors.accentLight,
    this.size = 22,
  });

  final SysGlyph glyph;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        color: color,
        disabledColor: SysColors.textInactive,
        icon: SysIcon(glyph, size: size, color: onPressed == null ? SysColors.textInactive : color),
      );
}

/// «Назад»: стрелка + подсказка (по умолчанию — системная локализованная «Назад»).
class SysBackButton extends StatelessWidget {
  const SysBackButton({super.key, this.onPressed, this.tooltip});

  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => SysIconButton(
        glyph: SysGlyph.arrowLeft,
        tooltip: tooltip ?? MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      );
}

/// Отклик на нажатие для произвольного содержимого: лёгкое «проседание» (0.97)
/// и тактильный щелчок. При «Уменьшении движения» — без масштаба.
class SysPressable extends StatefulWidget {
  const SysPressable({super.key, required this.child, required this.onTap, this.haptic = true});

  final Widget child;
  final VoidCallback? onTap;
  final bool haptic;

  @override
  State<SysPressable> createState() => _SysPressableState();
}

class _SysPressableState extends State<SysPressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && widget.onTap != null) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final reduce = sysReduceMotion(context);
    return Semantics(
      button: widget.onTap != null,
      child: _gesture(reduce),
    );
  }

  Widget _gesture(bool reduce) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.haptic) HapticFeedback.selectionClick();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _down && !reduce ? .97 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
