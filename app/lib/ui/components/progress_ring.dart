// КАРКАС: заглушка. Реализует сабагент A.
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
  });

  /// 0..1
  final double progress;
  final double size;
  final double strokeWidth;
  final Color color;
  final Widget? center;

  @override
  Widget build(BuildContext context) => SizedBox.square(dimension: size, child: center);
}
