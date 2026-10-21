// КАРКАС: заглушка. Реализует сабагент A.
import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';
import 'sys_icon.dart';

/// Маленькая метка-«пилюля» (бафф, ранг, награда).
class SysPill extends StatelessWidget {
  const SysPill({super.key, required this.label, this.tone = PanelTone.accent, this.icon, this.trailing});

  final String label;
  final PanelTone tone;
  final SysGlyph? icon;

  /// Например таймер эффекта (моноширинный).
  final String? trailing;

  @override
  Widget build(BuildContext context) => Text(label);
}
