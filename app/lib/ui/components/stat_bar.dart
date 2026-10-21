// КАРКАС: заглушка. Реализует сабагент A.
import 'package:flutter/widgets.dart';

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

  @override
  Widget build(BuildContext context) => Text(label);
}
