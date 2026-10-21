// КАРКАС: заглушка. Реализует сабагент A.
import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';

/// Фон: #03050B, радиальное свечение сверху, сетка 22px, сканлайны.
class SystemBackground extends StatelessWidget {
  const SystemBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(color: SysColors.background, child: child);
}
