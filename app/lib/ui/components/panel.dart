// КАРКАС: заглушка. Реализует сабагент A.
import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

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

  @override
  Widget build(BuildContext context) => Padding(padding: padding, child: child);
}
